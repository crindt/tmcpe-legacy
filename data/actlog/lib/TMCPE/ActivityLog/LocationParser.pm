package TMCPE::ActivityLog::LocationParser;

use strict;
use warnings;
use Carp;
use Parse::RecDescent;
use SpatialVds::Schema;
use OSM::Schema;

use Class::MethodMaker
    [
     scalar => [ { -default => "***REMOVED***" }, 'vds_db_host' ],
     scalar => [ { -default => "VDSUSER" }, 'vds_db_user' ],
     scalar => [ { -default => "VDSPASSWORD" }, 'vds_db_password' ],
     scalar => [ { -type => 'SpatialVds::Schema',
		   -default_ctor => sub {
		       SpatialVds::Schema->connect(
			   "dbi:Pg:dbname=spatialvds;host=***REMOVED***",
			   "VDSUSER", "VDSPASSWORD",
			   { AutoCommit => 1 },
			   );
		   }
		 }, 'vds_db' ],
     scalar => [ { -type => 'OSM::Schema',
		   -default_ctor => sub {
		       SpatialVds::Schema->connect(
			   "dbi:Pg:dbname=spatialvds;host=***REMOVED***",
			   "VDSUSER", "VDSPASSWORD",
			   { AutoCommit => 1 },
			   );
		   }
		 }, 'osm_db' ],
     scalar => [ { -type => 'Parse::RecDescent',
		   -default_ctor => sub { return TMCPE::ActivityLog::LocationParser::create_parser() },
		 }, 'parser' ],
     scalar => [ qw/ use_osm_geom / ],
     new    => [ qw/ new / ]
    ];

sub choke {
    my ( $self, @args ) = @_;
    1;
}


# Search for a facility that matches the given number in the given network $anet
# If anet is omitted, search all networks for the first match (interstate first, then SR)
sub get_facility {
    my ( $self, $num, $anet ) = @_;
    my $crit = { ref => $num };

    my @nets = ('I', 'SR');
    if ( $anet ) {
	@nets = ($anet);
    }

    # tweak net to known standards:
    foreach my $onet ( @nets ) {
	my $net = $onet;
	$_ = uc($net);
	/^I$/ && do { $net = 'US:I' };
	/^SR$/ && do { $net = 'US:CA' };
	/^CA$/ && do { $net = 'US:CA' };
	$crit->{net} = $net if defined $net;
	
	# look it up using testbed_facilities
	my @res = $self->vds_db->resultset( 'TestbedFacilities' )->search( 
	    $crit,
	    {
		columns => [ qw/net ref/ ],
		distinct => 1
	    }
	    );
	
	my $fac;
	if ( $#res > 0 ) {
	    # @ res should only contain one entry, more than one facility matches!
#	    warn "More than one facility matches: [".join( '-', grep { defined $_ } $net, $num )."]";
	    croak "More than one facility matches: [".join( '-', grep { defined $_ } $net, $num )."]";
	} elsif ( $#res == 0 ) {
	    # good
	    my $rec = shift @res;
	    #print STDERR "MATCHED FACILITY: ".join( ":",$rec->net,$rec->ref)."\n";
	    return { cname => join( '-', $rec->net, $rec->ref ),
		     net => $rec->net,
		     ref => $rec->ref
	    };
	} 
    }

    # didn't find any!!
#    warn "No facility found that matches: [".join( '-', grep { defined $_ } $anet, $num )."]";
    croak "No facility found that matches: [".join( '-', grep { defined $_ } $anet, $num )."]";
}

