=head1 NAME

TMCPE::DelayComputation - Performs TMCPE delay computation

=head1 SYNOPSIS

    use $dc = new TMCPE::DelayComputation();
    $dc->cad( '12345' ); # set the CAD id to compute delay for
    $dc->incid( 123 );   # set the database incident id

    # now we define the approximate location of the incident to analyze
    $dc->facil( 5 );       # set the facility number
    $dc->dir( 'N' );       # set the facility direction
    $dc->pm( 12.34 );      # set the postmile
    $dc->vdsid( 1234567 ); # set the vdsid of the nearest vds station
    $dc->logstart( $somestarttime ); # Set the start time of the log
    $dc->logend( $someendtime );     # Set the start time of the log

    $dc->compute_delay();  # compute the delay
    $dc->write_to_db();    # write the results to the database

=head1 DESCRIPTION

C<TMCPE::DelayComputation> encapsulates the delay computation task of
the TMC Performance Evaulation project.  

=cut
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
use Devel::Comments '###', '###';

our $VERSION = '0.3.4';

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
		       croak "TMCPE DB NOT SPECIFIED!" if not $self->tmcpe_db_name;
		       croak "TMCPE DB HOST NOT SPECIFIED!" if not $self->tmcpe_db_host;
		       croak "TMCPE DB USER SPECIFIED!" if not $self->tmcpe_db_user;
		       carp join(",", $self->tmcpe_db_name,$self->tmcpe_db_host,$self->tmcpe_db_user,$self->tmcpe_db_password);
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
     scalar => [ { -default => 0 }, 'bound_incident_time' ],
     scalar => [ { -default => 0.0 }, 'bias' ],
     scalar => [ { -default => 0 }, 'reprocess_existing' ],
     scalar => [ { -default => 1 }, 'use_eq1' ],
     scalar => [ { -default => 1 }, 'use_eq2' ],
     scalar => [ { -default => 1 }, 'use_eq3' ],
     scalar => [ { -default => 1 }, 'use_eq4567' ],
     scalar => [ { -default => 0 }, 'use_eq8' ],
     scalar => [ { -default => 0 }, 'use_eq8b' ],
     scalar => [ { -default => 5 }, 'dt' ],  # number of minutes in a time step
     scalar => [ { -default => 1 }, 'weight_for_length' ],
     scalar => [ { -default => 0 }, 'weight_for_distance' ],  # value is exponent of weighting function
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
     scalar => [ qw/ bad_solution d12_delay tot_delay avg_delay net_delay / ],
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
     scalar => [ { -default => '0' }, "cplex_predual" ],
     scalar => [ { -default => '1' }, "cplex_preind" ],
     scalar => [ { -default => '1' }, "cplex_preslvnd" ],
     scalar => [ { -default => '0' }, "cplex_mipemphasis" ],
     scalar => [ { -default => 35.0 }, "d12_delay_speed" ],
     scalar => [ { -default => 60.0 }, "max_incident_speed" ],  # the speed over which a section is always classified as clear
#     scalar => [ { -type => 'Parse::RecDescent',
#		   -default_ctor => sub { return TMCPE::ActivityLog::LocationParser::create_parser() },
#		 }, 'parser' ],
     new    => [ qw/ new / ]
    ];


=head1 METHODS

=head2 get_gams_file

    Returns a unique gams input filename based upon the CAD id and facility

=cut
sub get_gams_file {
     my $self = shift; 
     my $fn = $self->cad."-".$self->facil."=".$self->dir.".gms";
     $self->gamsfile( $fn );
     return $fn;
}

=head2 get_lst_file

    Returns a unique gams output (lst) filename based upon the CAD id and facility

=cut
sub get_lst_file {
    my $self = shift; 
    my $fn = $self->cad."-".$self->facil."=".$self->dir.".lst";
    $self->lstfile( $fn );
    return $fn;
}

=head2 get_affected_vds

    Compute and return the set of vds associated with freeway sections
    possibly affected by the incident.

=cut
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

=head2 get_gams_data

    Load the results from an existing gams solution.  Useful for
    re-parsing results if the result parser has changed.

