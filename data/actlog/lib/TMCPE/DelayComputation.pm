package TMCPE::DelayComputation;

use strict;
use warnings;
use Carp;
use IO::All;
use SpatialVds::Schema;
use Caltrans::ActivityLog::Schema;
use Date::Calc qw( Delta_DHMS Time_to_Date Day_of_Week Day_of_Week_to_Text Mktime Localtime Add_Delta_DHMS );
use Date::Parse;
use JSON;
use TMCPE::Schema;
use TBMAP::Schema;
use Date::Format;
use POSIX;

use Class::MethodMaker
    [
#     scalar => [ { -default => "localhost" }, 'gams_host' ],
     scalar => [ { -type => 'SpatialVds::Schema',
		   -default_ctor => sub {
		       SpatialVds::Schema->connect(
			   "dbi:Pg:dbname=spatialvds;host=localhost",
			   "VDSUSER", "VDSPASSWORD",
			   { AutoCommit => 1 },
			   );
		   }
		 }, 'vds_db' ],
     scalar => [ { -type => 'Caltrans::ActivityLog::Schema',
		   -default_ctor => sub {
		       CT_AL::Schema->connect(
			   "dbi:Pg:dbname=tmcpe_test;host=localhost",
			   "postgres", undef,
			   { AutoCommit => 1 },
			   );
		   }
		 }, 'actlog_db' ],

     scalar => [ { -type => 'TMCPE::Schema',
		   -default_ctor => sub {
		       my $self = shift;
		       die "TMCPE DB NOT SPECIFIED!" if not $self->tmcpe_db_name;
		       die "TMCPE DB HOST NOT SPECIFIED!" if not $self->tmcpe_db_host;
		       die "TMCPE DB USER SPECIFIED!" if not $self->tmcpe_db_user;
		       warn join(",", $self->tmcpe_db_name,$self->tmcpe_db_host,$self->tmcpe_db_user,$self->tmcpe_db_password);
		       TMCPE::Schema->connect(
			   join("", "dbi:Pg:dbname=",$self->tmcpe_db_name,";","host=",$self->tmcpe_db_host),
			   $self->tmcpe_db_user, $self->tmcpe_db_password,
			   { AutoCommit => 1, db_Schema => 'tmcpe' },
			   );
		   }
		 }, 'tmcpe_db' ],

     scalar => [ { -type => 'TBMAP::Schema',
		   -default_ctor => sub {
		       TBMAP::Schema->connect(
			   "dbi:Pg:dbname=tmcpe_test;host=localhost",
			   "postgres", undef,
			   { AutoCommit => 1, db_Schema => 'tbmap' },
			   );
		   }
		 }, 'tbmap_db' ],

     scalar => [ qw/ incid cad facil dir pm vdsid / ],
     scalar => [ qw/ data cell stationdata stationmap timemap / ],
     scalar => [ { -default_ctor => sub { my $self = shift; return $self->cad."-".$self->facil."=".$self->dir.".gms" } }, 
		 'gamsfile' ],
     scalar => [ { -default_ctor => sub { my $self = shift; return $self->cad."-".$self->facil."=".$self->dir.".lst" } }, 
		 'lstfile' ],
     scalar => [ { -default => 10 }, 'vds_upstream_fallback' ],
     scalar => [ { -default => 1 }, 'vds_downstream_fudge' ],
     scalar => [ { -default => '192.168.0.3' }, 'gams_host' ],
     scalar => [ { -default => 'crindt' }, 'gams_user' ],
     scalar => [ { -default => 10 }, 'prewindow' ],
     scalar => [ { -default => 120 }, 'postwindow' ],
     scalar => [ { -default => 20 }, 'min_avg_days' ],
     scalar => [ { -default => 25 }, 'min_avg_pct' ],
     scalar => [ { -default => 5 }, 'min_obs_pct' ],
     scalar => [ { -default => 1.0 }, 'band' ],
     scalar => [ { -default => 1 }, 'objective' ],
     scalar => [ { -default => 0.0 }, 'bias' ],
     scalar => [ { -default => 0 }, 'useexisting' ],
     scalar => [ { -default => 1 }, 'use_eq1' ],
     scalar => [ { -default => 1 }, 'use_eq2' ],
     scalar => [ { -default => 1 }, 'use_eq3' ],
     scalar => [ { -default => 1 }, 'use_eq4567' ],
     scalar => [ { -default => 0 }, 'use_eq8' ],
     scalar => [ { -default => 0 }, 'use_eq8b' ],
     scalar => [ { -default => 0 }, 'limrow' ],
     scalar => [ { -default => 500000000 }, 'iterlim' ],
     scalar => [ { -default => 300 }, 'reslim' ],  # 5 minutes
     scalar => [ { -default => 1 }, 'lengthweight' ],
     scalar => [ { -default => 15 }, 'max_load_shock_speed' ],  # 15 mi/hr
     scalar => [ { -default => 15 }, 'max_clear_shock_speed' ],  # 15 mi/hr
     scalar => [ { -default => {} }, 'force' ],
     scalar => [ qw/ logstart logend / ],
     scalar => [ qw/ calcstart calcend / ],
     scalar => [ qw/ mintimeofday mindate / ],
     scalar => [ qw/ bad_solution tot_delay avg_delay net_delay / ],
     scalar => [ { -default => 'tmcpe_test' }, 'tmcpe_db_name' ],
     scalar => [ { -default => 'localhost' }, 'tmcpe_db_host' ],
     scalar => [ { -default => 'postgres' }, 'tmcpe_db_user' ],
     scalar => [ { -default => '' }, 'tmcpe_db_password' ],

#     scalar => [ { -type => 'Parse::RecDescent',
#		   -default_ctor => sub { return TMCPE::ActivityLog::LocationParser::create_parser() },
#		 }, 'parser' ],
     new    => [ qw/ new / ]
    ];

