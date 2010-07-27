package edu.uci.its.tmcpe

import grails.converters.*

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
            withFormat {
                html {
                    return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
                }
                json {
                    def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
                    def timesteps = null
                    incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
                        if ( it.analyzedTimestep != null && ( timesteps == null || ( it.analyzedTimestep.size() > timesteps.size() ) ) ) {
                           timesteps = it.analyzedTimestep
                        }
                    }
                    def cnt = timesteps.size();
                    System.err.println( "A total of " + incidentFacilityImpactAnalysisInstance.analyzedSections.size() + " analyzed sections!\n" )
                    def json = [
                        id: incidentFacilityImpactAnalysisInstance.id,
                        incidentImpactAnalysis: incidentFacilityImpactAnalysisInstance.incidentImpactAnalysis.id,
                        location: incidentFacilityImpactAnalysisInstance.location,
                        startTime: incidentFacilityImpactAnalysisInstance.startTime,
                        endTime: incidentFacilityImpactAnalysisInstance.endTime,
                        timesteps: timesteps.collect { df.format( it?.fivemin ) },
                        sections: incidentFacilityImpactAnalysisInstance.analyzedSections.collect { 
                           [ vdsid: it.section.id, 
                             fwy: it.section.freewayId,
                             dir: it.section.freewayDir,
                             pm:  it.section.absPostmile,
                             name: it.section.name,
                             seglen: it.section.segmentLength,
                             analyzedTimesteps: it.analyzedTimestep.size() > 0 ? it.analyzedTimestep.collect { 
                                  [ vol: it.vol, spd: it.spd, occ: it.occ, 
                                    days_in_avg: it.days_in_avg, vol_avg: it.vol_avg, spd_avg: it.spd_avg, spd_std: it.spd_std, pct_obs_avg: it.pct_obs_avg, 
                                    p_j_m: it.p_j_m, inc: it.incident_flag, tmcpe_delay: it.tmcpe_delay ] 
                                } : [ 1..cnt ].collect {
                                      [ vol: 0, spd: 0, occ: 0, vol_avg: 0, spd_avg: 0, spd_std: 0, pct_obs_avg: 0, p_j_m: 0, inc: 0, tmcpe_delay: 0 ] }
                           ]
                        }
                        ]
                    render json as JSON
                }
            }
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
