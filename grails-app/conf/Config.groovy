// The following is required to avoid 'objectDefinitionSource' error
// per: https://cvs.codehaus.org/browse/GRAILSPLUGINS-2166
import grails.plugins.springsecurity.SecurityConfigType

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

grails.mime.types = [ 
	html: ['text/html','application/xhtml+xml'],
	xml: ['text/xml', 'application/xml'],
	text: 'text-plain',
	js: 'text/javascript',
	rss: 'application/rss+xml',
	atom: 'application/atom+xml',
	css: 'text/css',
	csv: 'text/csv',
	pdf: 'application/pdf',
	rtf: 'application/rtf',
	excel: 'application/vnd.ms-excel',
	xls: 'application/vnd.ms-excel',
	ods: 'application/vnd.oasis.opendocument.spreadsheet',
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
		grails.serverURL = "https://tmcpe.ctmlabs.net/${appName}-${appVersion}"
		grails.casURL = "https://cas.ctmlabs.net/cas"
	}
	development {
		grails.serverURL = "https://localhost:8443/${appName ? appName : ( appname ? appname :  'tmcpe' )}"
		grails.casURL = "https://cas.ctmlabs.net/cas"
	}
	test {
		grails.serverURL = "http://192.168.0.2:8080/${appName}"
		grails.casURL = "https://cas.ctmlabs.net/cas"
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
	debug 'edu.uci.its.tmcpe' //,
	//'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
	//'edu.uci.its',
	//'org.springframework.security',
	//'org.springframework.security.web',
	//'org.springframework.security.cas',
	//'org.jasig.cas'
	
	//,'org.svenson.JSONParser'
	
	//    info  'org.codehaus.groovy.grails.web.servlet', // controllers
	//	  'org.codehaus.groovy.grails.web.pages', //  GSP
	//info   'edu.uci.its.tmcpe'
	
	warn   'org.mortbay.log'
}

vdsdata {
	couchdb {
		host = "192.168.0.2"
		db_suffix = "morehash"
	}      
}

// Added by the Joda-Time plugin:
grails.gorm.default.mapping = {
	"user-type" type: org.joda.time.contrib.hibernate.PersistentDateTime, class: org.joda.time.DateTime
	"user-type" type: org.joda.time.contrib.hibernate.PersistentDuration, class: org.joda.time.Duration
	"user-type" type: org.joda.time.contrib.hibernate.PersistentInstant, class: org.joda.time.Instant
	"user-type" type: org.joda.time.contrib.hibernate.PersistentInterval, class: org.joda.time.Interval
	"user-type" type: org.joda.time.contrib.hibernate.PersistentLocalDate, class: org.joda.time.LocalDate
	"user-type" type: org.joda.time.contrib.hibernate.PersistentLocalTimeAsString, class: org.joda.time.LocalTime
	"user-type" type: org.joda.time.contrib.hibernate.PersistentLocalDateTime, class: org.joda.time.LocalDateTime
	"user-type" type: org.joda.time.contrib.hibernate.PersistentPeriod, class: org.joda.time.Period
}

// Added by the Spring Security Core plugin:
grails.plugins.springsecurity.userLookup.userDomainClassName = 'edu.uci.its.auth.User'
grails.plugins.springsecurity.userLookup.authorityJoinClassName = 'edu.uci.its.auth.UserRole'
grails.plugins.springsecurity.authority.className = 'edu.uci.its.auth.Role'
grails.plugins.springsecurity.requestMap.className = 'edu.uci.its.auth.Requestmap'
grails.plugins.springsecurity.securityConfigType = grails.plugins.springsecurity.SecurityConfigType.Requestmap
//grails.plugins.springsecurity.registerLoggerListener = true
//grails.plugins.springsecurity.rejectIfNoRule = true


// For CAS spring security plugin
grails.plugins.springsecurity.cas.loginUri = '/login'
grails.plugins.springsecurity.cas.serviceUrl = "${grails.serverURL}/j_spring_cas_security_check"
grails.plugins.springsecurity.cas.serverUrlPrefix = "${grails.casURL}"
grails.plugins.springsecurity.cas.proxyCallbackUrl = "${grails.serverURL}/secure/receptor"
grails.plugins.springsecurity.cas.proxyReceptorUrl = '/secure/receptor'
// Single-sign-out
grails.plugins.springsecurity.logout.afterLogoutUrl = "${grails.casURL}/logout?service=${grails.serverURL}/"

grails.plugins.springsecurity.securityConfigType = SecurityConfigType.Annotation
grails.plugins.springsecurity.openid.domainClass = 'edu.uci.its.auth.OpenID'


// For LDAP spring security plugin
grails.plugins.springsecurity.ldap.context.managerDn = 'cn=Manager,dc=ctmlabs,dc=org'
grails.plugins.springsecurity.ldap.context.managerPassword = 'ctmlabs.org'
grails.plugins.springsecurity.ldap.context.server = 'ldap://hyperion.its.uci.edu:389'
grails.plugins.springsecurity.ldap.authorities.groupSearchBase ='ou=groups,dc=ctmlabs,dc=org'
grails.plugins.springsecurity.ldap.authorities.ldapGroupSearchFilter = 'uniquemember={0}'
grails.plugins.springsecurity.ldap.search.base = 'ou=people,dc=ctmlabs,dc=org'
ldap.mapper.userDetailsClass = 'inetOrgPerson'

// Search for explicit validation tags on classes that aren't domain classes
grails.validateable.packages = ['edu.uci.its.auth']

environments {
	production {
	    uiperformance {
		enabled=true
		debug = false
		statsEnabled = false
		html.compress = true
		html.debug = false
	    }
	}
	development {
	    uiperformance {
		enabled=false
		debug = true
		statsEnabled = true
		html.compress = true
		html.debug = true
	    }
	}
}
uiperformance.html.includePathPatterns = [".*\\.geojson"]
uiperformance.html.includeContentTypes = [ "text/geojson", "application/json" ]

uiperformance.exclusions = [
    "**/grails_logo.jpg",
    "**/dojo/**",
    "**/dojo-src/**",
    "**/navigation*/**",
    "**/tmcpe/**",
    "**/openlayers*/**",
    "**/jquery*/**",
    "**/d3/**",
    "**/polymaps/**",
]

uiperformance.bundles = [
    [type: 'js',
     name: 'application-core',
     files: ['application']
    ],
    [type: 'css',
     name: 'bundled',
     files: ['tmcpe',
	     'main',
	     'navigation'
	    ]
    ]
]
