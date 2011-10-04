#!/usr/bin/perl -I./lib

use Parse::RecDescent;
use strict;
use Carp;
use TMCPE::ActivityLog::LocationParser;
use IO::All;
use Getopt::Long;
use OSM::Schema;
use DBI;
use IO::All;

#BEGIN { $ENV{DBIC_TRACE} = 1 }

$::RD_ERRORS=1;
my $rule = "memo";
my $osm = 0;

GetOptions ( "trace" => \$::RD_TRACE,
	     "err" => \$::RD_ERRORS,
	     "warn=i" => \$::RD_WARN,
	     "rule=s" => \$rule,
	     "use-osm-geom" => \$osm,
    );

my $lp = new TMCPE::ActivityLog::LocationParser();
$lp->use_osm_geom( $osm );

if ( $#ARGV >= 0 ) {
    my $res = $lp->testrule( $rule, $ARGV[0] );
} else {
    # use stdin
    my $memos = io('-');
    while ( my $line = $memos->getline() ) {
	chomp $line;
	my $res = $lp->testrule( $rule, $line );
    }
}

1;

