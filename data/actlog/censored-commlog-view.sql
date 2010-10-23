create or replace view actlog.d12_comm_log_censored AS
       select keyfield, cad, unitin, unitout, via, op, device_number, 
       	      device_extra, device_direction, device_fwy, device_name, 
	      status, activitysubject, 
	      regexp_replace( memo, E'\\m\\d{3}[-\\s]+\\d{4}\\M', 'XXX-XXXX', 'g' ) as memo, 
	      imms, made_contact, stamp 
       from actlog.d12_comm_log; 

create or replace view actlog.d12_activity_log_censored AS
       select keyfield, cad, unitin, unitout, via, op, device_number, 
       	      device_extra, device_direction, device_fwy, device_name, 
	      status, activitysubject, 
	      regexp_replace( memo, E'\\m\\d{3}[-\\s]+\\d{4}\\M', 'XXX-XXXX', 'g' ) as memo, 
	      stamp 
       from actlog.d12_activity_log; 
