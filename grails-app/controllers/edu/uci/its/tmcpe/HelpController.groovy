package edu.uci.its.tmcpe

class HelpController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [helpInstanceList: Help.list(params), helpInstanceTotal: Help.count()]
    }

    def create = {
        def helpInstance = new Help()
        helpInstance.properties = params
        return [helpInstance: helpInstance]
    }

    def save = {
        def helpInstance = new Help(params)
        if (helpInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'help.label', default: 'Help'), helpInstance.id])}"
            redirect(action: "show", id: helpInstance.id)
        }
        else {
            render(view: "create", model: [helpInstance: helpInstance])
        }
    }

    def show = {
        def helpInstance = Help.get(params.id)
        if (!helpInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
            redirect(action: "list")
        }
        else {
            [helpInstance: helpInstance]
        }
    }

    def edit = {
        def helpInstance = Help.get(params.id)
        if (!helpInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [helpInstance: helpInstance]
        }
    }

    def update = {
        def helpInstance = Help.get(params.id)
        if (helpInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (helpInstance.version > version) {
                    
                    helpInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'help.label', default: 'Help')] as Object[], "Another user has updated this Help while you were editing")
                    render(view: "edit", model: [helpInstance: helpInstance])
                    return
                }
            }
            helpInstance.properties = params
            if (!helpInstance.hasErrors() && helpInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'help.label', default: 'Help'), helpInstance.id])}"
                redirect(action: "show", id: helpInstance.id)
            }
            else {
                render(view: "edit", model: [helpInstance: helpInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def helpInstance = Help.get(params.id)
        if (helpInstance) {
            try {
                helpInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'help.label', default: 'Help'), params.id])}"
            redirect(action: "list")
        }
    }
}
