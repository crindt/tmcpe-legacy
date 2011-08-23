dataSource {
    pooled = true
    driverClassName = "org.hsqldb.jdbcDriver"
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
            //dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            //url = "jdbc:hsqldb:mem:devDB"
	    driverClassName = 'org.postgis.DriverWrapper'
	    username = "postgres"
	    dbCreate = "update"
	    url = 'jdbc:postgresql://192.168.0.2:5432/tmcpe_test'
        }
    }
    test {
        dataSource {
            dbCreate = "update"
            url = "jdbc:hsqldb:mem:testDb"
        }
    }
    production {
        dataSource {
            //dbCreate = "update"
            //url = "jdbc:hsqldb:file:prodDb;shutdown=true"

	    driverClassName = 'org.postgis.DriverWrapper'
	    dbCreate = "update"
	    url('jdbc:postgresql://localhost:5432/tmcpe')
	    username('VDSUSER')
	    password('VDSPASSWORD')
        }
    }
}
