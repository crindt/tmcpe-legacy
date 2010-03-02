#!/usr/bin/perl -I./lib

use strict;
use IO::All;
use DBI;
use Getopt::Long;
use JSON;
use Geo::WKT;

use Date::Parse;
use Date::Calc qw( Delta_DHMS Time_to_Date Day_of_Week Day_of_Week_to_Text Mktime Localtime );
use Date::Format;

use SpatialVds::Schema;
use TMCPE::Schema;
use CT_AL::Schema;

use warnings;
use English qw(-no_match_vars);
use Readonly;

my $spatialvds_db;
my $tmcpe_db;
my $actlog_db;

# turn off line buffering
select((select(STDOUT), $|=1)[0]);

my $band = 0.75;
my $test = 0;
my $rout = undef;
my $prewindow = 10; # minutes
my $postwindow = 250; # minutes
my $eq3 = "";
my $eq4 = "";
my $eq5 = "";
my $eq6 = "";
my $eq7 = "";
my $obj = 1;
my $bias = -0.1;
my $distance = 10;
my $use_existing = 0;
my $skip_query = 0;
my $gams_host = "192.168.0.3";
my $gams_user = "crindt";
my $vds_downstream_fudge = 1;  # How many miles to look downstream of the reported incident location
my $vds_upstream_fallback = 10; # How many miles to look upstream of the reported incident (in the absense of shockwave calcs)
my $g = 25; # default g factor
GetOptions ("band=f" => \$band,    # numeric
	    "test=i"   => \$test,      # string
	    "rout"   => \$rout,
	    "prewindow=i" => \$prewindow,
	    "postwindow=i" => \$postwindow,
	    "not-eq3" => sub { $eq3 = "*" },
	    "not-eq4" => sub { $eq4 = "*" },
	    "not-eq5" => sub { $eq5 = "*" },
	    "not-eq6" => sub { $eq6 = "*" },
	    "not-eq7" => sub { $eq7 = "*" },
	    "objective=i" => \$obj,
	    "bias=f" => \$bias,
	    "distance=f" => \$distance,
	    "use-existing" => \$use_existing,
	    "skip-query" => \$skip_query,
	    "gams-host=s" => \$gams_host,
	    "gams-user=s" => \$gams_user,
	    "g-factor=i"  => \$g
	    ) || die "usage: compute-delay.pl [--band=<stddev multiplier>] [--test=<case>] <incident> [<facility regexp>]\n";

if ( !$test ) {
} else {
    $skip_query=1;
}

my @objective;

foreach my $i (1..3)
{
    $objective[$i] = "*"  if ( $obj != $i );
}


my $data;
my $i = $ARGV[ 0 ] || die "You must specify the incident";
my $mintimeofday = undef;
my $mindate = undef;


