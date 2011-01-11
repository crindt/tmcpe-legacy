DROP TABLE IF EXISTS actlog.d12_activity_log CASCADE;
CREATE TABLE actlog.d12_activity_log (
    keyfield integer PRIMARY KEY,
    cad character varying(60) DEFAULT NULL::character varying,
    unitin character varying(20) DEFAULT NULL::character varying,
    unitout character varying(20) DEFAULT NULL::character varying,
    via character varying(30) DEFAULT NULL::character varying,
    op character varying(30) DEFAULT NULL::character varying,
    device_number integer,
    device_extra character varying(5) DEFAULT NULL::character varying,
    device_direction character(1) DEFAULT NULL::bpchar,
    device_fwy integer,
    device_name character varying(40) DEFAULT NULL::character varying,
    status character varying(30) DEFAULT NULL::character varying,
    activitysubject character varying(30) DEFAULT NULL::character varying,
    memo text DEFAULT NULL::character varying,
    stamp timestamp without time zone
);
CREATE INDEX idx_d12_activity_log_cad ON actlog.d12_activity_log( cad );
CREATE INDEX idx_d12_activity_log_stamp ON actlog.d12_activity_log( stamp );

DROP TABLE IF EXISTS actlog.d12_comm_log CASCADE;
CREATE TABLE actlog.d12_comm_log (
    keyfield integer PRIMARY KEY,
    cad character varying(60) DEFAULT NULL::character varying,
    unitin text DEFAULT NULL::text,
    unitout text DEFAULT NULL::text,
    via text DEFAULT NULL::text,
    op text DEFAULT NULL::text,
    device_number integer,
    device_extra text DEFAULT NULL::text,
    device_direction character(1) DEFAULT NULL::bpchar,
    device_fwy integer,
    device_name text DEFAULT NULL::text,
    status text DEFAULT NULL::text,
    activitysubject text DEFAULT NULL::text,
    memo text DEFAULT NULL::text,
    imms text DEFAULT NULL::text,
    made_contact char(1) DEFAULT NULL,
    stamp timestamp without time zone
);
CREATE INDEX idx_d12_comm_log_cad ON actlog.d12_comm_log( cad );
CREATE INDEX idx_d12_comm_log_stamp ON actlog.d12_comm_log( stamp );


DROP TABLE IF EXISTS actlog.icad CASCADE;
CREATE TABLE actlog.icad (
    keyfield integer PRIMARY KEY,
    logid character varying(40) NOT NULL,
    logtime character varying(80) DEFAULT NULL::character varying,
    logtype character varying(240) DEFAULT NULL::character varying,
    location character varying(240) DEFAULT NULL::character varying,
    area character varying(240) DEFAULT NULL::character varying,
    thomasbrothers character varying(80) DEFAULT NULL::character varying,
    tbxy character varying(40) DEFAULT NULL::character varying,
    d12cad character varying(80) DEFAULT NULL::character varying,
    d12cadalt character varying(80) DEFAULT NULL::character varying
);
CREATE INDEX idx_icad_d12cad ON actlog.icad( d12cad );
CREATE INDEX idx_icad_d12cadalt ON actlog.icad( d12cadalt );


ALTER TABLE actlog.icad OWNER TO postgres;

DROP TABLE IF EXISTS actlog.icad_detail;
CREATE TABLE actlog.icad_detail (
    keyfield SERIAL PRIMARY KEY,
    icad integer REFERENCES actlog.icad( keyfield ),
    stamp timestamp without time zone NOT NULL,
    detail character varying(1024)
);




SELECT DropGeometryColumn( 'actlog','incidents', 'location_geom' );
DROP TABLE IF EXISTS actlog.incidents CASCADE;
CREATE TABLE actlog.incidents (
       id SERIAL PRIMARY KEY NOT NULL,
       cad VARCHAR(40) UNIQUE,-- REFERENCES actlog.d12_activity_log( cad ),
       start_time TIMESTAMP,
       sigalert_begin INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       sigalert_end   INTEGER REFERENCES actlog.d12_activity_log( keyfield ),

       first_call     INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       verification   INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       lanes_clear    INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       incident_clear INTEGER REFERENCES actlog.d12_activity_log( keyfield ),

       location_vdsid INTEGER, -- REFERENCES...
       event_type VARCHAR( 80 )
);
SELECT AddGeometryColumn( 'actlog', 'incidents', 'location_geom', 4326, 'POINT', 2 );
CREATE INDEX idx_incidents_cad ON actlog.incidents( cad );
CREATE INDEX idx_incidents_start_time ON actlog.incidents( start_time );
CREATE INDEX idx_incidents_dow ON actlog.incidents( extract( 'dow' from start_time ) );

DROP TABLE IF EXISTS actlog.critical_events;
CREATE TABLE actlog.critical_events (
       id SERIAL PRIMARY KEY NOT NULL,
       log_id INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       event_type VARCHAR(40) NOT NULL,
       detail TEXT
);

DROP TABLE IF EXISTS actlog.performance_measures;
CREATE TABLE actlog.performance_measures (
       id SERIAL PRIMARY KEY NOT NULL,
       log_id INTEGER REFERENCES actlog.d12_activity_log( keyfield ),
       pmtext VARCHAR(120) NOT NULL,
       pmtype VARCHAR(80) NOT NULL,
       blocklanes VARCHAR(80),
       detail TEXT
);

DROP VIEW IF EXISTS actlog.full_incidents;
CREATE VIEW actlog.full_incidents AS
       SELECT i.*, 
       	      CASE WHEN location_geom IS NOT NULL THEN i.location_geom 
	      	   WHEN tvd.geom IS NOT NULL THEN tvd.geom 
		   ELSE NULL 
	           END AS best_geom 
	      FROM actlog.incidents i 
	      	   LEFT JOIN tbmap.tvd tvd ON ( i.location_vdsid = tvd.id );
