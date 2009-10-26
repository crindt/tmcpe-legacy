DROP VIEW IF EXISTS route_relations CASCADE;
CREATE VIEW route_relations AS
       SELECT relations.*, n.v as network, r.v as refnum, d.v as direction
   	  FROM relations 
	       JOIN relation_tags AS n ON (id=n.relation_id AND n.k='network') 
	       LEFT JOIN relation_tags AS r ON (id=r.relation_id AND r.k='ref')
	       LEFT JOIN relation_tags AS d ON (id=d.relation_id AND d.k='direction');

DROP FUNCTION IF EXISTS get_route_relations( network TEXT, ref TEXT, dir TEXT );
CREATE OR REPLACE FUNCTION get_route_relations( net TEXT, ref TEXT, dir TEXT ) RETURNS SETOF INTEGER AS
$$
DECLARE
   route RECORD;
   cdirs  TEXT[];
BEGIN
   IF ( lower(dir) IN ( 'n', 'north', 'northbound' ) ) THEN
   	     cdirs = ARRAY[ 'n', 'north', 'northbound' ];
        ELSIF lower(dir) IN ( 's', 'south', 'southbound' ) THEN
   	     cdirs = ARRAY[  's', 'south', 'southbound' ];
        ELSIF lower(dir) IN ( 'e', 'east', 'eastbound' ) THEN
   	     cdirs = ARRAY[  'e', 'east', 'eastbound' ];
        ELSIF lower(dir) IN ( 'w', 'west', 'westbound' ) THEN
   	     cdirs = ARRAY[  'w', 'west', 'westbound' ];
        ELSE
	     RAISE NOTICE '% is an invalid direction', dir;
   END IF;
   FOR route IN SELECT * 
       	     	       FROM route_relations
		       WHERE ( network=net OR 'US:'||network=net) AND refnum=ref
	  	AND ( lower(direction) = ANY( cdirs ) ) LOOP
	RETURN NEXT route.id;
   END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_route_relation( network TEXT, ref TEXT, dir TEXT );
CREATE OR REPLACE FUNCTION get_route_relation( net TEXT, ref TEXT, dir TEXT ) RETURNS INTEGER AS
$$
DECLARE
   route RECORD;
   cdirs  TEXT[];
BEGIN
   IF ( lower(dir) IN ( 'n', 'north', 'northbound' ) ) THEN
   	     cdirs = ARRAY[ 'n', 'north', 'northbound' ];
        ELSIF lower(dir) IN ( 's', 'south', 'southbound' ) THEN
   	     cdirs = ARRAY[  's', 'south', 'southbound' ];
        ELSIF lower(dir) IN ( 'e', 'east', 'eastbound' ) THEN
   	     cdirs = ARRAY[  'e', 'east', 'eastbound' ];
        ELSIF lower(dir) IN ( 'w', 'west', 'westbound' ) THEN
   	     cdirs = ARRAY[  'w', 'west', 'westbound' ];
        ELSE
	     RAISE NOTICE '% is an invalid direction', dir;
   END IF;
   FOR route IN SELECT * 
       	     	       FROM route_relations
		       WHERE (network=net OR 'US:'||network=net ) AND refnum=ref
	  	AND ( lower(direction) = ANY( cdirs ) ) LOOP
	RETURN route.id;
   END LOOP;
   RETURN NULL;
END;
$$ LANGUAGE plpgsql;

\i 'testbed-facilities.sql'


--- this view grabs all testbed relations and the best guess at the osm relations that match them (if they exist)
DROP VIEW IF EXISTS testbed_facilities_relation_match CASCADE;
CREATE VIEW testbed_facilities_relation_match AS
SELECT * 
       FROM testbed_facilities tf 
       LEFT JOIN route_relations rr 
       	    ON ( ('^.*'::text || tf.net::text) ~ rr.network 
	       	 AND rr.refnum = tf.ref 
		 AND ( ( lower(substring( tf.dir from 1 for 1 ))||'^.*') ~ lower(substring( rr.direction from 1 for 1 )) ) 
	        );

--- HERE WE update the testbed_facilities rteid using the above view
UPDATE testbed_facilities
              SET rteid=q.id
       FROM ( SELECT tfrm.tfid as otfid ,tfrm.id 
       	      	     FROM testbed_facilities_relation_match tfrm ) q
       WHERE tfid=q.otfid AND q.id IS NOT NULL;