# Here we perform the query to pull the data for each affected facility for a given incident
if ( not $skip_query )
{
    # First step: pull metadata for incident.  This has to come from
    # the tmcpe tables derived from the activity log---currently stored in 
    # tmcpe:sigalert_locations_grails_table
    $actlog_db = CT_AL::Schema->connect(
	"dbi:Pg:dbname=tmcpe;host=localhost",
	"postgres", undef,
	{ AutoCommit => 1, db_schema => 'actlog' },
	);

    $tmcpe_db = TMCPE::Schema->connect(
	"dbi:Pg:dbname=tmcpe;host=localhost",
	"postgres", undef,
	{ AutoCommit => 1, db_schema => 'tmcpe' },
	);

    my $incrs = $tmcpe_db->resultset('SigalertLocationsGrailsTable')->search( { cad=>$i } );
    
    my $incdata;
    eval { $incdata = $incrs->next; }
    or do {
	croak $@;
    };

    $incdata->vdsid =~ /\d+/ || die "Invalid vdsid ".$incdata->vdsid." returned for incident $i";

    print STDERR join( "", 
		       "Got incident $i @ ",
		       $incdata->vdsid,
		       "[",
		       $incdata->xs,
		       "]"
	);


    # Now we want to compute information about the incident that we
    # can get from the activity log such as the duration
    $actlog_db = CT_AL::Schema->connect(
	"dbi:Pg:dbname=tmcpe;host=localhost",
	"postgres", undef,
	{ AutoCommit => 1, db_schema => 'tmcpe' },
	);

    # here we grab all the activity log data
    my @al;
    eval {
	@al = $actlog_db->resultset( 'D12ActivityLog' )->search( 
	    {cad => $i}, 
	    { order_by => [ 'stampdate asc', 'stamptime asc' ] } 
	    )->all;
    } or do { 
	croak $@ 
    };
    
    # Dump them for information purposes
    map { 
	print STDERR "\t".join( " : ",
				$_->stampdate,
				$_->stamptime,
				$_->status,
				$_->activitysubject,
				$_->memo 
	    )."\n";
    } @al;


    # For now, define incstart as the earliest AL entry and incend as the latest
    my @tt = Localtime(str2time( join( ' ', $al[0]->stampdate, $al[0]->stamptime ) ));
    my $incstart = Mktime(@tt[0..5]);
    @tt = Localtime(str2time( join( ' ', $al[$#al]->stampdate, $al[$#al]->stamptime ) ));
    my $incend   = Mktime(@tt[0..5]);
    my @dur = Delta_DHMS( Time_to_Date( $incstart ), Time_to_Date( $incend ) );
    my $dirstr = sprintf( "%dd:%2.2d:%2.2d:%2.2d", @dur );
    print STDERR "\t".join( "",
			    "Incident $i from ",
			    time2str('%D %T', $incstart ),
			    " to ",
			    time2str('%D %T', $incend ),
			    " :: duration == ",
			    $dirstr,
			    "\n" );

    1;

    # OK, now we want to determine the vds to pull incdata has the
    # vdsid nearest the incident.  This is the proxy location and also
    # has the mainline facility.  We'll use that to query for the
    # relevant vds from spatialvds
    $spatialvds_db = SpatialVds::Schema->connect(
	"dbi:Pg:dbname=spatialvds;host=localhost",
	"VDSUSER", undef,
	{ AutoCommit => 0 },
	);

    $spatialvds_db->storage->debug(1);

    my $inclocrs = $spatialvds_db->resultset( 'VdsGeoviewFull' )->search( id => $incdata->vdsid );
    my $incloc;
    eval {
	$incloc = $inclocrs->next;
    } or do {
	croak $@;
    };



    ############# THIS SHOULD BE A SUB ##################
    # $incloc points to the complete metadata for the vds station
    # nearest the incident.  Now we want to determine the direction,
    # so we can query upstream from the incident some maximum distance
    $_ = $incloc->freeway_dir;
    my $vdsrs;
    if ( /N/ || /W/ ) {
	# northbound and westbound facilities increase downstream, so
	# we want to query between [ incloc - (max dist) ] and incloc
	$vdsrs = $spatialvds_db->resultset( 'VdsGeoviewFull' )->search( 
	    {
		freeway_id => $incloc->freeway_id,
		freeway_dir => $incloc->freeway_dir,
		abs_pm => {
		    -between => [ $incloc->abs_pm - $vds_upstream_fallback,
				  $incloc->abs_pm + $vds_downstream_fudge
			]
		}
	    },
	    { order_by => 'abs_pm desc' }
	    );
    } else {
	# southbound and eastbound facilities decrease downstream, so
	# we want to query between incloc and [ incloc + (max dist) ]
	$vdsrs = $spatialvds_db->resultset( 'VdsGeoviewFull' )->search( 
	    {
		freeway_id => $incloc->freeway_id,
		freeway_dir => $incloc->freeway_dir,
		type_id => 'ML',
		abs_pm => {
		    -between => [ $incloc->abs_pm - $vds_downstream_fudge,
				  $incloc->abs_pm + $vds_upstream_fallback
				  ]
		}
	    },
	    { order_by => 'abs_pm asc' }
	    );
    }

    my @avds = $vdsrs->all;
    print STDERR "POSSIBLY (DIRECTLY) AFFECTED VDS STATIONS\n";
    map {
	print STDERR join( " ",
			   $_->id,
			   join( "-", $_->freeway_id, $_->freeway_dir ),
			   "@",
			   $_->abs_pm,
			   ( $_->abs_pm == $incloc->abs_pm ? "***" : "" )
	    )."\n";
    } @avds;

    # Now, we need to hit couchdb to pull the avg data for these
    # locations for the given time range
    # curl -d 'startkey=[1214081,"Mon",11]&endkey=[1214081,"Mon",14.2]&group_level=3' -G  http://127.0.0.1:5984/pems_agg_d12_2007_10/_design/summary_dow_five/_view/dow_fivemin

    my @startdate = Localtime( $incstart );
    my $startdow = substr( Day_of_Week_to_Text( Day_of_Week( @startdate[0..2] ) ), 0, 3 );
    my $starttime = join( ".", $startdate[3], sprintf( "%2.2d", int($startdate[4]/5)*5 ) );
    my @enddate = Localtime( $incend );
    my $enddow = substr( Day_of_Week_to_Text( Day_of_Week( @enddate[0..2] ) ), 0, 3 );
    my $endtime = join( ".", $enddate[3], int($enddate[4]/5)*5 ); 
    foreach my $vds ( @avds ) {
	my $vdsid = $vds->id;
	my $facilkey = join( ":", $vds->freeway_id, $vds->freeway_dir );
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{abs_pm} = $vds->abs_pm;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{fwy} = $vds->freeway_id;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{dir} = $vds->freeway_dir;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{name} = $vds->name;

	# really, should take prior 12 month data, but right now we
	# only have 2007
	my $tt;
	foreach my $yr ( 2007 ) {
	    foreach my $mon ( 1..12 ) {
		my $fcmd = sprintf( "curl -s -d 'startkey=[$vdsid,\"$startdow\",$starttime]&endkey=[$vdsid,\"$enddow\",$endtime]&group_level=3' -G  http://127.0.0.1:5984/pems_agg_d12_2007_%2.2d/_design/summary_dow_five/_view/dow_fivemin|", $mon );
		#print STDERR $fcmd."\n";
		my $cdbres = io($fcmd);
		my $json_text < $cdbres;
		#print STDERR $json_text."\n";
		my $obj = from_json($json_text, {utf8 => 1});

		foreach my $rec ( @{$obj->{rows}} ) {

		    my $nlanes = $rec->{value}->[3];

		    if ( not defined( $tt->{$rec->{key}->[2]} ) ) {
			# create the cell for summing this period time
			# is defined as h.m, where the minutes are
			# truncated so that 5.1 means 5:10 and 5.15
			# means 5:15 and 5.5 means 5:50.  Kinda weird,
			# but the following teases it into a normal
			# time string.
			my ($h,$m) = split( /\./, $rec->{key}->[2] );
			if ( not defined $m ) {
			    $m = 0;
			} else {
			    $m = ".$m" + 0;
			}
			$m *= 100;

			# OK, now create the initial for this time cell
			$tt->{$rec->{key}->[2]} = {
			    timeofday => join( ":", $h, $m ),
			    nlanes => $nlanes,
			    yrint => 0,
			    yrvol => 0,
			    yrocc => 0
			}
		    }

		    # Now, sum the intervals, the volume, and the avg occupancies
		    $tt->{$rec->{key}->[2]}->{yrint} += $rec->{value}->[0];
		    $tt->{$rec->{key}->[2]}->{yrvol} += $rec->{value}->[1];
		    $tt->{$rec->{key}->[2]}->{yrocc} += $rec->{value}->[2];

		    # this is a weird one, but we're basically summing
		    # the number of days for which we have an
		    # occupancy average.  In the couchdb reply, the
		    # number of days is stored in the 3+nlanes*4'th
		    # column
		    $tt->{$rec->{key}->[2]}->{yrcnt} += $rec->{value}->[$nlanes*2+4]; 
		    1;
		}
	    }
	}
	# at this point, tt should hold the 5-minute annual data for
	# $vdsid.  We need to compute the averages
	foreach my $time ( sort { $a <=> $b } keys %{$tt} ) {
	    my $avg30vol = $tt->{$time}->{yrvol}/$tt->{$time}->{yrint};
	    my $avg5flw  = 120 * $avg30vol;
	    my $avg30occ = $tt->{$time}->{yrocc}/$tt->{$time}->{yrcnt};
	    my $avg5occ  = $avg30occ;
	    my $avg5spd = $g  # g factor
		* ( ( $avg5flw )       # avg 5-minute hourly flow rate
		    / $tt->{$time}->{nlanes} # convert to per-lane volume
		    / (5280.0 * $avg5occ)   # avg 5-minute occupancy 
		);
	    # this is a raw flw/occ value that is a proxy for speed
	    my $avg5v2o = $avg5flw / $avg5occ;
	    if ( $tt->{$time}->{yrint} < (10*52.0*.6) ) {
		$tt->{$time}->{avg5flw} = -1;
		$tt->{$time}->{avg5occ} = -1;
		$tt->{$time}->{avg5spd} = -1;
		$tt->{$time}->{avg5v2o} = -1;
	    } else {
		$tt->{$time}->{avg5flw} = $avg5flw;
		$tt->{$time}->{avg5occ} = $avg5occ;
		$tt->{$time}->{avg5spd} = $avg5spd;
		$tt->{$time}->{avg5v2o} = $avg5v2o;
	    }
	    
	    print STDERR join( " : ",
			       $vdsid,
			       $tt->{$time}->{timeofday},
			       $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name},
			       sprintf( "%5.0f", $tt->{$time}->{avg5flw}/ $tt->{$time}->{nlanes}  )." vph",
			       sprintf( "%5.1f", $tt->{$time}->{avg5occ}*100 )."%",
			       sprintf( "%5.1f", $tt->{$time}->{avg5spd} )." mph",
			       sprintf( "%10.4f", $tt->{$time}->{avg5v2o} )." XXX"
		)."\n";

	    # create the array if it's not defined yet
	    if ( not defined( $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} ) ) {
		$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} = [];
	    }
	    
	    # This is what we really need to fill!
	    push @{$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}}, { 
		timeofday => $tt->${time}->{timeofday},
		avg_spd => $tt->${time}->{avg5v2o},
		stddev_spd => 550,  # FIXME: HACK, couchdb doesn't give stddev
		avg_pctobs => ,   #
		incspd => $row->{incspd},
		incpctobs => $row->{incpctobs},
		avg_flw => $row->{avg_flw},
		incflw => $row->{incflw},
		p_j_m => $row->{p_j_m},
		incden => $row->{incflw}/$row->{incspd},  # inferred
		shockspd => $shockspd
	    };

			       
	}
    }
    
    exit;
    
    
    ############# END THIS SHOULD BE A SUB ##################
    

	# This is what we really need to fill!
	push @{$data->{$i}->{$facilkey}->{stations}->{$st}->{data}}, { 
	    timeofday => $row->{timeofday},
	    avg_spd => $row->{avg_spd},
	    stddev_spd => $row->{stddev_spd},
	    avg_pctobs => $row->{avg_pctobs},
	    incspd => $row->{incspd},
	    incpctobs => $row->{incpctobs},
	    avg_flw => $row->{avg_flw},
	    incflw => $row->{incflw},
	    p_j_m => $row->{p_j_m},
	    incden => $row->{incflw}/$row->{incspd},  # inferred
	    shockspd => $shockspd
	};
	$mintimeofday = $row->{timeofday} if ( not defined( $mintimeofday ) );
	$mindate = $row->{date} if ( not defined( $mindate ) );

	# grab closest
	if ( ( not defined( $data->{$i}->{$facilkey}->{mindist} ) ) || $row->{st_dist} < $data->{$i}->{$facilkey}->{mindist} )
	{
	    $data->{$i}->{$facilkey}->{mindist} = $row->{st_dist};
	    $data->{$i}->{$facilkey}->{nearest} = $data->{$i}->{$facilkey}->{stations}->{$st};
	}
    }
}

