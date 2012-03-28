modules = {
	scaffolding {
		dependsOn 'jquery'
		//resource url: 'css/scaffolding.css'
		//resource url:
		resource url:"less/tmcpe-common.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_scaffolding'
		resource url: 'http://www.ctmlabs.net/ctmlabs/bootstrap/css/bootstrap.css'
		resource url: 'http://www.ctmlabs.net/ctmlabs/bootstrap/css/bootstrap-responsive.css'
		resource url: 'http://www.ctmlabs.net/css/ctmlnav.css'
		resource url: 'http://www.ctmlabs.net/ctmlabs/bootstrap/js/bootstrap.js'
		resource url: 'http://www.ctmlabs.net/css/master.css'
		resource url: "css/curl.css"
		//		resource url: 'http://www.ctmlabs.net/js/ctmlabs-banner.js?appname=TMCPE&appurl=http://tmcpe.ctmlabs.net/&fluid=true', linkOverride: 'http://www.ctmlabs.net/js/ctmlabs-banner.js?appname=TMCPE&appurl=http://tmcpe.ctmlabs.net/&fluid=true&redmineproject=tmcpe'
	}
}