dataSource {
    pooled = true
//     driverClassName = "org.h2.Driver"
    username = "sa"
    password = ""
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
        dataSource {
            url = 'jdbc:postgresql://192.168.0.2:5432/tmcpe_test'
            dbCreate = "update"
            username = "postgres"
            password = ''
            loggingSql = false
            driverClassName = "org.postgresql.Driver"
            dialect = org.hibernatespatial.postgis.PostgisDialect
        }
        dataSource_vds { 
            url = 'jdbc:postgresql://localhost:5432/spatialvds'
            username = 'VDSUSER'
            password = 'VDSPASSWORD'
            readOnly = true
            dbCreate = 'update'
            driverClassName = "org.postgresql.Driver"
            dialect = org.hibernatespatial.postgis.PostgisDialect
        }
    }
    test {
        dataSource {
            dbCreate = "update"
            url = "jdbc:h2:mem:testDb"
        }
    }
    production {
        dataSource {
            url = 'jdbc:postgresql://localhost:5433/tmcpe_v0_9_7'
            dbCreate = "update"
            username = 'postgres'
            password = ''
            loggingSql = false
            driverClassName = "org.postgresql.Driver"
            dialect = org.hibernatespatial.postgis.PostgisDialect
        }
        dataSource_vds { 
            url = 'jdbc:postgresql://localhost:5432/spatialvds'
            username = 'VDSUSER'
            password = 'VDSPASSWORD'
            readOnly = true
            dbCreate = 'update'
            driverClassName = "org.postgresql.Driver"
            dialect = org.hibernatespatial.postgis.PostgisDialect
        }
    }
}

/* Added by the Hibernate Spatial Plugin. */
dataSource {
   driverClassName = "org.postgresql.Driver"
   dialect = org.hibernatespatial.postgis.PostgisDialect
}