# reset
TEST: if ( $test == 1 )
{
    $data = undef;

    $data->{$i}->{T}->{S0} = { abs_pm => 0,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 1 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 1 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S1} = { abs_pm => -1,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 1 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 1 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S2} = { abs_pm => -2,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 0 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 0 },
				    { timeofday => 3, p_j_m => 0 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S3} = { abs_pm => -3,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 0 },
				    { timeofday => 1, p_j_m => 0 },
				    { timeofday => 2, p_j_m => 0 },
				    { timeofday => 3, p_j_m => 0 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S4} = { abs_pm => -4,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 0 },
				    { timeofday => 1, p_j_m => 0 },
				    { timeofday => 2, p_j_m => 0 },
				    { timeofday => 3, p_j_m => 1 },
				    { timeofday => 4, p_j_m => 1 } ] };
}
elsif ( $test == 2 )
{
    $data = undef;

    $data->{$i}->{T}->{S0} = { abs_pm => -0,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 1 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 0 },
				    { timeofday => 4, p_j_m => 0 } ] };
    $data->{$i}->{T}->{S1} = { abs_pm => -1,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 1 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 0 },
				    { timeofday => 4, p_j_m => 0 } ] };
    $data->{$i}->{T}->{S2} = { abs_pm => -2,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 1 },
				    { timeofday => 1, p_j_m => 1 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 0 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S3} = { abs_pm => -3,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 0 },
				    { timeofday => 1, p_j_m => 0 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 1 },
				    { timeofday => 4, p_j_m => 1 } ] };
    $data->{$i}->{T}->{S4} = { abs_pm => -4,
			       data => 
				   [
				    { timeofday => 0, p_j_m => 0 },
				    { timeofday => 1, p_j_m => 0 },
				    { timeofday => 2, p_j_m => 1 },
				    { timeofday => 3, p_j_m => 1 },
				    { timeofday => 4, p_j_m => 1 } ] };
}
elsif ( $test == 3 )
{
    $data = undef;

    $data->{$i}->{T}->{stations} = 
    {
	S0 => { abs_pm => -0,
		data => 
		    [
		     { timeofday => 0, p_j_m => 1 },
		     { timeofday => 1, p_j_m => 1 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 0 },
		     { timeofday => 4, p_j_m => 0 } 
		     ] 
		     },
	S1 => { abs_pm => -1,
		data => 
		    [
		     { timeofday => 0, p_j_m => 1 },
		     { timeofday => 1, p_j_m => 1 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 0 },
		     { timeofday => 4, p_j_m => 0 } ] },
		    
	S2 =>  { abs_pm => -2,
		  data => 
		      [
		       { timeofday => 0, p_j_m => 1 },
		       { timeofday => 1, p_j_m => 1 },
		       { timeofday => 2, p_j_m => 1 },
		       { timeofday => 3, p_j_m => 0 },
		       { timeofday => 4, p_j_m => 1 } ] },
	S3 => { abs_pm => -3,
		data => 
		    [
		     { timeofday => 0, p_j_m => 0 },
		     { timeofday => 1, p_j_m => 0 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 1 },
		     { timeofday => 4, p_j_m => 1 } ] },
	S4 => { abs_pm => -4,
		data => 
		    [
		     { timeofday => 0, p_j_m => 0 },
		     { timeofday => 1, p_j_m => 0 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 0 },
		     { timeofday => 4, p_j_m => 1 } ] }
    };
}
elsif ( $test == 4 )
{
    $data = undef;
    $mindate = '2007-01-01';
    $mintimeofday = '08:00:00';

    $data->{$i}->{'5:N'}->{stations} = 
    {
	S0 => { abs_pm => -0,
		data => 
		    [
		     { timeofday => 0, p_j_m => 0 },
		     { timeofday => 1, p_j_m => 1 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 1 },
		     { timeofday => 4, p_j_m => 1 } 
		     ] 
		     },
	S1 => { abs_pm => -1,
		data => 
		    [
		     { timeofday => 0, p_j_m => 1 },
		     { timeofday => 1, p_j_m => 1 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 0 },
		     { timeofday => 4, p_j_m => 0 } ] },
		    
	S2 =>  { abs_pm => -2,
		  data => 
		      [
		       { timeofday => 0, p_j_m => 1 },
		       { timeofday => 1, p_j_m => 1 },
		       { timeofday => 2, p_j_m => 1 },
		       { timeofday => 3, p_j_m => 0 },
		       { timeofday => 4, p_j_m => 1 } ] },
	S3 => { abs_pm => -3,
		data => 
		    [
		     { timeofday => 0, p_j_m => 1 },
		     { timeofday => 1, p_j_m => 0 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 1 },
		     { timeofday => 4, p_j_m => 1 } ] },
	S4 => { abs_pm => -4,
		data => 
		    [
		     { timeofday => 0, p_j_m => 1 },
		     { timeofday => 1, p_j_m => 0 },
		     { timeofday => 2, p_j_m => 1 },
		     { timeofday => 3, p_j_m => 0 },
		     { timeofday => 4, p_j_m => 1 } ] }
    };
}

