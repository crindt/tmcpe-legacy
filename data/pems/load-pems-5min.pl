#!/usr/bin/perl

foreach my $ff (@ARGV) {
    my $f = $ff;
    $f =~ s/.gz$//g; 

    my $cc = 'zcat '.$ff.' | sed \'s/\([^,]*,[^,]*,\)[^,]*,[^,]*,[^,]*,[^,]*,\(.*\)/\1\2/g\' > '.$f;
    print $cc."\n";
    system ( $cc );

    my $cmd = join( "",
		    '"\\copy pems_5min',
		    "(stamp,vdsid,seg_len,samples_all,pct_obs_all,cnt_all,occ_all,spd_all,samples_1,cnt_1,occ_1,spd_1,obs_1,samples_2,cnt_2,occ_2,spd_2,obs_2,samples_3,cnt_3,occ_3,spd_3,obs_3,samples_4,cnt_4,occ_4,spd_4,obs_4,samples_5,cnt_5,occ_5,spd_5,obs_5,samples_6,cnt_6,occ_6,spd_6,obs_6,samples_7,cnt_7,occ_7,spd_7,obs_7,samples_8,cnt_8,occ_8,spd_8,obs_8)",
		    ' FROM \'',
		    $f,
		    "\' ",
		    'CSV"');
    my $fcmd = "echo $cmd" . "| psql -U VDSUSER -h ***REMOVED*** spatialvds";
    print $fcmd;
    system ( $fcmd ) && die "FAILED!";
    system ( "rm $f" ) && die "FAILED REMOVING";
    system ( "mv $ff done" ) && die "FAILED MOVING $f to done/`basename $ff`";
    system ( "echo $ff >> completed" );
}

