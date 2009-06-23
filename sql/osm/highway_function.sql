DROP VIEW IF EXISTS named_roads CASCADE;
CREATE VIEW named_roads AS
 SELECT ways.id, ways.version, ways.user_id, ways.tstamp, ways.bbox, ways.linestring, h.v AS highway, n.v AS name, r.v AS ref
   FROM ways
   JOIN way_tags h ON ways.id = h.way_id AND h.k = 'highway'::text
   LEFT JOIN way_tags n ON ways.id = n.way_id AND n.k = 'name'::text
   LEFT JOIN way_tags r ON ways.id = r.way_id AND r.k = 'ref'::text
  WHERE h.v = ANY (ARRAY['motorway'::text, 'motorway_link'::text, 'trunk'::text, 'trunk_link'::text, 'primary', 'secondary', 'tertiary', 'residential', 'unclassified']);

DROP FUNCTION IF EXISTS major_roads CASCADE;
CREATE VIEW major_roads AS
SELECT * from named_roads WHERE highway in ( 'motorway', 'motorway_link', 'trunk', 'trunk_link', 'primary', 'primary_link' );


