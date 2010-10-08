#!/usr/bin/perl  -I./lib

# This script accesses data from the D12 activity log about incidents
# meeting command line criteria and computes delay associated with
# those incidents using a MILP solved on a remote server.

use strict;
use Carp;
use Getopt::Long;
use Caltrans::ActivityLog::Schema;
use TMCPE::ActivityLog::Schema;
use SpatialVds::Schema;
use TBMAP::Schema;
use Date::Format;
use Date::Calc qw( Delta_DHMS Time_to_Date Day_of_Week Day_of_Week_to_Text Mktime Localtime Add_Delta_DHMS );
use Date::Parse;
use IO::All;
use Parse::RecDescent;
use SQL::Abstract;
use TMCPE::ActivityLog::LocationParser;
use TMCPE::DelayComputation;

my %opt = ();

GetOptions( \%opt, 
	    "skip-al-import",
	    "skip-icad-import",
	    "skip-incidents",
	    "skip-critical-events",
	    "only-sigalerts",
	    "date-from=s",
	    "date-to=s",
	    "use-existing",
	    "replace-existing",
	    "dont-replace-existing",
            "verbose",
	    "tmcpe-db-host=s",
	    "tmcpe-db-name=s",
	    "tmcpe-db-user=s",
	    "tmcpe-db-password=s",
	    "dc-band=f",
	    "dc-prewindow=i",
	    "dc-postwindow=i",
	    "dc-vds-downstream-fudge=f",
	    "dc-compute-vds-upstream-fallback",
	    "dc-dont-compute-vds-upstream-fallback",
	    "dc-vds-upstream-fallback=f",
	    "dc-min-avg-days=i",
	    "dc-min-obs-pct=i",
	    "dc-use-eq2",
	    "dc-dont-use-eq2",
	    "dc-use-eq3",
	    "dc-dont-use-eq3",
	    "dc-use-eq4567",
	    "dc-dont-use-eq4567",
	    "dc-bias=f",
	    "dc-weight-for-distance",
	    "dc-dont-weight-for-distance",
	    "dc-limit-loading-shockwave=f",
	    "dc-limit-clearing-shockwave=f",
	    "dc-use-eq8",
	    "dc-use-eq8b",
	    "dc-dont-use-eq8",
	    "dc-dont-use-eq8b",
	    "dc-force=s@",
	    "dc-reprocess-existing",
	    "dc-boundary-intersects-within=s",
	    "dc-limit-to-start-region",
	    "dc-unknown-evidence-value=f",
	    "dc-use-pems-cache",
	    "dc-dont-use-pems-cache",
	    "dc-gams-reslim=i",
	    "dc-gams-iterlim=i",
	    "dc-gams-limrow=i",
	    "dc-cplex-optcr=f",
	    "dc-cplex-threads=i",
	    "dc-cplex-probe=i",
	    "dc-cplex-ppriind=i",
	    "dc-cplex-mip-emphasis=i",
	    "dc-cplex-polishafterintsol=i",
	    "dc-cplex-nodesel=i",
	    "dc-cplex-varsel=i",
) || die "usage: import-al.pl [--skip-al] [--skip-icad]\n";


my $procopt = {
    al_import => 1,
    icad_import => 1,
    incidents => 1,
    critical_events => 1,
    dodelaycomp => 1,
    only_sigalerts => 0,
    verbose => 0,
    useexist => 0,
    tmcpe_db_host => "localhost",
    tmcpe_db_name => "tmcpe_test",
    tmcpe_db_user => "postgres",
    tmcpe_db_password => "",
    replace_existing => 1,
    reprocess_existing => 1,
    forced => []
};

foreach my $o ( keys %opt ) {
    # negate all skips
    my @p = split(/-/, $o);
    my $neg = undef;
    my @vv = ();
    my $var = "";
    my $dc = undef;
    while ( $_ = shift @p ) {
	if ( /^dc$/ ) {
	    $dc="dc";
	} elsif ( ( /^skip$/ || /^dont$/ ) && not @vv ) { 
	    $neg++; 
	} else {
	    push @vv, $_;
	}
    }
    $var = join( '_', grep { defined $_ } ( @vv ) );
    my $on = undef;
    if ( defined $neg ) {
	$on = ($neg+1) % 2;
    }

    my $val = defined( $on ) ? $on : $opt{$o};
    if ( $dc ) {
	$procopt->{dc}{$var} = $val;
    } else {
	$procopt->{$var} = $val;
    }

    1;
}


