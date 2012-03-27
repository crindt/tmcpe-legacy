package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*
import javax.servlet.http.Cookie 
import grails.gorm.DetachedCriteria

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class IncidentController extends BaseController {
	def incidentQueryService

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "summary", params: params)
    }

    def listFacilities = {
        System.err.println("=============LISTING FACILITIES: " + params )
        // should order by distance from center of viewport
        def items =
		  ProcessedIncident.executeQuery( 
			  "SELECT distinct i.section.freewayId,i.section.freewayDir from ProcessedIncident"
			  +" i order by i.section.freewayId,i.section.freewayDir" ).collect() { 
            [facdir: it[0]+'-'+it[1]]
        }
        items.reverse
        items.push( [facdir: '<Show All>'] )
        items.reverse
        def facs = [ identifier:'facdir', items: items ]
            
        render facs as JSON
    }

    def listEventTypes = {
        def items = 
		ProcessedIncident.executeQuery( "select distinct i.eventType from ProcessedIncident i" ).collect { [evtype: it] };
        items.reverse
        items.push( [evtype: '<Show All>'] )
        items.reverse
        def evtypes = [ identifier:'evtype', items: items ]

        render evtypes as JSON
    }

    def list = {
        log.debug("=============LISTING: " + params )

		
		//def c = ProcessedIncident.createCriteria()
		def c = new DetachedCriteria(ProcessedIncident);

		def year = params.year.toInteger()
		def from = Date.parse("yyyy-MM-dd", "${year}-01-01")
		def to =   Date.parse("yyyy-MM-dd", "${year+1}-01-01")
		//log.info("============DATES: ${from} <<>> ${to}")

		def month = params.month.split(",").grep{ 
			try {
				def val = it.toInteger(); 
				if ( val >= 1 && val <= 12 ) return true
				
			} catch ( java.lang.NumberFormatException e ) {
				// oops, coverting to integer failed
				log.warn( "Invalid month of year '${it}' passed as query argument" )
				return false
			}
			return false
		}

		def cc = c.build {
			between( 'startTime', from, to )
			//ProcessedIncident.startTimeDuringYear( params.year )
			//ProcessedIncident.startTimeDuringMonth( params.month )
			addToCriteria( 
				Restrictions.sqlRestriction( 
					// fixme: the this_ prefix here is a HQL-specific modifier to avoid name ambiguity
					"extract( month from this_.start_time ) IN ( ${month.join(',')} )"
				) 
			)
		}

		def theList = cc.list()
		//def theList = c { 
		//.idInList( params.idIn )
		//.sectionMatches( params )
		//ProcessedIncident.startTimeDuringYear( params.year )
		//	ProcessedIncident.startTimeDuringMonth( params.month )
		// .startTimeDuringHour( params.hour )
		// .startTimeBetweenDate( params.startDate, params.endDate )
		// .startTimeBetweenTimeOfDay( params.earliestTime, params.latestTime )
		// .startTimeDuringDayOfWeek( params.dow )
		// .analysisStatusMatches( params.analyzed )
			//ProcessedIncident.eventTypeMatches( params.eventType )
			//ProcessedIncident.solutionStatusMatches( params.solution )
		//}
		
		// .incidentInBBOX( params.bbox, params.proj )
		
		// located
		// sigalert
							 
		// now emit for various formats
		withFormat {
			html {
				// Get the total number for paging
				int totalCount = 0

				log.debug( "============COUNT: $totalCount" )

				def html = [ incidentInstanceList: theList, incidentInstanceTotal: totalCount ]
				return html
			}
	
			json { 
				// renders to json compatible with dojo::ItemFileReadStore 
				def json = [ items: theList ]
				render json as JSON 
			}
	
			geojson {
				log.info( "===========RENDERING GEOJSON" );
				def json = [];
				theList.each() { json.add( [ id: it.id, cad: it.cad, geometry: it.locationGeom?:it.section?.geom, eventType: it.eventType, properties: it ] ) }
				def fjson = [ type: "FeatureCollection", features: json ]
				log.info( "===========EMITTING ${theList.size()} GEOJSON" );
				render fjson as JSON
			}
		}

    }

    def summary = {
		return [ 
			formData: incidentQueryService.groupMap.collect { [ key:it.key, pretty: it.value.pretty] }, 
			filterData: incidentQueryService.filtersMap.grep { it.value.deflt != null }.collect { [ key:it.value.deflt, text: it.value.pretty] }
		]
    }

    def formData = {
		def json = [groups:[], filters:[]];
		for ( e in groupMap ) {
			json.groups.push( [ key: e.key, text: e.value.pretty ] );
		}

		render json as JSON;
    }

    def listGroups = {


        log.debug("=============LISTING GROUPS: " + params )

		withFormat {

			json {
				// create the query string from the processed parameters

				def res = incidentQueryService.queryGroups( params );
				def ll = res.list.collect { 

					// process the results by mapping things back to the appropriate location
					// based upon the order they were selected.  Groups were first and were sorted by key
					def retgroups = [:]
					def i = 0;
					for ( k in res.groups.keySet().sort() ) {
						//retgroups[groups[k].parent.pretty] = [retgroups[groups[k].parent.pretty]?:"",it[i]+""].join(" ");
						retgroups[k] = it[i]
						++i
					}
		    
					def retstackgroups = [:]
					def j = res.groups.size()
					i = 0;
					for ( k in res.stackgroups.keySet().sort() ) {
						//retstackgroups[stackgroups[k].parent.pretty] = [retstackgroups[stackgroups[k].parent.pretty]?:"",it[j+i]+""].join(" ");
						retstackgroups[k] = it[j+i]
						++i
					}

					def jj = res.stackgroups.size()
					i = 0
					def retstats = [:]
					for ( k in res.data.keySet() ) {
						retstats[k] = it[j+jj+i]
						++i
					}

					def retfilt = [:]
					for ( e in res.filtersraw ) {
						retfilt[e.key] = [e.value.param,e.value.cmp,e.value.val].grep({it != null}).join("")
						// for single word parameters
						if ( retfilt[e.key] == '' ) retfilt[e.key] = e.key
					}

					return [ "groups": retgroups,
							 "stackgroups": retstackgroups,
							 "filters": retfilt,
							 "stats": retstats ]
				};
				def json = [ ll ]
				System.err.println( "JSON###"+json )
				render json as JSON
			}
		}

    }

    def create = {
        def ii = new ProcessedIncident()
        ii.properties = params
        return [incidentInstance: ii]
    }

    def save = {
        def ii = new ProcessedIncident(params)
        if (ii.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), ii.id])}"
            redirect(action: "show", id: ii.id)
        }
        else {
            render(view: "create", model: [incidentInstance: ii])
        }
    }

    def show = {
        def ii = ProcessedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {

            withFormat {
                html {
                    return [incidentInstance: ii]
                }
                json {
                    render ii as JSON
                }
            }
        }
    }

    def showCustom = {
        def ii
        if ( params.id ) {
            ii = ProcessedIncident.get(params.id)
        } else if ( params.cad ) {
            // specified as a cad search for it.
            def c = ProcessedIncident.createCriteria()
            def theList = c.list {
                eq( "cad", params.cad )
            }
            if ( theList.size() == 1 ) {
                // Got it!
                ii = theList[0]
            }
        }
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {
            log.debug( "####################SHOWING CUSTOM: $params.id : $ii.cad" )
            def fia = ( ii.analyses.size() > 0) ? ( ii.analyses.first().incidentFacilityImpactAnalyses.size() > 0
													? ii.analyses.first().incidentFacilityImpactAnalyses.first() : null ) : null
            def fiaid = null
            if ( fia != null ) fiaid=fia.id
            def band =null
            if ( fia != null ) band=fia.band
            def maxIncidentSpeed = null;
            if ( fia != null ) maxIncidentSpeed=fia.maxIncidentSpeed
            log.debug( "############# II: $ii" )
            render( view:"showCustom", 
					model: [ incidentInstance: ii, 
							 iiJson: ii as JSON, 
							 band: band,
							 maxIncidentSpeed: maxIncidentSpeed
						   ] )
        }
    }

    def showAnalyses = {
        def ii = ProcessedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        } else {
            def analyses = ii.analyses.collect { ia -> 
                [
                    id: ia.id, 
                    name: ia.analysisName,
                    facilityAnalyses:ia.incidentFacilityImpactAnalyses.collect { fia ->
                        [ id: fia.id, 
						  fwy: fia.location?.freewayId, 
						  dir: fia.location?.freewayDir, 
						  fwydir: "${fia.location?.freewayId}-${fia.location?.freewayDir}" ]
                    }
                ]  
            }

            render analyses as JSON
        }
    }

    def getTmcLog = {
		def ii = ProcessedIncident.get(params.id)
		if ( ii != null ) {
			def json = [ log: ii.getTmcLogEntries() ]
			render json  as JSON
		} else {
			return null as JSON
		}
    }

    def edit = {
        def ii = ProcessedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentInstance: ii]
        }
    }

    def tsd = {
		def ii = ProcessedIncident.get(params.id)
        if ( params.id ) {
            ii = ProcessedIncident.get(params.id)
        } else if ( params.cad ) {
            // specified as a cad search for it.
            def c = ProcessedIncident.createCriteria()
            def theList = c.list {
                eq( "cad", params.cad )
            }
            if ( theList.size() == 1 ) {
                // Got it!
                ii = theList[0]
            }
        }

        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentInstance: ii]
        }
    }

    def update = {
        def ii = ProcessedIncident.get(params.id)
        if (ii) {
            if (params.version) {
                def version = params.version.toLong()
                if (ii.version > version) {
                    
                    ii.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incident.label', default: 'ProcessedIncident')] as Object[], "Another user has updated this Incident while you were editing")
                    render(view: "edit", model: [incidentInstance: ii])
                    return
                }
            }
            ii.properties = params
            if (!ii.hasErrors() && ii.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), ii.id])}"
                redirect(action: "show", id: ii.id)
            }
            else {
                render(view: "edit", model: [incidentInstance: ii])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def ii = ProcessedIncident.get(params.id)
        if (ii) {
            try {
                ii.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'ProcessedIncident'), params.id])}"
            redirect(action: "list")
        }
    }
}