# write program;

print STDERR "Got facilities: ".join( ", ", keys %{$data->{$i}} )."\n";

FACIL: foreach my $facil ( keys %{$data->{$i}} )
{
    next FACIL if ( defined $ARGV[ 1 ] && not ( $facil =~ /$ARGV[1]/ ) );

    my $tfacil = $facil;
    $tfacil =~ s/:/=/g;

    my $fname = "$i-$tfacil.gms";
    my $lstname = "$i-$tfacil.lst";
    my $of = io ( $fname );

    my $cell;
    my $z;
    my $n;


    my $J = keys %{$data->{$i}->{$facil}->{stations}};
    $J -= 1;
    my ( $tmp ) = values %{$data->{$i}->{$facil}->{stations}};
    my $M = @{$tmp->{data}};
    my $R = 1;
    my $RR = 2*$J*$M; # maximum number of upstream + time cells
#       my $mintime = $tmp->{data}->{timeofday};
    
    my $delay;
    my $stationdata;
    
    my $MM = $M - 1;

    # set up cell
    my $j = $J;
    foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facil}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
	    $cell->[$j]->[$m] = $d;
	    $stationdata->[$j] = $data->{$i}->{$facil}->{stations}->{$st};
	}
	--$j;
    }

    if ( ! $use_existing )
    {

	print STDERR "WRITING PROGRAM $i to $fname...";

#    $of < "\n\n/* INCIDENT $i, FACILITY, $facil */\n";
	$of < qq{
\$ONUELLIST
OPTIONS ITERLIM = 500000000
*OPTIONS LIMROW = 1000  ** UNCOMMENT TO GET LISTING OF ALL CONSTRAINTS
OPTIONS WORK = 800000
OPTION MIP = CPLEX;
};

	
	$of << qq{
SETS
	J1	Sections	/S0*S$J/
	M1	Time Steps	/0*$MM/

ALIAS ( J1, K1 )
ALIAS ( M1, R1 )

PARAMETERS
};

	$of << qq{
	L( J1 ) section length
	    /
};
	my $j = $J;
	my $last = undef;
	my $lastj = undef;
	my $target = undef;
	my $targetj = undef;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    my $l1 = 0;
	    my $l2 = 0;
	    if ( defined( $target ) )
	    {
		$l1 = abs( $data->{$i}->{$facil}->{stations}->{$target}->{abs_pm} - $data->{$i}->{$facil}->{stations}->{$st}->{abs_pm} ) / 2.0;
	    }
	    if ( defined( $last ) )
	    {
		$l2 = abs( $data->{$i}->{$facil}->{stations}->{$target}->{abs_pm} - $data->{$i}->{$facil}->{stations}->{$last}->{abs_pm} ) / 2.0;
	    }
	    
	    if ( defined( $target ) )
	    {
		my $l = $l1 + $l2;
		$of << sprintf( "		S%s	%f\n", $targetj, $l );
	    }
	    
	    $data->{$i}->{$facil}->{stations}->{$st}->{index} = $targetj;
	    
	    $last = $target;
	    $lastj = $targetj;
	    $target = $st;
	    $targetj = $j;
	    --$j;
	}
	$of << qq{
	    /
	    };
    

	$of << qq{	TABLE P(J1,M1) Evidence
};

	$of << sprintf( "    " );
	for ( my $m = 0; $m < $M; ++$m )
	{
	    $of << sprintf( " %3d", $m );
	}
	$of << "\n";

	$j = $J;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    $of << sprintf( "%4s", sprintf( "S%d", $j ) );
	    
	    for ( my $m = 0; $m < $M; ++$m )    
	    {
		my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
		my $pjm = $cell->[$j]->[$m]->{p_j_m};
		$of << sprintf( " %3.1f", $pjm );
	    }
	    $of << "\n";
	    --$j;
	}

	$of << qq{	TABLE V( J1, M1 )
};
	$of << sprintf( "    " );
	for ( my $m = 0; $m < $M; ++$m )
	{
	    $of << sprintf( " %4d", $m );
	}
	$of << "\n";
	
	$j = $J;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    $of << sprintf( "%4s", sprintf( "S%d", $j ) );
	    
	    for ( my $m = 0; $m < $M; ++$m )    
	    {
		my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
		my $ddd = $d->{incspd};
		$of << sprintf( " %4.1f", $ddd );
	    }
	    $of << "\n";
	    --$j;
	}


	$of << qq{	TABLE AV( J1, M1 )
};
	$of << sprintf( "    " );
	for ( my $m = 0; $m < $M; ++$m )
	{
	    $of << sprintf( " %4d", $m );
	}
	$of << "\n";
	
	$j = $J;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    $of << sprintf( "%4s", sprintf( "S%d", $j ) );
	    
	    for ( my $m = 0; $m < $M; ++$m )    
	    {
		my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
		my $ddd = $d->{avg_spd};
		$of << sprintf( " %4.1f", $ddd );
	    }
	    $of << "\n";
	    --$j;
	}

	$of << qq{	TABLE F( J1, M1 )
};

	$of << sprintf( "    " );
	for ( my $m = 0; $m < $M; ++$m )
	{
	    $of << sprintf( " %4d", $m );
	}
	$of << "\n";
	
	$j = $J;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    $of << sprintf( "%4s", sprintf( "S%d", $j ) );
	    
	    for ( my $m = 0; $m < $M; ++$m )    
	    {
		my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
		my $ddd = $d->{incflw};
		$of << sprintf( " %4.0f", $ddd );
	    }
	    $of << "\n";
	    --$j;
	}


	$of << qq{	TABLE AF( J1, M1 )
};

	$of << sprintf( "    " );
	for ( my $m = 0; $m < $M; ++$m )
	{
	    $of << sprintf( " %4d", $m );
	}
	$of << "\n";
	
	$j = $J;
	foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
			 keys %{ $data->{$i}->{$facil}->{stations} } )
	{
	    $of << sprintf( "%4s", sprintf( "S%d", $j ) );
	    
	    for ( my $m = 0; $m < $M; ++$m )    
	    {
		my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
		my $ddd = $d->{avg_flw};
		$of << sprintf( " %4.0f", $ddd );
	    }
	    $of << "\n";
	    --$j;
	}


	$of << qq{
VARIABLES
	Z		objective
	D(J1,M1)	incident state
	Y		total incident delay
	A		average delay
	N		net delay

BINARY VARIABLE D

EQUATIONS
OBJECTIVE
EQ1
EQ2
$eq3 EQ3
$eq4 EQ4
$eq5 EQ5
$eq6 EQ6
$eq7 EQ7
TOTDELAY
AVGDELAY
NETDELAY
;

$objective[1] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, P( J1, M1 ) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
$objective[2] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, $bias * D( J1, M1 ) + P(J1,M1) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
$objective[3] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, 0.1*P(J1,M1) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
EQ1(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), D( K1, M1 ) ) =l= CARD(J1) -  CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
EQ2(J1,M1) ..	SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( J1, R1 ) ) =l= CARD(M1) -  CARD(M1) * ( D( J1, M1 ) - D( J1, M1+1 ) );
$eq3 EQ3(J1,M1) ..	SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( J1, R1 ) ) =l= CARD(M1) +  CARD(M1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
***             the sum over all cells upstream and later than the target cell must be zero if the target cell is a boundary cell in space(-) and time(+)
$eq4 EQ4(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq4                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) );
***             the sum over all cells downstream and later than the target cell must be zero if the target cell is a boundary cell in space(+) and time(+)
$eq5 EQ5(J1,M1) ..	SUM( K1\$(ORD( K1 ) > ORD( J1 ) ), SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq5                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) );
***             the sum over all cells downstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(+) and time(-)
$eq6 EQ6(J1,M1) ..	SUM( K1\$(ORD( K1 ) > ORD( J1 ) ), SUM( R1\$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq6                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) );
***             the sum over all cells upstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(-) and time(-)
$eq7 EQ7(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), SUM( R1\$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq7                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) );
TOTDELAY ..	Y=E=SUM( J1, SUM( M1, L( J1 ) / V(J1,M1) * F( J1, M1 ) ) );
AVGDELAY ..	A=E=SUM( J1, SUM( M1, L( J1 ) / AV(J1,M1) * AF( J1, M1 ) ) );
NETDELAY ..	N=E=Y-A
};

    # constrain based upon shockwave?

	$of << qq{
MODEL BASE / ALL /;
SOLVE BASE USING MIP MINIMIZING Z;
DISPLAY D.l;
};

	$of->close;
	
	print "(done)\n";
	
	# Print data
	printf "    ";
	for ( my $j = $J; $j >= 0; --$j )
	{
	    printf " %2.2f", $stationdata->[$j]->{abs_pm}
	}
	printf "\n";
	printf "    ";
	for ( my $j = $J; $j >= 0; --$j )
	{
	    printf " %2.2d", $j;
	}
	printf "\n";
	
	for ( my $m = 0; $m < $M; ++$m )
	{
	    printf "%2.2d: ", $m;
	    for ( my $j = $J; $j >= 0; --$j )
	    {
		my $std = $stationdata->[$j];
		my $facilkey = join( ":", $std->{fwy}, $std->{dir} );
		if ( $m==$prewindow/5 && $data->{$i}->{$facilkey}->{nearest} == $std )
		{
		    printf " %1s%1s", "X";
		}
		else
		{
		    printf " %1s%1s", ($cell->[$j]->[$m]->{p_j_m}<0.5?"|":$cell->[$j]->[$m]->{p_j_m}>0.5?"/":" ")," ";
		}
	    }
	    printf "\n";
	}

    
	# OK, now solve it.
	print "SYNCING OVER...";
