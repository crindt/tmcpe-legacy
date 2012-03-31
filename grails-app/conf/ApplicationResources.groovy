/* @(#)ApplicationResources.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */

modules = { 
    common  { 
        resource url:"js/tmcpe/common.js"
		dependsOn 'bootstrap-less'
		resource url:"less/tmcpe-bootstrap.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_common'
		resource url:"less/tmcpe-common.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_common'
		resource url: "css/curl.css"
        //resource url:"less/tmcpe-base.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_common'
    }

	'docs' {
	    dependsOn 'common'
		resource url: "less/tmcpe-docs.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_docs'
		resource url: "css/twitter-docs.css"
		resource url: "js/tmcpe/docs.js"
	}

    'jquery-tools' { 
        dependsOn "jquery"
        resource url:"js/jquery.tools.min.js"
    }

    dthree { 
        resource url:"js/d3.js"
        resource url:"js/d3.time.js"
        resource url:"js/d3.geom.js"
    }
    
    stdui { 
        dependsOn "dthree"
        resource url:"js/underscore.js"
        resource url:"js/mustache.js"
        //resource url:"less/tabs-no-images.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_stdui'
        resource url:"less/range-input.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_stdui'
    }

    polymaps { 
        resource url:"js/polymaps.js"
        resource url:"js/polymaps_cluster.js"
    }

    datatables { 
        dependsOn "jquery"
        resource url:"js/jquery.format-1.2.min.js"
        resource url:"js/jquery.dataTables.js"
        resource url:"js/jquery.dataTables.js"
		resource url:"js/datatables/fixed-header/FixedHeader.min.js"
    }

    'tmcpe-incident-summary' { 
        dependsOn "dthree"
        resource url:"js/tmcpe/incident-summary.js"
        resource url:"less/tmcpe-incident-summary.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    }

    'tmcpe-map-show' { 
        dependsOn "stdui,datatables,dthree,polymaps"
        resource url:"js/tmcpe/map-show.js"
        resource url:"less/tmcpe-map-show.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_tmcpe-map-show'
    }

    'tmcpe-incident-tsd' {
        dependsOn "stdui,datatables,dthree,polymaps"
        resource url:"js/tmcpe/incident-tsd.js"
        resource url:"less/tmcpe-incident-tsd.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_tmcpe-incident-tsd'
    }

	/*
	'ctmlabs-bar-remote' { 
		dependsOn 'jquery'
		resource url: 'http://anne.its.uci.edu/css/ctmlbanner.css'
		resource url: 'http://anne.its.uci.edu/loggedout/banner.js'
		resource url: 'http://anne.its.uci.edu/js/ctmlbanner.js'
	}
	*/

	'ctmlabs-bar' { 
		//dependsOn 'ctmlabs-bar-remote'
		resource url: "css/ctmlbanner.css"
        resource url: "less/ctmlabs-menu.less", attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_ctmlabs-bar'
	}

	
    
}
