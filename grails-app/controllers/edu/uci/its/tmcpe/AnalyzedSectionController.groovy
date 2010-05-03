package edu.uci.its.tmcpe

class AnalyzedSectionController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [analyzedSectionInstanceList: AnalyzedSection.list(params), analyzedSectionInstanceTotal: AnalyzedSection.count()]
    }

    def create = {
        def analyzedSectionInstance = new AnalyzedSection()
        analyzedSectionInstance.properties = params
        return [analyzedSectionInstance: analyzedSectionInstance]
    }

    def save = {
        def analyzedSectionInstance = new AnalyzedSection(params)
        if (analyzedSectionInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), analyzedSectionInstance.id])}"
            redirect(action: "show", id: analyzedSectionInstance.id)
        }
        else {
            render(view: "create", model: [analyzedSectionInstance: analyzedSectionInstance])
        }
    }

    def show = {
        def analyzedSectionInstance = AnalyzedSection.get(params.id)
        if (!analyzedSectionInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
            redirect(action: "list")
        }
        else {
            [analyzedSectionInstance: analyzedSectionInstance]
        }
    }

    def edit = {
        def analyzedSectionInstance = AnalyzedSection.get(params.id)
        if (!analyzedSectionInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [analyzedSectionInstance: analyzedSectionInstance]
        }
    }

    def update = {
        def analyzedSectionInstance = AnalyzedSection.get(params.id)
        if (analyzedSectionInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (analyzedSectionInstance.version > version) {
                    
                    analyzedSectionInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'analyzedSection.label', default: 'AnalyzedSection')] as Object[], "Another user has updated this AnalyzedSection while you were editing")
                    render(view: "edit", model: [analyzedSectionInstance: analyzedSectionInstance])
                    return
                }
            }
            analyzedSectionInstance.properties = params
            if (!analyzedSectionInstance.hasErrors() && analyzedSectionInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), analyzedSectionInstance.id])}"
                redirect(action: "show", id: analyzedSectionInstance.id)
            }
            else {
                render(view: "edit", model: [analyzedSectionInstance: analyzedSectionInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def analyzedSectionInstance = AnalyzedSection.get(params.id)
        if (analyzedSectionInstance) {
            try {
                analyzedSectionInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'analyzedSection.label', default: 'AnalyzedSection'), params.id])}"
            redirect(action: "list")
        }
    }
}
