#!/usr/bin/perl -I./lib

use Parse::RecDescent;
use strict;
use Carp;
use TMCPE::ActivityLog::LocationParser;
use IO::All;
use Getopt::Long;
use OSM::Schema;
use DBI;

$::RD_ERRORS=1;
my $rule = "memo";

GetOptions ( "trace" => \$::RD_TRACE,
	     "err" => \$::RD_ERRORS,
	     "warn=i" => \$::RD_WARN,
	     "rule=s" => \$rule,
    );

my $lp = new TMCPE::ActivityLog::LocationParser();
$lp->use_osm_geom( 1 );

$lp->testrule( $rule, $ARGV[0] );

1;