DROP FUNCTION IF EXISTS get_testbed_relation( freeway INTEGER, dir TEXT );
CREATE OR REPLACE FUNCTION get_testbed_relation( freeway INTEGER, dir TEXT ) RETURNS INTEGER AS
$$
DECLARE
   route RECORD;
   netrec RECORD;
   cdirs  TEXT[];
BEGIN
   IF ( lower(dir) IN ( 'n', 'north', 'northbound' ) ) THEN
   	     cdirs = ARRAY[ 'n', 'north', 'northbound' ];
        ELSIF lower(dir) IN ( 's', 'south', 'southbound' ) THEN
   	     cdirs = ARRAY[  's', 'south', 'southbound' ];
        ELSIF lower(dir) IN ( 'e', 'east', 'eastbound' ) THEN
   	     cdirs = ARRAY[  'e', 'east', 'eastbound' ];
        ELSIF lower(dir) IN ( 'w', 'west', 'westbound' ) THEN
   	     cdirs = ARRAY[  'w', 'west', 'westbound' ];
        ELSE
	     RAISE NOTICE '% is an invalid direction', dir;
   END IF;
   SELECT net INTO netrec from testbed_facilities tf WHERE freeway::text = tf.ref AND lower( tf.dir ) = ANY(cdirs);
   FOR route IN SELECT * 
       	     	       FROM route_relations
		       WHERE ( network=netrec.net OR 'US:'||network = netrec.net ) AND refnum=freeway::text
	  	AND ( lower(direction) = ANY( cdirs ) ) LOOP
	RETURN route.id;
   END LOOP;
   RETURN NULL;
END;
$$ LANGUAGE plpgsql;



--- create lines for every testbed route
DROP TABLE IF EXISTS route_lines;
SELECT rteid,st_linemerge(st_collect(linestring)) AS routeline 
       INTO route_lines FROM 
       ( SELECT m.relation_id as rteid,w.id,linestring from relation_members AS m  
       	 	JOIN ways AS w ON ( member_id = w.id ) 
                WHERE npoints(linestring) > 1 
		      AND ( m.relation_id IN 
		      	    ( SELECT get_route_relation( tf.net, tf.ref, tf.dir ) AS rteid
        		      	     FROM testbed_facilities tf ) ) 
		ORDER BY sequence_id ) AS q 
       GROUP BY rteid;
ALTER TABLE route_lines ADD COLUMN id4 INTEGER;
UPDATE route_lines set id4 = rteid::int4;
ALTER TABLE route_lines ADD PRIMARY KEY (id4);


--- find the point on a multilinestring nearest to the given point
CREATE OR REPLACE FUNCTION multiline_locate_point(amultils geometry,apoint
geometry)
  RETURNS geometry AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    i integer;

BEGIN
    mindistance := (distance(apoint,amultils)+100);
    IF NumGeometries(amultils) IS NULL THEN
         mindistance:=distance(apoint,amultils);
	 nearestlinestring:=amultils;
    ELSE 
         FOR i IN 1 .. NumGeometries(amultils) LOOP
             IF distance(apoint,GeometryN(amultils,i)) < mindistance THEN
                mindistance:=distance(apoint,GeometryN(amultils,i));
                nearestlinestring:=GeometryN(amultils,i);
             END IF;	     
         END LOOP;
    END IF;

    nearestpoint:=line_interpolate_point(nearestlinestring,line_locate_point(nearestlinestring,apoint));
    RETURN nearestpoint;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION multiline_locate_point(amultils geometry,apoint geometry)
OWNER TO postgres;

DROP TYPE IF EXISTS pointsnap CASCADE;
CREATE TYPE pointsnap AS (
       point geometry,
       line  geometry,
       dist  FLOAT
);

--- find the point on a multilinestring nearest to the given point
CREATE OR REPLACE FUNCTION multiline_locate_point_data(amultils geometry,apoint
geometry)
  RETURNS pointsnap AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    i integer;
    ret pointsnap;
    dist FLOAT;
BEGIN
    mindistance := (distance(apoint,amultils)+100);
    IF NumGeometries(amultils) IS NULL THEN
         mindistance:=distance(apoint,amultils);
	 nearestlinestring:=amultils;
    ELSE 
         FOR i IN 1 .. NumGeometries(amultils) LOOP
             IF distance(apoint,GeometryN(amultils,i)) < mindistance THEN
                mindistance:=distance(apoint,GeometryN(amultils,i));
                nearestlinestring:=GeometryN(amultils,i);
             END IF;	     
         END LOOP;
    END IF;

    dist := line_locate_point(nearestlinestring,apoint);
    nearestpoint:=line_interpolate_point(nearestlinestring,dist);
    
    ret.point=nearestpoint;
    ret.line = nearestlinestring;
    ret.dist = dist;
    RETURN ret;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION multiline_locate_point_data(amultils geometry,apoint geometry)
