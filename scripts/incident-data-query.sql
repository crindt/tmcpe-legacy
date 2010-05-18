select c.cad,   
       min((c.stampdate || ' ' || c.stamptime)::timestamp) as st, 
       min((fc.stampdate || ' ' || fc.stamptime)::timestamp) as fc, 
       min((v.stampdate || ' ' || v.stamptime)::timestamp) as v, 
       min((fu.stampdate || ' ' || fu.stamptime)::timestamp) as fu 
from actlog.d12_activity_log c
     left join actlog.d12_activity_log fc on ( fc.cad=c.cad AND fc.status='FIRST CALL' )
     left join actlog.d12_activity_log v on ( v.cad=c.cad AND v.activitysubject='VERIFICATION' )
     left join actlog.d12_activity_log fu on  ( fu.cad=c.cad AND fu.status ~~ '10-97%' )
WHERE c.keyfield in ( select min(keyfield) from actlog.d12_activity_log WHERE cad <> '' group by cad) group by c.cad ;



--- diagnostic
select count(fc),count(v), count(fu) from (select c.cad, min((fc.stampdate || ' ' || fc.stamptime)::timestamp) as fc, 
       min((v.stampdate || ' ' || v.stamptime)::timestamp) as v, 
       min((fu.stampdate || ' ' || fu.stamptime)::timestamp) as fu 
from actlog.d12_activity_log c
     left join actlog.d12_activity_log fc on ( fc.cad=c.cad AND fc.status='FIRST CALL' )
     left join actlog.d12_activity_log v on ( v.cad=c.cad AND v.activitysubject='VERIFICATION' )
     left join actlog.d12_activity_log fu on  ( fu.cad=c.cad AND fu.status ~~ '10-97%' )
WHERE c.keyfield in ( select min(keyfield) from actlog.d12_activity_log WHERE cad <> '' group by cad) group by c.cad ) qq ;


DROP TABLE IF EXISTS actlog.timestamps;
SELECT keyfield,(stampdate || ' ' || stamptime)::timestamp as ts
       INTO actlog.timestamps 
       FROM actlog.d12_activity_log;
ALTER TABLE actlog.timestamps ADD PRIMARY KEY( keyfield );
CREATE INDEX idx_actlog_timestamps_ts ON actlog.timestamps( ts );


--- Helper view
DROP VIEW IF EXISTS actlog.al CASCADE;
CREATE VIEW actlog.al AS
SELECT actlog.d12_activity_log.*,actlog.timestamps.ts 
       FROM actlog.d12_activity_log 
       	    JOIN actlog.timestamps USING ( keyfield ) 
       ORDER BY actlog.timestamps.ts;


--- HERE, we want a list of all cads with their onset time
DROP VIEW IF EXISTS actlog.incidents CASCADE;
CREATE VIEW actlog.incidents AS
SELECT cad, min( ts ) as start_time
       FROM actlog.al
       WHERE cad ~ E'^\\d+-\\d+'
       GROUP BY cad;

--- All incidents
--- This uses a pgsql extension described here: http://stackoverflow.com/questions/1194525/get-primary-key-of-aggregated-group-by-sql-query-using-postgresql
DROP VIEW IF EXISTS actlog.incident_data;
CREATE VIEW actlog.incident_data AS
select distinct on (qqq.cad) qqq.*, fm.memo, v-first_call as vtime, fu-first_call as futime, sae-sab as satime,sae-first_call as incdur,et-st as logdur
FROM (
select qq.*,(case when fc IS NULL THEN st ELSE fc END) as first_call
from (SELECT distinct on (c.cad)
     	     c.cad,
       	     min(c.ts) as st, 
       	     min(fc.ts) as fc, 
       	     min(v.ts) as v, 
       	     min(fu.ts) as fu,
       	     min(sab.ts) as sab,
       	     min(sae.ts) as sae,
	     max(c.ts) as et
      FROM actlog.al c
      	   LEFT JOIN actlog.al fc on ( fc.cad=c.cad AND fc.status='FIRST CALL' )
     	   LEFT JOIN actlog.al v on ( v.cad=c.cad AND v.activitysubject='VERIFICATION' )
     	   LEFT JOIN actlog.al fu on  ( fu.cad=c.cad AND fu.status ~~ '10-97%' )
     	   LEFT JOIN actlog.al sab on  ( sab.cad=c.cad AND sab.activitysubject = 'SIGALERT BEGIN' )
     	   LEFT JOIN actlog.al sae on  ( sae.cad=c.cad AND sae.activitysubject = 'SIGALERT END' )
      WHERE c.cad
      	    in ( SELECT cad from actlog.incidents )
      GROUP BY c.cad
) qq 
) qqq
LEFT JOIN actlog.al fm on ( fm.cad=qqq.cad AND fm.memo <> '' )
ORDER BY qqq.cad, fm.ts asc
;




--- average verification time in seconds
select avg(extract( epoch from vtime ) ) from (select * from actlog.incident_data where st between '2007-01-01' AND '2008-01-01' AND vtime is not null AND vtime < '01:00' order by st)q;



--- FIELD UNIT TRACKING PER CAD
DROP VIEW IF EXISTS actlog.incident_units CASCADE;
CREATE VIEW actlog.incident_units AS
SELECT inc.cad as icad,inc.start_time,al.* 
       FROM actlog.al al
            JOIN actlog.incidents inc USING ( cad )
       WHERE status ~~ '10-%'
       	     AND unitin ~ E'^\\d+-W.*'
       ORDER BY inc.start_time,al.cad,unitin,ts;
