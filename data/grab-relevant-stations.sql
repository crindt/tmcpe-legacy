select distinct 
       A.cad,B.stampdate,B.stamptime,B.unitin,B.unitout,
       B.device_number,B.status,B.activitysubject, 
---       substring(B.memo,'JSO *(.*?),.*') AS jso, 
---       substring(B.memo,'JNO *(.*?),.*') as jno, 
---       substring(B.memo,'AT *(.*?),.*') as at, 
       stations.name, B.memo, substring(B.memo,'J[NS]O *(?:EL )?([^ ]*).*') 

from ct_al_transaction as A 
left join ct_al_transaction as B on A.cad=B.cad 
left join ct_al_transaction AS C on C.cad=B.cad 
left join stations 
     on substring(B.memo,'J[NS]O *(?:EL )?(?:LA )?([^ ]*).*') 
     	like substring( stations.name, '^(?:EL )?(?:LA )?([^ ]*)' )  

where A.activitysubject='SIGALERT BEGIN' 
      and ( C.activitysubject='OPEN INCIDENT' 
      	    AND ( C.memo ~ '^5[- ]*[SN] ' 
	    	  or C.memo ~ '^[SN][- ]*5 ' ) ) 

order by stampdate,stamptime