OWNER TO postgres;




--- This get's the route relations associated with all detectors in district 12
DROP TABLE IF EXISTS vds_route_relation;
SELECT id,adj_pm,rel,(vdssnap).point as vdssnap,(vdssnap).dist as dist, (vdssnap).line INTO vds_route_relation 
       FROM 
(
SELECT id,adj_pm,rel,multiline_locate_point_data( routeline, vdsgeom ) AS vdssnap
       FROM 
  (SELECT id,
       (CASE WHEN t.freeway_dir in ('N','E') THEN abs_pm ELSE -1*abs_pm END) as adj_pm,
       geom as vdsgeom,
       get_testbed_relation( t.freeway_id,t.freeway_dir ) as rel
       FROM tvd AS t
       WHERE --district in (7,8,11,12) and 
       	     vdstype='ML') q
       join route_lines ON ( q.rel=route_lines.rteid )
       WHERE routeline IS NOT NULL AND npoints(routeline)>1 ) qq
       ORDER BY rel,adj_pm;
ALTER TABLE vds_route_relation ADD PRIMARY KEY (id);
CREATE INDEX idx_vds_route_relation_vdssnap ON vds_route_relation USING gist( vdssnap );
ALTER TABLE vds_route_relation ADD COLUMN vds_sequence_id SERIAL;


--- OK, now they're snapped on there, we want to create the segment geometry...
DROP TABLE IF EXISTS vds_segment_geometry CASCADE;
SELECT id,adj_pm,rel,ST_line_substring( q.rls, ptsec,ntsec ) as seggeom INTO vds_segment_geometry
FROM (
SELECT t.id,t.adj_pm,t.rel,t.line as rls,p.dist as pdist,CASE WHEN p.dist IS NOT NULL THEN (t.dist+p.dist)/2 ELSE t.dist END as ptsec,n.dist as ndist, CASE WHEN n.dist IS NOT NULL THEN (t.dist+n.dist)/2 ELSE t.dist END as ntsec
       FROM vds_route_relation t 
       LEFT JOIN vds_route_relation p ON ( t.vds_sequence_id=p.vds_sequence_id+1 AND t.rel=p.rel)
       LEFT JOIN vds_route_relation n ON ( n.vds_sequence_id=t.vds_sequence_id+1 AND t.rel=n.rel)
       LEFT JOIN route_lines rl ON (rl.rteid=t.rel)
--       WHERE geometrytype(routeline) <> 'MULTILINESTRING'
--       AND t.id=1205012
       ORDER BY t.vds_sequence_id ) q
       WHERE ptsec <= ntsec
       ;

ALTER TABLE vds_segment_geometry ADD PRIMARY KEY (id);
DELETE FROM vds_segment_geometry WHERE seggeom IS NULL;


--- OK, now create a grails view of vds with segment geometry--the version field is a hack
DROP VIEW IF EXISTS vds_view CASCADE;
CREATE VIEW vds_view AS 
SELECT tvd.*,vsg.rel,vsg.seggeom as seg_geom, now() AS version 
       FROM tvd
       LEFT JOIN vds_segment_geometry AS vsg USING (id);

--- OH, and a qgis view
DROP VIEW IF EXISTS vds_view_qgis CASCADE;
CREATE VIEW vds_view_qgis AS 
SELECT * from vds_view 
       WHERE geometrytype( seg_geom )  = 'LINESTRING';


---------------
--- some direction stuff
CREATE OR REPLACE FUNCTION compute_sensex ( ls geometry ) 
       RETURNS CHAR AS 
$$
BEGIN
	IF ( numpoints( ls ) < 2 ) THEN
	   RETURN NULL;
	END IF;
	IF ( st_x(pointn(ls,1)) > st_x(pointn(ls,numpoints(ls))) ) THEN
	   RETURN 'W';
        ELSE
	   RETURN 'E';
        END IF;
END;
$$ 
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;

---------------
--- some direction stuff
CREATE OR REPLACE FUNCTION compute_sensey ( ls geometry ) 
       RETURNS CHAR AS 
$$
BEGIN
	IF ( numpoints( ls ) < 2 ) THEN
	   RETURN NULL;
	END IF;
	IF ( st_y(pointn(ls,1)) > st_y(pointn(ls,numpoints(ls))) ) THEN
	   RETURN 'S';
        ELSE
	   RETURN 'N';
        END IF;
END;
$$ 
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;


