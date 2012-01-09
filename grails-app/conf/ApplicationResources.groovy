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
        resource url:"less/tmcpe-base.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_common'
    }

    'jquery-tools' { 
        dependsOn "jquery"
        resource url:"js/jquery.tools.min.js"
    }

    dthree { 
        resource url:"js/d3.js"
        resource url:"js/d3.time.js"
    }
    
    stdui { 
        dependsOn "jquery-tools, dthree"
        resource url:"js/underscore.js"
        resource url:"js/mustache.js"
    }

    polymaps { 
        resource url:"js/polymaps.js"
        resource url:"js/polymaps_cluster.js"
    }

    datatables { 
        dependsOn "jquery"
        resource url:"js/jquery.format-1.2.min.js"
        resource url:"js/jquery.dataTables.js"
    }

    'tmcpe-incident-summary' { 
        dependsOn "dthree"
        resource url:"js/tmcpe/incident-summary.js"
        resource url:"less/tmcpe-incident-summary.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
        resource url:"less/tabs-no-images.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_tmcpe-incident-summary'
    }

    'tmcpe-map-show' { 
        dependsOn "dthree,polymaps"
        resource url:"js/tmcpe/map-show.js"
        resource url:"less/tmcpe-map-show.less",attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_tmcpe-map-show'
    }
    
}
