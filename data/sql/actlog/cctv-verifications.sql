--- simple query to compute CCTV verification times
select cad, stime, vtime, (vtime-stime) as dt 
from 
(
     select q.cad, min(stime) as stime, min(vtime) as vtime
     from
     ( 
       select al1.cad,
       	      min( (al2.stampdate || ' ' || al2.stamptime )::time ) as stime, 
	      (al1.stampdate || ' ' || al1.stamptime)::time as vtime
       from actlog.d12_activity_log al1 
     	    left join actlog.d12_activity_log al2 using (cad) 
       where al1.memo ~* '.*visual.*per.*cctv.*'
      	     or al1.activitysubject ~* 'verification'
     	     AND al1.stampdate between '2007-01-01' 
	     and '2008-01-01' 
       group by al1.cad,al1.stampdate,al1.stamptime 
     ) q
     group by q.cad
) qq;