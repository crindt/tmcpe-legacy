#!/usr/bin/perl

use IO::All;

my $ff = io('bad-dates');

while( my $line = $ff->getline() ) {
    my @vals = split(/[\s|]+/, $line);
    1;
}
