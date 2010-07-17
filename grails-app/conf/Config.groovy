// locations to search for config files that get merged into the main config
// config files can either be Java properties files or ConfigSlurper scripts

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if(System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      geojson: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data',
                      kml: 'application/vnd.google-earth.kml+xml .kml'
                    ]
// The default codec used to encode data with ${}
grails.views.default.codec="none" // none, html, base64
grails.views.gsp.encoding="UTF-8"
grails.converters.encoding="UTF-8"

// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true

// set per-environment serverURL stem for creating absolute links
environments {
    production {
        grails.serverURL = "http://parsons.its.uci.edu{$appName}"
    }
    development {
        grails.serverURL = "http://192.168.0.2:8080/${appName}"
    }
    test {
        grails.serverURL = "http://192.168.0.2:8080/${appName}"
    }

}

// log4j configuration
log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    //
    appenders {
	file name:'file', file:'mylog.log'
        console name:'stdout', layout:pattern(conversionPattern: '%c{2} %m%n')
    }

    root {
//        debug 'console', 'file'
        info 'console', 'file'
        additivity = true
    }

    error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
	       'org.codehaus.groovy.grails.web.pages', //  GSP
	       'org.codehaus.groovy.grails.web.sitemesh', //  layouts
	       'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
	       'org.codehaus.groovy.grails.web.mapping', // URL mapping
	       'org.codehaus.groovy.grails.commons', // core / classloading
	       'org.codehaus.groovy.grails.plugins', // plugins
	       'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
	       'org.springframework',
               'edu.uci.its.tmcpe',
	       'org.hibernate'

/*
    debug 'org.jcouchdb',
          'org.codehaus.groovy.grails.plugins.starksecurity',
          'edu.uci.its',
          'edu.uci.its.tmcpe',
          'org.codehaus.groovy.grails.web.servlet', // controllers
          'org.codehaus.groovy'
*/
    debug 'edu.uci.its.tmcpe',
          'edu.uci.its'

          //,'org.svenson.JSONParser'

//    info  'org.codehaus.groovy.grails.web.servlet', // controllers
//	  'org.codehaus.groovy.grails.web.pages', //  GSP
    info   'edu.uci.its.tmcpe'

    warn   'org.mortbay.log'
}

vdsdata {
couchdb {
      host = "localhost"
      db_suffix = "morehash"
}      
}
