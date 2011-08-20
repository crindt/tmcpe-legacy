drop view find_data_gaps;

create view find_data_gaps as select i.cad, i.start_time, count(case when isd.vol is null then 1 else NULL end) as bad,count(case when isd.vol is not null then 1 else NULL end) as good from actlog.incidents i join tmcpe.incident_impact_analysis iia on  (i.id = iia.incident_id) left join tmcpe.incident_facility_impact_analysis ifia on (iia.id = ifia.incident_impact_analysis_id ) left join tmcpe.analyzed_section ansec on (ifia.id = ansec.analysis_id) left join tmcpe.incident_section_data isd on (ansec.id=isd.section_id) group by i.cad,i.start_time;

create view find_data_gaps2 as select i.cad, ansec.section_id, min(isd.fivemin) mintime,max(isd.fivemin) maxtime, count(case when isd.vol is null then 1 else NULL end) as bad,count(case when isd.vol is not null then 1 else NULL end) as good from actlog.incidents i join tmcpe.incident_impact_analysis iia on  (i.id = iia.incident_id) left join tmcpe.incident_facility_impact_analysis ifia on (iia.id = ifia.incident_impact_analysis_id ) left join tmcpe.analyzed_section ansec on (ifia.id = ansec.analysis_id) left join tmcpe.incident_section_data isd on (ansec.id=isd.section_id) group by i.cad,ansec.section_id;

psql -U postgres -t  tmcpe_test -c "select start_time,start_time::date as date,cad,case when good = 0 THEN 10000000000000 ELSE 1.0*bad/good END as ratio from ( select * from find_data_gaps where start_time > '2009-03-01' limit 500) q order by ratio desc,start_time asc"


psql -U postgres -t  tmcpe_test -c "select cad from ( select start_time,start_time::date as date,cad,case when good = 0 THEN 10000000000000 ELSE 1.0*bad/good END as ratio from ( select * from find_data_gaps where start_time > '2009-03-01' ) q order by ratio desc,start_time asc ) qq where qq.ratio>.95"


psql -U postgres -t  tmcpe_test -c "select section_id,mintime,maxtime from (select cad,section_id, mintime,maxtime,case when good = 0 THEN 10000000000000 ELSE 1.0*bad/good END as ratio from ( select * from find_data_gaps2 where mintime > '2009-03-01') q order by mintime asc,cad) qq where ratio>.95"



# THIS COMMAND PRETTY MUCH LOADS MISSING DATA IN
psql -U postgres -t  tmcpe_test -c "select section_id,mintime,maxtime from (select cad,section_id, mintime,maxtime,case when good = 0 THEN 10000000000000 ELSE 1.0*bad/good END as ratio from ( select * from find_data_gaps2 where mintime > '2009-03-01') q order by mintime asc,cad) qq where ratio>.95" | perl -F'/\s*\|\s*/'  -ane 'my @args = map { s/^\s*//g;chomp($_);$_ } @F; system "ssh crindt\@localhost cd pems \\\; perl push-pems-5min.pl --vds=$args[0] --from=\\\"$args[1]\\\" --to=\\\"$args[2]\\\"\n" if ( @args && $args[1] ne "" && $args[2] ne "" );' 
