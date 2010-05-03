package edu.uci.its.tmcpe

class IncidentFacilityImpactAnalysisController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [incidentFacilityImpactAnalysisInstanceList: IncidentFacilityImpactAnalysis.list(params), incidentFacilityImpactAnalysisInstanceTotal: IncidentFacilityImpactAnalysis.count()]
    }

    def create = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis()
        incidentFacilityImpactAnalysisInstance.properties = params
        return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
    }

    def save = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis(params)
        if (incidentFacilityImpactAnalysisInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), incidentFacilityImpactAnalysisInstance.id])}"
            redirect(action: "show", id: incidentFacilityImpactAnalysisInstance.id)
        }
        else {
            render(view: "create", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
        }
    }

    def show = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (!incidentFacilityImpactAnalysisInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
        else {
            [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
        }
    }

    def edit = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (!incidentFacilityImpactAnalysisInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
        }
    }

    def update = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (incidentFacilityImpactAnalysisInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (incidentFacilityImpactAnalysisInstance.version > version) {
                    
                    incidentFacilityImpactAnalysisInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis')] as Object[], "Another user has updated this IncidentFacilityImpactAnalysis while you were editing")
                    render(view: "edit", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
                    return
                }
            }
            incidentFacilityImpactAnalysisInstance.properties = params
            if (!incidentFacilityImpactAnalysisInstance.hasErrors() && incidentFacilityImpactAnalysisInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), incidentFacilityImpactAnalysisInstance.id])}"
                redirect(action: "show", id: incidentFacilityImpactAnalysisInstance.id)
            }
            else {
                render(view: "edit", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (incidentFacilityImpactAnalysisInstance) {
            try {
                incidentFacilityImpactAnalysisInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
    }
}
