package TMCPE::ActivityLog::LocationParser;

use strict;
use warnings;
use Carp;
use Parse::RecDescent;
use SpatialVds::Schema;

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
     scalar => [ { -type => 'Parse::RecDescent',
		   -default_ctor => sub { return TMCPE::ActivityLog::LocationParser::create_parser() },
		 }, 'parser' ],
     new    => [ qw/ new / ]
    ];


sub get_facility {
    my ( $self, $num, $onet ) = @_;
    my $crit = { ref => $num };

    # tweak net to known standards:
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
	croak "More than one facility matches: [".join( '-', grep { defined $_ } $net, $num )."]";
    } elsif ( $#res == 0 ) {
	# good
	my $rec = shift @res;
	return { cname => join( '-', $rec->net, $rec->ref ),
		 net => $rec->net,
		 ref => $rec->ref
	};
    } else {
	croak "No facility found that matches: [".join( '-', grep { defined $_ } $net, $num )."]";
    }
}

sub get_vds_ramp {
    my ($self, %a) = @_;
    my $facdir = $a{facdir};
    my $ramp = $a{ramp};

    # assumptions
    $facdir->{facility}->{ref} =~ /\d+/ or croak join( "", "Bad facility refnum in get_vds: [", $facdir->{ref}, "]" );
    $facdir->{dir} =~ /[NSEW]/ or croak join( "", "Bad facility direction in get_vds: [", $facdir->{dir}, "]" );
    my $rstreet = $ramp->{street}->{stname} || croak join( "NO RAMP STREET NAME IN VDS LOOKUP" );
    my $rtype   = $ramp->{ramptype} || croak join ( "NO RAMP TYPE SPECIFIED" );

    $rtype = 'OR' if $rtype =~ /ON/;
    $rtype = 'FR' if $rtype =~ /OFF/;
    
    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	{
	    district_id => 12,  # hardcoded!
	    type_id => $rtype,
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $rstreet ] ], # using trigram similiarity
	},
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
	    order_by => [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ]
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
	croak "NO VDS FOUND TO MATCH $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $rstreet"
    }
    

}

sub get_vds_fw {
    my ( $self, $facdir, $relloc, $xfacdir ) = @_;

    # assumptions
    $facdir->{facility}->{ref} =~ /\d+/ or croak join( "", "Bad facility refnum in get_vds: [", $facdir->{ref}, "]" );
    $facdir->{dir} =~ /[NSEW]/ or croak join( "", "Bad facility direction in get_vds: [", $facdir->{dir}, "]" );
    my $xfac = join( "-", grep { defined $_ } ($xfacdir->{facility}->{net}, $xfacdir->{facility}->{ref} || croak join( "NO CROSS FREEWAY NAME IN VDS LOOKUP" ) ) );;
    my $xdir = $xfacdir->{dir} || undef;

    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xfac ] ], # using trigram similiarity
	},
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
	    order_by => [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ]
	}
	);

    # At this point, @res should contain a list of similar vds with names similar to the specified cross street
    if ( @res ) {
	# For now, we'll just take the first one.
	print STDERR "CANDIDATES FOR $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xfac \n" if $::RD_TRACE;
	print STDERR "\t".join( ",", map{ $_->freeway_dir . "B " . $_->name } @res )."\n" if $::RD_TRACE;

	my $vds = shift @res;

	return $vds;
    } else {
	croak "NO VDS FOUND TO MATCH $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xfac"
    }
    

}


sub get_vds_xs {
    my ($self, %a) = @_;

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
    $xstreet->{stname} || croak join( "NO XSTREET IN VDS LOOKUP" );

    # Do to some degenerate cases, we no longer match on the basis of
    # freeway direction.  Instead, we prioritize on freeway direction
    # matches.  If that fails, then we sort it out below...
    my @res = $self->vds_db->resultset( 'VdsGeoviewFull' )->search( 
	{
	    district_id => 12,  # hardcoded!
	    type_id => 'ML',
	    freeway_id => $facdir->{facility}->{ref},
#	    freeway_dir => $facdir->{dir},
	    -nest => \[ 'SIMILARITY( name, ? ) > 0.3', [ plain_value => $xstreet->{stname} ] ], # using trigram similiarity
	},
	{
	    select => [ 'id', 
			'name', 
			'freeway_id',
			'freeway_dir',
			'abs_pm',
			{similarity => [ 'name', "'$xstreet->{stname}'" ]},
			"freeway_dir = \'$facdir->{dir}\'"  
		],
	    as     => [ qw/ id name freeway_id freeway_dir abs_pm similarity dirmatch/ ],
	    order_by => [ "freeway_dir = \'$facdir->{dir}\' desc", 'similarity desc' ]
	}
	);

    # At this point, @res should contain a list of similar vds with names similar to the specified cross street
    if ( @res ) {
	# For now, we'll just take the first one.
	print STDERR "CANDIDATES FOR $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xstreet->{stname}\n" if $::RD_TRACE;
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
	croak "NO VDS FOUND TO MATCH $facdir->{dir}B $facdir->{facility}->{net}-$facdir->{facility}->{ref} @ $xstreet->{stname}"
    }
}