sub get_vds_ramp {
    my ($self, $icad_geom, %a) = @_;
    my $facdir = $a{facdir};
    my $ramp = $a{ramp};

    # assumptions
    $facdir->{facility}->{ref} =~ /\d+/ or croak join( "", "Bad facility refnum in get_vds: [", $facdir->{ref}, "]" );
    $facdir->{dir} =~ /[NSEW]/ or croak join( "", "Bad facility direction in get_vds: [", $facdir->{dir}, "]" );
    my $rstreet = $ramp->{street}->{stname} || croak join( "NO RAMP STREET NAME IN VDS LOOKUP" );
    my $rtype   = $ramp->{ramptype} || croak join ( "NO RAMP TYPE SPECIFIED" );

    my $rstname = join( " ", grep { defined $_ } ( $rstreet, $ramp->{street}->{sttype} ) );

    $rtype = 'OR' if $rtype =~ /ON/ || $rtype =~ /ONR/;
    $rtype = 'FR' if $rtype =~ /OFF/ || $rtype =~ /OFR/;

    # ignore the above, we'll always select the mainline
    $rtype = 'ML';

    my $geom;
    my $badgeom = 0;

    if ( not defined( $icad_geom ) ) {
	if ( $self->use_osm_geom ) {
	    $geom = join( '',
			  "GEOMFROMEWKT('",
			  $self->get_osm_geom( $facdir, $rstname ),
			  "')" );
	} else {
	    $geom = "GEOMFROMEWKT('SRID=2230;POINT(0 0)')";
	    $badgeom = 1;
	}
    } else {
	$geom = ${$icad_geom};
    }

    my $crit;
    my $order;
    if ( $geom && !$badgeom ) {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => $rtype,
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -or => {
		-nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $rstname ] ], # using trigram similiarity
	        -nest => \[ "ST_DWITHIN( ST_TRANSFORM( ".$geom.", 2230 ) , ST_TRANSFORM( geom, 2230 ), 1.5*5280 )" ]
            }
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 
		   "ST_DISTANCE( ST_TRANSFORM( ".$geom.", 2230 ), ST_TRANSFORM( geom, 2230 ) ) asc", 
		   'similarity desc' ];
    } else {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => $rtype,
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $rstname ] ] # using trigram similiarity
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ];
    }
    
    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( $crit,
	{
	    select => [ 'id', 
			'name', 
			'freeway_id',
			'freeway_dir',
			'abs_pm',
			{similarity => [ 'name', "'$rstreet'" ]},
			"freeway_dir = \'$facdir->{dir}\'"  
		],
	    as     => [ qw/ id name freeway_id freeway_dir abs_pm similarity dirmatch/ ],
            order_by => $order
	}
    );

    # At this point, @res should contain a list of similar vds with names similar to the specified cross street
    if ( @res ) {
	# For now, we'll just take the first one.
	print STDERR "CANDIDATES FOR $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $rstreet $ramp->{ramptype}\n" if $::RD_TRACE;
	print STDERR "\t".join( ",", map{ $_->freeway_dir . "B " . $_->name } @res )."\n" if $::RD_TRACE;

	my $vds = shift @res;

	return $vds;
    } else {
	croak join( "", 
                    grep { defined $_ }
                     ( "NO VDS FOUND TO MATCH ",
		       $facdir->{dir},"B ",
		       $facdir->{facility}->{net},"-",
		       $facdir->{facility}->{ref}," @ ",$rstreet ) );
    }
    

}

