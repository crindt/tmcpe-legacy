

package edu.uci.its.tmcpe

class VdsController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ vdsInstanceList: Vds.list( params ), vdsInstanceTotal: Vds.count() ]
    }

    def show = {
        def vdsInstance = Vds.get( params.id )

        if(!vdsInstance) {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ vdsInstance : vdsInstance ] }
    }

    def delete = {
        def vdsInstance = Vds.get( params.id )
        if(vdsInstance) {
            try {
                vdsInstance.delete()
                flash.message = "Vds ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "Vds ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def vdsInstance = Vds.get( params.id )

        if(!vdsInstance) {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ vdsInstance : vdsInstance ]
        }
    }

    def update = {
        def vdsInstance = Vds.get( params.id )
        if(vdsInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(vdsInstance.version > version) {
                    
                    vdsInstance.errors.rejectValue("version", "vds.optimistic.locking.failure", "Another user has updated this Vds while you were editing.")
                    render(view:'edit',model:[vdsInstance:vdsInstance])
                    return
                }
            }
            vdsInstance.properties = params
            if(!vdsInstance.hasErrors() && vdsInstance.save()) {
                flash.message = "Vds ${params.id} updated"
                redirect(action:show,id:vdsInstance.id)
            }
            else {
                render(view:'edit',model:[vdsInstance:vdsInstance])
            }
        }
        else {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def vdsInstance = new Vds()
        vdsInstance.properties = params
        return ['vdsInstance':vdsInstance]
    }

    def save = {
        def vdsInstance = new Vds(params)
        if(!vdsInstance.hasErrors() && vdsInstance.save()) {
            flash.message = "Vds ${vdsInstance.id} created"
            redirect(action:show,id:vdsInstance.id)
        }
        else {
            render(view:'create',model:[vdsInstance:vdsInstance])
        }
    }
}
