package edu.uci.its.testbed

class VdsDataController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [vdsDataInstanceList: VdsData.list(params), vdsDataInstanceTotal: "many" /*VdsData.count()*/]
    }

    def create = {
        def vdsDataInstance = new VdsData()
        vdsDataInstance.properties = params
        return [vdsDataInstance: vdsDataInstance]
    }

    def save = {
        def vdsDataInstance = new VdsData(params)
        if (vdsDataInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'vdsData.label', default: 'VdsData'), vdsDataInstance.id])}"
            redirect(action: "show", id: vdsDataInstance.id)
        }
        else {
            render(view: "create", model: [vdsDataInstance: vdsDataInstance])
        }
    }

    def show = {
        def vdsDataInstance = VdsData.get(new VdsData( params ) )
        if (!vdsDataInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
            redirect(action: "list")
        }
        else {
            [vdsDataInstance: vdsDataInstance]
        }
    }

    def edit = {
        def vdsDataInstance = VdsData.get(params.id)
        if (!vdsDataInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [vdsDataInstance: vdsDataInstance]
        }
    }

    def update = {
        def vdsDataInstance = VdsData.get(params.id)
        if (vdsDataInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (vdsDataInstance.version > version) {
                    
                    vdsDataInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'vdsData.label', default: 'VdsData')] as Object[], "Another user has updated this VdsData while you were editing")
                    render(view: "edit", model: [vdsDataInstance: vdsDataInstance])
                    return
                }
            }
            vdsDataInstance.properties = params
            if (!vdsDataInstance.hasErrors() && vdsDataInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'vdsData.label', default: 'VdsData'), vdsDataInstance.id])}"
                redirect(action: "show", id: vdsDataInstance.id)
            }
            else {
                render(view: "edit", model: [vdsDataInstance: vdsDataInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def vdsDataInstance = VdsData.get(params.id)
        if (vdsDataInstance) {
            try {
                vdsDataInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'vdsData.label', default: 'VdsData'), params.id])}"
            redirect(action: "list")
        }
    }
}