my $verbose if $procopt->{verbose};
my $tmcpe_db_host = $procopt->{tmcpe_db_host};
my $tmcpe_db_name = $procopt->{tmcpe_db_name};
my $tmcpe_db_user = $procopt->{tmcpe_db_user};
my $tmcpe_db_password = $procopt->{tmcpe_db_password};


my $d12 = Caltrans::ActivityLog::Schema->connect(
    "dbi:mysql:dbname=actlog;host=trantor.its.uci.edu;port=3366",
    "d12", "VDSPASSWORD",
    { AutoCommit => 1 },
    );

my $tmcpeal = TMCPE::ActivityLog::Schema->connect(
    "dbi:Pg:dbname=tmcpe_test;host=localhost",
    "postgres", undef,
    { AutoCommit => 1 },
    );

my $tmcpe = TMCPE::Schema->connect(
    join("", "dbi:Pg:dbname=","tmcpe_test",";","host=","localhost"),
    $tmcpe_db_user, $tmcpe_db_password,
    { AutoCommit => 1, db_Schema => 'tmcpe' },
    );


my $vdsdb = SpatialVds::Schema->connect(
    "dbi:Pg:dbname=spatialvds;host=localhost",
    "VDSUSER", "VDSPASSWORD",
    { AutoCommit => 1 },
    );

my $tbmapdb = TBMAP::Schema->connect(
    "dbi:Pg:dbname=tmcpe_test;host=localhost",
    "postgres", undef,
    { AutoCommit => 1 },
    );


my $logfile = io( 'import.log' );
$logfile < "IMPORT RUN AT ".time2str( "%D %T", localtime() )."\n";

my $loclogfile = io ( 'location-parse.log' );
$loclogfile < "IMPORT RUN AT ".time2str( "%D %T", localtime() )."\n";


my $lanesparser = new Parse::RecDescent( q(
lanes: 'LANES:' <leftop: laneid ',' laneid> /.*?$/ { $return = [$item[2], $item[3]]; }

laneid: lanetype /\d/ { $return = $item[1].$item[2]; }

lanetype: 'HOV' | '#'
)
    );


goto ICAD if not $procopt->{al_import};

foreach my $table ( ( map { "CtAlBackup$_" } ( 2003..2010 ) ) , "CtAlTransaction" )
{
    load_al_entries( $table );
}


