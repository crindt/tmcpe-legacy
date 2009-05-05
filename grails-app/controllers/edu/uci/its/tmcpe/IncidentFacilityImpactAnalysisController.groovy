

package edu.uci.its.tmcpe

class IncidentFacilityImpactAnalysisController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ incidentFacilityImpactAnalysisInstanceList: IncidentFacilityImpactAnalysis.list( params ), incidentFacilityImpactAnalysisInstanceTotal: IncidentFacilityImpactAnalysis.count() ]
    }

    def show = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get( params.id )

        if(!incidentFacilityImpactAnalysisInstance) {
            flash.message = "IncidentFacilityImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ incidentFacilityImpactAnalysisInstance : incidentFacilityImpactAnalysisInstance ] }
    }

    def delete = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get( params.id )
        if(incidentFacilityImpactAnalysisInstance) {
            try {
                incidentFacilityImpactAnalysisInstance.delete()
                flash.message = "IncidentFacilityImpactAnalysis ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "IncidentFacilityImpactAnalysis ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "IncidentFacilityImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get( params.id )

        if(!incidentFacilityImpactAnalysisInstance) {
            flash.message = "IncidentFacilityImpactAnalysis not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ incidentFacilityImpactAnalysisInstance : incidentFacilityImpactAnalysisInstance ]
        }
    }

    def update = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get( params.id )
        if(incidentFacilityImpactAnalysisInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(incidentFacilityImpactAnalysisInstance.version > version) {
                    
                    incidentFacilityImpactAnalysisInstance.errors.rejectValue("version", "incidentFacilityImpactAnalysis.optimistic.locking.failure", "Another user has updated this IncidentFacilityImpactAnalysis while you were editing.")
                    render(view:'edit',model:[incidentFacilityImpactAnalysisInstance:incidentFacilityImpactAnalysisInstance])
                    return
                }
            }
            incidentFacilityImpactAnalysisInstance.properties = params
            if(!incidentFacilityImpactAnalysisInstance.hasErrors() && incidentFacilityImpactAnalysisInstance.save()) {
                flash.message = "IncidentFacilityImpactAnalysis ${params.id} updated"
                redirect(action:show,id:incidentFacilityImpactAnalysisInstance.id)
            }
            else {
                render(view:'edit',model:[incidentFacilityImpactAnalysisInstance:incidentFacilityImpactAnalysisInstance])
            }
        }
        else {
            flash.message = "IncidentFacilityImpactAnalysis not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis()
        incidentFacilityImpactAnalysisInstance.properties = params
        return ['incidentFacilityImpactAnalysisInstance':incidentFacilityImpactAnalysisInstance]
    }

    def save = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis(params)
        if(!incidentFacilityImpactAnalysisInstance.hasErrors() && incidentFacilityImpactAnalysisInstance.save()) {
            flash.message = "IncidentFacilityImpactAnalysis ${incidentFacilityImpactAnalysisInstance.id} created"
            redirect(action:show,id:incidentFacilityImpactAnalysisInstance.id)
        }
        else {
            render(view:'create',model:[incidentFacilityImpactAnalysisInstance:incidentFacilityImpactAnalysisInstance])
        }
    }
}