#    my $resf = io( "/usr/local/src/lp_solve_5.5/lp_solve/lp_solve -presolve -wmps $mpsname < $fname|" );
	
	print "FNAME: $fname\n";
	print "rsync -avz $fname $gams_user\@$gams_host:tmcpe/work\n";
	system( "rsync -avz $fname $gams_user\@$gams_host:tmcpe/work" );

	print "SOLVING...";
	system( "ssh $gams_user\@$gams_host 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $fname'" );
	print "done\n";

	print "SYNCING BACK...$lstname";

#	system( "rsync -avz $gams_user@$gams_host:tmcpe/work/$fname.out ." );
	system( "rsync -avz $gams_user\@$gams_host:tmcpe/work/$lstname ." );

	print "DONE\nPROCESSING...";
    }
    my $outf = io( "$fname.out" );
    my $resf = io( "$lstname" );
    my $found = 0;
    my $error = 0;
  LINE: 
    while( my $line = $resf->getline() )
    {
	$_ = $line;
	/^Error Messages/ && do
	{
	    $error = 1;
	    print STDERR "\n****ERRORS****\n";
	    next LINE;
	};
	if ( $error )
	{
	    print STDERR $_;
	    
	}
	/^\*\*\*\* \d+ ERROR/ && do
	{
	    die "CONSULT $lstname for details";
	};
	
	/^----\s+VAR Z\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $z = $1;
	};
	/^----\s+VAR N\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $n = $1;
	};
      
	/^----\s+VAR D/ && do
	{
	    $found = 1;
	    next LINE;
	};
	/^\*\*\*\* REPORT SUMMARY/ && do
	{
	    $found = 0;
	    next LINE;
	};
	next LINE if not $found;
	
	/^S\s*(\d+)\s*\.\s*(\d+)\s+(.*)/ && do 
	{
	    # got soln
	    my $var = join( "_", "d", $1, $2 );
	    my ($nada, $val ) = split( /\s+/, $3 );
	    $val = 0 if ( $val eq '.' || $val != 1 );
	    $cell->[$1]->[$2]->{inc} = $val;
	};
    }
    print STDERR "done\n";

    # OK, now dump the JSON
    $mindate =~ s|-|/|g;
    my $opts = {
	band => $band,
	mindate => $mindate,  # NOTE: swaps 2007-01-01 for 2007/01/01
	mintimeofday => $mintimeofday,
	mintimestamp => $mindate." ".$mintimeofday,
	prewindow => $prewindow,
	postwindow => $postwindow,
	fwy => $facil,
	cad => $i
    };

    my $segments = [
	map { 
	    my $pm1 = $stationdata->[$_+1]->{abs_pm};
	    my $pm2 = $stationdata->[$_]->{abs_pm};
	    my $pm3 = $stationdata->[$_-1]->{abs_pm};
	    
	    $pm1 = $pm2 if not defined $pm1;
	    $pm3 = $pm2 if not defined $pm3;

	    { pmstart => ($pm1+$pm2)/2.0, pmend => ($pm3+$pm2)/2.0 }
	} ( reverse 0..$J )
    ];

    my $incspd;
    my $stdspd;
    my $avgspd;
    my $pjm;
    my $inc;
    my $cnt = 0;
    foreach my $st ( sort { $data->{$i}->{$facil}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facil}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facil}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    my $d = $data->{$i}->{$facil}->{stations}->{$st}->{data}->[$m];
	    my $ddd = $d->{incspd};
	    $incspd->[$m][$cnt] = $d->{incspd}+0;
	    $stdspd->[$m][$cnt] = $d->{stddev_spd}+0;
	    $avgspd->[$m][$cnt] = $d->{avg_spd}+0;
	    $pjm->[$m][$cnt] = $d->{p_j_m}+0;
	    $inc->[$m][$cnt] = $d->{inc}+0;
	    --$j;
	}
	$cnt++
    }

    my @incstart = ();
    my @actlog = ();
    if ( ! $test ) {
	my @incstart = spatialvds_db->resultset( 'CtAlTransaction' )->search(
	    { cad => $i, activitysubject => 'OPEN INCIDENT' },
	    {
		order_by => [ 'stampdate asc', 'stamptime asc' ]
	    }
	    );
	
	my @actlog = spatialvds_db->resultset( 'CtAlTransaction' )->search(
	    { cad => $i },
	    {
		order_by => [ 'stampdate asc', 'stamptime asc' ]
	    }
	    );
    }

    1;


    my $events = {
	};


    my ( $fwy, $dir ) = split( /:/, $facil );

    if ( $#incstart == 0 )
    {
	my ($h,$m,$s) = split( /:/, $incstart[ 0 ]->stamptime);
	my $amin = 60*$h+$m+$s/60.0;
	($h,$m,$s) = split( /:/, $mintimeofday);
	my $mtod = 60*$h+$m+$s/60.0;

	my $pm = $stationdata->[$J]->{abs_pm};

	if ( defined $incstart[ 0 ]->incloc )
	{
	    my $latlon = $incstart[ 0 ]->incloc
	}

	my $dbh = DBI->connect('dbi:Pg:database=fwydata;host=192.168.0.2;port=5431',
			       'crindt' );

	my $get_incident_pm = $dbh->prepare( 'SELECT tmcpe_incident_pm( ?, ?, ?, ? ) AS inc_pm' );

	$get_incident_pm->execute( $i, $fwy+0, $dir, 'ML' );

	my $row = $get_incident_pm->fetchrow_hashref();

	$events->{incident_start} = { pm => $row->{inc_pm} , tod => $amin-$mtod }
    }

    my $fn = "webtest/$i-$fwy-$dir.json";
    my $jsonf = io( "$fn" );
    my @dhash = map { 
	my $tt = $_;
	my $ttt = { stampdate => $tt->stampdate, 
		    stamptime => $tt->stamptime, 
		    status=>$tt->status, 
		    activitysubject=>$tt->activitysubject,
		    memo=>$tt->memo };
    } ( @actlog );
    $jsonf < to_json( { opts => $opts, 
			segments => $segments, 
			incspd => $incspd, 
			stdspd => $stdspd, 
			avgspd => $avgspd, 
			pjm => $pjm, 
			inc => $inc,
			events => $events,
			band => $band,
			actlog => [ @dhash ]
		      }, 
		   { pretty => 1 } );
    print STDERR "Wrote to $fn\n";

};



my $fn = "webtest/metadata2.json";

my $json_str;
{
    my $metf = io( "$fn" );
    $metf > $json_str;
}
my $metadata = from_json( $json_str );

my $id = 0;
if ( not defined $metadata )
{
    $metadata = { identifier => "id", label => "facility" };
}
else
{
    $id = scalar( $metadata->{items} );
}

foreach my $cad ( keys %{$data} )
{
    FAC: foreach my $facility ( keys %{$data->{$cad}} )
    {
	next FAC if ( grep { $_->{cad} eq $cad 
				     && $_->{facility} eq $facility } 
		      @{$metadata->{items}} );
	push @{$metadata->{items}}, { 
	    id => ( scalar @{$metadata->{items}}) + 1, 
	    cad => $cad, 
	    facility => $facility };
    }
}

my $metf = io( "$fn" );


$metf < to_json( $metadata, 
		 { pretty => 1 } );


1;
