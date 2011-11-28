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
use Pod::Usage;
use Devel::Comments '###', '###';

my %opt = ();

my $cmdline = join( ' ', 'import-al.pl', @ARGV );

GetOptions( \%opt, 
	    "skip-al-import",
	    "skip-rl-import",
	    "skip-icad-import",
	    "skip-incidents",
	    "skip-critical-events",
	    "skip-delay-comp",
	    "skip-location-parse",
	    "only-sigalerts",
	    "only-type=s@",
	    "date-from=s",
	    "date-to=s",
	    "use-existing",
	    "replace-existing",
	    "ignore-unprocessed",
	    "dont-replace-existing",
            "verbose",
	    "tmcpe-db-host=s",
	    "tmcpe-db-name=s",
	    "tmcpe-db-user=s",
	    "tmcpe-db-password=s",
	    "dont-use-osm-geom",
	    "use-osm-geom",
	    "max-recompute-loops=i",
	    "extend-time-increment=i",   # in minutes
	    "extend-space-increment=i",  # miles
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
	    "dc-weight-for-distance=f",  # value is exponent of weighting function
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
	    "dc-cplex-predual=i",
	    "dc-cplex-preind=i",
	    "dc-cplex-mipemphasis=i",
	    "dc-d12-delay-speed=f",
	    "dc-objective=i",
	    "dc-bound-incident-time",
	    "dc-max-incident-speed=f",
	    "extend-if-bounded",
	    "help",
	    "man"
    ) || pod2usage(2);
pod2usage(1)  if ($opt{help});
pod2usage(-verbose => 2)  if ($opt{help});

my $procopt = {
    al_import => 1,
    rl_import => 1,
    location_parse => 1,
    icad_import => 1,
    incidents => 1,
    critical_events => 1,
    delay_comp => 1,
    only_sigalerts => 0,
    verbose => 0,
    useexist => 0,
    use_osm_geom => 0,  # this is expensive!
    tmcpe_db_host => "localhost",
    tmcpe_db_name => "tmcpe_test",
    tmcpe_db_user => "postgres",
    tmcpe_db_password => "",
    replace_existing => 1,
    ignore_unprocessed => 0,
    reprocess_existing => 1,
    forced => [],
    only_type => [],
    max_recompute_loops => 3,
    extend_time_increment => 60,  # extend by 60 minutes by default
    extend_space_increment => 2,  # extend by 60 miles by default
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
	} elsif ( ( /^skip$/ || /^dont$/ ) && ! @vv ) { 
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


my $verbose = $procopt->{verbose} || 0;
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


my $logfile = io( "./logs/import-$$.log" );
$logfile < "IMPORT RUN AT ".time2str( "%D %T", localtime() )."\n";

my $loclogfile = io ( "./logs/location-parse-$$.log" );
$loclogfile < "IMPORT RUN AT ".time2str( "%D %T", localtime() )."\n";


my $lanesparser = Parse::RecDescent->new( q(
lanes: 'LANES:' <leftop: laneid ',' laneid> /.*?$/ { $return = [$item[2], $item[3]]; }

laneid: lanetype /\d/ { $return = $item[1].$item[2]; }

lanetype: 'HOV' | '#'
)
    );


goto RLOG if not $procopt->{al_import};

# FIXME: load to current year

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
	} elsif ( /VERIFICATION/ ||
		  /VERIFICATION BY CCTV\'S/ || 
		  /VERIFIED BY CCTV/ || 
		  /VERIFIED BY CHP/ ) {
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

	} elsif ( /INFO/ ) {
	    $pmtype = 'INFO';

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

	} elsif ( /LANES CLEAR/ || /LNS CLEAR/) {
	    $pmtype = 'STATUS';

	    # This grabs the lane identifiers spit out by the activity log
	    my $which = $lanesparser->lanes( $memo );

	    if ( $which ) {
		# got a good match.  Create info necessary to put them in the type eval table
		$lanes = join( ",", map { join( "", "-", $_ ) } @{$which->[0]} );
		$detail = $which->[1];

	    } else {
		# no match.  Assume all lanes clear.  FIXME: crindt: think about this
		
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

    print STDERR "LOADING ACTIVITY LOG ENTRIES FROM $table...";

    # BLOCK DB UPDATES DURING THIS OPERATION?
    
    my $rs;
    my $res = eval {
	my $condition = {};
	my $datecond;
	$datecond->{'>='} = $procopt->{date_from} if $procopt->{date_from};
	$datecond->{'<='} = $procopt->{date_to}   if $procopt->{date_to};
	
	$condition->{stampdate} = $datecond if $datecond;

	# only load for specific CAD
	my @include = grep { not /^not-/ } @ARGV;
	my @exclude = grep { /^not-/ } @ARGV;
	$condition->{cad}->{'-in'} = [ @include ] if @include;
	$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;
	
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
		
		my $res = eval { 
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
		    carp "ERROR ".$@;
		    $logfile << "ERROR ".$@;
		}
		warn "INSERTED ENTRY ".$t->keyfield."\n" if $verbose;
		1;
		
	    } else { 
		warn "SKIPPED DUPLICATE ENTRY ". $t->keyfield."\n"  if $verbose;
	    }
	}
    };
    croak "ERROR: ".$@ if $@;

    print STDERR "done\n";

    return;
}

