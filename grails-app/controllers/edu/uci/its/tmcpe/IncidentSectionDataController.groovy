package edu.uci.its.tmcpe

class IncidentSectionDataController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [incidentSectionDataInstanceList: IncidentSectionData.list(params), incidentSectionDataInstanceTotal: IncidentSectionData.count()]
    }

    def create = {
        def incidentSectionDataInstance = new IncidentSectionData()
        incidentSectionDataInstance.properties = params
        return [incidentSectionDataInstance: incidentSectionDataInstance]
    }

    def save = {
        def incidentSectionDataInstance = new IncidentSectionData(params)
        if (incidentSectionDataInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), incidentSectionDataInstance.id])}"
            redirect(action: "show", id: incidentSectionDataInstance.id)
        }
        else {
            render(view: "create", model: [incidentSectionDataInstance: incidentSectionDataInstance])
        }
    }

    def show = {
        def incidentSectionDataInstance = IncidentSectionData.get(params.id)
        if (!incidentSectionDataInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
            redirect(action: "list")
        }
        else {
            [incidentSectionDataInstance: incidentSectionDataInstance]
        }
    }

    def edit = {
        def incidentSectionDataInstance = IncidentSectionData.get(params.id)
        if (!incidentSectionDataInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentSectionDataInstance: incidentSectionDataInstance]
        }
    }

    def update = {
        def incidentSectionDataInstance = IncidentSectionData.get(params.id)
        if (incidentSectionDataInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (incidentSectionDataInstance.version > version) {
                    
                    incidentSectionDataInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incidentSectionData.label', default: 'IncidentSectionData')] as Object[], "Another user has updated this IncidentSectionData while you were editing")
                    render(view: "edit", model: [incidentSectionDataInstance: incidentSectionDataInstance])
                    return
                }
            }
            incidentSectionDataInstance.properties = params
            if (!incidentSectionDataInstance.hasErrors() && incidentSectionDataInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), incidentSectionDataInstance.id])}"
                redirect(action: "show", id: incidentSectionDataInstance.id)
            }
            else {
                render(view: "edit", model: [incidentSectionDataInstance: incidentSectionDataInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def incidentSectionDataInstance = IncidentSectionData.get(params.id)
        if (incidentSectionDataInstance) {
            try {
                incidentSectionDataInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentSectionData.label', default: 'IncidentSectionData'), params.id])}"
            redirect(action: "list")
        }
    }
}
