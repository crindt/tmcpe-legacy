package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*
import org.apache.commons.logging.LogFactory


class IncidentController {
    static navigation = [
        group:'tabs',
        order:1000,
        title:'Incidents'
        ]

    static log = LogFactory.getLog("edu.uci.its.tmcpe.IncidentController")

    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
     static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
//        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
//        [ incidentInstanceList: Incident.list( params ), incidentInstanceTotal: Incident.count() ]
          System.err.println("=============LISTING")
          def maxl = Math.min( params.max ? params.max.toInteger() : 10,  1000)
          def _params = params
          def c = Incident.createCriteria()
          def now = new java.util.Date();
          def theList = c.list {
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
                      between( 'stampDate', from, to )
                  }
                  if ( params.earliestTime || params.latestTime ) {
                      def from = java.sql.Time.parse( "HH:mm", params.earliestTime ? params.earliestTime : '00:00' )
                      def to = java.sql.Time.parse( "HH:mm", params.latestTime ? params.latestTime : '23:59' )
                      System.err.println("============TIMES: " + from + " <<>> "  + to )
                      log.debug("============TIMES: " + from + " <<>> "  + to )
                      between( 'stampTime', from, to )
                  }
                  if ( params.bbox ) {
                      def bbox = params.bbox.split(",")
                      def valid = 0;
                      log.debug("============BBOX: " + bbox.join(","))
                      def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                      addToCriteria(Restrictions.sqlRestriction( "st_transform(location,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+")" ))
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
                          addToCriteria(Restrictions.sqlRestriction( "extract( dow from stampDate ) IN (" + dow.join(",") + ")" ) )
                      }
                  }
                  maxResults(maxl)
                  order( 'stampDate', 'asc' )
                  order( 'stampTime', 'asc' )
              }
          }
          System.err.println( "============COUNT: " + theList.count() )
          withFormat {
              html {
                  def html = [ incidentInstanceList: theList, incidentInstanceTotal: theList.count() ]
                  return html
              }
              kml  {
                  return [ incidentInstanceList: theList, incidentInstanceTotal: theList.count() ]
              }
              json { 
                  // renders to json compatible with dojo::ItemFileReadStore 
                  def json = [ items: theList ]
                  render json as JSON 
              }
              geojson {
                  def json = [];
                  theList.each() { json.add( [ id: it.id, geometry: it.location, properties: it ] ) }
                  def fjson = [ type: "FeatureCollection", features: json ]
                  render fjson as JSON;
              }
          }
    }

    def show = {
        def incidentInstance = Incident.get( params.id )

        if(!incidentInstance) {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        }
        withFormat {
            html {
                def html = [ incidentInstance : incidentInstance, 
                             logEntries : [ items: incidentInstance.getTmcLogEntries(),
                             jsonString : incidentInstance.hackToJSON()
                    ] as JSON
                ] 
                return html
            }
            json {
                render incidentInstance as JSON
            }
//            json {
//                render incidentInstance as grails.converters.deep.JSON
//            }
        }
    }
    
/*
    // injected from Spring
    def incidentImpactAnalysisService

    def analyze = {
        log.debug "*** In incidentController.analyze"

        def incidentInstance = Incident.get( params.id )

        if ( incidentInstance ) 
        {
            if ( incidentImpactAnalysisService )
            {
                flash.message = "Analyzing incident ${incidentInstance.id}..."
                incidentImpactAnalysisService.analyzeIncidentImpact( incidentInstance, "test" )
                redirect(action:show,id:incidentInstance.id)
            }
            else
            {
                flash.message = "The incident analysis service is not active"
                redirect(action:show,id:incidentInstance.id)
            }
        }
        else
        {
            flash.message = "Failed to find incident ${incidentInstance} to analyze!?!?!"
            redirect(action:list)
        }
    }
*/

    def delete = {
        def incidentInstance = Incident.get( params.id )
        if(incidentInstance) {
            try {
                incidentInstance.delete(flush:true)
                flash.message = "Incident ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "Incident ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def incidentInstance = Incident.get( params.id )

        if(!incidentInstance) {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ incidentInstance : incidentInstance ]
        }
    }

    def update = {
        def incidentInstance = Incident.get( params.id )
        if(incidentInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(incidentInstance.version > version) {
                    
                    incidentInstance.errors.rejectValue("version", "incident.optimistic.locking.failure", "Another user has updated this Incident while you were editing.")
                    render(view:'edit',model:[incidentInstance:incidentInstance])
                    return
                }
            }
            incidentInstance.properties = params
            if(!incidentInstance.hasErrors() && incidentInstance.save()) {
                flash.message = "Incident ${params.id} updated"
                redirect(action:show,id:incidentInstance.id)
            }
            else {
                render(view:'edit',model:[incidentInstance:incidentInstance])
            }
        }
        else {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def create = {
        def incidentInstance = new Incident()
        incidentInstance.properties = params
        return ['incidentInstance':incidentInstance]
    }

    def save = {
        def incidentInstance = new Incident(params)
        if(!incidentInstance.hasErrors() && incidentInstance.save()) {
            flash.message = "Incident ${incidentInstance.id} created"
            redirect(action:show,id:incidentInstance.id)
        }
        else {
            render(view:'create',model:[incidentInstance:incidentInstance])
        }
    }

    def listAllAsKml = {
        def incidentList = Incident.list()
        render(contentType:"text/xml",
               view:'listAllAsKml',
               model:[ incidentInstanceList: incidentList, incidentInstanceTotal: incidentList.count() ])
    }

    def listAnalyses = {
        def incident = Incident.get( params.id )

        if ( !incident ) {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        } else {
            def tt = [items: incident.listAnalyses() ]
            render tt  as JSON
        }
    }

//     def listAllAsJSON = {
//         def incidentList = Incident.list()
//         render( contentType:"text/json",
//                 incidentList as JSON )
//     }
}
