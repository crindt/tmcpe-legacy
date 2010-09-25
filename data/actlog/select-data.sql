select q.*,	CASE WHEN ( 
       		     days_in_avg < ?
       		     OR o_pct_obs < ?
		     )
		THEN 0.5 
		ELSE 
			CASE WHEN o_spd<a_spd-?*sd_spd
				THEN 0
				ELSE 1
			END 
		END AS p_j_m
from (
select o.vdsid, o.stamp, max(o.cnt_all) o_vol, max(o.occ_all) o_occ, max(o.spd_all) o_spd, max(o.pct_obs_all) o_pct_obs,
       count(a.cnt_all) days_in_avg, sum(a.samples_all)/count(a.cnt_all) avg_samples, avg(a.pct_obs_all) a_pct_obs,
       avg(a.cnt_all) a_vol, avg(a.occ_all) a_occ, avg(a.spd_all) a_spd, 
       stddev(a.cnt_all) sd_vol, stddev(a.occ_all) sd_occ, stddev(a.spd_all) sd_spd
from pems_5min o 
     left join pems_5min a on (
     	  a.vdsid=o.vdsid AND 
     	  o.stamp::time=a.stamp::time AND 
	  extract( 'dow' from o.stamp ) = extract( 'dow' from a.stamp ) 
	  ) 
WHERE o.vdsid=? AND 
      o.stamp between ? AND ?
      AND a.pct_obs_all > ?
GROUP BY o.vdsid,o.stamp
) q;
