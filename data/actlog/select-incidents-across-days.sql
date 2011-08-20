select qqq.cad from (
select qq.id,
       qq.cad
       ,min(fivemin) start_time,max(fivemin) end_time 
from 
( select q.id,q.cad,q.ifia_id,max(anas.id) anas_id 
  from 
  ( select i.id,i.cad,max(ifia.id) ifia_id 
    from actlog.full_incidents i 
    	 join tmcpe.incident_impact_analysis iia on ( iia.incident_id = i.id ) 
	 join tmcpe.incident_facility_impact_analysis ifia on ( iia.id = ifia.incident_impact_analysis_id ) 
    group by i.id,i.cad 
  ) q 
       left join tmcpe.analyzed_section anas on (anas.analysis_id = q.ifia_id) 
  group by q.id,q.cad,ifia_id
) qq 
     left join tmcpe.incident_section_data on (section_id = anas_id) 
group by qq.id,qq.cad
) qqq
where start_time::date <> end_time::date AND start_time > '2009-01-01';