sub get_vds_fw {
    my ( $self, $icad_geom, %a ) = @_;
    #$facdir, $relloc, $xfacdir
    my $facdir = $a{facdir};

    # if facdir relloc facdir2
    my $xfacdir = $a{facdir2};

    # if facdir relloc facility
    $xfacdir = { facility => $a{facility} } if !$xfacdir;

    # assumptions
    $facdir->{facility}->{ref} =~ /\d+/ or croak join( "", "Bad facility refnum in get_vds: [", $facdir->{ref}, "]" );
    $facdir->{dir} =~ /[NSEW]/ or croak join( "", "Bad facility direction in get_vds: [", $facdir->{dir}, "]" );
    my $xfac = join( "-", grep { defined $_ } ($xfacdir->{facility}->{net}, $xfacdir->{facility}->{ref} || croak join( "NO CROSS FREEWAY NAME IN VDS LOOKUP" ) ) );;
    my $xdir = $xfacdir->{dir} || undef;

    # convert freeway cross references e.g., NB 55 AT I-5, (with
    # no direction) to '<dir> OF <xfreeway>' notation
    $xfac = join( ' ', $facdir->{dir}, 'OF', $xfac );

    # Some hardcoded transformations...
    $xfac =~ s/\bSR[-\s]*241\b/GYPSUM 1/g;
    $xfac =~ s/\b241\b/GYPSUM 1/g;


    my $geom;
    my $badgeom = 0;

    if ( not defined( $icad_geom ) ) {
	if ( $self->use_osm_geom ) {
	    $geom = join( '',
			  "GEOMFROMEWKT('",
			  $self->get_osm_geom( $facdir, $xfac ),
			  "')" );
	} else {
	    $geom = "GEOMFROMEWKT('SRID=2230;POINT(0 0)')";
	    $badgeom = 1;
	}
    } else {
	$geom = ${$icad_geom};
    }


    my $crit;
    my $order;
    if ( $geom && !$badgeom ) {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -or => {
		-nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xfac ] ], # using trigram similiarity
	        -nest => \[ "ST_DWITHIN( ST_TRANSFORM( ".$geom.", 2230 ) , ST_TRANSFORM( geom, 2230 ), 1.5*5280 )" ]
            }
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 
		   "ST_DISTANCE( ST_TRANSFORM( ".$geom.", 2230 ), ST_TRANSFORM( geom, 2230 ) ) asc", 
		   'similarity desc' ];
    } else {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xfac ] ] # using trigram similiarity
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ];
    }


    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( $crit,
	{
	    select => [ 'id', 
			'name', 
			'freeway_id',
			'freeway_dir',
			'abs_pm',
			{similarity => [ 'name', "'$xfac'" ]},
			"freeway_dir = \'$facdir->{dir}\'"  
		],
	    as     => [ qw/ id name freeway_id freeway_dir abs_pm similarity dirmatch/ ],
	    order_by => $order
	}
	);

    # At this point, @res should contain a list of similar vds with names similar to the specified cross street
    if ( @res ) {
	# For now, we'll just take the first one.
	print STDERR "CANDIDATES FOR $facdir->{dir}B ".join( '-', grep { $_ } ( $facdir->{facility}->{net},$facdir->{facility}->{ref}))." @ $xfac \n" if $::RD_TRACE;
	print STDERR "\t".join( ",", map{ $_->freeway_dir . "B " . $_->name } @res )."\n" if $::RD_TRACE;

	my $vds = shift @res;

	return $vds;
    } else {
	croak "NO VDS FOUND TO MATCH $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xfac"
    }
    

}