# loop over the radio log records
RLOG:;

goto ICAD if not $procopt->{rl_import};

# FIXME: load to current year

foreach my $table ( ( map { "CommRlBackup$_" } ( 2009..2010 ) ) , "CtAlTransaction" )
{
    load_rl_entries( $table );
}

sub load_rl_entries {
    my ( $table ) = @_;

    print STDERR "LOADING COMM LOG ENTRIES FROM $table...";
    
    # BLOCK DB UPDATES DURING THIS OPERATION?
    my $rs;
    eval {
	my $condition = {};
	my $datecond;
	$datecond->{'>='} = $procopt->{date_from} if $procopt->{date_from};
	$datecond->{'<='} = $procopt->{date_to}   if $procopt->{date_to};
	
	$condition->{stampdate} = $datecond if $datecond;

	# load for specific CAD
	my @include = grep { not /^not-/ } @ARGV;
	my @exclude = grep { /^not-/ } @ARGV;
	$condition->{cad}->{'-in'} = [ @include ] if @include;
	$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;

	
	$rs = $d12->resultset($table)->search(
	    $condition,
	    { order_by => 'keyfield asc' }
	    );
	
	# loop over all the new records, and shove them into the postgres db
	while ( my $t = $rs->next ) {  ### Looping over CommLog entries (% done)

	    # push data in.
	    my $rec;
	    
	    my $date = $t->stampdate;
	    $date =~ s/-/\//g;
	    my $stamp = join(" ", $date, $t->stamptime );
	    
	    my $exist = $tmcpeal->resultset('D12CommLog')->find( $t->keyfield );
	    
	    if ( not $exist ) {
		eval { 
		    $rec = $tmcpeal->resultset('D12CommLog')->create(
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
			    memo => $t->memo,
			    imms => $t->imms,
			    made_contact => $t->madecontact
			});
		};
		if ( $@ ) {
		    carp "ERROR ".($@->{msg} || $@);
		    $logfile << "ERROR ".($@->{msg} || $@ );
		} else {
		    warn "INSERTED ENTRY ".$t->keyfield."\n" if $verbose;
		}
		1;
	    }
	}
    };

    print STDERR "done\n";

    return;
}


# loop over the icad records 

ICAD:

    goto INCIDENTS if not $procopt->{icad_import};

print STDERR "PROCESSING ICAD...";

