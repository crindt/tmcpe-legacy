package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*
import javax.servlet.http.Cookie 

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class IncidentController extends BaseController {
    def sessionFactory

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
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
        // NOTE, 10000 is the max we'll allow to be returned here
        def maxl = Math.min( params.max ? params.max.toInteger() : 10,  10000)
        def now = new java.util.Date();

	// construct the sql where clause from parameters

	def incidentCriteria = null

	// Use the database id or CAD id if they're provided
	if ( params.id )  { 
	    incidentCriteria = { 
		eq( "id", params.id.toInteger() ) 
	    }
	} else if ( params.cad ) {
	    incidentCriteria = { 
		eq( "cad", params.cad )           
	    }

	} else {
	    // otherwise, construct the general query

	    incidentCriteria = {

		and {
		
		    // the idIn parameter lets you specify a
		    // comma-delimited list of incident ids
		    if ( params.idIn && params.type != '' ) {
			'in'( "id", params.idIn.split(',')*.toInteger() )
		    }

		    // Limit the section to particular facility/directions
		    section {
			if ( params.freeway && params.freeway != '' ) {
			    eq( "freewayId", params.freeway.toInteger() )
			}
			if ( params.direction && params.direction != '' ) {
			    eq( "freewayDir", params.direction )
			}
		    }
      
		    // Limit to particular date range
		    if ( params.startDate || params.endDate ) {
			def early = params.startDate ? params.startDate : '0000-00-00'
			def from = Date.parse( "yyyy-MM-dd", early )
			def to = ( params.endDate 
				   ? Date.parse( "yyyy-MM-dd", params.endDate ) 
				   : new Date() )
			log.info("============DATES: " + from + " <<>> "  + to )

			between( 'startTime', from, to )
		    }
      
		    // Limit to particular time of day
		    if ( params.earliestTime || params.latestTime ) {
			def early = params.earliestTime ? params.earliestTime : '00:00'
			def late  = params.latestTime ? params.latestTime : '23:59'

			// We need an explicit query to do time of day restrictions
			addToCriteria(
			    Restrictions.sqlRestriction(
				"""start_time::time between '${early}' AND '${late}'"""
			    ))

			//between( 'startTime', from.toString(), to.toString() )
		    }

		    // Limit depending on whether the incident has been analyzed
		    if ( params.Analyzed == "onlyAnalyzed" ) {
			// Limit to analyzed...
			not { sizeEq("analyses", 0) }
	    
		    } else if ( params.Analyzed == "unAnalyzed" ) {
			// ...or unanalyzed incidents
			sizeEq("analyses", 0)
		    }
      
		    // Limit spatially if the bbox and projection are specified
		    // along with the "geographic" toggle
		    if ( params.bbox && params.proj /* && params.geographic*/ ) {
			def bbox = params.bbox.split(",")
			log.debug("============BBOX: " + bbox.join(","))

			// Parse out the projection
			def proj_re_res = ( params.proj =~ /^EPSG\:(\d+)/ )
			def proj = proj_re_res[0][1]

			or {
			    // This does a bounding box query around the iCAD
			    // location. Note: postgresql specific implementation
			    // here
			    addToCriteria(
				Restrictions.sqlRestriction( 
				    """( st_transform( best_geom, $proj ) &&
                                     st_transform(
                                     st_setsrid( 
                                        st_makebox2d(
                                           st_makepoint( ${bbox[0]}, ${bbox[1]} ), 
                                           st_makepoint( ${bbox[2]}, ${bbox[3]} ) 
                                           ), 
                                        4326 ), $proj )
                                   )"""
				) )
			}
		    }
      
		    // Limit to given days of the week, specified as comma delimited
		    // string. (0=Sunday...6=Saturday)
		    if ( params.dow ) {

			// grep out anything that's not 0..6
			def dow = params.dow.split(",").grep{ 
			    try {
				def val = it.toInteger(); 
				if ( val >= 0 && val <= 6 ) return true

			    } catch ( java.lang.NumberFormatException e ) {
				// oops, coverting to integer failed
				log.warn( "Invalid DayOfWeek '${it}' passed as query argument" )
				return false
			    }
			    return false
			}
      
			// if there's anything left after the grep, add to criteria.
			// Note, postgresql specific implementation here
			if ( dow.size() > 0 ) {
			    addToCriteria( 
				Restrictions.sqlRestriction( 
				    "extract( dow from start_time ) IN ( ${dow.join(',')} )"
				) )
			}
		    }

		    // Limit to particular event types
		    if ( params.eventType && params.eventType != '<Show All>' ) {
			eq( 'eventType', params.eventType )
		    }

		    if ( params.located == '1' ) {
			// limit to incidents that have been located
			or {
			    isNotNull( 'locationGeom' )
			    isNotNull( 'section' )
			}

		    } else if ( params.located == '0' ) {
			// limit to incidents that have no (known) location
			and {
			    isNull( 'locationGeom' )
			    isNull( 'section' )
			}
		    } 

		    // Limit to sigalerts
		    if ( params.onlySigalerts == "onlySigalerts" ) {
			not { isNull( 'sigalertBegin' ) }
		    }

		    // Finally, figured out how to do projections!
		    projections {
			analyses {
			    incidentFacilityImpactAnalyses {
				//				not { isNull( 'minMilesObserved' ) }

				if ( params.solution ) {
				    if ( params.solution != "bad" ) {
					isNull( 'badSolution' )
				    }
				    if ( params.solution == "notBounded" ) {
					and { 
					    isFalse( 'solutionTimeBounded' )
					    isFalse( 'solutionSpaceBounded' )
					}
				    }
				    if ( params.solution == "bad" ) {
					not { isNull( 'badSolution' ) }
				    }
				}
			    }
			}
		    }
		}
	    }
        }

        // now get the page...
        def c = ProcessedIncident.createCriteria()
	log.info( "===================PERFORMING QUERY" )
        def theList = c.list {
            maxResults(maxl)
            if ( params.offset ) { firstResult( params.offset.toInteger() ) }
            or( incidentCriteria )
            order( 'startTime', 'asc' )
        }

	log.info( "===================QUERY DONE" )
	
	// now emit for various formats
	withFormat {
	    html {
		// Get the total number for paging
		c = ProcessedIncident.createCriteria()
		int totalCount = c.get {
		    projections {
			count( 'id' )
		    }
		    or( incidentCriteria )
		}

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

    def listGroups = {

	// Get session from hibernate to perform raw query
	//def sessionFactory = com.burtbeckwith.grails.plugin.datasources.DatasourcesUtils.getSessionFactory('ds2_devel')
	def session = sessionFactory.getCurrentSession()

        log.debug("=============LISTING GROUPS: " + params )

	// columns to group by, specified as parameters
	def groupsraw = [:]
	params.groups.tokenize(",").each() { 
	  if ( it =~ /(?i)year/ ) groupsraw[it] = "extract(year from inc_start_time)";
	  if ( it =~ /(?i)month/ ) groupsraw[it] = "extract(month from inc_start_time)";
	  if ( it =~ /(?i)district/ ) groupsraw[it] = "district";
	  if ( it =~ /(?i)facility/ ) {
	      groupsraw["facility_id"] = "freeway_id";
	      groupsraw["freeway_dir"] = "freeway_dir";
	  }
	  if ( it =~ /(?i)eventType/ ) groupsraw[it] = "event_type";
	  if ( it =~ /(?i)sigAlert/ ) groupsraw[it] = "(sigalert_begin IS NOT NULL)";
	  if ( it =~ /(?i)analyzed/ ) groupsraw[it] = "(id IS NOT NULL)"
	  //	  if ( it =~ /cctv/ ) groupsraw[it] = "(i.verification.pMeas.pmType)";
	}
	def groups = new TreeMap(groupsraw)

	def stackgroupsraw = [:]
	def stackgroupsstr = params.stackgroups ?: "";
	stackgroupsstr.tokenize(",").each() { 
	  if ( it =~ /(?i)year/ ) stackgroupsraw[it] = "extract(year from inc_start_time)";
	  if ( it =~ /(?i)month/ ) stackgroupsraw[it] = "extract(month from inc_start_time)";
	  if ( it =~ /(?i)district/ ) stackgroupsraw[it] = "district";
	  if ( it =~ /(?i)facility/ ) {
	      stackgroupsraw["facility_id"] = "freeway_id";
	      stackgroupsraw["freeway_dir"] = "freeway_dir";
	  }
	  if ( it =~ /(?i)eventType/ ) stackgroupsraw[it] = "event_type";
	  if ( it =~ /(?i)sigAlert/ ) stackgroupsraw[it] = "(sigalert_begin IS NOT NULL)";
	  if ( it =~ /(?i)analyzed/ ) stackgroupsraw[it] = "(id IS NOT NULL)"
	  //	  if ( it =~ /cctv/ ) groupsraw[it] = "(i.verification.pMeas.pmType)";
	}
	def stackgroups = new TreeMap(stackgroupsraw)

	

	def dataraw = ["cnt":"count(distinct cad)"]

	if ( params.data ) {
	    params.data.tokenize(",").each() {
		if ( it =~ /d12_delay/ ) dataraw[it] = "avg(d12delay)"
		else if ( it =~ /tmcpe_delay/ ) dataraw[it] = "avg(net_delay)"
		else if ( it =~ /clearance_time/ ) dataraw[it] = "avg(extract( epoch from (computed_incident_clear_time-inc_start_time)))"

		       //"vtime":"avg(case when i.verificationTimeInSeconds > 0 AND i.verificationTimeInSeconds < 60*30 THEN i.verificationTimeInSeconds ELSE null END)"
	    //[k:"iia",v:"avg(count(i.analyses))"]
	    }
	}
	def data = new TreeMap(dataraw)


	def filtersraw = [:]
	System.err.println("FILTERS " + params.filters)
	def filt = params.filters ?: params.filter;
	if ( filt ) {
	    filt.tokenize(",").each() {
		System.err.println("FILTER " + it)

		def match = it =~ /(.*?)(=|[<>]=*|<>)(.*)/;
		if ( match.size() == 1 ) {
		    System.err.println("Adding filter " + match[0].join(" "))
		    def key = match[0][0]+match[0][1]
		    if ( it =~ /date/ ) {
			filtersraw[key] = "("+["inc_start_time",
					       match[0][2],
					       "'"+match[0][3]+"'"].join(" ")+")"
		    } else if ( it =~ /sigalerts/ ) {
			filtersraw[key] = "(sigalert_begin IS " + (match[0][3] == "true" ? "" : "NOT" )  + " NULL"
		    } else if ( it =~ /solution/ ) {
			def not = ""
			if ( match[0][2] == '<>' ) not = " NOT "
		    
			if ( match[0][3] == 'good' ) {
			    filtersraw[key] = "$not (bad_solution IS NULL AND id IS NOT NULL)"
			} else if ( match[0][3] == 'bad' ) {
			    filtersraw[key] = "$not (bad_solution IS NOT NULL)"
			} else if ( match[0][3] == 'bounded' ) {
			    filtersraw[key] = "$not (solution_time_bounded OR solution_space_bounded AND id IS NOT NULL)"
			} else if ( match[0][3] == 'timeBounded' ) {
			    filtersraw[key] = "$not (solution_time_bounded and id IS NOT NULL)"
			} else if ( match[0][3] == 'spaceBounded' ) {
			    filtersraw[key] = "$not (solution_space_bounded and id IS NOT NULL)"
			} else if ( match[0][3] == 'resourceConstrained' ) {
			    filtersraw[key] = "$not (bad_solution ~ 'RESOURCE')"
			}

		    } else if ( it =~ /eventType/ ) {
			def not = ""
			if ( match[0][2] == '<>' ) not = " NOT "
			def type = '';
			if ( match[0][3] =~ /(?i)INCIDENT/ ) type = "INCIDENT"
			else if ( match[0][3] =~ /(?i)CONSTRUCTION/ ) type = "^CONSTRUCTION"
			else if ( match[0][3] =~ /(?i)MAINTENANCE/ ) type = "^MAINTENANCE"
			else if ( match[0][3] =~ /(?i)EMERGENCY/ ) type = "^EMERGENCY"
			else if ( match[0][3] =~ /(?i)ANGEL/ ) type = "^ANGEL.*"
			else if ( match[0][3] =~ /(?i)HONDA/ ) type = "^HONDA.*"
			else if ( match[0][3] =~ /(?i)OCFAIR/ ) type = "^OCFAIR.*"
			else if ( match[0][3] =~ /(?i)UNKNOWN/ ) type = "^UNKNOWN.*"
			filtersraw[key] = "$not (event_type ~* '$type')"
		    }
		} else if ( it =~ /(?i)onlyAnalyzed/ ) {
		    filtersraw[it] = "(id IS NOT NULL)"   // in this query "id" is the id of the ifia

		} else if ( it =~ /(?i)onlyUnanalyzed/ ) {
		    filtersraw[it] = "(id IS NULL)"   // in this query "id" is the id of the ifia

		} else if ( it =~ /(?i)onlySigalerts/ ) {
		    filtersraw[it] = "(sigalert_begin IS NOT NULL)"
		} else if ( it =~ /(?i)noSigalerts/ ) {
		    filtersraw[it] = "(sigalert_begin IS NULL)"
		}

	    }
	}	

	if ( groups.size() == 0 ) groups = [1];

	withFormat {

	    json {
		def qq = ("select "+
			  groups.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }
			  .join(",")
			  +( stackgroups.entrySet().size() > 0
			     ? ","+stackgroups.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }.join(",")
			     : "" )
			  +","+data.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }
			  .join(",")+" from tmcpe.incall i "+
			  // where clause
			  (filtersraw.entrySet().size()>0?
			   " where " +
			   filtersraw.entrySet().collect{ 
			       return it.value 
			   }
			  .join(" AND ") : "" )+
			  " group by "+groups.entrySet().sort{it.key}.collect{ 
			      return it.value 
 			  }.join(",")+
			  ( stackgroups.entrySet().size() > 0 
			    ? ","+stackgroups.entrySet().sort{it.key}.collect{return it.value}.join(",")
			    : "" )+
			  " order by "+
			  groups.entrySet().sort{it.key}.collect{ return it.value }.join(",")+
			  ( stackgroups.entrySet().size() > 0
			    ? ","+stackgroups.entrySet().sort{it.key}.collect{return it.value}.join(",")
			    : "" )
			 )
  	        System.err.println(qq)
		
		System.err.println(groups)
		System.err.println(data)
		//		System.err.println(results)
		//qq = "select * from tvd"
		def ll = session.createSQLQuery(qq).list().collect{ 
		    System.err.println("ROW: "+it)
		    def retgroups = [:]
		    def i = 0;
		    for ( k in groups.keySet().sort() ) {
			retgroups[k] = it[i]
			++i
		    }
		    
		    def retstackgroups = [:]
		    def j = groups.size()
		    i = 0;
		    for ( k in stackgroups.keySet().sort() ) {
			retstackgroups[k] = it[j+i]
			++i
		    }

		    def jj = stackgroups.size()
		    i = 0
		    def retstats = [:]
		    for ( k in data.keySet() ) {
			retstats[k] = it[j+jj+i]
			++i
		    }
		    return [ "groups": retgroups,
			     "stackgroups": retstackgroups,
			     "stats": retstats ]
		};
		def json = [ ll ]
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
