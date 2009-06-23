

package edu.uci.its.tmcpe

class TmcLogEntryController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 20,  100)
        params.offset = params.offset ? params.offset.toInteger() : 0
        def cc = TmcLogEntry.createCriteria()
        def c = TmcLogEntry.createCriteria()
        def rtot = cc.list {
            and { 
                isNotNull( "cad" )
                ne( "cad", "" )
                params.cad ? eq ( "cad", params.cad ) : true 
            }
        }
        Integer abc = rtot.size()
        def results = c.list {
            and { 
                isNotNull( "cad" )
                ne( "cad", "" )
                params.cad ? eq ( "cad", params.cad ) : true 
            }
            order( "cad", "asc" )
            order( "stampdate", "asc" )
            order( "stamptime", "asc" )
            maxResults( params.max )
            firstResult( params.offset ?:0 )
        }
        [ tmcLogEntryInstanceList: results, tmcLogEntryInstanceTotal: abc ]
    }

    def show = {
        def tmcLogEntryInstance = TmcLogEntry.get( params.id )

        if(!tmcLogEntryInstance) {
            flash.message = "TmcLogEntry not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ tmcLogEntryInstance : tmcLogEntryInstance ] }
    }

    def delete = {
        def tmcLogEntryInstance = TmcLogEntry.get( params.id )
        if(tmcLogEntryInstance) {
            try {
                tmcLogEntryInstance.delete()
                flash.message = "TmcLogEntry ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "TmcLogEntry ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "TmcLogEntry not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def tmcLogEntryInstance = TmcLogEntry.get( params.id )

        if(!tmcLogEntryInstance) {
            flash.message = "TmcLogEntry not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ tmcLogEntryInstance : tmcLogEntryInstance ]
        }
    }

    def update = {
        def tmcLogEntryInstance = TmcLogEntry.get( params.id )
        if(tmcLogEntryInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(tmcLogEntryInstance.version > version) {
                    
                    tmcLogEntryInstance.errors.rejectValue("version", "tmcLogEntry.optimistic.locking.failure", "Another user has updated this TmcLogEntry while you were editing.")
                    render(view:'edit',model:[tmcLogEntryInstance:tmcLogEntryInstance])
                    return
                }
            }
            tmcLogEntryInstance.properties = params
            if(!tmcLogEntryInstance.hasErrors() && tmcLogEntryInstance.save()) {
                flash.message = "TmcLogEntry ${params.id} updated"
                redirect(action:show,id:tmcLogEntryInstance.id)
            }
            else {
                render(view:'edit',model:[tmcLogEntryInstance:tmcLogEntryInstance])
            }
        }
        else {
            flash.message = "TmcLogEntry not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def tmcLogEntryInstance = new TmcLogEntry()
        tmcLogEntryInstance.properties = params
        return ['tmcLogEntryInstance':tmcLogEntryInstance]
    }

    def save = {
        def tmcLogEntryInstance = new TmcLogEntry(params)
        if(!tmcLogEntryInstance.hasErrors() && tmcLogEntryInstance.save()) {
            flash.message = "TmcLogEntry ${tmcLogEntryInstance.id} created"
            redirect(action:show,id:tmcLogEntryInstance.id)
        }
        else {
            render(view:'create',model:[tmcLogEntryInstance:tmcLogEntryInstance])
        }
    }
}
