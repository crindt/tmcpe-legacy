package edu.uci.its.tmcpe

import grails.converters.*

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class IncidentImpactAnalysisController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ incidentImpactAnalysisInstanceList: IncidentImpactAnalysis.list( params ), incidentImpactAnalysisInstanceTotal: IncidentImpactAnalysis.count() ]
    }

    def show = {
        def incidentImpactAnalysisInstance = IncidentImpactAnalysis.get( params.id )

        if(!incidentImpactAnalysisInstance) {
            flash.message = "IncidentImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
        else { 
            withFormat {
                html {
                    return [ incidentImpactAnalysisInstance : incidentImpactAnalysisInstance ] 
                }
                json {
                    render incidentImpactAnalysisInstance as JSON
                }
            }
        }
    }
    def showAnalyses = {
        def iia = IncidentImpactAnalysis.get(params.id.toInteger())

	withFormat {
	    html {
		if (!iia) {
		    flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
		    redirect(action: "list")
		} else {
		    flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
		    // fixme
		}
	    }
	    json {
		if ( !iia ) {
		    log.info( "INCIDENT ANALYSES FOUND MATCHING ID: ${params.id.toInteger()}" )
		    return [] as JSON
		} else {
		    def analyses = 
		    [
			identifier: "id",
			label: "fwydir",
			items: iia.incidentFacilityImpactAnalyses.collect { fia ->
			    [ id: fia.id, fwy: fia.location?.freewayId, dir: fia.location?.freewayDir, fwydir: "" + fia.location?.freewayId + "-" + fia.location?.freewayDir]
			}
		    ]  
		    
		    render analyses as JSON
		}
	    }
	}
        if (!iia) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'Incident'), params.id])}"
            redirect(action: "list")
        } else {
        }
    }

    def delete = {
        def incidentImpactAnalysisInstance = IncidentImpactAnalysis.get( params.id.toInteger() )
        if(incidentImpactAnalysisInstance) {
            try {
                incidentImpactAnalysisInstance.delete()
                flash.message = "IncidentImpactAnalysis ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "IncidentImpactAnalysis ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "IncidentImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def incidentImpactAnalysisInstance = IncidentImpactAnalysis.get( params.id.toInteger() )

        if(!incidentImpactAnalysisInstance) {
            flash.message = "IncidentImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ incidentImpactAnalysisInstance : incidentImpactAnalysisInstance ]
        }
    }

    def update = {
        def incidentImpactAnalysisInstance = IncidentImpactAnalysis.get( params.id )
        if(incidentImpactAnalysisInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(incidentImpactAnalysisInstance.version > version) {
                    
                    incidentImpactAnalysisInstance.errors.rejectValue("version", "incidentImpactAnalysis.optimistic.locking.failure", "Another user has updated this IncidentImpactAnalysis while you were editing.")
                    render(view:'edit',model:[incidentImpactAnalysisInstance:incidentImpactAnalysisInstance])
                    return
                }
            }
            incidentImpactAnalysisInstance.properties = params
            if(!incidentImpactAnalysisInstance.hasErrors() && incidentImpactAnalysisInstance.save()) {
                flash.message = "IncidentImpactAnalysis ${params.id} updated"
                redirect(action:show,id:incidentImpactAnalysisInstance.id)
            }
            else {
                render(view:'edit',model:[incidentImpactAnalysisInstance:incidentImpactAnalysisInstance])
            }
        }
        else {
            flash.message = "IncidentImpactAnalysis not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def incidentImpactAnalysisInstance = new IncidentImpactAnalysis()
        incidentImpactAnalysisInstance.properties = params
        return ['incidentImpactAnalysisInstance':incidentImpactAnalysisInstance]
    }

    def save = {
        def incidentImpactAnalysisInstance = new IncidentImpactAnalysis(params)
        if(!incidentImpactAnalysisInstance.hasErrors() && incidentImpactAnalysisInstance.save()) {
            flash.message = "IncidentImpactAnalysis ${incidentImpactAnalysisInstance.id} created"
            redirect(action:show,id:incidentImpactAnalysisInstance.id)
        }
        else {
            render(view:'create',model:[incidentImpactAnalysisInstance:incidentImpactAnalysisInstance])
        }
    }
}