sub process_performance_measures {
    my ( $inc, $log, $type, $memo ) = @_;

    my $pmtype;
    my $data;
    if ( $type ) {
	($_) = ( $type =~ /^\s*(.*?)\s*$/ );
	my $logid = $log->keyfield;
	my $detail = $memo;
	my $lanes;
	
	############################# FIRST CALL ############################
	if (/FIRST CALL/ || /DETECTION/ ) {
	    $pmtype = 'FIRST CALL';

	    ############################# VERIFICATION ############################
	} elsif ( /VERIFICATION/ ) {
	    $pmtype = 'VERIFICATION';
	} elsif ( /VERIFICATION BY CCTV\'S/ || /VERIFIED BY CCTV/) {
	    $pmtype = 'VERIFICATION';
	} elsif ( /VERIFIED BY CHP/ ) {
	    $pmtype = 'VERIFICATION';

	    ############################# STATUS ############################
	} elsif ( /EXIT LANES BLOCKED/  || /OFF\/R LANES BLOCKED/) {
	    $pmtype = 'STATUS';

	} elsif ( /ALL LANES BLOCKED/ || /ALL LNS BLKD/ ) {
	    $lanes => "ALL";

	} elsif ( /LANES? BLOCKED/ ) {
	    $pmtype = 'STATUS';

	    # This grabs the lane identifiers spit out by the activity log
	    my $which = $lanesparser->lanes( $memo );

	    if ( $which ) {
		# got a good match.  Create info necessary to put them in the type eval table
		$lanes = join( ",", @{$which->[0]} );
		$detail = $which->[1];
	    }

	} elsif ( /MAX Q (MI)/ || /MAX Q (X-STREET)/) {
	    $pmtype = 'STATUS';

	    ############################# RESPONSE (OPS) ############################
	} elsif ( /CMS ACTIVATION/ ) {
	    $pmtype = 'RESPONSE';
	} elsif ( /ALL CON LNS CLSD/ || /ALL CONN LNS CLSD/ ) {
	    $pmtype = 'RESPONSE';
	} elsif ( /OFF\/R CLOSED/ || /OFF\/R CLSD/ ) {
	    $pmtype = 'RESPONSE';
	} elsif ( /ALL LNS CLSD/ || /CLOSED/ || /LANES CLOSED/ || /ALL FRWY LNS CLSD/ || /ALL SR-74 LNS CLSD/ || /FASTRAK LNS CLSD/ ) {
	    $pmtype = 'RESPONSE';
	    # This grabs the lane identifiers spit out by the activity log
	    my $which = $lanesparser->lanes( $memo );

	    if ( $which ) {
		# got a good match.  Create info necessary to put them in the type eval table
		$lanes = join( ",", @{$which->[0]} );
		$detail = $which->[1];
	    }

	} elsif ( /SR-133 CONN CLSD/ || /WB SR-91 TO N\/S-57 TRANS CLSD/ || /STILL CLOSED/ ) {
	    $pmtype = 'RESPONSE';
	} elsif ( /DETOUR/ ) {
	    $pmtype = 'RESPONSE';
	} elsif ( /1097 FIRST UNIT/ || /CT ETA/) {
	    $pmtype = 'UNITS';

	    ############################# RESPONSE (EMERG) ############################
	} elsif ( /ROLL CORONER/ || /CORONER/ || /1039[\s-]*CORONER/) {
	    $pmtype = 'UNITS';
	} elsif ( /HAZMAT/ ) {
	    $pmtype = 'UNITS';
	} elsif ( /MEDICS/ || /FIRE DEPT/ ) {
	    $pmtype = 'UNITS';
	    
	    ############################# STATUS 2 ############################
	} elsif ( /OFF\/R OPEN/ || /RAMP OPEN/ || /PARTIAL OPENING/ || /OPEN/ ) {
	    $pmtype = 'STATUS';
	} elsif ( /ALL LANES CLEAR/ || /ROADWAY CLEAR/ ) {
	    $pmtype = 'STATUS';
	    $lanes = 'ALL';

	} elsif ( /OFF\/R LANES CLEAR/ || /0FF\/R LANES CLEAR/ || /FASTRAK LNS CLEAR/ || /CON LANES CLEAR/ ) {
	    $pmtype = 'STATUS';

	} elsif ( /LANES CLEAR/ ) {
	    $pmtype = 'STATUS';

	    # This grabs the lane identifiers spit out by the activity log
	    my $which = $lanesparser->lanes( $memo );

	    if ( $which ) {
		# got a good match.  Create info necessary to put them in the type eval table
		$lanes = join( ",", map { join( "", "-", $_ ) } @{$which->[0]} );
		$detail = $which->[1];
	    }
	    
	    ############################# MISC? ############################
	} elsif ( /CHP/ || /CT MAINT/ || /CT CLOSURE CREW/ || /RESPONDING/ ) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /D.E.I.R UPDATE #1/ || /DEIR/ || /D.E.I.R/ || /D.E.I.R FINAL/ ) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /M.I.R/ || /MIR/ || /MIRF/) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /CT SUPERVISOR/ || /CT MAINT CREW/ ) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /REMOTE VCR TAPING/) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /NEED  CT RESPONSE/ || /REQ CT/ || /\# CT RESPONDING/) {
	    $pmtype = 'UNCLASSIFIED';
	} elsif ( /CT INFO/) {
	    $pmtype = 'UNCLASSIFIED';
	} else {
	    $pmtype = 'UNKNOWN';
	};

	if ( $pmtype ) {
	    $data = {
		pmtext => $type,
		pmtype => $pmtype,
		detail => $detail
	    };
	    $data->{blocklanes} = $lanes;
	    $log->create_related( 'performance_measures', $data );
	}
    }
    return $data;
}



###### LOAD NEW ACTIVITY LOG ENTRIES ######

