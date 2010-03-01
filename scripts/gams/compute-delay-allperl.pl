#!/usr/bin/perl -I./lib

use strict;
use IO::All;
use DBI;
use Getopt::Long;
use JSON;
use Geo::WKT;

#use TMCPE::Schema;
use SpatialVds::Schema;

use warnings;
use English qw(-no_match_vars);
use Readonly;

my $schema;

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
	    "gams-host" => \$gams_host
	    "gams-user" => \$gams_user;
	    ) || die "usage: compute-delay.pl [--band=<stddev multiplier>] [--test=<case>] <incident> [<facility regexp>]\n";

if ( !$test ) {
    $schema = SpatialVds::Schema->connect(
	"dbi:Pg:dbname=spatialvds;host=localhost;user=VDSUSER;password=VDSPASSWORD",
	slash, undef,
	{ AutoCommit => 1 },
	);
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





    # Read in the query to pull all data upstream from an incident location given:
    # * a band (for computing p_j_m
    # * the incident CAD id
    # * the upstream distance to pull
    # * the pre window in minutes
    # * the post window in minutes
    my $sqlf = io( "select-incident-region.sql" );
    my $sql < $sqlf;

    print STDERR "CONNECTING TO DATABASE...";
    my $dbh = DBI->connect('dbi:Pg:database=fwydata;host=192.168.0.2;port=5431',
			   'crindt' );
    print STDERR "(done)\n";

    my $sth = $dbh->prepare( $sql );

    goto TEST if $test;

    # Here we run the query for the given incident.  The result has
    # data for all affected freeways.  Except it's imperfect and needs
    # to be revamped
    print STDERR "QUERYING $i...";
    $sth->execute( $band, $i, $distance, "$prewindow minutes", "$postwindow minutes" );
    print STDERR "(done)\n";

    my $lastkey = undef;
    my $lastst = undef;
    while( my $row = $sth->fetchrow_hashref() )
    {
	my $facilkey = join(":",$row->{fwy},$row->{dir});
	my $st = $row->{id};
	$data->{$i}->{$facilkey}->{stations}->{$st}->{abs_pm} = $row->{abs_pm};
	$data->{$i}->{$facilkey}->{stations}->{$st}->{fwy} = $row->{fwy};
	$data->{$i}->{$facilkey}->{stations}->{$st}->{dir} = $row->{dir};

	my $incden = $row->{incflw}/$row->{incspd};
	my $kj = 150; # jam density (vpm)
	my $shockspd = $row->{incflw}/($kj-$incden);
	die "bad shockspd: $shockspd" if $shockspd < 0;

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
	my @incstart = $schema->resultset( 'CtAlTransaction' )->search(
	    { cad => $i, activitysubject => 'OPEN INCIDENT' },
	    {
		order_by => [ 'stampdate asc', 'stamptime asc' ]
	    }
	    );
	
	my @actlog = $schema->resultset( 'CtAlTransaction' )->search(
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