sub get_affected_vds {
    my ( $self ) = @_;
    
    my $vdsrs;
    $_ = $self->dir;
    if ( /N/ || /E/ ) {
    # northbound and westbound facilities increase downstream, so
    # we want to query between [ incloc - (max dist) ] and incloc
    $vdsrs = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	{
	    freeway_id => $self->facil,
	    freeway_dir => $self->dir,
	    type_id => 'ML',
	    abs_pm => {
		-between => [ $self->pm - $self->vds_upstream_fallback,
			      $self->pm + $self->vds_downstream_fudge
		    ]
	    }
	},
	{ order_by => 'abs_pm desc' }
	);
    } else {
	# southbound and eastbound facilities decrease downstream, so
	# we want to query between incloc and [ incloc + (max dist) ]
	$vdsrs = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	    {
		freeway_id => $self->facil,
		freeway_dir => $self->dir,
		type_id => 'ML',
		abs_pm => {
		    -between => [ $self->pm - $self->vds_downstream_fudge,
				  $self->pm + $self->vds_upstream_fallback
			]
		}
	    },
	    { order_by => 'abs_pm asc' }
	    );
    }

    return $vdsrs->all
    
}


sub get_pems_data {
    my ( $self, @avds ) = @_;

    my @tt = Localtime(str2time($self->logstart));
    my $incstart = Mktime(@tt[0..5]);
    my $calcstart = Mktime(Add_Delta_DHMS(@tt[0..5],0,0,-$self->prewindow,0));
    $self->calcstart( $calcstart );
    @tt = Localtime(str2time($self->logend));
    my $incend   = Mktime(@tt[0..5]);
    my $calcend   = Mktime(Add_Delta_DHMS(@tt[0..5],0,0,$self->postwindow,0));
    $self->calcend( $calcend );
#    @tt = Localtime(postwindow,0);


    # run the pems 5min query to get relevant results
    my $select_query < io("./select-data.sql");
    
    my $dbh = DBI->connect('dbi:Pg:database=spatialvds;host=localhost',
			   'VDSUSER' );
    
    my $select_data = $dbh->prepare( $select_query );

    my $data;

    my $i = $self->cad;


    # OK, we need to determine the time periods for which we expect
    # data: Basically, it's every five-minute period between calcstart
    # and calcend inclusive.
    my $cs5 = ($calcstart % 300) ? POSIX::floor( $calcstart/300 ) * 300 : $calcstart;
    my $ce5 = ($calcend % 300) ? POSIX::ceil( $calcend/300 ) * 300 : $calcend;

    my @times;
    for ( my $ct = $cs5; $ct <= $ce5; $ct += 300 ) {
	push @times, time2str( "%D %T", $ct );
    }
	
    my $ss = time2str( "%D %T", $cs5 );
    my $es = time2str( "%D %T", $ce5 );

    print STDERR "ANALYZED TIMES BETWEEN $ss AND $es ARE:\n";
    map { print STDERR "\t$_\n"; } @times;

    foreach my $vds ( @avds ) {
	my $vdsid = $vds->id;
	my $facilkey = join( ":", $vds->freeway_id, $vds->freeway_dir );
	
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{vds} = $vds;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{abs_pm} = $vds->abs_pm;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{fwy} = $vds->freeway_id;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{dir} = $vds->freeway_dir;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{name} = $vds->name;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{seglen} = $vds->length;
	
	my @rows = @{ $dbh->selectall_arrayref( $select_data, { Slice=>{} }, $self->min_avg_days, $self->min_obs_pct, $self->band, $vds->id, $ss, $es, $self->min_avg_pct ) };
	
	1;
	
	my $tt;
	# create the array if it's not defined yet
	if ( not defined( $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} ) ) {
	    $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} = [];
	}
	
	if ( !@rows ) {
	    # no DATA
	    print STDERR join( "",
			       "NO DATA FOR $vdsid ",
			       $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name},
			       "!!!\n"
		);
	    # CREATE SOME DUMMY DATA FOR THIS STATION
	    foreach ( @times ) {
		my ($date,$time) = split(/\s+/);
		push @{$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}}, { 
		    date => $date,
		    timeofday => $time,
		    avg_spd => undef,
		    stddev_spd => undef,
		    avg_pctobs => 0,   #
		    incspd => undef,
		    incpctobs => 0,
		    incocc => undef,
		    avg_occ => undef,
		    avg_flw => undef,
		    incflw => undef,
		    p_j_m => 0.5,
		    days_in_avg => 0,
		    incden => 0,  # inferred
		    shockspd => undef   # (0 - a_flw)/(0-a_den) = -a_flw /-a_den = -a_flw / -( a_flw / a_spd ) = a_spd
		};
	    }
	    1;
	    
	} else {
	    if ( @rows != @times ) {
		croak "# ROWS DOESN'T EQUAL # TIMES---CHUCKING" if ( @rows != @times  );
	    }

	    foreach my $row ( @rows ) {
		my ($date,$time) = split(/\s+/, $row->{stamp});
		$row->{date} = $date;
		$row->{timeofday} = $time;

		
		print STDERR join( " : ",
				   $vdsid,
				   $date,
				   $time,
				   $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name},
				   sprintf( "%5.0f", $row->{a_vol} * 12  )." vph",
				   sprintf( "%5.1f", $row->{a_occ}*100 )."%",
				   sprintf( "%5.1f", $row->{a_spd} )." mph",
				   sprintf( "%5.1f", $row->{o_spd} )." mph",
				   $row->{days_in_avg},
				   $row->{o_pct_obs},
				   p_j_m => $row->{p_j_m},
		    )."\n";

		# This is what we really need to fill!
		push @{$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}}, { 
		    date => $date,
		    timeofday => $time,
		    avg_spd => $row->{a_spd},
		    stddev_spd => $row->{sd_spd},
		    avg_pctobs => $row->{a_pct_obs},   #
		    incspd => $row->{o_spd},
		    incpctobs => $row->{o_pct_obs},
		    incocc => $row->{o_occ},
		    avg_occ => $row->{a_occ},
		    avg_flw => $row->{a_vol},
		    incflw => $row->{o_vol},
		    p_j_m => $row->{p_j_m},
		    days_in_avg => $row->{days_in_avg},
		    incden => 0,  # inferred
		    shockspd => $row->{a_spd}   # (0 - a_flw)/(0-a_den) = -a_flw /-a_den = -a_flw / -( a_flw / a_spd ) = a_spd
		};
		
		############# END THIS SHOULD BE A SUB ##################
		
		my $st=$vdsid;
		
		# # This is what we really need to fill!
		# push @{$data->{$i}->{$facilkey}->{stations}->{$st}->{data}}, { 
		#     timeofday => $row->{timeofday},
		#     avg_spd => $row->{avg_spd},
		#     stddev_spd => $row->{stddev_spd},
		#     avg_pctobs => $row->{avg_pctobs},
		#     incspd => $row->{incspd},
		#     incpctobs => $row->{incpctobs},
		#     avg_flw => $row->{avg_flw},
		#     incflw => $row->{incflw},
		#     p_j_m => $row->{p_j_m},
		#     incden => $row->{incflw}/$row->{incspd},  # inferred
		#     shockspd => $shockspd
		# };
		
		$self->mintimeofday( $row->{timeofday} ) if ( not defined( $self->mintimeofday ) );
		$self->mindate( $row->{date} ) if ( not defined( $self->mindate ) );
		
		# grab closest
		if ( ( not defined( $data->{$i}->{$facilkey}->{mindist} ) ) || $row->{st_dist} < $data->{$i}->{$facilkey}->{mindist} )
		{
		    $data->{$i}->{$facilkey}->{mindist} = $row->{st_dist};
		    $data->{$i}->{$facilkey}->{nearest} = $data->{$i}->{$facilkey}->{stations}->{$st};
		}
		
	    }
	}
    }

#    $dbh->close();

    $self->data( $data );


    my $facilkey = join( ":", $self->facil, $self->dir );
    my $J = keys %{$data->{$i}->{$facilkey}->{stations}};
    $J -= 1;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$data->{$i}->{$facilkey}->{stations}};

    my $j = $J;

    $self->stationdata( [] );
    $self->stationmap( {} );
    $self->timemap( {} );

    foreach my $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    $self->stationdata->[$j] = $data->{$i}->{$facilkey}->{stations}->{$st};
	    $self->stationmap->{$data->{$i}->{$facilkey}->{stations}->{$st}->{vds}->id} = $j
	}
	--$j;
    }
    
    
}

sub write_gams_program {
    my ( $self ) = @_;

    my $eq1 = "*";
    $eq1 = "" if $self->use_eq1;

    my $eq2 = "*";
    $eq2 = "" if $self->use_eq2;

    my $eq3 = "*";
    $eq3 = "" if $self->use_eq3;
    my $eq4 = "*" ;
    $eq4 = "" if $self->use_eq4567;
    my $eq5 = "*";
    $eq5 = "" if $self->use_eq4567;
    my $eq6 = "*";
    $eq6 = "" if $self->use_eq4567;
    my $eq7 = "*";
    $eq7 = "" if $self->use_eq4567;
    my $eq8 = "*";
    $eq8 = "" if $self->use_eq8;
    my $eq8b = "*";
    $eq8b = "" if $self->use_eq8;
    my @objective;
    my $bias = $self->bias || 0;

    if ( $self->lengthweight ) { $self->objective( 2 ) }
    
    foreach my $iii (1..3)
    {
	$objective[$iii] = "*"  if ( $self->objective != $iii );
    }
    

    my $data = $self->data;
    my $i = $self->cad;

    my $facilkey = join( ":", $self->facil, $self->dir );

    my $of = io ( $self->gamsfile );

    my $J = keys %{$data->{$i}->{$facilkey}->{stations}};
    $J -= 1;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$data->{$i}->{$facilkey}->{stations}};
    my $R = 1;
    my $RR = 2*$J*$M; # maximum number of upstream + time cells
#       my $mintime = $tmp->{data}->{timeofday};
    
    my $MM = $M - 1;

    # set up cell
    my $j = $J;
    my $st;
    my $m;
    my $d;
    $self->cell( [] );
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    if ( not defined $d ) {
		warn "BAD data for $st, $m";
		$self->cell->[$j]->[$m] = { 
		    timeofday => 0,
		    avg_spd => 0,
		    stddev_spd => 0,
		    avg_pctobs => 0,
		    incspd => 0,
		    incpctobs => 0,
		    avg_flw => 0,
		    incflw => 0,
		    p_j_m => 0.5,
		    incden => 0,  # inferred
		    shockspd => 0
		};
	    } else {
		$self->cell->[$j]->[$m] = $d;
	    }
	}
	--$j;
    }

    print STDERR "WRITING PROGRAM $i to ".$self->gamsfile."...";
    my $RESLIM="*";
    $RESLIM = join( " = ", "OPTIONS RESLIM", $self->reslim ) if $self->reslim;
    my $LIMROW = "*";
    $LIMROW = join( " = ", "OPTIONS LIMROW", $self->limrow ) if $self->limrow;
    
    $of < qq{
\$ONUELLIST
OPTIONS ITERLIM = 500000000
$RESLIM
$LIMROW
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
	PM( J1 ) section postmile
	    /
};
    $j = $J;
    my $last = undef;
    my $lastj = undef;
    my $target = undef;
    my $targetj = undef;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	if ( defined( $target ) )
	{
	    $of << sprintf( "*		S%s = %s %s\n", 
			    $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{vds}->id, 
			    $data->{$i}->{$facilkey}->{stations}->{$target}->{name} );
	    $of << sprintf( "		S%s	%f\n", $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{abs_pm} );
	}
	
	$data->{$i}->{$facilkey}->{stations}->{$st}->{index} = $targetj;
	
	$last = $target;
	$lastj = $targetj;
	$target = $st;
	$targetj = $j;
	--$j;
    }
    # gotta dump the last one too!
    if ( defined( $target ) )
    {
	$of << sprintf( "*		S%s = %s %s\n", 
			$targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{vds}->id, 
			$data->{$i}->{$facilkey}->{stations}->{$target}->{name} );
	$of << sprintf( "		S%s	%f\n", $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{abs_pm} );
    }
    $of << qq{
	    /
	    };

    
    $of << qq{
	L( J1 ) section length
	    /
};
    $j = $J;
    $last = undef;
    $lastj = undef;
    $target = undef;
    $targetj = undef;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	if ( defined( $target ) )
	{
	    $of << sprintf( "*		S%s = %s %s\n", 
			    $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{vds}->id, 
			    $data->{$i}->{$facilkey}->{stations}->{$target}->{name} );
	    $of << sprintf( "		S%s	%f\n", $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{seglen} );
	}
	
	$data->{$i}->{$facilkey}->{stations}->{$st}->{index} = $targetj;
	
	$last = $target;
	$lastj = $targetj;
	$target = $st;
	$targetj = $j;
	--$j;
    }
    # gotta dump the last one too!
    if ( defined( $target ) )
    {
	$of << sprintf( "*		S%s = %s %s\n", 
			$targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{vds}->id, 
			$data->{$i}->{$facilkey}->{stations}->{$target}->{name} );
	$of << sprintf( "		S%s	%f\n", $targetj, $data->{$i}->{$facilkey}->{stations}->{$target}->{seglen} );
    }
    $of << qq{
	    /
	    };
    
    
    $of << qq{	TABLE P(J1,M1) Evidence
};
    
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    if ( not defined $self->cell->[$j]->[$m]->{p_j_m} ) {
		1;
	    }
	    my $pjm = $self->cell->[$j]->[$m]->{p_j_m};
	    $of << sprintf( " %5.1f", $pjm );
	}
	$of << "\n";
	--$j;
    }
    
    $of << qq{	TABLE V( J1, M1 )
};
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    my $ddd = $d->{incspd};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.1f", $ddd );
	}
	$of << "\n";
	--$j;
    }
    
    
    $of << qq{	TABLE AV( J1, M1 )
};
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    my $ddd;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    $ddd = $d->{avg_spd};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.1f", $ddd );
	}
	$of << "\n";
	--$j;
    }
    
    $of << qq{	TABLE F( J1, M1 )
};
    
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    $ddd = $d->{incflw};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.0f", $ddd );
	}
	$of << "\n";
	--$j;
    }
    
    
    $of << qq{	TABLE AF( J1, M1 )
};
    
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    $ddd = $d->{avg_flw};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.0f", $ddd );
	}
	$of << "\n";
	--$j;
    }
    
    $of << qq{
	TABLE FORCE( J1, M1 ) 
};
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = $J;
    foreach $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $ddd = 0;
#	    $ddd = $self->force->[$j][$m] if defined( $self->force->[$j][$m] );
#	    $ddd = 1 if ($m == 2 && $j == 5 );
#	    $ddd = 1 if ($m == 15 && $j == 8 );
	    $of << sprintf( " %5.0f", $ddd );
	}
	$of << "\n";
	--$j;
    }
    my $MAX_LOAD_SHOCK_DIST = $self->max_load_shock_speed/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    my $MAX_CLEAR_SHOCK_DIST = $self->max_clear_shock_speed/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    
    my $shockdir=1;
    if ( /N/ || /E/ ) {
	$shockdir=-1;
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
$eq1 EQ1
$eq2 EQ2
$eq3 EQ3
$eq3 EQ3b
*$eq3 EQ3c
*$eq3 EQ3d
$eq4 EQ4
$eq5 EQ5
$eq6 EQ6
$eq7 EQ7
$eq8 EQ8
$eq8b EQ8b
TOTDELAY
AVGDELAY
NETDELAY
*FORCEEQ
};

    if ( $self->force ) {
	foreach my $k ( keys %{$self->force} ) {
	    my $v = $self->force->{$k};
	    my ( $j, $m ) = split(/:/, $k );
	    $of << "FORCE_S$j"."_$m\n";
	}
    }
	
    $of << qq{
;

$objective[1] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, (1-($bias)) * L( J1 ) * P( J1, M1 ) * D( J1, M1 ) + L( J1 ) * ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
$objective[2] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, (1-($bias)) *           P( J1, M1 ) * D( J1, M1 ) +           ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
$objective[3] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, 0.1*P(J1,M1) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
***             if j1,m1 is a boundary in space (-, upstream) at time m1, the sum of all D's upstream at time M1 must be <= 0
$eq1 EQ1(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), D( K1, M1 ) ) =l= CARD(J1) -  CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
***             if j1,m1 is a boundary in time (+, later) at J1, the sum of all D's later than M1 at section J1 must be <= 0
$eq2 EQ2(J1,M1) ..	SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( J1, R1 ) ) =l= CARD(M1) -  CARD(M1) * ( D( J1, M1 ) - D( J1, M1+1 ) );
***             if j1,m1 is a boundary in space (+, downstream) at time m1, the sum of all D's later that M1 at section J1+1 must be <= 0
***             The point of this is to ensure that congestion only grows upstream from the head of the incident, not downstream
$eq3 EQ3(J1,M1) ..	SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( J1+1, R1 ) ) =l= CARD(M1) -  CARD(M1) * ( D( J1, M1 ) - D( J1+1, M1 ) );
**$eq3 EQ3(J1,M1) ..	D( J1-1, M1+1 ) =l= CARD(M1) +  CARD(M1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
***             if j1,m1 is a boundary in time (-, earlier) at section j1, the sum of all D's upstream from j1 at section time M1-1 must be <= 0
***             The point of this is to ensure that congestion only grows upstream from the head of the incident, not downstream
$eq3 EQ3b(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), D( K1, M1-1 ) ) =l= CARD(J1) -  CARD(J1) * ( D( J1, M1 ) - D( J1, M1-1 ) );
**$eq3 EQ3b(J1,M1) ..	D( J1+1, M1-1 ) =l= CARD(J1) +  CARD(J1) * ( D( J1, M1 ) - D( J1, M1-1 ) );
***             if 
***             the sum over all cells upstream and later than the target cell must be zero if the target cell is a boundary cell in space(-) and time(+)
***             We tweak this to require that all sections at time M1+1 and all times at section J1-1 are non-incident as well
$eq4 EQ4(J1,M1) ..	SUM( K1, SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq4                  =l= (2+CARD(M1)+CARD(J1))*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) )
$eq4                       - CARD(M1) * CARD(J1) * (SUM(R1,1-D(J1-1,R1))+SUM(K1,1-D(K1,M1+1)));
* $eq4 EQ4(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
* $eq4                  =l= (2+CARD(M1)+CARD(J1))*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) )
* $eq4                       - CARD(M1) * CARD(J1) * (SUM(R1,1-D(J1-1,R1))+SUM(K1,1-D(K1,M1+1)));
***             the sum over all cells downstream and later than the target cell must be zero if the target cell is a boundary cell in space(+) and time(+)
$eq5 EQ5(J1,M1) ..	SUM( K1\$(ORD( K1 ) > ORD( J1 ) ), SUM( R1\$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq5                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) );
***             the sum over all cells downstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(+) and time(-)
$eq6 EQ6(J1,M1) ..	SUM( K1\$(ORD( K1 ) > ORD( J1 ) ), SUM( R1\$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq6                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) );
***             the sum over all cells upstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(-) and time(-)
***             We tweak this to require that all sections at section J1-1 are non-incident as well
$eq7 EQ7(J1,M1) ..	SUM( K1\$(ORD( K1 ) < ORD( J1 ) ), SUM( R1\$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
$eq7                  =l= (2+CARD(M1))*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) )
$eq7                       - CARD(M1) * CARD(J1) * (SUM(R1,1-D(J1-1,R1)));
** SHOCKWAVE CONSTRAINT
** Loading wave
$eq8 EQ8(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) > ($shockdir)*(PM(J1)+$MAX_LOAD_SHOCK_DIST)), D(K1,M1+1) ) =l= CARD(M1) - CARD(M1)*( D(J1,M1) - D(J1-1,M1) );
** Clearing wave
$eq8b EQ8b(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) < ($shockdir)*(PM(J1)-$MAX_CLEAR_SHOCK_DIST)), D(K1,M1-1) ) =l= CARD(M1) - CARD(M1)*( D(J1+1,M1) - D(J1,M1) );
TOTDELAY ..	Y=E=SUM( J1, SUM( M1, L( J1 ) / V(J1,M1) * F( J1, M1 ) * D(J1,M1) ) );
AVGDELAY ..	A=E=SUM( J1, SUM( M1, L( J1 ) / AV(J1,M1) * AF( J1, M1 ) * D(J1,M1) ) );
NETDELAY ..	N=E=Y-A;
*FORCEEQ(J1,M1) .. D( J1, M1 ) =G= FORCE( J1, M1 );
};
    if ( $self->force ) {
	foreach my $k ( keys %{$self->force} ) {
	    my $v = $self->force->{$k};
	    my ( $j, $m ) = split(/:/, $k );
	    $of << "FORCE_S$j"."_$m .. D( 'S$j', '$m' ) =e= $v;\n";
	}
    }
    
    $of << qq{
MODEL BASE / ALL /;

*** Use the cplex.opt options file---should contain probe(3) to speed solution!
BASE.OptFile=1;

SOLVE BASE USING MIP MINIMIZING Z;
DISPLAY D.l;
};
    
    $of->close;
    
    print "(done)\n";
    
    # # Print data
    # printf "    ";
    # for ( my $j = $J; $j >= 0; --$j )
    # {
    # 	printf " %2.2f", $stationdata->[$j]->{abs_pm}
    # }
    # printf "\n";
    # printf "    ";
    # for ( my $j = $J; $j >= 0; --$j )
    # {
    # 	printf " %2.2d", $j;
    # }
    # printf "\n";
    
    # for ( my $m = 0; $m < $M; ++$m )
    # {
    # 	printf "%2.2d: ", $m;
    # 	for ( my $j = $J; $j >= 0; --$j )
    # 	{
    # 	    my $std = $stationdata->[$j];
    # 	    my $facilkey = join( ":", $std->{fwy}, $std->{dir} );
    # 	    if ( $m==$prewindow/5 && $data->{$i}->{$facilkey}->{nearest} == $std )
    # 	    {
    # 		printf " %1s%1s", "X"," ";
    # 	    }
    # 	    else
    # 	    {
    # 		printf " %1s%1s", ($cell->[$j]->[$m]->{p_j_m}<0.5?"|":$cell->[$j]->[$m]->{p_j_m}>0.5?"/":" ")," ";
    # 	    }
    # 	}
    # 	printf "\n";
    # }
}

sub solve_program {
    my ( $self ) = @_;

    # OK, now solve it.
    print "SYNCING OVER...";
#    my $resf = io( "/usr/local/src/lp_solve_5.5/lp_solve/lp_solve -presolve -wmps $mpsname < $self->fname|" );

    my $gf = $self->gamsfile;
    my $gu = $self->gams_user;
    my $gh = $self->gams_host;
    
    print "FNAME: $gf\n";
    print "rsync -avz $gf $gu\@$gh:tmcpe/work\n";
    system( "rsync -avz $gf $gu\@$gh:tmcpe/work" );
    
    print "SOLVING...";
    my $RESLIM="";
    $RESLIM = join( " = ", "RESLIM", $self->reslim ) if $self->reslim;
    print "ssh $gu\@$gh 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $gf $RESLIM'";
    system( "ssh $gu\@$gh 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $gf $RESLIM'" );
    print "done\n";
    
    print "SYNCING BACK...".$self->lstfile;

    system( "rsync -avz $gu\@$gh:tmcpe/work/".$self->lstfile." ." );
    
    print "DONE\nPROCESSING...";
}

sub parse_results {
    my ( $self ) = @_;

    # Now read and parse the results returned from GAMS
    my $resf = io( $self->lstfile );
    my $found = 0;
    my $error = 0;

    my $cell;
    my $z;
    my $tot_delay;
    my $avg_delay;
    my $net_delay;

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
	    die "CONSULT ".$self->lstfile." for details";
	};
	
	/^----\s+VAR Z\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $z = $1;
	    $z = 0 if $z eq '.';
	};
	/^----\s+VAR Y\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $tot_delay = $1;
	    $tot_delay = 0 if $tot_delay eq '.';
	};
	/^----\s+VAR N\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $net_delay = $1;
	    $net_delay = 0 if $net_delay eq '.';
	};
	/^----\s+VAR A\s+[^\s]+\s+(-?[\d.]+)\s+.*/ && do
	{
	    $avg_delay = $1;
	    $avg_delay = 0 if $avg_delay eq '.';
	};
      
	/^----\s+VAR D/ && do
	{
	    $found = 1;
	    next LINE;
	};
	/^\*\*\*\* REPORT SUMMARY\s*([^\s].*)/ && do
	{
	    $found = 0;
	    next LINE;
	};
	( /.*(\d+)\s+(NONOPT)/ || /.*(\d+)\s+(INFEASIBLE)/ || /.*(\d+)\s+(UNBOUNDED)/ ) && do
        {
	    if ( ($1+0) > 0 ) {
		$self->bad_solution( "Failed to find a solution: $1 $2 rows" );
	    }
	};
	/RESOURCE INTERRUPT/ && do
	{
	    $self->bad_solution( $_ );
	};
	next LINE if not $found;
	
	/^S\s*(\d+)\s*\.\s*(\d+)\s+(.*)/ && do 
	{
	    # got soln
	    my $var = join( "_", "d", $1, $2 );
	    my ($nada, $val ) = split( /\s+/, $3 );
	    $val = 0 if ( $val eq '.' || $val != 1 );
	    $cell->[$1]->[$2]->{inc} = $val;
	    print "INC: ($1,$2) = $val\n";
	};
    }
    print STDERR "done\n";

    $self->tot_delay( $tot_delay );
    $self->net_delay( $net_delay );
    $self->avg_delay( $avg_delay );

    $self->cell( $cell );
}

sub write_to_db {
    my ( $self, $overwrite ) = @_;

    my $i = $self->cad;
    my $fwy = $self->facil;
    my $dir = $self->dir;
    my $cell = $self->cell;

    my $facilkey = join( ":", $fwy, $dir );

    # This gives us the FacilitySection associated with the incident location on this facility
    my $loc;
    eval { 
	my @locs = $self->tbmap_db->resultset( 'VdsView' )->search( {id => $self->vdsid} );
	$loc = shift @locs;
    };
    croak $@ if $@;
    croak "BAD VDSID ".$self->vdsid if not $loc;

    my $data = $self->data;

    my $dirscale = 1;
    $dirscale = -1 if ( $self->dir eq 'S' || $self->dir eq 'E' );

    my $ia;
    my $ifa;
    eval {
	# search for and delete all existing analyses
	my @existing = $self->tmcpe_db->resultset( 'IncidentImpactAnalysis' )->search(
	    {   incident_id => $self->incid });
	foreach my $ex (@existing) {
	    my @related = $ex->search_related( 'incident_facility_impact_analyses' );
	    foreach my $fia ( @related ) {
		my @irel = $fia->search_related('analyzed_sections');
		foreach my $as ( @irel ) {
		    $as->delete_related( 'incident_section_datas' );
		}
		$fia->delete_related('analyzed_sections');
		$fia->delete;
	    }
	    $ex->delete;	    
	}

	croak {msg => join(":", "BAD SOLUTION: ", $self->bad_solution ) } if $self->bad_solution;

	$ia = $self->tmcpe_db->resultset( 'IncidentImpactAnalysis' )->create(
	    {
		analysis_name => "Default",
		incident_id => $self->incid
	    });
	$ifa = $ia->create_related( 'incident_facility_impact_analyses',
				    {
					start_time => time2str( "%D %T", $self->calcstart ),
					end_time => time2str( "%D %T", $self->calcend ),
					band => $self->band,
					location_id => $loc->id,
					total_delay => $self->tot_delay,
					net_delay => $self->net_delay,
					avg_delay => $self->avg_delay,
				    } );
	$ifa->update;
    };
    if ( $@ ) {
    	warn $@->{msg};
	croak $@->{msg} ;
	exit 1;
    }
    
    # now shove the station data in there...
    my @stations = sort { $dirscale*$a->{abs_pm} cmp $dirscale*$b->{abs_pm} } values %{$data->{$i}->{$facilkey}->{stations}};

    my $J = @stations;
#    $J--;
    my $j = $J;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$self->data->{$i}->{$facilkey}->{stations}};

    my $cnt = 0;
    foreach my $station ( @stations ) {
	my $as;
	eval { $as = $ifa->create_related( 'analyzed_sections', { section_id=> $station->{vds}->id } ); };
	croak $@->{msg} if $@;

	printf STDERR "CREATING ". $station->{vds}->id . ":\n";
	my $m = 0;
	foreach my $secdat ( sort { $a->{timeofday} cmp $b->{timeofday} } @{$station->{data}} ) {
	    my $at;
	    eval { 
		my $tmcpedelay = 0;
		if ( (defined $secdat->{incspd} && $secdat->{incspd} > 0) && (defined $secdat->{avg_spd} && $secdat->{avg_spd} > 0) ) {
		    $tmcpedelay = $secdat->{incflw} / $secdat->{incspd} * $station->{seglen} - 
		    $secdat->{avg_flw} / $secdat->{avg_spd} * $station->{seglen};
		}
		my $stnidx = $self->stationmap->{$station->{vds}->id};
		my $iflag = defined $self->cell->[$stnidx][$m]->{inc} ? $self->cell->[$stnidx][$m]->{inc} + 0 : 0;
		printf STDERR "\t* ".join( ' ', '(',$cnt,$m,') -> [', $J-$cnt, $m, ']', $secdat->{date}, $secdat->{timeofday}, $iflag ) . "\n";
		$at = $as->create_related( 'incident_section_datas', 
					   {
					       fivemin => join( ' ', $secdat->{date}, $secdat->{timeofday} ),
					       vol => $secdat->{incflw},
					       spd => $secdat->{incspd},
					       occ => $secdat->{incocc},
					       days_in_avg => $secdat->{days_in_avg},
					       pct_obs_avg => $secdat->{avg_pctobs},
					       vol_avg => $secdat->{avg_flw},
					       spd_avg => $secdat->{avg_spd},
					       spd_std => $secdat->{stddev_spd},
					       occ_avg => $secdat->{avg_occ},
					       p_j_m => $secdat->{p_j_m},
					       
					       incident_flag => $iflag,
					       tmcpe_delay => $tmcpedelay * $iflag,
					       #d12_delay => ,
					   } );
	    };
	    if ( $@ ) {
		croak $@->{msg};
	    }
	    $m++;
	}
	$cnt++;
    }
}

sub write_json {
    my ( $self, $outdir ) = @_;

    my $i = $self->cad;
    my $fwy = $self->facil;
    my $dir = $self->dir;
    my $cell = $self->cell;

    my $facilkey = join( ":", $fwy, $dir );

    my $J = keys %{$self->data->{$i}->{$facilkey}->{stations}};
    $J--;  # crindt: FIXME: hack
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$self->data->{$i}->{$facilkey}->{stations}};

    my $mindate = $self->mindate;
    $mindate =~ s|-|/|g;

    my $mintimeofday = $self->mintimeofday;

    my @calcdur = Delta_DHMS( Time_to_Date( $self->calcstart ), Time_to_Date( $self->calcend ) );

    my $opts = {
	band => $self->band,
	mindate => $mindate,  # NOTE: swaps 2007-01-01 for 2007/01/01
	mintimeofday => $mintimeofday,
	mintimestamp => $mindate." ".$mintimeofday,
	prewindow => $self->prewindow,
	postwindow => ($calcdur[1]*60+$calcdur[2]), #$postwindow, # postwindow is time from incident onset to end of calcs
	fwy => join( '-', $fwy, $dir ),
	cad => $i,
	tot_delay => $self->tot_delay,
	avg_delay => $self->avg_delay,
	net_delay => $self->net_delay
    };

    my $segments = [
	map { 
	    my $pm1 = $self->stationdata->[$_+1]->{abs_pm};
	    my $pm2 = $self->stationdata->[$_]->{abs_pm};
	    my $pm3 = $self->stationdata->[$_-1]->{abs_pm};
	    
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
    my $j = $J;
    foreach my $st ( sort { $self->data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $self->data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $self->data->{$i}->{$facilkey}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    my $d = $self->data->{$i}->{$facilkey}->{stations}->{$st}->{data}->[$m];
	    my $ddd = $d->{incspd};
	    $incspd->[$m][$cnt] = $d->{incspd}+0;
	    $stdspd->[$m][$cnt] = $d->{stddev_spd}+0;
	    $avgspd->[$m][$cnt] = $d->{avg_spd}+0;
	    $pjm->[$m][$cnt] = $d->{p_j_m}+0;
	    $inc->[$m][$cnt] = 0; #$d->{inc}+0;
	    $inc->[$m][$cnt] = $self->cell->[$m][$cnt]->{inc}+0 if defined $self->cell->[$m][$cnt]->{inc};  #$d->{inc}+0;
	    --$j;
	}
	$cnt++
    }

    my $events = {};

    my @actlog = $self->actlog_db->resultset( 'Al' )->search(
	{ cad => $self->cad },
	{ order_by => 'ts asc' }
	);

    my $fn = "$outdir/$i-$fwy-$dir.json";
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
			band => $self->band,
			actlog => [ @dhash ]
		      }, 
		   { pretty => 1 } );
    print STDERR "Wrote to $fn\n";
}

sub compute_delay {
    my ( $self ) = @_;

    croak "No incident specified to analyze" if ( !$self->cad );
    croak "No facility specified to analyze for incident $self->cad" if ( !$self->facil );
    croak "No direction specified for facility $self->facil to analyze for incident $self->cad" if ( !$self->dir );
    croak "No postmile specified for $self->dir-$self->facil to analyze for incident $self->cad" if ( !$self->pm );

    my @avds = $self->get_affected_vds( $self->facil, $self->dir, $self->pm );

	$self->get_pems_data( @avds );
	
    if ( !$self->useexisting ) {
	$self->write_gams_program( );
	
	$self->solve_program( );
    }

    $self->parse_results( );
}

1;