my $rs;
eval {
    my $condition = {};
    my $datecond;
    $datecond->{'>='} = $procopt->{date_from} if $procopt->{date_from};
    $datecond->{'<='} = $procopt->{date_to}   if $procopt->{date_to};
    
    $condition->{logtime} = $datecond if $datecond;

    my $txt1 = "STR_TO_DATE( logtime, '%m/%d/%Y %h:%i:%s %p' )";
    my $txt2 = "STR_TO_DATE('$procopt->{date_from}','%Y-%m-%d')";
    
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
		       log_id => $t->logid,
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
	    eval { $rec->create_related( 'icad_details', { stamp => $det->{stamp}, detail => $det->{det} } ); };
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
$datecond->{'>='} = $procopt->{date_from} if $procopt->{date_from};
$datecond->{'<='} = $procopt->{date_to}   if $procopt->{date_to};

my $condition;

# Can't use this condition because starttime doesn't exist in the D12ActivityLog
$condition->{stamp} = $datecond if $datecond;
my @include = grep { not /^not-/ } @ARGV;
my @exclude = grep { /^not-/ } @ARGV;
$condition->{cad}->{'-in'} = [ @include ] if @include;
$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;

my $alrs = $tmcpeal->resultset('D12ActivityLog')->search( $condition, { 
    'select' => [ 'cad', { min => 'stamp', -as => 'starttime' }	],
    'as'       => [ qw/ cad starttime / ],
    group_by => [ qw/ cad / ],
    order_by => 'starttime asc'
							  } );

my $lp = new TMCPE::ActivityLog::LocationParser();
$lp->use_osm_geom( $procopt->{use_osm_geom} );

eval {
  INCIDENT:
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
	    # clear critical events for reprocessing
	    $inc->verification(undef);
	    $inc->lanes_clear(undef);
	}

	# Set the start time
	$inc->start_time( $al->get_column( 'starttime' ) );
		      
	my $locdata;

	# Get and set the event type
	$_ = $al->cad;
	my $type="UNKNOWN";
	if ( /^\d+-\d\d\d\d\d\d$/ || /^\d+-\d\d\d\d\d\d\d\d$/ ) { $type = "INCIDENT" }
	elsif ( /^ANGEL.*$/ ) { 
	    $type = "ANGEL STADIUM";
	    # Hardcode location
	    my @res = $vdsdb->resultset('VdsGeoviewFull')->search( { id=>1202093 } );
	    $locdata = shift @res  || croak "BAD VDSID";
	}
	elsif ( /^HONDA.*$/ ) { 
	    $type = "HONDA CENTER";
	    my @res = $vdsdb->resultset('VdsGeoviewFull')->search( { id=>1202093 } );
	    $locdata = shift @res || croak "BAD VDSID";
	}
	elsif ( /^C[^-]*-\d\d\d\d\d\d$/ || /^C[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "CONSTRUCTION" }
	elsif ( /^M[^-]*-\d\d\d\d\d\d$/ || /^M[^-]*-\d\d\d\d\d\d\d\d$/ || /^CONST-.*/) { $type = "MAINTENANCE" }
	elsif ( /^FAIR.*$/ || /^OC[\s_]*FAIR.*$/ ) { $type = "OCFAIR" }
	elsif ( /^EMERG.*$/ ) { $type = "EMERGENCY" }

	if ( @{$procopt->{only_type}} && ( not grep { $type =~ /$_/ } @{$procopt->{only_type}} ) ) {
	    next INCIDENT;
	}

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
	my $openinc;
	my $proxyver;
	foreach my $log ( @incloc ) {

	    # check activity subject
	    $_ = $log->activitysubject;
	    if ( /SIGALERT\s+(\w+)/ ) 
	    {
            $inc->sigalert_begin( $log ) if $1 eq 'BEGIN';
            $inc->sigalert_end( $log ) if $1 eq 'END';
	    } elsif ( /OPEN INCIDENT/ ) {
            $openinc = $log;
            
            # this is a hack to determine the proxy verification
	    } 
	    if ( ( /INFO/ || /SIGALERT BEGIN/ ) && !$proxyver) { 
            $proxyver = $log;
	    }

	    # first, delete existing performance measures, we'll recompute
	    $log->delete_related( 'performance_measures' );

	    my @details = split( /:DOSEP:/, $log->memo );
	    my $memo = shift @details;
	    foreach ( @details ) {
		if ( /ROUTE\/DIR\/LOCATION:/ && $procopt->{"location_parse"}) {
		    # always use R/D/L string to identify location
		    my ( $locstr ) = ( /ROUTE\/DIR\/LOCATION:\s*(.*)/ );
		    if ( $locstr ) {
			warn "PARSING LOCSTR: $locstr";
			$locdata = $lp->get_location( uc($locstr), $inc->location_geom ) ;
			if ( !$locdata ) {
			    warn "FAILED TO PARSE R/D/L: $locstr";
			    $loclogfile << "FAIL [" << $inc->cad << "]: " << $locstr."\n";
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
			    $loclogfile << "SUCC [" << $inc->cad << "]" << $locstr << " = " 
				<< join( "",
					 $locdata->id,
					 " [",
					 $locdata->freeway_id,
					 "-",
					 $locdata->freeway_dir,
					 " @ ",
					 $locdata->name,
					 "]\n");
			}
		    }
		} elsif ( /Performance_Measures:(.*)/ ) {
		    my $pm = process_performance_measures( $inc, $log, $1, $memo );

		    if ( $pm->{pmtype} eq 'FIRST CALL' ) {
			$inc->first_call( $log );

		    } elsif ( $pm->{pmtype} eq 'VERIFICATION' && 
				not defined( $inc->verification ) ) {
			# assume first verification is t1
			print STDERR "-----------------SETTING VERIFICATION------------------\n";
			$inc->verification( $log );

		    } elsif ( $pm->{pmtype} eq 'LANES BLOCKED' && 
				not defined( $inc->verification ) ) {
			# assume first identification of lanes blocked is verification
			$inc->verification( $log );

		    } elsif ( $pm->{pmtype} eq 'STATUS' && $pm->{pmtext} eq 'LANES CLEAR' ) {
			$inc->lanes_clear( $log );
			
		    }
		}
	    }
	    
	    # fallback to finding location
	    if ( ! $locdata && ( ! ( $memo =~ /^\s*$/ ) ) && $procopt->{"location_parse"} ) {
		warn "PARSING MEMO: $memo";
		$locdata = $lp->get_location( uc($memo), $inc->location_geom );

		# fallback to finding nearest location based on CAD log
		# try breaking memo into comma delimited sections
		my @submemo = split( /\s*,\s*/, $memo );
		while( !$locdata && ( my $sm = pop @submemo ) ) {
		    $locdata = $lp->get_location( uc( $sm ), $inc->location_geom );
		}

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

	    # fallback to finding verification
	    if ( !$inc->verification ) {
		$_ = $memo;
		if ( /TMC HAS VISUAL/ || /VISUAL PER CCTV/) {
		    $inc->verification( $log );
		} elsif ( $inc->sigalert_begin 
			  && !$inc->verification
		    ) {
		    $inc->verification( $inc->sigalert_begin );
		}
	    }

	    # fallback to finding clearance
	    if ( !$inc->lanes_clear( ) ) {
            $_ = $memo;
            if ( /SIGALERT END/ || /LANES CLEAR/ || /LANES CLR/ || /ROADWAY CLEAR/ || /RDWY CLR/ 
                 || /RDWY CLEAR/ || /ROADWAY IS CLEAR/ || /RDWY IS CLEAR/ || /LANES OPEN/ || /LNS ARE OPEN/
                 || /LNS OPEN/ || /ALL LANES ARE CLEAR/) {
                $inc->lanes_clear( $log );
            }
	    }
	}

    # now, parse the icad log to pull any additional data
	    
	# now set the locdata if we found it...
	if ( $locdata ) {
	    $inc->location_vdsid( $locdata->id );
	}

	if ( ! $inc->first_call && $openinc ) {
	    # first call not defined in performance measures, use open incident line
	    $inc->first_call( $openinc );
	}

	if ( ! $inc->verification && $proxyver ) {
	    # verification not defined, use proxy
	    $inc->verification( $proxyver );
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
CRITEVENTS: goto DELAYCOMP if not $procopt->{critical_events};


DELAYCOMP: goto DONE if not $procopt->{delay_comp};

my $datecond;
$datecond->{'>='} = $procopt->{date_from} if $procopt->{date_from};
$datecond->{'<='} = $procopt->{date_to}   if $procopt->{date_to};

my $condition;

# require a location_vdsid to analyze ( handle this on iteration )
#$condition->{location_vdsid} = { '!=' => undef };   
my @include = grep { not /^not-/ } @ARGV;
my @exclude = grep { /^not-/ } @ARGV;
$condition->{cad}->{'-in'} = [ @include ] if @include;
$condition->{cad}->{'-not_in'} = [ map { $_ =~ s/^not-//g; $_ } @exclude ] if @exclude;

# use the date condition if it was given AND a specific (set of) cad was NOT given
$condition->{start_time} = $datecond if ( $datecond && !@include );

# only process sigalerts if option is specified AND we haven't specified @include
$condition->{sigalert_begin}->{'!='} = undef if ( $procopt->{only_sigalerts} && !@include );


my $incrs = $tmcpeal->resultset('Incidents')->search(
    $condition, 
    {
	order_by => qw/ start_time asc /
    }
    );

INCDEL: while( my $inc = $incrs->next ) {

    my $ia;
    my @existing = $tmcpe->resultset( 'IncidentImpactAnalysis' )->search(
	{ incident_id => $inc->id });

    if ( ! $procopt->{replace_existing} && @existing) {
	# don't do the computation if one exists (should tweak to use confirm parameters are identical
	warn "SKIPPING DELAY COMPUTATION FOR ".$inc->cad." BECAUSE ONE ALREADY EXISTS";
	next INCDEL;
    }

    if ( $procopt->{ignore_unprocessed} && ! @existing ) {
	# Don't compute unless a computation has already been performed
	warn "SKIPPING DELAY COMPUTATION FOR ".$inc->cad." BECAUSE PARAMETERS SAY TO SKIP UNPROCESSED";
	next INCDEL;
    }

    if ( !$inc->location_vdsid ) {
	warn "SKIPPING DELAY COMPUTATION FOR ".$inc->cad." BECAUSE THE LOCATION CAN'T BE DETERMINED";
	next INCDEL;
    }

    ### =: join( "", "COMPUTING DELAY FOR ", $inc->id, " [", $inc->cad || "<undef>", "]" )

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
    $dc->cmdline( $cmdline );

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


	# set the critical event types in the incident management
	$dc->first_call( $inc->start_time );

	
	$dc->verification( $inc->verification->stamp ) if $inc->verification;
	$dc->lanes_clear( $inc->lanes_clear->stamp ) if $inc->lanes_clear;


	my @incloc = $tmcpeal->resultset( 'D12ActivityLog' )->search( 
	    {
		cad => $inc->cad
	    },
	    {
		order_by => 'stamp asc'
	    });
	my $end = pop @incloc;

	# catch incident logs that were left open too long
	if ( $inc->sigalert_end() ) { $end = $inc->sigalert_end(); }

	my $last = $inc->first_call || shift @incloc;
      LOGSEARCH:
	foreach my $ll ( @incloc ) {
	    my $lastlogdiff = str2time($ll->stamp) - str2time($last->stamp);
	    if ( $lastlogdiff > 90*60 ) {  
		# assume the incident is effectively over if there hasn't been an entry for 90 minutes
		$end = $last;
		last LOGSEARCH;
	    }
	    $last = $ll;
	}

	$dc->logend( $end->stamp );
	
	
	my $cnt=0;
	do {
	    if ( $dc->solution_time_bounded() > 1 ) {
		# increment time post window by 60 minutes
		warn "INCREMENTING INCIDENT POST TIME WINDOW BY ".$procopt->{extend_time_increment}." MINUTES";
		$dc->postwindow( $dc->postwindow() + $procopt->{extend_time_increment} );
	    } 
	    if ( $dc->solution_space_bounded() > 1 ) {
		# increment upstream space bound by 2 miles
		# FIXME: need to account for freeway termination.
		warn "INCREMENTING INCIDENT POST TIME WINDOW BY ".$procopt->{extend_space_increment}." MILES";
		$dc->vds_upstream_fallback( $dc->vds_upstream_fallback() + $procopt->{extend_space_increment} ) ;
	    }
	    
	    $dc->compute_delay;

	} while ( !$dc->bad_solution()
		  && ( $dc->solution_time_bounded()>1 || $dc->solution_space_bounded()>1 )
		  && $cnt++ < $procopt->{max_recompute_loops} );

	$dc->write_to_db;

	if ( not $dc->bad_solution() ) {
	    $dc->compute_fraction_observed();

	    $dc->compute_incident_clear();

	    $dc->compute_diversion();
	    
	    $dc->compute_delay2();
	}
    };
    if ( $@ ) {
	$_ = ref $@;
	if    ( /SCALAR/ ) { warn $@; }
	elsif ( /DBIx::Class::Exception/ )   { croak $@->{msg}; }
	else               { warn "UNKNOWN PROBLEM COMPUTING DELAY: " . ($@->{msg}?$@->{msg}:$@); }
	next INCDEL;
    }

}



 DONE:

    1;

__END__
