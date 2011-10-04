#!/usr/bin/perl

use Date::Calc qw/ Today Add_N_Delta_YMD /;

#cd /home/crindt/workspace-sts-2.3.3.M2/tmcpe-webapp/data/actlog; 

# yesterday
my @dd = Today();

my @dd2 = Add_N_Delta_YMD(@dd, 0,0,-1);

my $START = join( "-", map { sprintf("%2.2d",$_) } @dd2 );


chdir '/home/crindt/workspace-sts-2.3.3.M2/tmcpe-webapp/data/actlog';

print "====== STARTING JOB ".`date`." in ".`pwd`." ========\n";
my $cmd = "perl import-al.pl --dc-vds-downstream-fudge=1.5 --dc-vds-upstream-fallback=6 --dc-prewindow=20 --dc-postwindow=90  --date-from=$START --dc-use-eq4567 --dc-use-eq3 --dc-min-obs-pct=20 --dc-limit-loading-shockwave=20 --dc-limit-clearing-shockwave=20 --dc-use-eq8 --dc-use-eq8b  --dc-unknown-evidence-value=0.50 --dc-dont-compute-vds-upstream-fallback --dc-band=1 not-40-1210 --dont-use-osm-geom --dc-cplex-optcr=0 --dc-gams-reslim=300 --dc-weight-for-distance=3 --dc-bound-incident-time  --dont-replace-existing not-505-031509  --verbose";
system( $cmd );




