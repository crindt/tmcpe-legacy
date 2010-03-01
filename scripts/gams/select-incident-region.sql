--- This function is used to negate the postmile of north- and east-bound
--- facilities as a means to sort and select the most downstream station
CREATE OR REPLACE FUNCTION dsign( CHARACTER(1) ) RETURNS INTEGER
	AS 'SELECT CASE WHEN $1=\'N\' OR $1=\'E\' THEN -1 ELSE 1 END'
	LANGUAGE SQL
	IMMUTABLE;

--- select all stations 10 miles upstream of the
---EXPLAIN
---EXPLAIN ANALYZE
SELECT ct_al_transaction.cad,stations.fwy,stations.dir,stations.id,
	dsign( stations.dir )*stations.abs_pm as abs_pm,
	distance( min(incloc.inc_geom), min(stations.station_geom) ) as st_dist,
	dow,
	min(obs5.date) as date,
	obs5avgs.timeofday,
	count(*) AS n_samp,
	max(avg_spd) as avg_spd,
	max(stddev_spd) as stddev_spd,
	max(avg_pctobs) AS avg_pctobs,
	min(obs5.spd) AS incspd, 
	max(obs5.pctobs) AS incpctobs,
	min(obs5.flw) AS incflw,
	max(avg_flw) as avg_flw,
	CASE WHEN max( avg_pctobs ) < 10 
		THEN 0.5 
		ELSE 
			CASE WHEN min(obs5.spd)<max(avg_spd)-?*max(stddev_spd) 
				THEN 0 
				ELSE 1 
			END 
		END AS p_j_m

--- the first table (zzz) we select from is a subquery of the furthest 
--- downstream station for each facility within a 2.5 km radius of the incident
from (
	--- This query grabs the actual id of the most downstream mainline
	--- station as returned by the following subquery
	SELECT zz.cad,id,zz.fwy,zz.dir,zz.pm FROM stations 
	join ( 
		--- NOTE: pm here is the most downstream postmile for the
		---       given cad,fwy,dir combination.  We'll use this
		---       in the outer query to select upstream stations
		---       of interest
		SELECT cad,fwy,dir,min(pm) AS pm
		FROM ( 
			--- This selects all stations with 2.5km of the each incident
			--- NOTE: we negate the postmile of N and E bound facilities
			---       as a trick to select the furthest downstream detector
			---       for each affected facility
			SELECT cad,fwy,dir,stations.id,dsign(dir)*max(abs_pm) AS pm
			FROM stations,incloc
			WHERE ST_DWithin( incloc.inc_geom, stations.station_geom, 2500 ) AND stations.type='ML' 
---				 and cad='101-113007' 
---				 AND cad='114-092107'
---				AND cad='101-113007'
---				AND cad='83-113007'
---				AND cad='520-122007'
---				AND incloc.cad='138-112807'
				AND cad=?
			GROUP BY cad,fwy,dir,stations.id
			ORDER BY fwy,dir,dsign(dir)*max(abs_pm) 
		) AS z 
		GROUP BY cad,fwy,dir 
	) AS zz 
	ON stations.fwy=zz.fwy AND stations.dir=zz.dir AND stations.abs_pm=abs(zz.pm) 
--AND type='ML'
) AS zzz 
--- join the activity log transaction 'open incident' to each cad/station record
	INNER JOIN ct_al_transaction ON ct_al_transaction.cad=zzz.cad AND ct_al_transaction.activitysubject='OPEN INCIDENT'
	INNER JOIN incloc on zzz.cad=incloc.cad,

	--- now, well combine all stations with their observations subject to
	--- certain constraints we put in the where clause 
	stations 
---	AND yrobs5.pctobs>=100
		LEFT JOIN obs5 ON stations.id=obs5.station
		INNER JOIN obs5avgs 
			ON obs5.station=obs5avgs.station 
			AND extract( dow FROM obs5.date )=obs5avgs.dow 
			AND obs5.timeofday = obs5avgs.timeofday
WHERE 
	--- select all mainline stations within 10 miles of the furthest upstream station for each facility
	stations.dir=zzz.dir 
		AND stations.fwy=zzz.fwy 
		AND dsign(zzz.dir)*stations.abs_pm >= zzz.pm 
		AND dsign(zzz.dir)*stations.abs_pm <= (zzz.pm+?) -- note: zzz.pm is negative if N or E bound
---		AND avg_pctobs >= 100
--		AND type = 'ML'

	--- sample observations for the 4 hours following the incident
	AND obs5.timeofday >= ct_al_transaction.stamptime - interval ? AND obs5.timeofday <= ct_al_transaction.stamptime + interval ?

	AND obs5.date=ct_al_transaction.stampdate 

---	AND ct_al_transaction.stampdate='2007-09-21'
---	AND ct_al_transaction.cad='101-113007'
---	AND ct_al_transaction.cad='114-092107'
GROUP BY ct_al_transaction.cad, stations.id, stations.dir, stations.fwy, stations.abs_pm, dow,obs5avgs.timeofday
ORDER BY ct_al_transaction.cad, stations.dir, stations.fwy, dsign(stations.dir)*stations.abs_pm,obs5avgs.timeofday
	 asc
