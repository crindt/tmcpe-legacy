DROP VIEW IF EXISTS testbed_roads CASCADE;
CREATE VIEW testbed_roads AS 
 SELECT ways.id, nodes.geom, wn.sequence_id
   FROM ways
   JOIN way_tags AS h ON ( ways.id = h.way_id AND h.k = 'highway'::text AND h.v = 'motorway'::text )
   LEFT JOIN way_tags n ON ways.id = n.way_id AND n.k = 'name'::text
   LEFT JOIN way_tags r ON ways.id = r.way_id AND r.k = 'ref'::text
   JOIN way_nodes wn ON wn.way_id = ways.id
   JOIN nodes ON wn.node_id = nodes.id
  WHERE 
  --- (n.v ~ 'I[- ]5'::text OR r.v ~ 'I[- ]5'::text) AND 
  nodes.geom && setsrid('BOX3D(-117.9142 33.6074 0,-117.6972 33.7634 0)'::box3d::geometry, 4326)
  ORDER BY ways.id, wn.sequence_id;

DROP TABLE IF EXISTS testbed_lines CASCADE;
---SELECT id, st_collect(geom), askml(st_geom) as kml into testbed_lines from testbed_roads;
SELECT id,geom,askml(geom) AS kml
       INTO testbed_lines
       FROM ( SELECT id, st_makeline( geom ) AS geom 
       	      	     FROM testbed_roads
       		     GROUP BY id ) AS q;
