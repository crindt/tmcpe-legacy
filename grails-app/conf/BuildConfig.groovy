grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir	= "target/test-reports"
grails.project.war.file = "target/${appName}-${appVersion}.war"
grails.project.dependency.resolution = {
    inherits "global" // inherit Grails' default dependencies
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    repositories {        
        grailsPlugins()
        grailsHome()

        // uncomment the below to enable remote dependency resolution
        // from public Maven repositories
        //mavenLocal()
        mavenCentral()
        mavenRepo "http://snapshots.repository.codehaus.org"
        mavenRepo "http://repository.codehaus.org"
        mavenRepo "http://mirrors.ibiblio.org"
        //mavenRepo "http://download.java.net/maven/2/"
        mavenRepo "http://repository.jboss.com/maven2/"
		mavenRepo "http://m2repo.spockframework.org/snapshots/"
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
        // runtime 'mysql:mysql-connector-java:5.1.5'
        // for hibernate-spatial-postgres
        runtime 'postgresql:postgresql:9.0-801.jdbc4'
        compile 'jts:jts:1.8'

        // fixes for 1.3.7->2.0 upgrade related to joda-time: 
        // see: http://grails.1312388.n4.nabble.com/Unable-to-run-grails-1-3-7-application-in-Grails-2-0-0-tp4234628p4236822.html
        /* FIXME: JODA
        compile 'joda-time:joda-time-hibernate:1.3' 
        compile 'org.jadira.usertype:usertype.jodatime:1.9' 
        */
    }
    plugins {
        // supporting missing deps for hibernate-spatial-postgis
        //compile ":plugin-config:0.1.5"

		// testing
		compile ':spock:0.6-SNAPSHOT'

		// security
		runtime ":spring-security-cas:1.0.2"
		runtime ":spring-security-core:1.2.7"
		runtime ":spring-security-ldap:1.0.5"

		// resources
		runtime ":jquery:1.7.1"
		runtime ":resources:1.1.6"
		runtime ":zipped-resources:1.0"
		compile ":lesscss-resources:1.0.1"
		compile ":cdn-resources:0.2"
		runtime ":cached-resources:1.0"
        compile ":cache-headers:1.0.4" // redq'd by cached-resources

		// databases
		compile ":mongodb:1.0.0.RC4"
        compile ":hibernate-spatial:0.0.4"

		// app support code
		runtime ":javascript-url-mappings:0.1.1"
		runtime ":browser-detection:0.3.3"

		// layout
		compile ":twitter-bootstrap:2.0.0.16"
		runtime ':fields:1.0.1' // req'd by twitter bootstrap
		runtime ":markdown:1.0.0.RC1"
		
    }

}