sub get_vds_xs {
    my ($self, $icad_geom, %a) = @_;

    my $facdir = $a{facdir};
    my $xstreet = $a{street};

    if ( !$xstreet ) {
	my $ramp = $a{ramp};
	$xstreet = $ramp->{street} if ( $ramp );
    }

    # assumptions
    defined $facdir->{facility}->{ref} && ($facdir->{facility}->{ref} =~ /\d+/ ) 
	or croak join( "", "Bad facility refnum in get_vds: [", ($facdir->{facility}->{ref} ? $facdir->{facility}->{ref} : "<no ref found>"), "]" );
    defined $facdir->{dir} && ($facdir->{dir} =~ /[NSEW]/) or croak join( "", "Bad facility direction in get_vds: [", $facdir->{dir}, "]" );
    if ( !$xstreet->{stname} ) {
#	warn "NO XSTREET IN VDS LOOKUP";
	croak join( "NO XSTREET IN VDS LOOKUP" ); 
    };

    my $xstreetname = $xstreet->{stname};
    $xstreetname =~ s/^\s*(.*?)\s*/$1/g;

    my $geom;
    my $badgeom = 0;

    if ( not defined( $icad_geom ) ) {
	if ( $self->use_osm_geom ) {
	    $geom = join( '',
			  "GEOMFROMEWKT('",
			  $self->get_osm_geom( $facdir, $xstreetname ),
			  "')" );
	} else {
	    $geom = "GEOMFROMEWKT('SRID=2230;POINT(0 0)')";
	    $badgeom = 1;
	    
	}
    } else {
	$geom = ${$icad_geom};
    }

    my $crit;
    my $order;
    if ( $geom && !$badgeom ) {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
#	    freeway_dir => $facdir->{dir},
	    -or => {
		-nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xstreetname ] ], # using trigram similiarity
	        -nest => \[ "ST_DWITHIN( ST_TRANSFORM( ".$geom.", 2230 ) , ST_TRANSFORM( geom, 2230 ), 1.5*5280 )" ]
            }
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 
		   "ST_DISTANCE( ST_TRANSFORM( ".$geom.", 2230 ), ST_TRANSFORM( geom, 2230 ) ) asc", 
		   'similarity desc' ];
    } else {
	$crit =	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
#	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xstreetname ] ] # using trigram similiarity
        };
        $order = [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ];
    }

    # Do to some degenerate cases, we no longer match on the basis of
    # freeway direction.  Instead, we prioritize on freeway direction
    # matches.  If that fails, then we sort it out below...
    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( $crit,
	{
	    select => [ 'id', 
			'name', 
			'freeway_id',
			'freeway_dir',
			'abs_pm',
			{similarity => [ 'name', "'$xstreetname'" ]},
			"freeway_dir = \'$facdir->{dir}\'",
			{ st_distance => [ 'st_transform( '.$geom.', 2230 )', 'st_transform( geom, 2230 )'], -as => 'dist' }
		],
	    as     => [ qw/ id name freeway_id freeway_dir abs_pm similarity dirmatch dist/ ],
	    order_by => $order
	}
	);

    # At this point, @res should contain a list of similar vds with names similar to the specified cross street
    if ( @res ) {
	# For now, we'll just take the first one.
	print STDERR "CANDIDATES FOR $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xstreetname\n" if $::RD_TRACE;
	print STDERR "\t".join( ",", map{ $_->freeway_dir . "B " . $_->name } @res )."\n" if $::RD_TRACE;

	my $vds = shift @res;

	# Confirm direction.  
	if ( $vds->freeway_dir ne $facdir->{dir} ) {
	    # OK, we matched a vds on the other side (the correct side doesn't have a name match).
	    # Find the nearest vds on the correct side
	    my @ores = $self->vds_db->resultset( 'VdsGeoviewFull' )->search(
		{
		    district_id => 12, # hardcoded
		    type_id => 'ML',
		    freeway_id => $facdir->{facility}->{ref},
		    freeway_dir => $facdir->{dir},
		},
		{
		    order_by => [ "abs( abs_pm - ".$vds->abs_pm." ) asc" ]
		}
		);
	    if ( @ores ) {
		# looks like we found one on the correct side of the freeway.  Do a sanity check
		my $ovds = shift @ores;
		if ( ( $ovds->abs_pm - $vds->abs_pm ) > 1.0 ) {
		    # vds in correct direction is too more than a mile from the target.  Seems like something's wrong
		    croak "FOUND VDS IN THE WRONG DIRECTION, BUT NO VDS IN THE RIGHT DIRECTION WITHIN 1 MILE";
		}
		
		# Looks good...use it.
		$vds = $ovds;
	    }
	}

	return $vds;
    } else {
	croak "NO VDS FOUND TO MATCH $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xstreetname"
    }
}


sub get_osm_geom {
    my ( $self, $facdir, $xs ) = @_;

    my $dbh = DBI->connect('dbi:Pg:database=osm;host=***REMOVED***',
		       'VDSPASSWORD' );
    
    my $qstr = qq{
    select distinct w.id,h.v hw,n.v as name,similarity( n.v, ? ) as sim,asewkt(st_intersection( q.rr,w.linestring)) as ii,st_distance(geomfromewkt('srid=4326;point(-117.830 33.693)'::text),st_intersection( q.rr,w.linestring)) as ocdist from ways w join way_tags h on (h.k='highway' AND h.way_id = w.id) left join way_tags n on ( n.way_id = w.id AND n.k='name' ) join ( select linestring rr from ways w join relation_members rm on ( w.id = rm.member_id ) where rm.relation_id in ( select id from routes r WHERE r.ref=? AND r.dir in (?,?) order by version desc limit 1) ) q on ( st_intersects( q.rr, w.linestring ) ) 
where n.v IS NOT NULL order by sim desc,ocdist desc limit 3;
};
    
    my $select_data = $dbh->prepare( $qstr );
    
    my $row;
    my @rows;
    eval {
	my $longdir;
	$_ = $facdir->{dir};
	/N/ && ( $longdir = 'north' );
	/S/ && ( $longdir = 'south' );
	/E/ && ( $longdir = 'east' );
	/W/ && ( $longdir = 'west' );
	( $row, @rows ) = @{ $dbh->selectall_arrayref( $select_data, { Slice=>{} }, $xs, $facdir->{facility}->{ref}, $facdir->{dir}, $longdir ) };
    };
    
    if ( $row ) {
	return $row->{ii};
    } else {
	return undef;
    }
}