sub load_al_entries {
    my ( $table ) = @_;

    print STDERR "LOADING FROM $table...";

    # BLOCK DB UPDATES DURING THIS OPERATION?
    
    my $rs;
    eval {
	my $condition = {};
	my $datecond;
	$datecond->{'>='} = $procopt->{datefrom} if $procopt->{datefrom};
	$datecond->{'<='} = $procopt->{dateto}   if $procopt->{dateto};
	
	$condition->{stampdate} = $datecond if $datecond;
	
	$rs = $d12->resultset($table)->search(
	    $condition,
	    { order_by => 'keyfield asc' }
	    );
	
	# loop over all the new records, and shove them into the postgres db
	while ( my $t = $rs->next ) {
	    
	    # push data in.
	    my $rec;
	    
	    my $date = $t->stampdate;
	    $date =~ s/-/\//g;
	    my $stamp = join(" ", $date, $t->stamptime );
	    
	    my $exist = $tmcpeal->resultset('D12ActivityLog')->find( $t->keyfield );
	    
	    if ( not $exist ) {
		
		eval { 
		    $rec = $tmcpeal->resultset('D12ActivityLog')->create(
			{
			    keyfield => $t->keyfield,
			    stamp => $stamp,
			    cad => $t->cad,
			    unitin => $t->unitin,
			    unitout => $t->unitout,
			    via => $t->via,
			    op => $t->op,
			    device_number => $t->device_number,
			    device_direction => $t->device_direction,
			    device_fwy => $t->device_fwy,
			    device_name => $t->device_name,
			    status => $t->status,
			    activitysubject => $t->activitysubject,
			    memo => $t->memo
			});
		};
		if ( $@ ) {
		    warn "ERROR ".$@->{msg};
		    $logfile << "ERROR ".$@->{msg};
		}
		warn "INSERTED ENTRY ".$t->keyfield."\n" if $verbose;
		1;
		
	    } else { 
		warn "SKIPPED DUPLICATE ENTRY ". $t->keyfield."\n"  if $verbose;
	    }
	}
    };
    croak "ERROR ".$@->{msg} if $@;

    print STDERR "done\n";
}

# loop over the icad records 

ICAD:

    goto INCIDENTS if not $procopt->{icad_import};

print STDERR "PROCESSING ICAD...";

my $rs;
eval {
    my $condition = {};
    my $datecond;
    $datecond->{'>='} = $procopt->{datefrom} if $procopt->{datefrom};
    $datecond->{'<='} = $procopt->{dateto}   if $procopt->{dateto};
    
    $condition->{logtime} = $datecond if $datecond;

    my $txt1 = "STR_TO_DATE( logtime, '%m/%d/%Y %h:%i:%s %p' )";
    my $txt2 = "STR_TO_DATE('$procopt->{datefrom}','%Y-%m-%d')";
    
    $rs = $d12->resultset('UciAtIcad')->search(	
	{
	    $txt1 => { '>=' => \$txt2 }
	}
	, { 
	order_by => 'keyfield asc'
						}
	);
};
croak "ERROR ".$@->{msg} if $@;

