for i in `psql -U postgres -t tmcpe_test -c "select cad from actlog.incidents i join tmcpe.incident_impact_analysis iia ON (i.id=iia.incident_id) left join tmcpe.incident_facility_impact_analysis ifia ON (iia.id=ifia.incident_impact_analysis_id) WHERE event_type='INCIDENT' AND sigalert_begin IS NOT NULL AND location_geom IS NOT NULL AND ifia.computed_incident_clear_time IS NULL AND i.start_time < '2010-01-01' AND i.start_time > '2009-01-01'order by i.start_time;"`; 
    do echo ========== $i ==============; 
    export exists="true"
    ls $i-*.lst && export exists="true"
    if [ ".$exists" == ".true" ]; then
       perl import-al.pl --dc-vds-downstream-fudge=1.5 --dc-vds-upstream-fallback=6 --dc-prewindow=20 --dc-postwindow=90 --date-from=2010-07-15 --dc-use-eq4567 --dc-use-eq3 --dc-min-obs-pct=20 --dc-limit-loading-shockwave=20 --dc-limit-clearing-shockwave=20 --dc-use-eq8 --dc-use-eq8b --dc-unknown-evidence-value=0.50 --dc-dont-compute-vds-upstream-fallback --dc-band=1 not-40-1210 --verbose --use-osm-geom --only-sigalerts --dc-cplex-optcr=0 --dc-gams-reslim=500 --dc-weight-for-distance=3 --dc-bound-incident-time not-505-031509 --verbose --skip-al-import --skip-rl-import --skip-icad-import --replace-existing $i ; 
    else
       echo NO LST FILE
    fi
done