sub create_parser {

    #$::RD_AUTOACTION= q{ $#item > 1 ? "[".$item[0].":".join(",",map { ref $_ eq 'ARRAY'? @{$_}:$_ } @item[1..$#item])."]" : "<<".$item[1].">>"  };
    $::RD_AUTOACTION= q{ $#item > 0 ? join(" ",map { ref $_ eq 'ARRAY'? @{$_}:$_ } @item[1..$#item]) : "" };
    #$::RD_TRACE=1;
    #$::RD_HINT=1;
    
    my $mparser = Parse::RecDescent->new(q(
memo: embeddedloc[ $arg[0], $arg[ 2 ] ] { 
          print STDERR "SUCCESSFULLY IDENTIFIED VDS ".$item{embeddedloc}->id." [".$item{embeddedloc}->name."] AS LOCATION\n" if $::RD_TRACE; 
	  ${$arg[1]} = $item{embeddedloc};
      } |
      /^.*$/ {print STDERR "FAILED  ON: [".$item[1]."]\n" if $::RD_TRACE; ${$arg[1]} = undef; }

embeddedloc: incloc[ $arg[0], $arg[ 1 ] ] { $return = $item{incloc} } |
       incloc[ $arg[0], $arg[ 2 ] ] /[-,\.]+/ { $return = $item{incloc} } |
       /.*?[-,\.]+/ incloc[ $arg[ 0 ], $arg[ 1 ]  ] /[-,\.]+/ { $return = $item{incloc} } |
       /.*?[-,\.]+/ incloc[ $arg[ 0 ], $arg[ 1 ]  ] { $return = $item{incloc} }

conto: connector to

incloc: facdir[ $arg[0] ] hov connector to facdir2[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > | 
        facdir[ $arg[0] ] connector to facdir2[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_fw( $arg[ 1 ], %item ); } } <reject: $@ > | 
        facdir[ $arg[0] ] to facdir2[ $arg[0] ] connector { eval{ $return = $arg[0]->get_vds_fw( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] connector facdir2[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > | 
        ramp to facorst[ $arg[0] ]  { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc facdir2[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_fw( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc facility[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_fw( $arg[ 1 ], %item); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc street { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc ramp { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] ramp { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] on ramp  { eval{ $return = $arg[0]->get_vds_ramp( $arg[ 1 ], %item ); } } <reject: $@ >

force:  facdir[ $arg[0] ] relloc street { eval{ $return = $arg[0]->get_vds_xs( $arg[ 1 ], %item ); }; return 1; } <reject: $@ >

        

facorst: facdir[ $arg[0] ] | 
         ramp | 
         facility[ $arg[0] ] | 
         street


facdir: dir sep(?) facility[ $arg[0] ] { $return = { facility => $item{facility}, dir => $item{dir} }; } |
        facility[ $arg[ 0 ] ] sep(?) dir { $return = { facility => $item{facility}, dir => $item{dir} }; }

facdir2: facdir[ $arg[ 0 ] ] { $return = $item{facdir} }

ramp: street ramptype { $return = { street => $item{street}, ramptype => $item{ramptype} }; }

ramptype: onramp | offramp

onramp: 'ON-RAMP' | 'ONRAMP' | 'ON/RAMP' | 'ON/R' | 'ONR'
offramp: 'OFF-RAMP' | 'OFFRAMP' | 'OFF/RAMP' | 'OFF/R' | 'OFR'
route: 'route' | 'rte' |  'RTE'


street: eng_street { $return = $item{eng_street} } | 
        span_street { $return = $item{span_street} }

eng_street: stdir stname sttype dir(?) { 
               $return = { stname => $item{stname}, 
                           sttype => $item{sttype},
                           stdir  => $item{stdir},
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef ),
               }; 
            } |
            dir stname sttype { 
               $return = { stname => $item{stname}, 
                           sttype => $item{sttype},
               }; 
            } |
            sttype dir(?) {  # need separate production for things like "SOUTH ST"
               $return = { stname => $item{stname}, 
                           sttype => $item{sttype},
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef )
               }; 
            } |
            stdir stname dir(?) { 
               $return = { stname => $item{stname}, 
                           stdir  => $item{stdir},
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef )
               };
            } |
            stname sttype dir(?) { 
               $return = { stname => $item{stname},
                           sttype => $item{sttype},
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef )
               } ; 
            } |
            stname dir(?) { 
               $return = { stname => $item{stname} } ; 
            }

span_street: sp_sttype stname dir(?)  { 
               $return = { stname => join ( " ", $item{sp_sttype}, $item{stname} ),
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef )
               }; 
            }

keyword: sttype | sp_sttype | ramptype | dir | facmod | relloc | to | connector | hov | on

stname: word(s) |
        special_stname

word: ...!keyword /[a-zA-Z0-9_]\w*\b/

stdir: /\b[NSEW]\b/ |  # distinct from dir, which is direction of travel.  Specifies E SOMETHING ST vs W SOMETHING ST
       /\bNORTH\b/ |
       /\bSOUTH\b/ |
       /\bEAST\b/ |
       /\bWEST\b/

special_stname:      # some special street names that are keywords and therefore wouldn't be matched by the generic name rule
       /\bNORTH\b/ |
       /\bSOUTH\b/ |
       /\bEAST\b/ |
       /\bWEST\b/


sttype: st | rd | dr | ave | blvd | ln | pkwy | hwy
st: /\bST\b/ | /\bSTREET\b/
rd: /\bRD\b/ | /\bROAD\b/
dr: /\bDR\b/ | /\bDRIVE\b/
ave: /\bAVE\b/ | /\bAV\b/ | /\bAVENUE\b/
blvd: /\bBLVD\b/ | /\bBOULEVARD\b/ | /\bBL\b/
ln: /\bLN\b/ | /\bLANE\b/
pkwy: /\bPARKWAY\b/ | /\bPKY\b/ | /\bPKWY\b/
hwy: /\bHIGHWAY\b/ | /\bHWY\b/

sp_sttype: avenida | camino
avenida: /\bAVENIDA\b/ | /\bAVDA\b/ | /\bAVE\b/
camino: /\bCAMINO\b/ | /\bCAM\b/ | /\bEL CAMINO\b/
        

sep: '-' | '/'

relloc: at | /\bJ?[NSEW]O\b/

at: /\bAT\b/ | /\@/

facility: net sep facnum { 
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed: ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum}, $item{net} ) };
              $return = { net => $item{net}, ref => $item{facnum} };
          } <reject: $@> |
          net facnum {
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum}, $item{net} ) }; 
              $return = { net => $item{net}, ref => $item{facnum} };
          } <reject: $@> |
          route facnum {
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum}, 'I' ) }; 
              $return = { ref => $item{facnum} };
          } <reject: $@> |
          facnum { 
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum} ) }; 
              $return = { ref => $item{facnum} };
          } <reject: $@>

