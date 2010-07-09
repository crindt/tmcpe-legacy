package edu.uci.its.tmcpe

import grails.converters.*

class TmcLogEntryController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

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
          order( "stamp", "asc" )
          order( "id", "asc" )
          maxResults( params.max )
          firstResult( params.offset ?:0 )
      }

      withFormat {
         html { return [ tmcLogEntryInstanceList: results, tmcLogEntryInstanceTotal: abc ] }
         json { 
//            log.debug( results )
            def json = [ items: results ]
            render json  as JSON 
         }
      }
    }

    def create = {
        def tmcLogEntryInstance = new TmcLogEntry()
        tmcLogEntryInstance.properties = params
        return [tmcLogEntryInstance: tmcLogEntryInstance]
    }

    def save = {
        def tmcLogEntryInstance = new TmcLogEntry(params)
        if (tmcLogEntryInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), tmcLogEntryInstance.id])}"
            redirect(action: "show", id: tmcLogEntryInstance.id)
        }
        else {
            render(view: "create", model: [tmcLogEntryInstance: tmcLogEntryInstance])
        }
    }

    def show = {
        def tmcLogEntryInstance = TmcLogEntry.get(params.id)
        if (!tmcLogEntryInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
            redirect(action: "list")
        }
        else {
            [tmcLogEntryInstance: tmcLogEntryInstance]
        }
    }

    def edit = {
        def tmcLogEntryInstance = TmcLogEntry.get(params.id)
        if (!tmcLogEntryInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [tmcLogEntryInstance: tmcLogEntryInstance]
        }
    }

    def update = {
        def tmcLogEntryInstance = TmcLogEntry.get(params.id)
        if (tmcLogEntryInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (tmcLogEntryInstance.version > version) {
                    
                    tmcLogEntryInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry')] as Object[], "Another user has updated this TmcLogEntry while you were editing")
                    render(view: "edit", model: [tmcLogEntryInstance: tmcLogEntryInstance])
                    return
                }
            }
            tmcLogEntryInstance.properties = params
            if (!tmcLogEntryInstance.hasErrors() && tmcLogEntryInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), tmcLogEntryInstance.id])}"
                redirect(action: "show", id: tmcLogEntryInstance.id)
            }
            else {
                render(view: "edit", model: [tmcLogEntryInstance: tmcLogEntryInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def tmcLogEntryInstance = TmcLogEntry.get(params.id)
        if (tmcLogEntryInstance) {
            try {
                tmcLogEntryInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'tmcLogEntry.label', default: 'TmcLogEntry'), params.id])}"
            redirect(action: "list")
        }
    }
}
