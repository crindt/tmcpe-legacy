

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

DROP TABLE IF EXISTS sigalert_list_aug;
SELECT *,get_testbed_relation( f1fac::int4, f1dir ) AS fac1,get_testbed_relation(f2fac::int4, f2dir) AS fac2 
       INTO sigalert_list_aug 
       FROM sigalert_list;

DROP VIEW IF EXISTS linked_sigalerts CASCADE;
CREATE VIEW linked_sigalerts AS
       SELECT sla.*,tvd.id,tvd.name,tvd.abs_pm,tvd.freeway_dir,process_xs(xs) as pxs,str_compare_trim( name, (process_xs(xs))[1] ) AS sct 
       FROM sigalert_list_aug AS sla
       	    LEFT JOIN temp_vds_data tvd ON ( f1dir=freeway_dir AND f1fac::int4=freeway_id AND vdstype='ML' 
	    	      		    	     AND str_compare_trim( name, (process_xs(xs))[1] ) > 0 );

DROP VIEW IF EXISTS matched_sigalerts CASCADE;
CREATE VIEW matched_sigalerts AS
       SELECT cad,id,q.name,rel_pm,xs,pxs
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
