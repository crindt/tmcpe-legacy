datasources = {

    datasource(name: 'ds2_devel') {
        driverClassName('org.postgis.DriverWrapper')
//        url('jdbc:postgresql://192.168.0.2:5432/osm')
//        url('jdbc:postgresql://parsons.its.uci.edu:5432/tmcpe')
        url('jdbc:postgresql://192.168.0.2:5432/tmcpe_test')
//        url('jdbc:postgresql://192.168.0.2:5433/osm')
        username('postgres')
        password('')
//        readOnly(false)
        domainClasses([edu.uci.its.tmcpe.TmcLogEntry,/*edu.uci.its.tmcpe.Incident,*/edu.uci.its.tmcpe.ProcessedIncident/*,edu.uci.its.tmcpe.AnalyzedIncident*/,edu.uci.its.tmcpe.FacilitySection,edu.uci.its.tmcpe.IncidentImpactAnalysis,edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis,edu.uci.its.tmcpe.TmcFacilityImpactAnalysis,edu.uci.its.tmcpe.AnalyzedSection,edu.uci.its.tmcpe.IncidentSectionData,edu.uci.its.tmcpe.Icad,edu.uci.its.tmcpe.IcadDetail,edu.uci.its.tmcpe.TmcPerformanceMeasures,edu.uci.its.testbed.Vds,edu.uci.its.tmcpe.CommLogEntry])
        dbCreate('update')
        loggingSql(true)
        dialect(org.postgis.hibernate.PostGISDialect)
//        dialect(org.hibernatespatial.postgis.PostGISDialect) 
        environments(['development','test'])
        hibernate {
            cache {
                use_second_level_cache(true)
                use_query_cache(true)
                provider_class('org.hibernate.cache.EhCacheProvider') 
            }
        }
    }

    datasource(name: 'ds2_prod') {
        driverClassName('org.postgis.DriverWrapper')
//        url('jdbc:postgresql://192.168.0.2:5432/osm')
//        url('jdbc:postgresql://parsons.its.uci.edu:5432/tmcpe')
        url('jdbc:postgresql://localhost:5432/tmcpe_test')
//        url('jdbc:postgresql://192.168.0.2:5433/osm')
        username('VDSUSER')
        password('VDSPASSWORD')
//        readOnly(false)
        domainClasses([edu.uci.its.tmcpe.TmcLogEntry/*,edu.uci.its.tmcpe.Incident*/,edu.uci.its.tmcpe.ProcessedIncident/*,edu.uci.its.tmcpe.AnalyzedIncident*/,edu.uci.its.tmcpe.FacilitySection,edu.uci.its.tmcpe.IncidentImpactAnalysis,edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis,edu.uci.its.tmcpe.TmcFacilityImpactAnalysis,edu.uci.its.tmcpe.AnalyzedSection,edu.uci.its.tmcpe.IncidentSectionData,edu.uci.its.tmcpe.Icad,edu.uci.its.tmcpe.IcadDetail,edu.uci.its.tmcpe.TmcPerformanceMeasures,edu.uci.its.testbed.Vds,edu.uci.its.tmcpe.CommLogEntry])
        dbCreate('update')
//        loggingSql(true)
        dialect(org.postgis.hibernate.PostGISDialect)
//        dialect(org.hibernatespatial.postgis.PostGISDialect) 
        environments(['production'])
        hibernate {
            cache {
                use_second_level_cache(true)
                use_query_cache(true)
                provider_class('org.hibernate.cache.EhCacheProvider') 
            }
        }
    }

/*
    datasource(name: 'ds3_devel') {
        driverClassName('org.postgis.DriverWrapper')
//        url('jdbc:postgresql://192.168.0.2:5432/osm')
//        url('jdbc:postgresql://parsons.its.uci.edu:5432/tmcpe')
        url('jdbc:postgresql://192.168.0.2:5432/tmcpe_help_test')
//        url('jdbc:postgresql://192.168.0.2:5433/osm')
        username('postgres')
        password('')
//        readOnly(false)
        domainClasses([edu.uci.its.tmcpe.Help])
        dbCreate('update')
//        loggingSql(true)
        dialect(org.postgis.hibernate.PostGISDialect)
//        dialect(org.hibernatespatial.postgis.PostGISDialect) 
        environments(['development','test'])
        hibernate {
            cache {
                use_second_level_cache(true)
                use_query_cache(true)
                provider_class('org.hibernate.cache.EhCacheProvider') 
            }
        }
    }
*/

    datasource(name: 'ds4') {
        driverClassName('org.postgis.DriverWrapper')
//        url('jdbc:postgresql://192.168.0.2:5431/osm6b')
//        url('jdbc:postgresql://localhost:5432/osm6b')
//        url('jdbc:postgresql://localhost:5432/osm')
        url('jdbc:postgresql://localhost/osm')
        username('VDSUSER')
        password('VDSPASSWORD')
        readOnly(true)
        domainClasses([])
        dbCreate('update')
//        loggingSql(true)
        dialect(org.postgis.hibernate.PostGISDialect)
        environments(['development','test','production'])
        hibernate {
            cache {
                use_second_level_cache(true)
                use_query_cache(true)
                provider_class('org.hibernate.cache.EhCacheProvider')
            }
        }
    }
    // datasource(name: 'ds5') {
    //     driverClassName('com.mysql.jdbc.Driver')
    //     url('jdbc:mysql://localhost/actlog')
    //     username('d12')
    //     password('rbz44v5h')
    //     readOnly(true)
    //     domainClasses([edu.uci.its.tmcpe.TmcLogEntry])
    //     dbCreate('update')
    //     loggingSql(true)
    //     environments(['development','test','production'])
    //     dialect(org.hibernate.dialect.MySQLMyISAMDialect)
    //     hibernate {
    //         cache {
    //             use_second_level_cache(true)
    //             use_query_cache(true)
    //             provider_class('org.hibernate.cache.EhCacheProvider')
    //         }
    //     }
    // }
    datasource(name: 'ds6') {
        driverClassName('org.postgis.DriverWrapper')
        url('jdbc:postgresql://localhost:5432/spatialvds')
        username('VDSUSER')
        password('VDSPASSWORD')
        readOnly(true)
        domainClasses([edu.uci.its.testbed.VdsRawData,edu.uci.its.testbed.VdsData])
        dbCreate('update')
//        loggingSql(true)
        dialect(org.postgis.hibernate.PostGISDialect)
        hibernate {
            cache {
                use_second_level_cache(true)
                use_query_cache(true)
                provider_class('org.hibernate.cache.EhCacheProvider')
            }
        }
    }
}
