package edu.uci.its.tmcpe

import grails.converters.* 

class IncidentController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
//        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
//        [ incidentInstanceList: Incident.list( params ), incidentInstanceTotal: Incident.count() ]
          params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
          withFormat {
             kml  incidentInstanceList: Incident.list()
             json { render Incident.list( ) as JSON }
             html incidentInstanceList: Incident.list( ), incidentInstanceTotal: Incident.list().count()
          }
    }

    def show = {
        def incidentInstance = Incident.get( params.id )

        if(!incidentInstance) {
            flash.message = "Incident not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ incidentInstance : incidentInstance ] }
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

//     def listAllAsJSON = {
//         def incidentList = Incident.list()
//         render( contentType:"text/json",
//                 incidentList as JSON )
//     }
}
