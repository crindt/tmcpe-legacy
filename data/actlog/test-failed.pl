#!/usr/bin/perl -I./lib

use Parse::RecDescent;
use strict;
use Carp;
use TMCPE::ActivityLog::LocationParser;
use IO::All;
use Getopt::Long;

$::RD_ERRORS=1;

GetOptions ( "trace" => \$::RD_TRACE,
	     "err" => \$::RD_ERRORS,
	     "warn=i" => \$::RD_WARN );

my $f = io( $ARGV[0] || 'location-parse.log' );

my $lp = new TMCPE::ActivityLog::LocationParser();

#$::RD_HINT = 1;

LINE: while( my $line = uc($f->getline()) ) {
    chomp( $line );
    warn "TRYING: $line\n";
    $_ = $line;
    /^IMPORT RUN AT/ && next LINE;
    /^\s*$/ && next LINE;

    my $locdata = $lp->get_location( $line );

    if ( ! $locdata ) {
	warn "FAILED ON $line";
    } else {
	warn "SUCCESS ON $line";
    }
    
}