# loop over all the new records, and shove them into the postgres db
my $tot=0;
my $imported=0;
my $dup=0;
while ( my $t = $rs->next ) {
    # push data in
    my $rec;

    my $logid = $t->logid;

    my $stampt = str2time( $t->logtime );
    my @stamp = Localtime( $stampt );
    my ($num,$dist,$sup) = ( $logid =~ /(\d+)D(\d\d)(\d+)/ );
    my $d12cad = join( '-', 
		       sprintf( "%d", $num),  # the number /shouldn't/ have leading zeros
		       sprintf( "%2.2d%2.2d%2.2d", $stamp[1], $stamp[2], $stamp[0]-2000 ) # the dates /should/ have leading zeros
	);
    my $d12cadalt = join( '-', 
			  sprintf( "%d", $num),  # the number /shouldn't/ have leading zeros
			  sprintf( "%2.2d%2.2d%4.4d", $stamp[1], $stamp[2], $stamp[0] ) # the dates /should/ have leading zeros
	);

    my $exist = $tmcpeal->resultset('Icad')->find( $t->keyfield );

    if ( not $exist ) {
	
	
	# OK, create the record for this entry
	eval { $rec = $tmcpeal->resultset('Icad')->create( 
		   {
		       keyfield => $t->keyfield,
		       logid => $t->logid,
		       logtime => $t->logtime,
		       logtype => $t->logtype,
		       location => $t->location,
		       area => $t->area,
		       thomasbrothers => $t->thomasbrothers,
		       tbxy => $t->tbxy,
		       d12cad => $d12cad,
		       d12cadalt => $d12cadalt,
		   }); };
	croak join( "", "ERROR: ", ( $@->{msg} ? $@->{msg} : $@ ) ) if ( $@ );    
	warn "INSERTED ENTRY ".$t->logid."\n"  if $verbose;
	# split out the details
	my @dets;
	foreach my $detrec ( split( /\n/, $t->detail ) ) 
	{
	    # construct a true date-time stamp for the detail there's a
	    # weakness in the iCAD logging that means the details don't
	    # have a date stamp.  We construct one by assuming the date is
	    # the same as the date on the log entry.  

	    my ( $time, $det ) = split ( /\s*-\s*/, $detrec );
	    my $timestr = join( ' ', join('/', $stamp[1], $stamp[2], $stamp[0] ), $time );
	    my $dstampt = str2time( $timestr );

	    # The following catches the case when the log overlaps
	    # midnight.  In this case, some of the log detail entries will
	    # be on the next day.  Basically, if the computed date time
	    # stamp for a detail is less than the date-time stamp for the
	    # (whole) log entry, then we assume it occurs on the next day
	    if ( $dstampt < $stampt ) 
	    {
		my @lt = Localtime( $dstampt );
		my @new_lt = Add_Delta_DHMS( @lt[0..5], 1, 0, 0, 0 );
		$dstampt = Mktime( @new_lt[0..5] );
	    }
	    
	    my $fstamp = time2str( "%D %T", $dstampt );
	    push @dets, { stamp => $fstamp, det => $det };
	}

	# now, push 'em into the db in order
	foreach my $det ( sort { str2time( $a->{stamp} ) cmp str2time( $b->{stamp} ) } @dets )
	{
	    eval { $rec->create_related( 'icad_details', { stamp => $det->{stamp}, detail => $det->{detail} } ); };
	    croak join( "", "ERROR: ", ( $@->{msg} ? $@->{msg} : $@ ) ) if ( $@ );
	}

	warn "SUCCESSFULLY PROCESSED ICAD $logid to $d12cad\n" if $verbose;
	$imported++;

    } else {
	warn "SKIPPED DUPLICATE ENTRY ".$t->logid."\n"  if $verbose;
	$rec = $exist;
	$dup++;
    }
    $tot++
}
print STDERR "$imported imported and $dup duplicates ignored out of $tot total entries\n";


# here we create incidents and tag them coursely by type inferring
# from the cad id
INCIDENTS:

    goto CRITEVENTS if not $procopt->{incidents};

# Add to/update incidents
my $datecond;
$datecond->{'>='} = $procopt->{datefrom} if $procopt->{datefrom};
$datecond->{'<='} = $procopt->{dateto}   if $procopt->{dateto};

my $condition;

# Can't use this condition because starttime doesn't exist in the D12ActivityLog
#$condition->{starttime} = $datecond if $datecond;
my @include = grep { not /^not-/ } @ARGV;
my @exclude = grep { /^not-/ } @ARGV;
$condition->{cad}->{'-in'} = [ @include ] if @include;
$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;

my $alrs = $tmcpeal->resultset('D12ActivityLog')->search( $condition, { 
    'select' => [ 'cad', { min => 'stamp', -as => 'starttime' }	],
    'as'       => [ qw/ cad starttime / ],
    group_by => [ qw/ cad / ],
							} );

my $lp = new TMCPE::ActivityLog::LocationParser();