=cut
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
    my $i = $self->cad;
    my $data;

    my $facilkey = join( ":", $self->facil, $self->dir );

    foreach my $vds ( @avds ) {

	### require: $self->facil eq $vds->freeway_id && $self->dir eq $vds->freeway_dir

	my $vdsid = $vds->id;
	
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
		/^\s*\/\s*$/x && do { if ( ++$delimcount > 1 ) { 
		    $inseclen = 0 }; 
		};
		/^\*\s+S(\d+)\s=\s(\d+)\s(.*?)\s*$/x && do {
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
    map { 
	$M = @{$_->{data}} if $M < @{$_->{data}}; 
    } values %{$data->{$i}->{$facilkey}->{stations}};

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

    return;
}


sub fmt_unit {
    my ( $val, $unit, $fmt ) = @_;
    $val = defined $val ? $val : '<undef>';
    if ( $fmt ) {
	$fmt = "%s" if ( $val eq '<undef>' );
	return sprintf( $fmt, $val, $unit );
    } else {
	return join( "", $val, $unit );
    }
}

=head2 get_pems_data( @avds )

    Read the relevant PEMS data observed and statistics from the
    database for the given list of vds stations.  Unless otherwise
    specified, this method will read data from the PEMS statistics
    cache table, rather than compute the statistics on the fly.  If
    the statistics don't exist, or if use of the cache is disabled,
    this method will generate the statistics and insert them into the
    cache table for later use.

=cut
sub get_pems_data {
    my ( $self, @avds ) = @_;

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

    #### ANALYZED TIMES BETWEEN $ss AND $es ARE:
    #map { print STDERR "\t$_\n"; } @times if $self->debug;

    my $data = {}; # the data structure we'll fill

    foreach my $vds ( @avds ) {  ### Getting PEMS data (% done)

	my $vdsid = $vds->id;
	my $facilkey = join( ":", $vds->freeway_id, $vds->freeway_dir );
	
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{vds} = $vds;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{abs_pm} = $vds->abs_pm;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{fwy} = $vds->freeway_id;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{dir} = $vds->freeway_dir;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{name} = $vds->name;
	$data->{$i}->{$facilkey}->{stations}->{$vds->id}->{seglen} = $vds->length;
	
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
	    ### =: "COMPUTING MISSING ANNUAL AVERAGES FOR ".$vds->name

	    foreach my $br ( @bad_rows ) {   ### Processing |===[%]   | 
		#### =: join( "", "CREATING FOR ",$br->stamp,"..." )
		
		# tmcpe_data_create is a view that generates the
		# averages.  Here, we compute the stats for this row
		my @created_rows = $self->vds_db->resultset( 'TmcpeDataCreate' ) ->search(
		    {
			vdsid => $vds->id,
#			stamp => { -in => [ map {$_->stamp} @bad_rows ] }
			stamp => $br->stamp
		    });
		
		# created_rows will contain the data we want to push
		# into 'Pems5minAnnualAvg'
		if ( @created_rows ) {

		    ### require: @created_rows == 1

		    # see if it already exists, which can occur if
		    # we're updating the cache
		    my @existing_rows = $self->vds_db->resultset( 'Pems5minAnnualAvg' )->search(
			{
			    vdsid => $vds->id,
			    stamp => $br->stamp
			});

		    if ( @existing_rows ) {
			#### =: join( '', 'Row exists for (',$vds->id,',',$br->stamp,'), updating it' )

			### require: @existing_rows == 1

			my $er = shift @existing_rows;

			# this loops over all the columns in the
			# created row and updates the existing row accordingly
			foreach my $cr ( @created_rows ) {
			    foreach my $col ( $er->result_source->columns ) {
				$er->set_column( $_ => $cr->get_column( $_ ) ) 
			    }
			}

			# Push the changes to the database
			$er->update;

		    } else {

			#### =: join( '', Row doesn't exist for (',$vds->id,',',$br->stamp,'), create a new one' )
			$self->vds_db->populate( 
			    'Pems5minAnnualAvg',
			    [ [ $created_rows[0]->result_source->columns ],

			      # create an array containing the data
			      # corresponding to the columns
			      map { 
				  my $row = $_; 
				  [ map { $row->get_column( $_ ); } $row->result_source->columns ] 
			      } @created_rows

			    ]);
		    }
		}
	    }
	} else {
	    #### =: "ALL DATA IS CACHED FOR ".$vds->id." between $ss and $es"
	}

	#### GRABBING DATA FOR $vds->id between $ss and $es
	my @rows = $self->vds_db->resultset( 'TmcpeData' )->search(
	    { 
		vdsid => $vds->id,
		stamp => { -between => [$ss,$es] },
	    },
	    {
		order_by => 'stamp asc'
	    });

	# create the array if it's not defined yet
	if ( not defined( $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} ) ) {
	    $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{data} = [];
	}
	
	if ( !@rows ) {
	    ### =: "NO DATA FOR $vdsid $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name}!!!"

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
	    ### require: @rows == @times

	    foreach my $row ( @rows ) {
		my ($date,$time) = split(/\s+/, $row->stamp);
		
		my $pjm=$self->unknown_evidence_value;  # default to unknown
		if ( $row->days_in_avg >= $self->min_avg_days && $row->o_pct_obs >= $self->min_obs_pct ) 
		{
		    if ( not defined $row->o_spd ) {
			# this means there's no valid data for this period, mark it bad
			$pjm = $self->unknown_evidence_value;
		    } else {
			if ( $row->o_spd < ( $row->a_spd - $self->band * $row->sd_spd ) 

			     # we won't flag speeds over some maximum as incidents,
			     # regardless of their relationship to averages
			     && ( $row->o_spd <= $self->max_incident_speed ) 
			    ) {
			    $pjm = 0;
			} else {
			    $pjm = 1;
			}
		    }
		}

		my $diag = join( " : ",
				 $vdsid,
				 $date,
				 $time,
				 $data->{$i}->{$facilkey}->{stations}->{$vdsid}->{name},
				 fmt_unit( $row->a_vol * 12, " vph", "%5.0f" ),
				 fmt_unit( $row->a_occ * 100 , "%", "%5.1f" ),
				 fmt_unit( $row->a_spd , " mph", "%5.1f" ),
				 fmt_unit( $row->sd_spd , " mph", "%5.1f" ),
				 fmt_unit( $self->band * $row->sd_spd , " mph", "%5.1f" ),
				 fmt_unit( $row->a_spd - $self->band * $row->sd_spd , " mph", "%5.1f" ),
				 fmt_unit( $row->o_spd , " mph", "%5.1f" ),
				 $row->days_in_avg,
				 $row->o_pct_obs,
				 $pjm,
		    );
		#### rec: $diag

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
    map { 
	$M = @{$_->{data}} if $M < @{$_->{data}} 
    } values %{$data->{$i}->{$facilkey}->{stations}};

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

    return;
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
    $eq8b = "" if $self->use_eq8b;
    my @objective;
    my $bias = $self->bias || 0;

    my $weight_for_length = "L( J1 )";
    $weight_for_length = "1" if ( not $self->weight_for_length );


    my $incstart_index = $self->prewindow/5;
    my $incpm = $self->pm;
    my $dt = $self->dt;

    my $weight_for_distance = 1;
    if ( $self->weight_for_distance ) {
	my $wfd_exponent = $self->weight_for_distance;
	$weight_for_distance = "1.0/power(1 + sqrt(sqr(5*(ORD(M1)-$incstart_index)/60.0)+sqr(PM(J1)-$incpm)),$wfd_exponent)";
    }
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

    # compute number of sections
    my $J = keys %{$data->{$i}->{$facilkey}->{stations}};
    $J -= 1;

    # compute number of time steps
    my $M = 0;
    map { 
	$M = @{$_->{data}} if $M < @{$_->{data}}
    } values %{$data->{$i}->{$facilkey}->{stations}};

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
    foreach my $st ( @stations ) {

	for ( $m = 0; $m < $M; ++$m ) {
	    $d = $st->{data}->[$m];

	    if ( not defined $d ) {
		carp "BAD data for $st, $m";
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

    ### =: join( "", "WRITING PROGRAM $i to ", $self->get_gams_file, "..." )

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
    foreach my $st ( @stations ) {    ### Writing postmiles (% done)
	$of << sprintf( "*		S%s = %s %s\n", 
			map { defined $_ ? $_ : '<undef>' } (
			    $j,
			    $st->{vds}->id, 
			    $st->{name} ) );
	$of << sprintf( "		S%s	%f\n", 
			map { defined $_ ? $_ : '<undef>' } (
			    $j, $st->{abs_pm} 
			)
	    );

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
    foreach my $st ( @stations ) {    ### Writing section lengths (% done)
	$of << sprintf( "*		S%s = %s %s\n", 
			map { defined $_ ? $_ : '<undef>' } (
			    $j,
			    $st->{vds}->id, 
			    $st->{name} ) );
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
    foreach my $st ( @stations ) {    ### Writing evidence (% done)
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
    foreach my $st ( @stations ) {    ### Writing observed speeds (% done)
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
    foreach my $st ( @stations ) {    ### Writing mean speeds (% done)
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
    foreach my $st ( @stations ) {    ### Writing observed flows (% done)
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
    foreach my $st ( @stations ) {    ### Writing mean flows (% done)
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

    # Shockwave contraint parameters
    my $MAX_LOAD_SHOCK_DIST = $self->limit_loading_shockwave/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    my $MAX_CLEAR_SHOCK_DIST = $self->limit_clearing_shockwave/12.0;  # maximum dist a shockwave can travel in 5 minutes...[(0-2200)/(150-35)=15mi/hr=1.25mi/5min]
    
    my $shockdir=1;
    $_ = $self->dir;
    if ( /S/ || /W/ ) {
	$shockdir=-1;
    }
    
    # Require start region comps if eq8 is used
    if ( ! $self->limit_to_start_region && $self->use_eq8 ) {
	### OVERRIDING GAMS PARAMETERS TO COMPUTE START CELL IN SUPPORT OF EQ8
	$self->limit_to_start_region( 1 );
    }

    # Start region constraint parameters
    my $use_boundary_constraint = "*";
    my $startlim = $self->limit_to_start_region ? "" : "*";
    my ($BOUNDARY_DX, $BOUNDARY_DT) = (10000,10000);  # set these to not bind
    if ( $self->limit_to_start_region && $self->boundary_intersects_within ) {
	($BOUNDARY_DX, $BOUNDARY_DT) = split(/,/, $self->boundary_intersects_within );
	if ( defined( $BOUNDARY_DX ) && defined( $BOUNDARY_DT ) ) {
	    $use_boundary_constraint = "";
	}
    }
    
    # bound incident time
    my $bound_incident_time = $self->bound_incident_time ? "" : "*";
    
    
    $of << qq{
VARIABLES
	Z		objective
	D(J1,M1)	incident state
	S(J1,M1)	start point
	CW(J1,M1)	cell weight
	CV(J1,M1)	cell val
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
$eq8 EQ8_START
$eq8b EQ8b
TOTDELAY
AVGDELAY
NETDELAY
CWEIGHT
CVALUE
$startlim ONESTART
$startlim NOSTART_NOREGION
$startlim IFSTART_THEN_D
$startlim START_BOUNDARY
$startlim$use_boundary_constraint START_CONSTRAINT
$startlim$use_boundary_constraint START_CONSTRAINT2
$bound_incident_time BOUND_INCIDENT_TIME
};

    if ( $self->force ) {
	foreach my $k ( keys %{$self->force} ) {
	    my $v = $self->force->{$k};
	    my ( $j, $m ) = split(/:/, $k );
	    $of << "FORCE_S$j"."_$m\n";
	}
    }
	
    ### WRITING EQUATIONS
    $of << qq{
;

$objective[1] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, $weight_for_distance * (1-($bias)) * $weight_for_length * ( P( J1, M1 ) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ) ); 
$objective[2] OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, 1.0/power(1 + sqrt(sqr(5*(ORD(M1)-$incstart_index)/60.0)+sqr(PM(J1)-$incpm)),3) * (1-($bias)) * $weight_for_length * ( P( J1, M1 ) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ) ); 

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
***** SHOCKWAVE CONSTRAINT
*** Loading wave
$eq8 EQ8(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) < ($shockdir)*(PM(J1)-($shockdir)*$MAX_LOAD_SHOCK_DIST)), D(K1,M1+1) ) =l= CARD(M1) - CARD(M1)*( D(J1,M1) - D(J1-1,M1) );
* Enforce the loading wave constraint at the start too
$eq8 EQ8_START(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) < ($shockdir)*(PM(J1)-($shockdir)*$MAX_LOAD_SHOCK_DIST)), D(K1,M1) ) =l= CARD(M1) - CARD(M1)*( S(J1,M1) );
** Clearing wave
$eq8b EQ8b(J1,M1) .. SUM( K1\$(($shockdir) * PM( K1 ) > ($shockdir)*(PM(J1)+($shockdir)*$MAX_CLEAR_SHOCK_DIST)), D(K1,M1-1) ) =l= CARD(M1) - CARD(M1)*( D(J1,M1) - D(J1+1,M1) );
TOTDELAY ..	Y=E=SUM( J1, SUM( M1, L( J1 ) / V(J1,M1) * F( J1, M1 ) * D(J1,M1) ) );
AVGDELAY ..	A=E=SUM( J1, SUM( M1, L( J1 ) / AV(J1,M1) * AF( J1, M1 ) * D(J1,M1) ) );
NETDELAY ..	N=E=Y-A;
CWEIGHT(J1,M1) .. CW(J1,M1)=E=$weight_for_distance;
CVALUE(J1,M1) .. CV(J1,M1)=E=$weight_for_distance * (1-($bias)) * $weight_for_length * ( P( J1, M1 ) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) );
$startlim ONESTART .. (SUM(J1,SUM(M1,S(J1,M1)))) =L= 1;
$startlim NOSTART_NOREGION .. SUM(J1,SUM(M1,D(J1,M1))) =L= CARD(M1)*CARD(J1)*(SUM(J1,SUM(M1,S(J1,M1))));
$startlim IFSTART_THEN_D(J1,M1) .. D(J1,M1) =G= S(J1,M1);
$startlim START_BOUNDARY(J1,M1) .. SUM( K1, D( K1, M1-1 ) ) + SUM( R1, D( J1 + 1, R1 ) ) 
$startlim                  =l= CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( S( J1, M1 ) );
** REQUIRE THAT IF THERE IS ANY BOUNDARY, IT MUST INCLUDE CELLS WITHIN A CERTAIN DISTANCE OF THE EXPECTED TIME-SPACE LOCATION OF THE DISRUPTION
$startlim$use_boundary_constraint START_CONSTRAINT .. SUM( J1, SUM( M1, S(J1,M1) ) ) =l= CARD(M1) * CARD(J1) * SUM( K1\$(ABS(PM(K1)-$incpm)<=$BOUNDARY_DX), SUM( R1\$(ABS(ORD(R1)-$incstart_index)*$dt<=$BOUNDARY_DT), S(K1,R1)));
** REQUIRE THAT THE START IS ON A CELL WITH POSITIVE EVIDENCE FOR AN INCIDENT
$startlim$use_boundary_constraint START_CONSTRAINT2(J1,M1) .. S(J1,M1) =l= (1 - P(J1,M1));

** Incident time bound constraint: All cells with time index less than the incident start time must be zero
$bound_incident_time BOUND_INCIDENT_TIME .. SUM( J1, SUM( M1\$(ORD(M1)<$incstart_index+1), D(J1,M1) ) ) =L= 0;
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
DISPLAY CW.l;
DISPLAY CV.l;
};
    
    $of->close;
    
    ### DONE WRITING EQUATIONS
}

sub solve_program {
    my ( $self ) = @_;

    ### SOLVING PROGRAM...

    my $gf = $self->get_gams_file;
    my $gu = $self->gams_user;
    my $gh = $self->gams_host;
    my $rsynccmd = "rsync -avz $gf $gu\@$gh:tmcpe/work\n";
    ### =: "SYNCING...$rsynccmd"

    system( "rsync -avz $gf $gu\@$gh:tmcpe/work" );
    
    my $RESLIM="";
    $RESLIM = join( " = ", "RESLIM", $self->gams_reslim ) if $self->gams_reslim;
    my $gamscmd = "ssh $gu\@$gh 'cd tmcpe/work && /cygdrive/c/Progra~1/GAMS22.2/gams.exe $gf $RESLIM'";
    ### =: "SOLVING...$gamscmd"
    system( $gamscmd );
    
    my $lf = $self->get_lst_file;
    $rsynccmd = "rsync -avz $gu\@$gh:tmcpe/work/$lf .";
    ### =: "SYNCING BACK...$rsynccmd"
    system( $rsynccmd );

    ### DONE SOLVING PROGRAM
}

# Read and parse the results returned from GAMS
sub parse_results {
    my ( $self ) = @_;

    my $resf = io( $self->get_lst_file );
    my $found = 0;
    my $error = 0;

    my $cell;
    my $z;
    my $tot_delay;
    my $avg_delay;
    my $net_delay;

  LINE: 
    while( my $line = $resf->getline() ) { ### PROCESSING RESULTS |===[%]              |
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
	    croak "CONSULT ".$self->get_lst_file." FOR DETAILS";
	};
	/EXECERROR/ && do 
	{
	    croak "EXECERROR: CONSULT ".$self->get_lst_file." FOR DETAILS";
	};
	/Error solving MIP subprogram/ && do 
	{
	    croak "Error solving MIP: CONSULT ".$self->get_lst_file." FOR DETAILS (and possibly the CPLEX subdir)";
	};
	/No solution returned/ && do 
	{
	    croak "No solution?: CONSULT ".$self->get_lst_file." FOR DETAILS";
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
	/^----\s+VAR C[WV]/ && do
	{
	    $found = 0;
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
	    #print "INC: ($1,$2) = $val\n" if $self->debug;
	};
    }
    print STDERR "done\n";

    $self->d12_delay( 0 ); # not computed by GAMS
    $self->tot_delay( $tot_delay );
    $self->net_delay( $net_delay );
    $self->avg_delay( $avg_delay );

    $self->cell( $cell );
}

# Write the solution to the database
sub write_to_db {
    my ( $self, $overwrite ) = @_;

    my $i = $self->cad;
    my $fwy = $self->facil;
    my $dir = $self->dir;
    my $cell = $self->cell;

    my $facilkey = join( ":", $fwy, $dir );

    # Don't write if the solution is bad
    croak {msg => join(":", "BAD SOLUTION: ", $self->bad_solution ) } if $self->bad_solution;

    # This gives us the FacilitySection associated with the incident
    # location on this facility
    my $loc;
    eval { 
	my @locs = $self->tbmap_db->resultset( 'VdsView' )->search( {id => $self->vdsid} );
	$loc = shift @locs;
    };
    croak $@ if $@;
    croak "BAD VDSID ".$self->vdsid if not $loc;
    

    # shorthand for the solution data
    my $data = $self->data;

    # sort the stations to go from upstream to down stream based upon
    # the postmile and facility direction.  Caltrans absolute
    # postmiles increase going northbound and eastbound.
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

	# create a new incident impact analysis to store this result
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
					max_incident_speed => $self->max_incident_speed,
					location_id => $loc->id,
					d12delay => 0,
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
    my $d12delaysum = 0;
    foreach my $station ( @stations ) {
	my $as;
	eval { $as = $ifa->create_related( 'analyzed_sections', { section_id=> $station->{vds}->id } ); };
	croak $@->{msg} if $@;

	my $m = 0;
	my @statdat = sort { $a->{timeofday} cmp $b->{timeofday} } @{$station->{data}};
	my $vdsid = $station->{vds}->id;
	foreach my $secdat ( @statdat ) { ### CREATING VDS $vdsid DATA |===[%]            |
	    my $at;
	    eval { 
		my $tmcpedelay = 0;
		my $d12delay = 0;
		my $stnidx = $j;
		my $iflag = defined $self->cell->[$stnidx][$m]->{inc} ? $self->cell->[$stnidx][$m]->{inc} + 0 : 0;
		if ( (defined $secdat->{incspd} && $secdat->{incspd} > 0) && (defined $secdat->{avg_spd} && $secdat->{avg_spd} > 0) ) {
		    $tmcpedelay = $iflag * $station->{seglen} * ( 1.0 / $secdat->{incspd} - 1.0 / $secdat->{avg_spd} ) * $secdat->{incflw};
		    $tmcpedelay = 0 if $tmcpedelay < 0;
		    $d12delay   = $iflag * $station->{seglen} * ( 1.0 / $secdat->{incspd} - 1.0 / $self->d12_delay_speed ) * $secdat->{incflw};
		    $d12delay = 0 if $d12delay < 0;
		    
		    $d12delaysum += $d12delay;
		}
#		printf STDERR "\t* ".join( ' ', '(',$j,$m,')', $secdat->{date}, $secdat->{timeofday}, $iflag,
#		    $secdat->{incspd}, $secdat->{avg_spd}) . "\n";
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
					       d12_delay => $d12delay * $iflag,
					   } );
	    };
	    if ( $@ ) {
		croak $@->{msg};
	    }
	    $m++;
	}
	$j++;
    }
    $ifa->d12delay( $d12delaysum );
    $ifa->update();
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
__END__

=head1 AUTHOR

Craig Rindt.

=cut