sub create_parser {

    #$::RD_AUTOACTION= q{ $#item > 1 ? "[".$item[0].":".join(",",map { ref $_ eq 'ARRAY'? @{$_}:$_ } @item[1..$#item])."]" : "<<".$item[1].">>"  };
    $::RD_AUTOACTION= q{ $#item > 0 ? join(" ",map { ref $_ eq 'ARRAY'? @{$_}:$_ } @item[1..$#item]) : "" };
    #$::RD_TRACE=1;
    #$::RD_HINT=1;
    
    my $mparser = Parse::RecDescent->new(q(

{ my $parent = 'dog';  print STDERR "----PARENT IS $parent----\n"; }

memo: embeddedloc[ $arg[0] ] { 
          print STDERR "SUCCESSFULLY IDENTIFIED VDS ".$item{embeddedloc}->id." [".$item{embeddedloc}->name."] AS LOCATION\n" if $::RD_TRACE; 
	  ${$arg[1]} = $item{embeddedloc};
      } |
      /^.*$/ {print STDERR "FAILED  ON: [".$item[1]."]\n" if $::RD_TRACE }

embeddedloc: incloc[ $arg[0] ] { $return = $item{incloc} } |
       incloc[ $arg[0] ] /[-,\.]+/ { $return = $item{incloc} } |
       /.*?[-,\.]+/ incloc[ $arg[ 0 ] ] /[-,\.]+/ { $return = $item{incloc} } |
       /.*?[-,\.]+/ incloc[ $arg[ 0 ] ] { $return = $item{incloc} }

conto: connector to

incloc: facdir[ $arg[0] ] hov connector to facdir[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > | 
        facdir[ $arg[0] ] connector to facdir[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > | 
        facdir[ $arg[0] ] to facdir[ $arg[0] ] connector { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] connector facdir[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > | 
        ramp to facorst[ $arg[0] ]  { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc facdir[ $arg[0] ] { eval{ $return = $arg[0]->get_vds_fw( @item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc street { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] relloc ramp { eval{ $return = $arg[0]->get_vds_xs( %item ); } } <reject: $@ > |
        facdir[ $arg[0] ] on ramp  { eval{ $return = $arg[0]->get_vds_ramp( %item ); } } <reject: $@ >

force:  facdir[ $arg[0] ] relloc street { eval{ $return = $arg[0]->get_vds_xs( %item ); }; return 1; } <reject: $@ >

        

facorst: facdir[ $arg[0] ] | 
         ramp | 
         facility[ $arg[0] ] | 
         street

facdir: dir sep(?) facility[ $arg[0] ] { $return = { facility => $item{facility}, dir => $item{dir} }; }

ramp: street ramptype { $return = { street => $item{street}, ramptype => $item{ramptype} }; }

ramptype: onramp | offramp

onramp: 'ON-RAMP' | 'ONRAMP' | 'ON/RAMP' | 'ON/R'  
offramp: 'OFF-RAMP' | 'OFFRAMP' | 'OFF/RAMP' | 'OFF/R' 

street: eng_street { $return = $item{eng_street} } | 
        span_street { $return = $item{span_street} }

eng_street: stdir stname sttype dir(?) { 
               $return = { stname => $item{stname}, 
                           sttype => $item{sttype},
                           stdir  => $item{stdir},
                           dir    => ($item{dir} && @{$item{dir}} ? $item{dir}[0] : undef ),
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
            stname dir(?) { $return = { stname => $item{stname} } ; } |

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


sttype: st | rd | dr | ave | blvd | ln | pkwy
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

relloc: /\bAT\b/ | /\bJ[NSEW]O\b/

facility: net sep facnum { 
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed: ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum}, $item{net} ) };
          } <reject: $@> |
          net facnum {
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum}, $item{net} ) }; 
          } <reject: $@> |
          facnum { 
              ref $arg[0] eq 'TMCPE::ActivityLog::LocationParser' || ::croak "No object passed ".join(",", map { $_.'='.(ref $_) } @arg ); 
	      eval{ $return = $arg[0]->get_facility( $item{facnum} ) }; 
          } <reject: $@>

net: /\bI/ | 
     /\bSR/| 
     /\bCA/

facnum: /\d+/

facmod: hov | connector

hov: /\bHOV\b/

connector: /\bCONNECTOR\b/ | /\bCONN\b/

to: /\bTO\b/

on: /\bON\b/

dir: /\b([NSEW])B*\b/ { my $val = $item[1]; $val =~ s/B//g; $return = $val; } | 
     /\bNORTH\b/ { $return = 'N'; } |
     /\bSOUTH\b/ { $return = 'S'; } |
     /\bEAST\b/ { $return = 'E'; } |
     /\bWEST\b/ { $return = 'W'; }

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
    my ( $self, $str ) = @_;

    my $res = {};
    if ( $self->parser->memo( $str, 1, $self, \$res ) ) {
	return $res;
    } else {
	warn " FAILED TO PARSE [".$str."]" if $::RD_TRACE;
	return undef;
    }
}

1;
