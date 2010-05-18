package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*

class IncidentController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        System.err.println("=============LISTING: " + params )
        // NOTE, 10000 is the max we'll allow to be returned here
        def maxl = Math.min( params.max ? params.max.toInteger() : 10,  10000)
        def _params = params
        def now = new java.util.Date();
        def incidentCriteria = {
            and {
                section {
                    if ( params.freeway && params.freeway != '' ) {
                        eq( "freewayId", params.freeway.toInteger() )
                    }
                    if ( params.direction && params.direction != '' ) {
                        eq( "freewayDir", params.direction )
                    }
                }
      
                if ( params.fromDate || params.toDate ) {
                    def from = Date.parse( "yyyy-MM-dd", params.fromDate ? params.fromDate : '0000-00-00' )
                    def to = params.toDate ? Date.parse( "yyyy-MM-dd", params.toDate ) : new Date()
                    System.err.println("============DATES: " + from + " <<>> "  + to )
                    between( 'startTime', from, to )
                }
      
                if ( params.earliestTime || params.latestTime ) {
                    def from = java.sql.Time.parse( "HH:mm", params.earliestTime ? params.earliestTime : '00:00' )
                    def to = java.sql.Time.parse( "HH:mm", params.latestTime ? params.latestTime : '23:59' )
                    System.err.println("============TIMES: " + from + " <<>> "  + to )
                    log.debug("============TIMES: " + from + " <<>> "  + to )
                    between( 'startTime', from, to )
                }
      
                if ( params.bbox ) {
                    def bbox = params.bbox.split(",")
                    def valid = 0;
                    log.debug("============BBOX: " + bbox.join(","))
                    def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                    or {
                        // This does a bounding box query around the iCAD location
                        addToCriteria(Restrictions.sqlRestriction
                                      ( "( st_transform(best_geom,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+") )") )
                    }
                }
      
                if ( params.dow ) {
                    // validate
                    def dow = params.dow.split(",").grep{ 
                        try {
                            def val = it.toInteger(); 
                            if ( val >= 0 && val <= 6 ) return true
                        } catch ( java.lang.NumberFormatException e ) {
                            log.warn( "Invalid DayOfWeek '${it}' passed as query argument" )
                            return false
                        }
                        return false
                    }
      
                    if ( _params.idIn && _params.type != '' ) {
                        'in'( "id", _params.idIn.split(',')*.toInteger() )
                    }
      
                    if ( dow.size() > 0 ) {
                        addToCriteria(Restrictions.sqlRestriction( "extract( dow from start_time ) IN (" + dow.join(",") + ")" ) )
                    }
                }

                if ( params.located == '1' ) {
                    or {
                        isNotNull( 'locationGeom' )
                        isNotNull( 'section' )
                    }
                } else if ( params.located == '0' ) {
                    and {
                        isNull( 'locationGeom' )
                        isNull( 'section' )
                    }
                } 
            }
        }
     
//        maxResults(maxl)
     
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
	
       withFormat {
           html {
               def html = [ incidentInstanceList: theList, incidentInstanceTotal: totalCount ]
               return html
           }
	
           kml  {
               return [ incidentInstanceList: theList, incidentInstanceTotal: totalCount ]
           }
	
           json { 
               // renders to json compatible with dojo::ItemFileReadStore 
               def json = [ items: theList ]
               render json as JSON 
           }
	
           geojson {
               def json = [];
               theList.each() { json.add( [ id: it.id, cad: it.cad, geometry: it.locationGeom?:it.section?.geom, properties: it ] ) }
               def fjson = [ type: "FeatureCollection", features: json ]
               render fjson as JSON;
           }
       }

    }

    def create = {
        def incidentInstance = new Incident()
        incidentInstance.properties = params
        return [incidentInstance: incidentInstance]
    }

    def save = {
        def incidentInstance = new Incident(params)
        if (incidentInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incident.label', default: 'Incident'), incidentInstance.id])}"
            redirect(action: "show", id: incidentInstance.id)
        }
        else {
            render(view: "create", model: [incidentInstance: incidentInstance])
        }
    }

    def show = {
        def incidentInstance = Incident.get(params.id)
        if (!incidentInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        }
        else {
            [incidentInstance: incidentInstance]
        }
    }

    def showCustom = {
        def incidentInstance = Incident.get(params.id)
        if (!incidentInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        }
        else {
            [incidentInstance: incidentInstance]
        }
    }

    def showAnalyses = {
        def incidentInstance = Incident.get(params.id)
        if (!incidentInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        } else {
            def analyses = 
                incidentInstance.analyses.collect { ia -> 
                [
                    id: ia.id, 
                    name: ia.analysisName,
                    facilityAnalyses:ia.incidentFacilityImpactAnalyses.collect { fia ->
                        [ id: fia.id, fwy: fia.location?.freewayId, dir: fia.location?.freewayDir, fwydir: "" + fia.location?.freewayId + "-" + fia.location?.freewayDir]
                    }
                ]  
            }

            render analyses as JSON
        }
    }

    def edit = {
        def incidentInstance = Incident.get(params.id)
        if (!incidentInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentInstance: incidentInstance]
        }
    }

    def update = {
        def incidentInstance = Incident.get(params.id)
        if (incidentInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (incidentInstance.version > version) {
                    
                    incidentInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incident.label', default: 'Incident')] as Object[], "Another user has updated this Incident while you were editing")
                    render(view: "edit", model: [incidentInstance: incidentInstance])
                    return
                }
            }
            incidentInstance.properties = params
            if (!incidentInstance.hasErrors() && incidentInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incident.label', default: 'Incident'), incidentInstance.id])}"
                redirect(action: "show", id: incidentInstance.id)
            }
            else {
                render(view: "edit", model: [incidentInstance: incidentInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def incidentInstance = Incident.get(params.id)
        if (incidentInstance) {
            try {
                incidentInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        }
    }
}
