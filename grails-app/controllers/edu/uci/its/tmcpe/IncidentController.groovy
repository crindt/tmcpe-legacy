package edu.uci.its.tmcpe

import grails.converters.*

class IncidentController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
     static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
//        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
//        [ incidentInstanceList: Incident.list( params ), incidentInstanceTotal: Incident.count() ]
          def maxl = Math.min( params.max ? params.max.toInteger() : 10,  100)
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
                  maxResults(maxl)
                  order( 'stampDate', 'asc' )
                  order( 'stampTime', 'asc' )
              }
          }
          withFormat {
              html {
                  def html = [ incidentInstanceList: theList, incidentInstanceTotal: theList.count() ]
                  return html
              }
              kml  incidentInstanceList: theList
              json { 
                  // renders to json compatible with dojo::ItemFileReadStore 
                  def json = [ items: theList ]
                  render json as JSON 
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
                def html = [ incidentInstance : incidentInstance ] 
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

    def tmp = {
        render(contentType:"text/html",
               view:'incident-list',
               model:[] )
    }

//     def listAllAsJSON = {
//         def incidentList = Incident.list()
//         render( contentType:"text/json",
//                 incidentList as JSON )
//     }
}
