--- Load trigram support
\i /usr/share/postgresql-8.4/contrib/pg_trgm.sql

--- Create the routes view
DROP VIEW IF EXISTS routes;
 CREATE VIEW routes AS SELECT r.id, r.version, r.user_id, r.tstamp, r.changeset_id, n.v AS net, ref.v AS ref, dir.v AS dir
   FROM relations r
   JOIN relation_tags n ON n.k = 'network'::text AND n.relation_id = r.id
   JOIN relation_tags ref ON ref.k = 'ref'::text AND ref.relation_id = r.id
   JOIN relation_tags dir ON dir.k = 'direction'::text AND dir.relation_id = r.id;
