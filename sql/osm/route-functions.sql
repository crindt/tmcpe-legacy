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
		       WHERE network=net AND refnum=ref
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
		       WHERE network=net AND refnum=ref
	  	AND ( lower(direction) = ANY( cdirs ) ) LOOP
	RETURN route.id;
   END LOOP;
   RETURN NULL;
END;
$$ LANGUAGE plpgsql;


DROP TABLE IF EXISTS testbed_facilities;
CREATE TABLE testbed_facilities (
       net TEXT,
       ref TEXT,
       dir TEXT
);

INSERT INTO testbed_facilities VALUES 
       ( 'US:I', '5', 'N' ),
       ( 'US:I', '5', 'S' ),
       ( 'US:I', '405', 'N' ),
       ( 'US:I', '405', 'S' ),
       ( 'US:I', '605', 'N' ),
       ( 'US:I', '605', 'S' ),
       ( 'US:CA', '133', 'N' ),
       ( 'US:CA', '133', 'S' ),
       ( 'US:CA', '73', 'N' ),
       ( 'US:CA', '73', 'S' ),
       ( 'US:CA', '241', 'N' ),
       ( 'US:CA', '241', 'S' ),
       ( 'US:CA', '261', 'N' ),
       ( 'US:CA', '261', 'S' ),
       ( 'US:CA', '55', 'N' ),
       ( 'US:CA', '55', 'S' ),
       ( 'US:CA', '57', 'N' ),
       ( 'US:CA', '57', 'S' ),
       ( 'US:CA', '91', 'E' ),
       ( 'US:CA', '91', 'W' ),
       ( 'US:CA', '71', 'N' ),
       ( 'US:CA', '71', 'S' ),
       ( 'US:CA', '22', 'E' ),
       ( 'US:CA', '22', 'W' ),
       ( 'US:CA', '56', 'E' ),
       ( 'US:CA', '56', 'W' ),
       ( 'US:CA', '52', 'E' ),
       ( 'US:CA', '52', 'W' ),
       ( 'US:CA', '78', 'E' ),
       ( 'US:CA', '78', 'W' ),
       ( 'US:CA', '76', 'E' ),
       ( 'US:CA', '76', 'W' ),
       ( 'US:CA', '163', 'E' ),
       ( 'US:CA', '163', 'W' ),
       ( 'US:I', '805', 'N' ),
       ( 'US:I', '805', 'S' ),
       ( 'US:I', '15', 'N' ),
       ( 'US:I', '15', 'S' ),
       ( 'US:I', '215', 'N' ),
       ( 'US:I', '215', 'S' ),
       ( 'US:I', '10', 'E' ),
       ( 'US:I', '10', 'W' ),
       ( 'US:CA', '60', 'E' ),
       ( 'US:CA', '60', 'W' ),
       ( 'US:I', '8', 'E' ),
       ( 'US:I', '8', 'W' )
       ;

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
		       WHERE network=netrec.net AND refnum=freeway::text
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
       FROM temp_vds_data AS t
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


--- OK, now create a grails view of vds with segment geometry
DROP VIEW IF EXISTS vds_view CASCADE;
CREATE VIEW vds_view AS 
SELECT tvd.*,vsg.rel,vsg.seggeom as seg_geom
       FROM temp_vds_data AS tvd
       LEFT JOIN vds_segment_geometry AS vsg USING (id);

--- OH, and a qgis view
DROP VIEW IF EXISTS vds_view_qgis CASCADE;
CREATE VIEW vds_view_qgis AS 
SELECT * from vds_view 
       WHERE geometrytype( seg_geom )  = 'LINESTRING';
