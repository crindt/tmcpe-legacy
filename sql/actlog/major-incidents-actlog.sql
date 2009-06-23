DROP VIEW IF EXISTS sigalerts CASCADE;
CREATE VIEW sigalerts AS
SELECT DISTINCT cad 
       FROM ct_al_backup_2007 
       WHERE activitysubject='SIGALERT BEGIN' AND cad <> '';


DROP TYPE IF EXISTS location_parse CASCADE;
CREATE TYPE LOCATION_PARSE AS (
       f1dir TEXT,
       f1net TEXT,
       f1fac TEXT,
       relloc TEXT,
       f2dir TEXT,
       f2net TEXT,
       f2fac TEXT,
       xs    TEXT,
       f3dir TEXT,
       f3net TEXT,
       f3fac TEXT
);

CREATE LANGUAGE PLPERL;
DROP FUNCTION IF EXISTS parse_al_memo( memo TEXT ) CASCADE;
CREATE FUNCTION parse_al_memo( memo TEXT ) RETURNS LOCATION_PARSE AS
---CREATE FUNCTION parse_al_memo( memo TEXT ) RETURNS TEXT[] AS
$$
	$_ = $_[0];
#	our @fwys = grep { $_ ne '' } ( $_ =~ /([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
	$res;
	our @blocks = ( $_ =~ /(.*)(J[NSEW]O)(.*)/g );
	our @blocks = ( $_ =~ /(.*)(AT)(.*)/g ) if not @blocks;
	our ($f1dir,$f1net,$f1fac) = ( $blocks[0] =~ /([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
	$res->{f1dir} = $f1dir;
	$res->{f1net} = $f1net;
	$res->{f1fac} = $f1fac;
	our ($f2dir,$f2net,$f2fac) = ( $blocks[2] =~ / ([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
	$res->{relloc} = $blocks[1];
	$res->{f2dir} = $f2dir;
	$res->{f2net} = $f2net;
	$res->{f2fac} = $f2fac;
	our @xs = ( $blocks[2] =~ /\s*(.*?)[-,\.]/ );
	$res->{xs} = join( ":", @xs );
	our $xxs = join( " ", @xs );
	our ($f3dir,$f3net,$f3fac) = ( $xxs =~ / ([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
	$res->{f3dir} = $f3dir;
	$res->{f3net} = $f3net;
	$res->{f3fac} = $f3fac;
#	return join( "---", join(":", @fwy1 ), $blocks[1], join(":", @fwy2 ), join( ":", @xs ), join(":", @fwy3 ) );
#	return [ join(":", @fwy1 ), $blocks[1], join(":", @fwy2 ), join( ":", @xs ), join(":", @fwy3 ) ];
#	return { f1dir => $f1dir,
#	         f1net => $f1net,
#	         f1fac => $f1fac,
#		 relloc => $blocks[1],
#		 f1dir => $fwy2[0],
#	         f1net => $fwy2[1],
#	         f1fac => $fwy2[2],
#		 xs    => join( ":", @xs ),
#		 f1dir => $fwy3[0],
#	         f1net => $fwy3[1],
#	         f1fac => $fwy3[2] };
        return $res;
$$ LANGUAGE plperl;


DROP VIEW IF EXISTS locate_sigalerts CASCADE;
CREATE VIEW locate_sigalerts AS
SELECT cad,memo,parse_al_memo( memo ) as lp
       FROM ct_al_backup_2007 
       WHERE activitysubject='OPEN INCIDENT' AND cad IN ( SELECT cad from sigalerts );

DROP TABLE IF EXISTS sigalert_list;
SELECT cad,(lp).f1dir as f1dir,(lp).f1fac as f1fac,(lp).relloc as relloc,(lp).xs as xs,(lp).f2dir as f2dir,(lp).f2fac as f2fac 
       INTO sigalert_list
       FROM locate_sigalerts 
       WHERE (lp).f1dir IS NOT NULL AND (lp).relloc IS NOT NULL 
       	     AND (((lp).xs IS NOT NULL AND (lp).xs <> '' ) 
       	     	  OR ( (lp).f2dir IS NOT NULL AND (lp).f2fac IS NOT NULL ) );



DROP FUNCTION IF EXISTS process_xs( TEXT ) CASCADE;
CREATE FUNCTION process_xs( TEXT ) RETURNS TEXT[] AS
$$
	$_ = $_[0];
	our @parts = split( /\s+/, $_ );
	our $prefix = '';
        our $roadtype = '';
	$_ = $parts[ $#parts ];
	if ( /^PKWY$/ ||
	     /^RD$/ ||
	     /^ROAD$/ ||
	     /^AVE$/ ||
	     /^ST$/ ||
	     /^AV$/ ||
	     /^BLVD$/ ||
	     /^BL$/ ||
	     /^DR$/ ||
	     /^HWY/
	     ) {
	     # last is road type, pop it
	     $roadtype = pop @parts;
        }
	$_ = join( ' ', @parts );
	/CAMINO DE/ && do { $prefix = join( ' ', shift @parts, shift @parts ); };
	(/AVENIDA/ || /AVNDA/ || /AVENDIA/ ) && do { $prefix = shift @parts; };
        return [ join( ' ', @parts ), $prefix, $roadtype ];	
$$ LANGUAGE plperl;

DROP FUNCTION str_compare_trim( TEXT, TEXT ) CASCADE;
CREATE FUNCTION str_compare_trim( arg1 TEXT, arg2 TEXT ) RETURNS FLOAT AS
$$
	our ($a1,$num1) = ( $_[0] =~ /^(.*?)\s*(\d*)$/ );
	our ($a2,$num1) = ( $_[1] =~ /^(.*?)\s*(\d*)$/ );
	$l1 = length( $a1 );
	$l2 = length( $a2 );
	$l = $l1 < $l2 ? $l1 : $l2;
	$max = $l1 > $l2 ? $l1 : $l2;
	$s1 = uc( substr( $a1, 0, $l) );
	$s2 = uc( substr( $a2, 0, $l ) );
	return 0.0 if ( ! $s1 || ! $s2 );
	return ($l / $max) if ( $s1 eq $s2 );
        return 0.0;
$$ LANGUAGE plperl;

DROP VIEW IF EXISTS linked_sigalerts CASCADE;
CREATE VIEW linked_sigalerts AS
       SELECT sla.*,tvd.id,tvd.name,tvd.abs_pm,tvd.freeway_dir,process_xs(xs) as pxs,str_compare_trim( name, (process_xs(xs))[1] ) AS sct 
       FROM sigalert_list AS sla
       	    LEFT JOIN temp_vds_data tvd ON ( f1dir=freeway_dir AND f1fac::int4=freeway_id AND vdstype='ML' 
	    	      		    	     AND str_compare_trim( name, (process_xs(xs))[1] ) > 0 );

DROP VIEW IF EXISTS matched_sigalerts CASCADE;
CREATE VIEW matched_sigalerts AS
       SELECT cad,id as vdsid,q.name as signame,rel_pm,xs,pxs
       FROM ( SELECT *,CASE WHEN freeway_dir IN ( 'S', 'W' ) THEN -1 ELSE 1 END * abs_pm as rel_pm FROM linked_sigalerts ) q	
       	      WHERE sct=1 GROUP BY cad,id,q.name,rel_pm,xs,pxs;


DROP VIEW IF EXISTS sigalert_locations CASCADE;
CREATE VIEW sigalert_locations AS
       SELECT ms.* FROM 
       (
	SELECT cad,min(rel_pm) AS mrp 
	       FROM matched_sigalerts 
	       GROUP BY cad
       ) q 
       	 JOIN matched_sigalerts ms ON ( ms.cad=q.cad AND q.mrp=ms.rel_pm );

DROP TABLE IF EXISTS sigalert_locations_tmcpe CASCADE;
SELECT * into sigalert_locations_tmcpe from sigalert_locations;
ALTER TABLE sigalert_locations_tmcpe ADD PRIMARY KEY ( cad );
CREATE INDEX idx_sigalert_locations_tmcpe_vdsid ON sigalert_locations_tmcpe( vdsid );

DROP VIEW IF EXISTS sigalert_locations_grails CASCADE;
CREATE VIEW sigalert_locations_grails AS
       SELECT slt.*,tvd.geom as location
       	      from sigalert_locations_tmcpe slt
       	      LEFT JOIN temp_vds_data tvd ON ( tvd.id = slt.vdsid );
