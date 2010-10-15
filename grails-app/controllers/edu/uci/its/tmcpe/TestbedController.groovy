package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*

class TestbedController {

    def incidentSummary = {
        System.err.println("=============LISTING: " + params )
        // NOTE, 10000 is the max we'll allow to be returned here
        def maxl = Math.min( params.max ? params.max.toInteger() : 10000,  10000)
        def _params = params
        def now = new java.util.Date();
        def incidentCriteria = {
            and {
                if ( params.fromDate || params.toDate ) {
                    def from = Date.parse( "yyyy-MM-dd", params.fromDate ? params.fromDate : '0000-00-00' )
                    def to = params.toDate ? Date.parse( "yyyy-MM-dd", params.toDate ) : new Date()
                    System.err.println("============DATES: " + from + " <<>> "  + to )
                    between( 'startTime', from, to )
                }

                if ( params.bbox ) {
                    def bbox = params.bbox.split(",")
                    def valid = 0;
                    def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                    or {
                        // This does a bounding box query around the iCAD location
                        addToCriteria(Restrictions.sqlRestriction
                                      ( "( st_transform(best_geom,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+") )") )
                    }
                }
            }
        }
     
        // Get the total number...
        def c = Incident.createCriteria()
        int totalCount = c.get {
            projections {
                count( 'id' )
            }
            or( incidentCriteria )
        }

        // now get the page...
        c = Incident.createCriteria()
        def theList = c.list {
            maxResults(maxl)
            if ( params.offset ) { firstResult( params.offset.toInteger() ) }
            or( incidentCriteria )
            order( 'startTime', 'asc' )
        }

        System.err.println( "============COUNT: " + totalCount )
	
        def json = [];
        theList.each() { 
            if ( it.section ) {
                json.add( [ id: it.id, cad: it.cad, geometry: it.locationGeom?:it.section?.geom, 
                        //properties: it
                        properties: [ locString: "Incident " + it.cad + ": " + it.section.toString(), 
                                      memo: '<p>it.memo</p><p><a href="http://parsons.its.uci.edu/tmcpe-devel/incident/showCustom/'+it.id+'">Click to see the incident analysis on the TMCPE Website</a>']  
                        ] ) 
            }
        }
        def fjson = [ type: "FeatureCollection", features: json ]
        if (params.callback) {
            // for jsonp
            def converter = fjson as JSON
            def txt = params.callback + "(" + converter.toString() + ")"
            render( contentType:"application/javascript", text: txt )
        } else {
            render fjson as JSON
        }
    }

    def tmcpeSummary = {
        System.err.println("=============LISTING: " + params )
        // NOTE, 10000 is the max we'll allow to be returned here
        def maxl = Math.min( params.max ? params.max.toInteger() : 10000,  10000)
        def _params = params
        def now = new java.util.Date();
        def incidentCriteria = {
            and {
                if ( params.fromDate || params.toDate ) {
                    def from = Date.parse( "yyyy-MM-dd", params.fromDate ? params.fromDate : '0000-00-00' )
                    def to = params.toDate ? Date.parse( "yyyy-MM-dd", params.toDate ) : new Date()
                    System.err.println("============DATES: " + from + " <<>> "  + to )
                    between( 'startTime', from, to )
                }

                // only return analyzed incidents
                not {
                    sizeEq("analyses", 0)
                }
      
                if ( params.bbox ) {
                    def bbox = params.bbox.split(",")
                    def valid = 0;
                    def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                    or {
                        // This does a bounding box query around the iCAD location
                        addToCriteria(Restrictions.sqlRestriction
                                      ( "( st_transform(best_geom,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+") )") )
                    }
                }
            }
        }
     
        // Get the total number...
        def c = Incident.createCriteria()
        int totalCount = c.get {
            projections {
                count( 'id' )
            }
            or( incidentCriteria )
        }

        // now get the page...
        c = Incident.createCriteria()
        def theList = c.list {
            maxResults(maxl)
            if ( params.offset ) { firstResult( params.offset.toInteger() ) }
            or( incidentCriteria )
            order( 'startTime', 'asc' )
        }

        System.err.println( "============COUNT: " + totalCount )
	
        def json = [];
        theList.each() { 
            def memo = it.firstCall ? it.firstCall.memo:it.sigalertBegin?it.sigalertBegin.memo : "<NO MEMO>"
            json.add( [ id: it.id, cad: it.cad, geometry: it.locationGeom?:it.section?.geom, 
                        //properties: it
                        properties: [ locString: "Incident " + it.cad + ": " + it.section.toString(), 
                                      //memo: '[it.memo](http://parsons.its.uci.edu/tmcpe-devel/incident/showCustom/'+it.id+')'
                                      memo: '<a href="http://parsons.its.uci.edu/tmcpe-devel/incident/showCustom/'+it.id+'">detail:'+memo+'</a>'
                                    ]
                        ] ) 
        }
        def fjson = [ type: "FeatureCollection", features: json ]
        if (params.callback) {
            // for jsonp
            def converter = fjson as JSON
            def txt = params.callback + "(" + converter.toString() + ")"
            render( contentType:"application/javascript", text: txt )
        } else {
            render fjson as JSON
        }
    }

}