net: /\bI/ | 
     /\bSR/| 
     /\bCA/

facnum: /\d+\b/

facmod: hov | connector

hov: /\bHOV\b/

connector: /\bCONNECTOR\b/ | /\bCONN\b/

to: /\bTO\b/

on: /\bON\b/

dir: /\b([NSEW])B\b/ PERIOD(?) { my $val = $item[1]; $val =~ s/B//g; $return = $val; } | 
     /\b([NSEW])\b/ PERIOD(?) { my $val = $item[1]; $val =~ s/B//g; $return = $val; } | 
     /\bNORTH\b/ { $return = 'N'; } |
     /\bSOUTH\b/ { $return = 'S'; } |
     /\bEAST\b/ { $return = 'E'; } |
     /\bWEST\b/ { $return = 'W'; }

PERIOD: /\./

)) || die "Bad Grammar!";
    return $mparser;
}

sub testrule {
    my ( $self, $rule, $str ) = @_;
    my $exec = join( "",
		     'print join( "", defined $self->parser->',
		     $rule,
		     '( ',
		     join ( ',',
			    '\''.$str.'\'', 
			    1, 
			    '$self' ),
		     ') ? "Success" : "Failed", " on ',
		     $rule,
		     " [$str]\\n\");" );
#    print $exec."\n";
    eval $exec;
    warn $@ if $@;
}


sub get_location {
    my ( $self, $str, $icad_geom ) = @_;

    my $res = {};
    if ( $self->parser->memo( $str, 1, $self, \$res, $icad_geom ) ) {
	return $res;
    } else {
	warn " FAILED TO PARSE [".$str."]" if $::RD_TRACE;
	return undef;
    }
}

1;
