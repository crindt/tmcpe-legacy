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

my $doal=1;
my $doicad=1;
my $doinc=1;
my $docritevents=1;
my $dodelaycomp=1;
my $onlysigalerts=0;
my $datefrom;
my $dateto;
my $verbose;
my $useexist=0;
my $reslim=0;
my $tmcpe_db_host = "localhost";
my $tmcpe_db_name = "tmcpe_test";
my $tmcpe_db_user = "postgres";
my $tmcpe_db_password = "";
my $skipifexisting=1;

my $dc = new TMCPE::DelayComputation();

GetOptions ("skip-al-import" => sub { $doal = 0 },
	    "skip-icad-import" => sub { $doicad = 0 },
	    "skip-incidents" => sub { $doinc = 0 },
	    "skip-critical-events" => sub { $docritevents = 0 },
	    "only-sigalerts" => \$onlysigalerts,
	    "date-from=s" => \$datefrom,
	    "date-to=s" => \$dateto,
	    "use-existing" => \$useexist,
	    "skip-if-existing" => \$skipifexisting,  # don't do a delay analysis if there's already a solution in the db
	    "dont-skip-if-existing" => sub { $skipifexisting = 0 },  # don't do a delay analysis if there's already a solution in the db
            "verbose" => \$verbose,
	    "tmcpe-db-host=s" => \$tmcpe_db_host,
	    "tmcpe-db-name=s" => \$tmcpe_db_name,
	    "tmcpe-db-user=s" => \$tmcpe_db_user,
	    "tmcpe-db-password=s" => \$tmcpe_db_password,
	    "dc-band=f" => sub { $dc->band( $_[1] ) },
	    "dc-prewindow=i" => sub { $dc->prewindow( $_[1] ) },
	    "dc-postwindow=i" => sub { $dc->postwindow( $_[1] ) },
	    "dc-vds-downstream-fudge=f" => sub { $dc->vds_downstream_fudge( $_[1] ) },
	    "dc-vds-upstream-fallback=f" => sub { $dc->vds_upstream_fallback( $_[1] ) },
	    "dc-min-avg-days=i" => sub { $dc->min_avg_days( $_[1] ) },
	    "dc-min-obs-pct=i" => sub { $dc->min_obs_pct( $_[1] ) },
	    "dc-use-eq3" => sub { $dc->use_eq3( 1 ) },
	    "dc-dont-use-eq3" => sub { $dc->use_eq3( 0 ) },
	    "dc-use-eq4567" => sub { $dc->use_eq4567( 1 ) },
	    "dc-dont-use-eq4567" => sub { $dc->use_eq4567( 0 ) },
	    "dc-reslim=i" => sub { $dc->reslim( $_[1] ) },
	    "dc-iterlim=i" => sub { $dc->iterlim( $_[1] ) },
	    "dc-bias=f" => sub { $dc->bias( $_[1] ) },
    ) || die "usage: import-al.pl [--skip-al] [--skip-icad]\n";



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


goto ICAD if not $doal;

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
	$datecond->{'>='} = $datefrom if $datefrom;
	$datecond->{'<='} = $dateto   if $dateto;
	
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

    goto INCIDENTS if not $doicad;

print STDERR "PROCESSING ICAD...";

my $rs;
eval {
    my $condition = {};
    my $datecond;
    $datecond->{'>='} = $datefrom if $datefrom;
    $datecond->{'<='} = $dateto   if $dateto;
    
    $condition->{logtime} = $datecond if $datecond;

    my $txt1 = "STR_TO_DATE( logtime, '%m/%d/%Y %h:%i:%s %p' )";
    my $txt2 = "STR_TO_DATE('$datefrom','%Y-%m-%d')";
    
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

    goto CRITEVENTS if not $doinc;

# Add to/update incidents
my $datecond;
$datecond->{'>='} = $datefrom if $datefrom;
$datecond->{'<='} = $dateto   if $dateto;

my $condition;

# Can't use this condition because starttime doesn't exist in the D12ActivityLog
#$condition->{starttime} = $datecond if $datecond;
$condition->{cad} = { -in => [ @ARGV ] } if @ARGV;

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

	if ( not $inc ) {
	    # if not, create a new incident object
	    warn join( "", "ADDING CAD ", $al->cad, " TO CAD TABLE\n" );
	    $_ = $al->cad;
	    my $type="UNKNOWN";
	    if ( /^\d+-\d\d\d\d\d\d$/ || /^\d+-\d\d\d\d\d\d\d\d$/ ) { $type = "INCIDENT" }
	    elsif ( /^ANGEL.*$/ ) { $type = "ANGEL STADIUM" }
	    elsif ( /^HONDA.*$/ ) { $type = "HONDA CENTER" }
	    elsif ( /^C[^-]*-\d\d\d\d\d\d$/ || /^C[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "CONSTRUCTION" }
	    elsif ( /^M[^-]*-\d\d\d\d\d\d$/ || /^M[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "MAINTENANCE" }
	    elsif ( /^FAIR.*$/ || /^OC[\s_]*FAIR.*$/ ) { $type = "OCFAIR" }
	    elsif ( /^EMERG.*$/ ) { $type = "EMERGENCY" }
	    
	    $inc = $tmcpeal->resultset('Incidents')->create( 
		{ cad => $al->cad,
		  event_type => $type,
		  start_time => $al->get_column( 'starttime' )
		} );
	}
	
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
			    warn "SUCCESS TO PARSE R/D/L: $locstr";
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
		$locdata = $lp->get_location( uc($memo) );
		if ( !$locdata ) {
		    warn "FAILED TO PARSE MEMO: $memo";
		    $loclogfile << $memo."\n";
		} else {
		    warn "SUCCESS TO PARSE MEMO: $memo";
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
CRITEVENTS: goto DONE if not $docritevents;


DELAYCOMP: goto DONE if not $dodelaycomp;

my $datecond;
$datecond->{'>='} = $datefrom if $datefrom;
$datecond->{'<='} = $dateto   if $dateto;

my $condition;

$condition->{start_time} = $datecond if $datecond;
$condition->{location_vdsid} = { '!=' => undef };
$condition->{cad} = { -in => [ @ARGV ] } if @ARGV;


my $incrs = $tmcpeal->resultset('Incidents')->search(
    $condition, 
    {
	order_by => qw/ start_time asc /
    }
    );

INCDEL: while( my $inc = $incrs->next ) {

    # skip incidents if cadids are specified and they don't match.
    next INCDEL if ( !( $inc->sigalert_begin ) && $onlysigalerts );
    
    if ( $skipifexisting ) {
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

    $dc->tmcpe_db_host( $tmcpe_db_host );
    $dc->tmcpe_db_name( $tmcpe_db_name );
    $dc->tmcpe_db_user( $tmcpe_db_user );
    $dc->tmcpe_db_password( $tmcpe_db_password );
    $dc->cad( $inc->cad );
    $dc->incid( $inc->id );

    if ( !$inc->cad ) {
	croak "INCIDENT DOESN'T have a cadid!!!!";
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

	my @incloc = $tmcpeal->resultset( 'D12ActivityLog' )->search( 
	    {
		cad => $inc->cad
	    },
	    {
		order_by => 'stamp asc'
	    });
	my $end = pop @incloc;

	$dc->logend( $end->stamp );
	$dc->useexisting( $useexist );
	
	$dc->compute_delay;

	$dc->write_to_db;
    };
    if ( $@ ) {
	warn $@;
	next INCDEL;
    }

}



DONE:

