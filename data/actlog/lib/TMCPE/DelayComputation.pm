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
     scalar => [ qw/ data cell stationdata timemap / ],
     scalar => [ { -default_ctor => sub { my $self = shift; return $self->cad."-".$self->facil."=".$self->dir.".gms" } }, 
		 'gamsfile' ],
     scalar => [ { -default_ctor => sub { my $self = shift; return $self->cad."-".$self->facil."=".$self->dir.".lst" } }, 
		 'lstfile' ],
     scalar => [ { -default => 0 }, 'debug' ],
     scalar => [ { -default => 1 }, 'compute_vds_upstream_fallback' ],
     scalar => [ { -default => 10 }, 'vds_upstream_fallback' ],
     scalar => [ { -default => 1 }, 'vds_downstream_fudge' ],
     scalar => [ { -default => '192.168.0.3' }, 'gams_host' ],
     scalar => [ { -default => 'crindt' }, 'gams_user' ],
     scalar => [ { -default => 10 }, 'prewindow' ],
     scalar => [ { -default => 120 }, 'postwindow' ],
     scalar => [ { -default => 20 }, 'min_avg_days' ],
     scalar => [ { -default => 25 }, 'min_avg_pct' ],
     scalar => [ { -default => 5 }, 'min_obs_pct' ],
     scalar => [ { -default => 0.5 }, 'unknown_evidence_value' ],
     scalar => [ { -default => 1.0 }, 'band' ],
     scalar => [ { -default => 1 }, 'objective' ],
     scalar => [ { -default => 0.0 }, 'bias' ],
     scalar => [ { -default => 0 }, 'reprocess_existing' ],
     scalar => [ { -default => 1 }, 'use_eq1' ],
     scalar => [ { -default => 1 }, 'use_eq2' ],
     scalar => [ { -default => 1 }, 'use_eq3' ],
     scalar => [ { -default => 1 }, 'use_eq4567' ],
     scalar => [ { -default => 0 }, 'use_eq8' ],
     scalar => [ { -default => 0 }, 'use_eq8b' ],
     scalar => [ { -default => 5 }, 'dt' ],  # number of minutes in a time step
     scalar => [ { -default => 1 }, 'weight_for_distance' ],
     scalar => [ { -default => 20 }, 'limit_loading_shockwave' ],  # 15 mi/hr
     scalar => [ { -default => 60 }, 'limit_clearing_shockwave' ],  # 15 mi/hr
     scalar => [ qw/ boundary_intersects_within / ], # =[dx,dt]: require incident boundary to include at least 
		                                    # one cell within dx miles of reported location AND
		                                    #          within dt minutes of log start
     scalar => [ { -default => 0 }, 'limit_to_start_region' ],
     scalar => [ { -default => {} }, 'force' ],
     scalar => [ qw/ logstart logend / ],
     scalar => [ qw/ calcstart calcend / ],
     scalar => [ qw/ mintimeofday mindate / ],
     scalar => [ qw/ bad_solution tot_delay avg_delay net_delay / ],
     scalar => [ { -default => 'tmcpe_test' }, 'tmcpe_db_name' ],
     scalar => [ { -default => 'localhost' }, 'tmcpe_db_host' ],
     scalar => [ { -default => 'postgres' }, 'tmcpe_db_user' ],
     scalar => [ { -default => '' }, 'tmcpe_db_password' ],
     scalar => [ { -default => 1 }, 'use_pems_cache' ],
     scalar => [ { -default => 500000000 }, 'gams_iterlim' ],
     scalar => [ { -default => 0 }, 'gams_limrow' ],
     scalar => [ { -default => 300 }, 'gams_reslim' ],  # 5 minutes
     scalar => [ { -default => '0.1' }, "cplex_optcr" ],
     scalar => [ { -default => '2' }, "cplex_threads" ],
     scalar => [ { -default => '3' }, "cplex_probe" ],
     scalar => [ { -default => '0' }, "cplex_ppriind" ],
     scalar => [ { -default => '0' }, "cplex_mip_emphasis" ],
     scalar => [ { -default => '0' }, "cplex_polishafterintsol" ],
     scalar => [ { -default => '1' }, "cplex_nodesel" ],
     scalar => [ { -default => '0' }, "cplex_varsel" ],
#     scalar => [ { -type => 'Parse::RecDescent',
#		   -default_ctor => sub { return TMCPE::ActivityLog::LocationParser::create_parser() },
#		 }, 'parser' ],
     new    => [ qw/ new / ]
    ];

sub get_gams_file {
     my $self = shift; 
     my $fn = $self->cad."-".$self->facil."=".$self->dir.".gms";
     $self->gamsfile( $fn );
     return $fn;
}

sub get_lst_file {
    my $self = shift; 
    my $fn = $self->cad."-".$self->facil."=".$self->dir.".lst";
    $self->lstfile( $fn );
    return $fn;
}

sub get_affected_vds {
    my ( $self ) = @_;
    
    my $vdsrs;
    my $maxdist = $self->vds_upstream_fallback;
    if ( $self->compute_vds_upstream_fallback ) {
	my $maxdur = ($self->calcend - $self->calcstart - $self->prewindow*60 - $self->postwindow*60)/2.0;
	my $md = ($maxdur/3600.0) * $self->limit_loading_shockwave;
	$maxdist = $md if ($md < $maxdist);
    }

    $_ = $self->dir;
    if ( /N/ || /E/ ) {
	# northbound and eastbound facilities increase downstream, so
	# we want to query between [ incloc - (max dist) ] and incloc
	$vdsrs = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	    {
		freeway_id => $self->facil,
		freeway_dir => $self->dir,
		type_id => 'ML',
		abs_pm => {
		    -between => [ $self->pm - $maxdist,
				  $self->pm + $self->vds_downstream_fudge
			]
		}
	    },
	    { order_by => 'abs_pm desc' }
	    );
    } else {
	# southbound and westbound facilities decrease downstream, so
	# we want to query between incloc and [ incloc + (max dist) ]
	$vdsrs = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	    {
		freeway_id => $self->facil,
		freeway_dir => $self->dir,
		type_id => 'ML',
		abs_pm => {
		    -between => [ $self->pm - $self->vds_downstream_fudge,
				  $self->pm + $maxdist
			]
		}
	    },
	    { order_by => 'abs_pm asc' }
	    );
    }

    return $vdsrs->all
    
}

# routine to read data from an existing GAMS program file
sub get_gams_data {
    my ( $self, @avds ) = @_;

    my $if = io ( $self->get_gams_file );

    my $inseclen=0;
    my $inpjm=0;
    my $inv=0;
    my $inav=0;
    my $inf=0;
    my $inaf=0;
    my $delimcount;
    my $insets=0;
    my $inparams=0;
    my ( $mstart, $mend );
    my ( $jstart, $jend );
    my $pjmcnt;
    my $vcnt;
    my $avcnt;
    my $fcnt;
    my $afcnt;
    my $seccnt;
    my $facilkey = join( ":", $self->facil, $self->dir );
    my $i = $self->cad;
    my $data;

    foreach my $vds ( @avds ) {
	my $vdsid = $vds->id;
	my $facilkey = join( ":", $vds->freeway_id, $vds->freeway_dir );
	
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{vds} = $vds;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{abs_pm} = $vds->abs_pm;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{fwy} = $vds->freeway_id;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{dir} = $vds->freeway_dir;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{name} = $vds->name;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{seglen} = $vds->length;
    };

    # OK, we need to determine the time periods for which we expect
    # data: Basically, it's every five-minute period between calcstart
    # and calcend inclusive.
    my $calcstart = $self->calcstart;
    my $calcend = $self->calcend;
    my $cs5 = ($calcstart % 300) ? POSIX::floor( $calcstart/300 ) * 300 : $calcstart;
    my $ce5 = ($calcend % 300) ? POSIX::ceil( $calcend/300 ) * 300 : $calcend;

    my @times;
    for ( my $ct = $cs5; $ct <= $ce5; $ct += 300 ) {
	push @times, time2str( "%D %T", $ct );
    }


    my $secs;

    my @ms;

  LINE:
    while( my $line = $if->getline() ) {
	$_ = $line;
	if ( $inparams ) {
	    if ( $inseclen ) {
		# read sections
		/^\s*\/\s*$/ && do { if ( ++$delimcount > 1 ) { 
		    $inseclen = 0 }; 
		};
		/^\*\s+S(\d+)\s=\s(\d+)\s(.*?)\s*$/ && do {
		    my ( $secnum, $vdsid, $vdsname ) = ($1,$2,$3);
		    $seccnt++;
		    # store seclens here
		    $secs->{$secnum} = { vdsid => $vdsid, vdsname => $vdsname, secnum => $secnum };
		}
	    } elsif ( $inpjm ) {
		# read evidence
		if ( $pjmcnt < 0 ) {  # the headers
		    @ms = grep { $_ ne "" } split( /\s+/, $_ );
		} else {
		    my ( $sec, @pjm ) = grep { $_ ne "" } split( /\s+/, $_ );

		    # store evidence here
		    my $vdsid = $secs->{$pjmcnt}->{vdsid};
		    croak "BAD VDSID IN PJM READ" if not $vdsid;
		    for my $m (0..$#pjm) {
			# do the date/time here too
			my ($date,$time) = split(/\s+/, $times[$m]);			
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{date} = $date;
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{timeofday} = $time;
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{days_in_avg} = $pjm[$m] == $self->unknown_evidence_value ? 0 : 30;
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{avg_pctobs} = $pjm[$m] == $self->unknown_evidence_value ? 0 : 100;
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{p_j_m} = $pjm[$m];
		    }

		}
		$pjmcnt++;
		if ( $pjmcnt > $jend ) {
		    # we've read all the evidence
		    $inpjm = 0;
		}
	    } elsif ( $inv ) {
		# read speeds
		if ( $vcnt < 0 ) {  # the headers
		    @ms = grep { $_ ne "" } split( /\s+/, $_ );
		} else {
		    my ( $sec, @v ) = grep { $_ ne "" } split( /\s+/, $_ );

		    # store speeds here
		    my $vdsid = $secs->{$vcnt}->{vdsid};
		    croak "BAD VDSID IN V READ" if not $vdsid;
		    for my $m (0..$#v) {
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{incspd} = $v[$m];
		    }
		}
		$vcnt++;
		if ( $vcnt > $jend ) {
		    # we've read all the evidence
		    $inv = 0;
		}
	    } elsif ( $inav ) {
		# read avg speeds
		if ( $avcnt < 0 ) {  # the headers
		    @ms = grep { $_ ne "" } split( /\s+/, $_ );
		} else {
		    my ( $sec, @av ) = grep { $_ ne "" } split( /\s+/, $_ );

		    # store avg speeds here
		    my $vdsid = $secs->{$avcnt}->{vdsid};
		    croak "BAD VDSID IN AV READ" if not $vdsid;
		    for my $m (0..$#av) {
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{avg_spd} = $av[$m];
		    }
		}
		$avcnt++;
		if ( $avcnt > $jend ) {
		    # we've read all the evidence
		    $inav = 0;
		}
	    } elsif ( $inf ) {
		# read flows
		if ( $fcnt < 0 ) {  # the headers
		    @ms = grep { $_ ne "" } split( /\s+/, $_ );
		} else {
		    my ( $sec, @f ) = grep { $_ ne "" } split( /\s+/, $_ );

		    # store flow here
		    my $vdsid = $secs->{$fcnt}->{vdsid};
		    croak "BAD VDSID IN F READ" if not $vdsid;
		    for my $m (0..$#f) {
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{incflw} = $f[$m];
		    }
		}
		$fcnt++;
		if ( $fcnt > $jend ) {
		    # we've read all the evidence
		    $inf = 0;
		}
	    } elsif ( $inaf ) {
		# read avg speeds
		if ( $afcnt < 0 ) {  # the headers
		    @ms = grep { $_ ne "" } split( /\s+/, $_ );
		} else {
		    my ( $sec, @af ) = grep { $_ ne "" } split( /\s+/, $_ );

		    # store avg flow here
		    my $vdsid = $secs->{$afcnt}->{vdsid};
		    croak "BAD VDSID IN AF READ" if not $vdsid;
		    for my $m (0..$#af) {
			$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}->[$m]->{avg_flw} = $af[$m];
		    }
		}
		$afcnt++;
		if ( $afcnt > $jend ) {
		    # we've read all the evidence
		    $inaf = 0;
		}
	    }


	    /\s+L\(\s*J1\s*\)\ssection\slength/ && do { $inseclen = 1; $delimcount = 0; $seccnt = 0; };
	    /\s+TABLE\s+P\(\s*J1\s*,\s*M1\s*\)\sEvidence/ && do { $inpjm = 1; $pjmcnt=-1; };
	    /\s+TABLE\s+V\(\s*J1\s*,\s*M1\s*\)/ && do { $inv = 1; $vcnt = -1 };
	    /\s+TABLE\s+AV\(\s*J1\s*,\s*M1\s*\)/ && do { $inav = 1; $avcnt = -1 };
	    /\s+TABLE\s+F\(\s*J1\s*,\s*M1\s*\)/ && do { $inf = 1; $fcnt = -1 };
	    /\s+TABLE\s+AF\(\s*J1\s*,\s*M1\s*\)/ && do { $inaf = 1; $afcnt = -1 };
	}


	/^\s*SETS/ && do { 
	    $insets = 1; 
	};
	if ( $insets ) {
	    /\s*J1\s*Sections\s*\/S(\d+)\*S(\d+)\// && do {
		($jstart, $jend) = ($1,$2);
	    };
	    /\s*M1\s*Time\sSteps\s*\/(\d+)\*(\d+)\// && do {
		($mstart, $mend) = ($1,$2);
	    };

	}

	/\s*PARAMETERS/ && do { 
	    $insets = 0; $inparams = 1 
	};
    }
    $self->data( $data );


    my $J = keys %{$data->{$i}->{$facilkey}->{stations}};
    $J -= 1;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$data->{$i}->{$facilkey}->{stations}};

    my $j = $J;

    $self->stationdata( [] );
    $self->timemap( {} );

    foreach my $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    $self->stationdata->[$j] = $data->{$i}->{$facilkey}->{stations}->{$st};
	}
	--$j;
    }
}

sub get_pems_data {
    my ( $self, @avds ) = @_;

#    @tt = Localtime(postwindow,0);


    # run the pems 5min query to get relevant results
    my $select_query < io("./select-data.sql");
    
    my $dbh = DBI->connect('dbi:Pg:database=spatialvds;host=localhost',
			   'VDSUSER' );
    

    my $data;

    my $i = $self->cad;


    # OK, we need to determine the time periods for which we expect
    # data: Basically, it's every five-minute period between calcstart
    # and calcend inclusive.
    my $calcstart = $self->calcstart;
    my $calcend = $self->calcend;
    my $cs5 = ($calcstart % 300) ? POSIX::floor( $calcstart/300 ) * 300 : $calcstart;
    my $ce5 = ($calcend % 300) ? POSIX::ceil( $calcend/300 ) * 300 : $calcend;

    my @times;
    for ( my $ct = $cs5; $ct <= $ce5; $ct += 300 ) {
	push @times, time2str( "%D %T", $ct );
    }
	
    my $ss = time2str( "%D %T", $cs5 );
    my $es = time2str( "%D %T", $ce5 );

    print STDERR "ANALYZED TIMES BETWEEN $ss AND $es ARE:\n" if $self->debug;
    map { print STDERR "\t$_\n"; } @times if $self->debug;

    foreach my $vds ( @avds ) {
	my $vdsid = $vds->id;
	my $facilkey = join( ":", $vds->freeway_id, $vds->freeway_dir );
	
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{vds} = $vds;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{abs_pm} = $vds->abs_pm;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{fwy} = $vds->freeway_id;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{dir} = $vds->freeway_dir;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{name} = $vds->name;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{seglen} = $vds->length;
	
	#    my $select_data = $dbh->prepare( $select_query );
	#    my $select_data = "select * from tmcpe_data where vdsid=1203021 AND stamp between '2010-01-05 05:30:00' AND '2010-01-05 06:30:00' AND avg_samples IS NULL;"

	# See if we need to generate some averages
	my $qq = { 
		vdsid => $vds->id,
		stamp => { -between => [$ss,$es] },
	};
	# if we're using the pems cache, we only need to compute
	# averages for rows that don't already have averages computed
	# (if this is the case, then the days_in_avg record will be
	# null)
	$qq->{days_in_avg} = undef if ( $self->use_pems_cache );

	my @bad_rows = $self->vds_db->resultset( 'TmcpeData' )->search(
	    $qq,
	    {
		order_by => 'stamp asc'
	    });

	# oops, no avg data for some rows, let's compute it now.
	if ( @bad_rows ) {
	    print STDERR join("",
			      "COMPUTING MISSING ANNUAL AVERAGES FOR ",
			      $vds->name,
			      ( $self->debug ? ":\n\t".join("\n\t", map {$_->stamp} @bad_rows ) : ":" ),
			      "\n");
	    foreach my $br ( @bad_rows ) {
		print STDERR "\tCREATING FOR ".$br->stamp."...";
		my @created_rows = $self->vds_db->resultset( 'TmcpeDataCreate' ) ->search(
		    {
			vdsid => $vds->id,
#			stamp => { -in => [ map {$_->stamp} @bad_rows ] }
			stamp => $br->stamp
		    });
		
		# created_rows will contain the data we want to push into 'Pems5minAnnualAvg'
		if ( @created_rows ) {

		    croak "TOO MANY ROWS RETURNED WHILE CREATING AVERAGES!!!" if ( @created_rows > 1 );

		    # see if it already exists
		    my @existing_rows = $self->vds_db->resultset( 'Pems5minAnnualAvg' )->search(
			{
			    vdsid => $vds->id,
			    stamp => $br->stamp
			});

		    croak "TOO MANY EXISTING ROWS RETURNED WHILE CREATING AVERAGES!!!" if ( @existing_rows > 1 );

		    if ( @existing_rows ) {
			# just update
			my $er = shift @existing_rows;
			map { my $cr = $_; map { $er->set_column( $_ => $cr->get_column( $_ ) ) } $er->result_source->columns; } @created_rows;
			$er->update;

		    } else {
			# create a new one
			$self->vds_db->populate( 'Pems5minAnnualAvg',
						 [ [ $created_rows[0]->result_source->columns ],
						   map { my $row = $_; [ map { $row->get_column( $_ ); } $row->result_source->columns ] } @created_rows
						 ]);
		    }
		}
		print STDERR "done\n";
	    }
	} else {
	    print STDERR "ALL DATA IS CACHED\n";
	}

	# OK, now grab the data...
	print STDERR "GRABBING ALL DATA...";
	my @rows = $self->vds_db->resultset( 'TmcpeData' )->search(
	    { 
		vdsid => $vds->id,
		stamp => { -between => [$ss,$es] },
	    },
	    {
		order_by => 'stamp asc'
	    });
	print STDERR "DONE";

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
		    p_j_m => $self->unknown_evidence_value,
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
		my ($date,$time) = split(/\s+/, $row->stamp);
		
		my $pjm=$self->unknown_evidence_value;  # default to unknown
		if ( $row->days_in_avg >= $self->min_avg_days && $row->o_pct_obs >= $self->min_obs_pct ) 
		{
		    if ( $row->o_spd < ( $row->a_spd - $self->band * $row->sd_spd ) ) {
			$pjm = 0;
		    } else {
			$pjm = 1;
		    }
		}
		print STDERR join( " : ",
				   $vdsid,
				   $date,
				   $time,
				   $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name},
				   sprintf( "%5.0f", $row->a_vol * 12  )." vph",
				   sprintf( "%5.1f", $row->a_occ * 100 )."%",
				   sprintf( "%5.1f", $row->a_spd )." mph",
				   sprintf( "%5.1f", $row->o_spd )." mph",
				   $row->days_in_avg,
				   $row->o_pct_obs,
				   p_j_m => $pjm,
		    )."\n";

		# This is what we really need to fill!
		push @{$data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data}}, { 
		    date => $date,
		    timeofday => $time,
		    avg_spd => $row->a_spd,
		    stddev_spd => $row->sd_spd,
		    avg_pctobs => $row->a_pct_obs,   #
		    incspd => $row->o_spd,
		    incpctobs => $row->o_pct_obs,
		    incocc => $row->o_occ,
		    avg_occ => $row->a_occ,
		    avg_flw => $row->a_vol,
		    incflw => $row->o_vol,
		    p_j_m => $pjm,
		    days_in_avg => $row->days_in_avg,
		    incden => 0,  # inferred
		    shockspd => $row->a_spd   # (0 - a_flw)/(0-a_den) = -a_flw /-a_den = -a_flw / -( a_flw / a_spd ) = a_spd
		};
		
		############# END THIS SHOULD BE A SUB ##################
		
		my $st=$vdsid;
		
		$self->mintimeofday( $time ) if ( not defined( $self->mintimeofday ) );
		$self->mindate( $date ) if ( not defined( $self->mindate ) );
		
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
    $self->timemap( {} );

    foreach my $st ( sort { $data->{$i}->{$facilkey}->{stations}->{$a}->{abs_pm} <=> $data->{$i}->{$facilkey}->{stations}->{$b}->{abs_pm} } 
		     keys %{ $data->{$i}->{$facilkey}->{stations} } )
    {
	for ( my $m = 0; $m < $M; ++$m )    
	{
	    $self->stationdata->[$j] = $data->{$i}->{$facilkey}->{stations}->{$st};
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

    if ( $self->weight_for_distance ) { $self->objective( 1 ) }
    
    foreach my $iii (1..3)
    {
	if ( $self->objective != $iii ) {
	    $objective[$iii] = "*";
	} else {
	    $objective[$iii] = "";
	}
    }
    

    my $data = $self->data;
    my $i = $self->cad;

    my $facilkey = join( ":", $self->facil, $self->dir );

    my $of = io ( $self->get_gams_file );

    my $J = keys %{$data->{$i}->{$facilkey}->{stations}};
    $J -= 1;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$data->{$i}->{$facilkey}->{stations}};
    my $R = 1;
    my $RR = 2*$J*$M; # maximum number of upstream + time cells
#       my $mintime = $tmp->{data}->{timeofday};
    
    my $MM = $M - 1;

    my @stations = sort { $a->{abs_pm} <=> $b->{abs_pm} } ( values %{$data->{$i}->{$facilkey}->{stations}} );
    $_ = $self->dir;
    @stations = reverse @stations if ( /S/ || /W/ );

    # set up cell
    my $j = 0;
    my $m;
    my $d;
    $self->cell( [] );
    foreach my $st ( @stations )
    {
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
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
		    p_j_m => $self->unknown_evidence_value,
		    incden => 0,  # inferred
		    shockspd => 0
		};
	    } else {
		$self->cell->[$j]->[$m] = $d;
	    }
	}
	$j++;
    }

    print STDERR "WRITING PROGRAM $i to ".$self->get_gams_file."...";
    my $RESLIM="*";
    $RESLIM = join( " = ", "OPTIONS RESLIM", $self->gams_reslim ) if $self->gams_reslim;
    my $LIMROW = "*";
    $LIMROW = join( " = ", "OPTIONS LIMROW", $self->gams_limrow ) if $self->gams_limrow;
    
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

    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "*		S%s = %s %s\n", 
			$st->{vds}->id, 
			$st->{name} );
	$of << sprintf( "		S%s	%f\n", $j, $st->{abs_pm} );

	$j++;
    }
    $of << qq{
	    /
	    };

    
    $of << qq{
	L( J1 ) section length
	    /
};

    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "*		S%s = %s %s\n", 
			$j, $st->{vds}->id, 
			$st->{name} );
	$of << sprintf( "		S%s	%f\n", $j, $st->{seglen} );
	
	$j++;
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
    

    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
	    if ( not defined $self->cell->[$j]->[$m]->{p_j_m} ) {
		1;
	    }
	    my $pjm = $self->cell->[$j]->[$m]->{p_j_m};
	    $of << sprintf( " %5.1f", $pjm );
	}
	$of << "\n";
	$j++;
    }
    
    $of << qq{	TABLE V( J1, M1 ) 
};
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
	    my $ddd = $d->{incspd};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.1f", $ddd );
	}
	$of << "\n";
	$j++;
    }
    
    
    $of << qq{	TABLE AV( J1, M1 )
};
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
	    my $ddd = $d->{avg_spd};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.1f", $ddd );
	}
	$of << "\n";
	$j++;
    }
    
    $of << qq{	TABLE F( J1, M1 )
};
    
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
	    my $ddd = $d->{incflw};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.0f", $ddd );
	}
	$of << "\n";
	$j++;
    }
    
    
    $of << qq{	TABLE AF( J1, M1 )
};
    
    $of << sprintf( "     " );
    for ( $m = 0; $m < $M; ++$m )
    {
	$of << sprintf( " %5d", $m );
    }
    $of << "\n";
    
    $j = 0;
    foreach my $st ( @stations )
    {
	$of << sprintf( "%5s", sprintf( "S%d", $j ) );
	
	for ( $m = 0; $m < $M; ++$m )    
	{
	    $d = $st->{data}->[$m];
	    my $ddd = $d->{avg_flw};
	    $ddd = 0 if !$ddd;
	    $of << sprintf( " %5.0f", $ddd );
	}
	$of << "\n";
	$j++;
    }

    my $MAX_LOAD_SHOCK_DIST = $self->limit_loading_shockwave/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    my $MAX_CLEAR_SHOCK_DIST = $self->limit_clearing_shockwave/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    
    my ($BOUNDARY_DX, $BOUNDARY_DT) = split(/,/, $self->boundary_intersects_within );
    my $use_boundary_constraint = "*";
    if ( defined( $BOUNDARY_DX ) && defined( $BOUNDARY_DT ) ) {
	$use_boundary_constraint = "";
    }
    my $startlim = $self->limit_to_start_region ? "" : "*";
    
    
    my $shockdir=1;
    $_ = $self->dir;
    if ( /S/ || /W/ ) {
	$shockdir=-1;
    }

    my $incstart_index = $self->prewindow/5;
    my $incpm = $self->pm;
    my $dt = $self->dt;

    
    
    $of << qq{
VARIABLES
	Z		objective
	D(J1,M1)	incident state
	S(J1,M1)	start point
	Y		total incident delay
	A		average delay
	N		net delay

BINARY VARIABLE D
BINARY VARIABLE S

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
$use_boundary_constraint EQ9
TOTDELAY
AVGDELAY
NETDELAY
$startlim ONESTART
$startlim NOSTART_NOREGION
$startlim IFSTART_THEN_D
$startlim START_BOUNDARY
$startlim $use_boundary_constraint START_CONSTRAINT
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
$eq8 EQ8(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) < ($shockdir)*(PM(J1)-($shockdir)*$MAX_LOAD_SHOCK_DIST)), D(K1,M1+1) ) =l= CARD(M1) - CARD(M1)*( D(J1,M1) - D(J1-1,M1) );
** Clearing wave
$eq8b EQ8b(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) > ($shockdir)*(PM(J1)+($shockdir)*$MAX_CLEAR_SHOCK_DIST)), D(K1,M1-1) ) =l= CARD(M1) - CARD(M1)*( D(J1+1,M1) - D(J1,M1) );
** REQUIRE THAT IF THERE IS ANY BOUNDARY, IT MUST INCLUDE CELLS WITHIN A CERTAIN DISTANCE OF THE EXPECTED TIME-SPACE LOCATION OF THE DISRUPTION
$use_boundary_constraint EQ9 .. SUM( J1, SUM( M1, D(J1,M1) ) ) =l= CARD(M1) * CARD(J1) * SUM( K1\$(ABS(PM(K1)-$incpm)<=$BOUNDARY_DX), SUM( R1\$(ABS(ORD(R1)-$incstart_index)*$dt<$BOUNDARY_DT), D(K1,R1)));
TOTDELAY ..	Y=E=SUM( J1, SUM( M1, L( J1 ) / V(J1,M1) * F( J1, M1 ) * D(J1,M1) ) );
AVGDELAY ..	A=E=SUM( J1, SUM( M1, L( J1 ) / AV(J1,M1) * AF( J1, M1 ) * D(J1,M1) ) );
NETDELAY ..	N=E=Y-A;
$startlim ONESTART .. (SUM(J1,SUM(M1,S(J1,M1)))) =L= 1;
$startlim NOSTART_NOREGION .. SUM(J1,SUM(M1,D(J1,M1))) =L= CARD(M1)*CARD(J1)*(SUM(J1,SUM(M1,S(J1,M1))));
$startlim IFSTART_THEN_D(J1,M1) .. D(J1,M1) =G= S(J1,M1);
$startlim START_BOUNDARY(J1,M1) .. SUM( K1, D( K1, M1-1 ) ) + SUM( R1, D( J1 + 1, R1 ) ) 
$startlim                  =l= CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( S( J1, M1 ) );
** REQUIRE THAT IF THERE IS ANY BOUNDARY, IT MUST INCLUDE CELLS WITHIN A CERTAIN DISTANCE OF THE EXPECTED TIME-SPACE LOCATION OF THE DISRUPTION
$startlim $use_boundary_constraint START_CONSTRAINT .. SUM( J1, SUM( M1, S(J1,M1) ) ) =l= CARD(M1) * CARD(J1) * SUM( K1\$(ABS(PM(K1)-$incpm)<=$BOUNDARY_DX), SUM( R1\$(ABS(ORD(R1)-$incstart_index)*$dt<$BOUNDARY_DT), S(K1,R1)));
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

*** Write the options file
file opt cplex options file /cplex.opt/;
put opt;
};

    # write out the cplex options
    $self->cplex_threads;  # make sure the threads variable gets instantiated with the default
    foreach my $cplex_opt ( grep { /^cplex/ } keys %{$self} ) {
	my $optname = $cplex_opt;
	$optname =~ s/^cplex_//g;
	$of << "put '".$optname."   ".$self->{$cplex_opt}."'/;\n"
    }

    $of << "put 'logline   2'/;\n" if $self->debug;
    $of << "put 'mipdisplay   4'/;\n" if $self->debug;
    $of << "put 'mipinterval   1'/;\n" if $self->debug;
    $of << "put 'quality   1'/;\n" if $self->debug;
    $of << "put 'simdisplay   2'/;\n" if $self->debug;

    $of << qq{
putclose opt;

SOLVE BASE USING MIP MINIMIZING Z;
DISPLAY D.l;
$startlim DISPLAY S.l;
};
    
    $of->close;
    
    print "(done)\n";
}

sub solve_program {
    my ( $self ) = @_;

    # OK, now solve it.
    print "SYNCING OVER...";
#    my $resf = io( "/usr/local/src/lp_solve_5.5/lp_solve/lp_solve -presolve -wmps $mpsname < $self->fname|" );

    my $gf = $self->get_gams_file;
    my $gu = $self->gams_user;
    my $gh = $self->gams_host;
    
    print "FNAME: $gf\n";
    print "rsync -avz $gf $gu\@$gh:tmcpe/work\n";
    system( "rsync -avz $gf $gu\@$gh:tmcpe/work" );
    
    print "SOLVING...";
    my $RESLIM="";
    $RESLIM = join( " = ", "RESLIM", $self->gams_reslim ) if $self->gams_reslim;
    print "ssh $gu\@$gh 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $gf $RESLIM'";
    system( "ssh $gu\@$gh 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $gf $RESLIM'" );
    print "done\n";
    
    print "SYNCING BACK...".$self->get_lst_file;

    system( "rsync -avz $gu\@$gh:tmcpe/work/".$self->get_lst_file." ." );
    
    print "DONE\nPROCESSING...";
}

sub parse_results {
    my ( $self ) = @_;

    # Now read and parse the results returned from GAMS
    my $resf = io( $self->get_lst_file );
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
	    die "CONSULT ".$self->get_lst_file." for details";
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
      
	/^----\s+VAR S/ && do
	{
	    $found = 0;
	    next LINE;
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
	    print "INC: ($1,$2) = $val\n" if $self->debug;
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

    my @stations = sort { $a->{abs_pm} <=> $b->{abs_pm} } ( values %{$data->{$i}->{$facilkey}->{stations}} );
    $_ = $self->dir;
    @stations = reverse @stations if ( /S/ || /W/ );

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
    	warn ( ref $@ ? $@->{msg} : $@ );
    	croak ( ref $@ ? $@->{msg} : $@ );
    }
    
    # now shove the station data in there...
    my $J = @stations;
#    $J--;
    my $M = 0;
    map { my $sz = @{$_->{data}}; $M = $sz if $M < $sz; } values %{$self->data->{$i}->{$facilkey}->{stations}};

    my $j = 0;
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
		my $stnidx = $j;
		my $iflag = defined $self->cell->[$stnidx][$m]->{inc} ? $self->cell->[$stnidx][$m]->{inc} + 0 : 0;
		printf STDERR "\t* ".join( ' ', '(',$j,$m,')', $secdat->{date}, $secdat->{timeofday}, $iflag,
		    $secdat->{incspd}, $secdat->{avg_spd}) . "\n";
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
	$j++;
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
	    my $d = $self->st->{data}->[$m];
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

sub update_time_bounds() {
    my ( $self ) = @_;
    my @tt = Localtime(str2time($self->logstart));
    my $incstart = Mktime(@tt[0..5]);
    my $calcstart = Mktime(Add_Delta_DHMS(@tt[0..5],0,0,-$self->prewindow,0));
    $self->calcstart( $calcstart );
    @tt = Localtime(str2time($self->logend));
    my $incend   = Mktime(@tt[0..5]);
    my $calcend   = Mktime(Add_Delta_DHMS(@tt[0..5],0,0,$self->postwindow,0));
    $self->calcend( $calcend );
}

sub compute_delay {
    my ( $self ) = @_;

    croak "No incident specified to analyze" if ( !$self->cad );
    croak "No facility specified to analyze for incident $self->cad" if ( !$self->facil );
    croak "No direction specified for facility $self->facil to analyze for incident $self->cad" if ( !$self->dir );
    croak "No postmile specified for $self->dir-$self->facil to analyze for incident $self->cad" if ( !$self->pm );

    $self->update_time_bounds();

    my @avds = $self->get_affected_vds( $self->facil, $self->dir, $self->pm );
    
    if ( $self->reprocess_existing && 0 ) {
	# read old data from the gams program
	$self->get_gams_data( @avds );

    } else {
	$self->get_pems_data( @avds );
    }
	
    if ( !$self->reprocess_existing ) {
	$self->write_gams_program( );
	
	$self->solve_program( );
    }

    $self->parse_results( );
}

1;