eval {
    while ( my $al = $alrs->next ) {
	    
	# see if the incident is already in the database
	my $inc = $tmcpeal->resultset('Incidents')->search(
	    { cad => $al->cad},
	    { rows => 1 } )->single;

	# if not, create a new incident object
	if ( not $inc ) {
	    warn join( "", "ADDING CAD ", $al->cad, " TO CAD TABLE\n" );
	    $inc = $tmcpeal->resultset('Incidents')->create( 
		{ cad => $al->cad } );
	} else {
	    warn join( "", "UPDATING CAD ", $al->cad, " IN CAD TABLE\n" );
	}

	# Set the start time
	$inc->start_time( $al->get_column( 'starttime' ) );
		      
	# Get and set the event type
	$_ = $al->cad;
	my $type="UNKNOWN";
	if ( /^\d+-\d\d\d\d\d\d$/ || /^\d+-\d\d\d\d\d\d\d\d$/ ) { $type = "INCIDENT" }
	elsif ( /^ANGEL.*$/ ) { $type = "ANGEL STADIUM" }
	elsif ( /^HONDA.*$/ ) { $type = "HONDA CENTER" }
	elsif ( /^C[^-]*-\d\d\d\d\d\d$/ || /^C[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "CONSTRUCTION" }
	elsif ( /^M[^-]*-\d\d\d\d\d\d$/ || /^M[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "MAINTENANCE" }
	elsif ( /^FAIR.*$/ || /^OC[\s_]*FAIR.*$/ ) { $type = "OCFAIR" }
	elsif ( /^EMERG.*$/ ) { $type = "EMERGENCY" }

	$inc->event_type( $type );

	
	# OK, now match up the icad entry, if any
	my $icad = $tmcpeal->resultset('Icad')->search( 
	    {
		-or => [
		     'd12cad' => $inc->cad,
		     'd12cadalt' => $inc->cad
		    ]
	    },
	    {
		rows => 1 
	    }
	    )->single;

	if ( $icad && $icad->tbxy ) {
	    # got I cad, convert the TBXY
	    my ( $x, $y ) = split(/:/, $icad->tbxy );
	    my $txt =join( '',
			   'st_transform(',
			   join( ',',
				 join( '', 
				       'geomfromtext(',
				       join( ',',
					     '\'POINT('.join(' ',$x,$y).')\'',
					     2875
				       ),
				       ')' )
				 ,4326 ),
			   ')' );
	    $inc->location_geom( \$txt );
	}

	# Now, search for any location strings in the cad logs
	my @incloc = $tmcpeal->resultset( 'D12ActivityLog' )->search( 
	    {
		cad => $inc->cad
	    },
	    {
		order_by => 'stamp asc'
	    });
	my $locdata;
	my $openinc;
	foreach my $log ( @incloc ) {

	    # check activity subject
	    $_ = $log->activitysubject;
	    if ( /SIGALERT\s+(\w+)/ ) 
	    {
		$inc->sigalert_begin( $log ) if $1 eq 'BEGIN';
		$inc->sigalert_end( $log ) if $1 eq 'END';
	    } elsif ( /OPEN INCIDENT/ ) {
		$openinc = $log;
	    }

	    my @details = split( /:DOSEP:/, $log->memo );
	    my $memo = shift @details;
	    foreach ( @details ) {
		if ( /ROUTE\/DIR\/LOCATION:/ ) {
		    # always use R/D/L string to identify location
		    my ( $locstr ) = ( /ROUTE\/DIR\/LOCATION:\s*(.*)/ );
		    if ( $locstr ) {
			$locdata = $lp->get_location( uc($locstr), $inc->location_geom ) ;
			if ( !$locdata ) {
			    warn "FAILED TO PARSE R/D/L: $locstr";
			    $loclogfile << $locstr."\n";
			} else {
			    warn "SUCCESS TO PARSE R/D/L: $locstr: vds=".join( "",
					    $locdata->id,
					    " [",
					    $locdata->freeway_id,
					    "-",
					    $locdata->freeway_dir,
					    " @ ",
					    $locdata->name,
					    "]\n" );
			}
		    }
		} elsif ( /Performance_Measures:(.*)/ ) {
		    my $type = process_performance_measures( $inc, $log, $1, $memo );
		    if ( $type->{pmtype} eq 'FIRST CALL' ) {
			$inc->first_call( $log );
		    }
		}
	    }
	    
	    # fallback to finding location
	    if ( ! $locdata && ( ! ( $memo =~ /^\s*$/ ) ) ) {
		$locdata = $lp->get_location( uc($memo), $inc->location_geom );
		if ( !$locdata ) {
		    warn "FAILED TO PARSE MEMO: $memo";
		    $loclogfile << $memo."\n";
		} else {
		    warn "SUCCESS TO PARSE MEMO: $memo: vds=".join( "",
					    $locdata->id,
					    " [",
					    $locdata->freeway_id,
					    "-",
					    $locdata->freeway_dir,
					    " @ ",
					    $locdata->name,
					    "]\n" );
		}
	    }
	}
	    
	# now set the locdata if we found it...
	if ( $locdata ) {
	    $inc->location_vdsid( $locdata->id );
	}

	if ( ! $inc->first_call && $openinc ) {
	    # first call not defined in performance measures, use open incident line
	    $inc->first_call( $openinc );
	}

	$inc->update();
    }
};
if ( $@ ) {
    warn "ERROR ".$@->{msg};
    $logfile << "ERROR ".$@->{msg};
}



# next, we should parse the new entries to identify critical events,
# including incidents to analyze
CRITEVENTS: goto DONE if not $procopt->{critical_events};


DELAYCOMP: goto DONE if not $procopt->{dodelaycomp};

my $datecond;
$datecond->{'>='} = $procopt->{datefrom} if $procopt->{datefrom};
$datecond->{'<='} = $procopt->{dateto}   if $procopt->{dateto};

my $condition;

$condition->{start_time} = $datecond if $datecond;
$condition->{location_vdsid} = { '!=' => undef };
my @include = grep { not /^not-/ } @ARGV;
my @exclude = grep { /^not-/ } @ARGV;
$condition->{cad}->{'-in'} = [ @include ] if @include;
$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;


my $incrs = $tmcpeal->resultset('Incidents')->search(
    $condition, 
    {
	order_by => qw/ start_time asc /
    }
    );

INCDEL: while( my $inc = $incrs->next ) {

    # skip incidents if cadids are specified and they don't match.
    next INCDEL if ( !( $inc->sigalert_begin ) && $procopt->{only_sigalerts} );
    
    if ( not $procopt->{replace_existing} ) {
	# don't do the computation if one exists (should tweak to use confirm parameters are identical
	my $ia;
	my @existing = $tmcpe->resultset( 'IncidentImpactAnalysis' )->search(
	    { incident_id => $inc->id });
	
	if ( @existing ) {
	    warn "SKIPPING DELAY COMPUTATION FOR ".$inc->cad." BECAUSE ONE ALREADY EXISTS";
	    next INCDEL;
	}
    }

    warn "SOLVING ".$inc->cad."\n";

    my $dc = new TMCPE::DelayComputation();

    my $force;
    map { my ( $j,$m,$v ) = /(\d+),(\d+)=(\d+)/ ; $force->{"$j:$m"} = $v; } @{$procopt->{dc}{force}};
    $dc->force( $force );
    
    $dc->debug( $procopt->{verbose} );
    $dc->tmcpe_db_host( $tmcpe_db_host );
    $dc->tmcpe_db_name( $tmcpe_db_name );
    $dc->tmcpe_db_user( $tmcpe_db_user );
    $dc->tmcpe_db_password( $tmcpe_db_password );
    $dc->cad( $inc->cad );
    $dc->incid( $inc->id );

  DCOPT:
    foreach my $o ( keys %{$procopt->{dc}} ) {
	next DCOPT if $o eq 'force';
	my $val = $procopt->{dc}{$o};
	my $cmd = "\$dc->$o( '$val' )";
	eval $cmd;
	croak "FAILED SETTING DELAYCOMP OPTION: $@\n" if $@;
    }
    
    if ( !$inc->cad ) {
#	croak "INCIDENT DOESN'T have a cadid!!!!";
	warn  "INCIDENT DOESN'T have a cadid!!!!";
	next INCDEL;
    }
    
    my $vdsid = $inc->location_vdsid;
    
    eval { 
	my $vds = $tbmapdb->resultset('Tvd')->find( $vdsid );
	if ( !$vds ) {
	    warn "INCIDENT " + $inc->cad + " ISN'T ASSOCIATED WITH A VDS LOCATION...SKIPPING!";
	    next INCDEL;
	}
	
	$dc->facil( $vds->freeway_id );
	$dc->dir( $vds->freeway_dir );
	$dc->pm( $vds->abs_pm );
	$dc->vdsid( $vds->id );
	$dc->logstart( $inc->start_time );
	$dc->bad_solution( 0 );

	my @incloc = $tmcpeal->resultset( 'D12ActivityLog' )->search( 
	    {
		cad => $inc->cad
	    },
	    {
		order_by => 'stamp asc'
	    });
	my $end = pop @incloc;

	$dc->logend( $end->stamp );
	
	$dc->compute_delay;

	$dc->write_to_db;
    };
    if ( $@ ) {
	warn $@;
	next INCDEL;
    }

}



DONE:

