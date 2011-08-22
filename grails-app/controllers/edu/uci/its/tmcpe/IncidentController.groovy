package edu.uci.its.tmcpe

import grails.converters.*
import org.hibernate.criterion.*
import javax.servlet.http.Cookie 

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class IncidentController extends BaseController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def listFacilities = {
        System.err.println("=============LISTING FACILITIES: " + params )
        // should order by distance from center of viewport
        def items =
            AnalyzedIncident.executeQuery( 
		"SELECT distinct i.section.freewayId,i.section.freewayDir from AnalyzedIncident"
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
	AnalyzedIncident.executeQuery( "select distinct i.eventType from AnalyzedIncident i" ).collect { [evtype: it] };
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
        def c = AnalyzedIncident.createCriteria()
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
		c = AnalyzedIncident.createCriteria()
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

        log.debug("=============LISTING GROUPS: " + params )

	// columns to group by, specified as parameters
	def groupsraw = [:]
	params.groups.tokenize(",").each() { 
	  if ( it =~ /year/ ) groupsraw[it] = "year(i.startTime)";
	  if ( it =~ /month/ ) groupsraw[it] = "month(i.startTime)";
	  if ( it =~ /district/ ) groupsraw[it] = "i.section.district";
	  if ( it =~ /eventType/ ) groupsraw[it] = "i.eventType";
	  if ( it =~ /sigAlert/ ) groupsraw[it] = "(i.isSigalert )";
	  //	  if ( it =~ /cctv/ ) groupsraw[it] = "(i.verification.pMeas.pmType)";
	}
	def groups = new TreeMap(groupsraw)

	// (aggregate) data to return 
	def dataraw = ["cnt":"count(*)",
		       "vtime":"avg(case when i.verificationTimeInSeconds > 0 AND i.verificationTimeInSeconds < 60*30 THEN i.verificationTimeInSeconds ELSE null END)"
		      ] // verification time of group
	    //[k:"iia",v:"avg(count(i.analyses))"]
	def data = new TreeMap(dataraw)
	    

	if ( groups.size() == 0 ) groups = [1];

	withFormat {

	    json {
	      def qq = "select "+
		groups.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }.join(",")+
		    ","+
		    data.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }.join(",")+
		    " from AnalyzedIncident i group by "+
		    groups.entrySet().sort{it.key}.collect{ return it.value }.join(",")+
		    " order by "+
		    groups.entrySet().sort{it.key}.collect{ return it.value }.join(",")
  	        System.err.println(qq)
		def results = AnalyzedIncident.executeQuery(
		    qq
		)
		System.err.println(groups)
		System.err.println(data)
		System.err.println(results)
		render results.collect{ 
		    def ret = [:];
		    def i = 0;
		    for ( k in groups.keySet().sort() ) {
			ret[k] = it[i]
			System.err.println(k+"=="+it[i])
			++i
		    }
		    i = 0
		    def j = groups.size()
		    for ( k in data.keySet() ) {
			ret[k] = it[j+i]
			System.err.println(k+"==["+[i,j].join(",")+"]:="+it[j+i])
			++i
		    }
		    return ret;
		} as JSON
	    }
	}

    }

    def create = {
        def ii = new AnalyzedIncident()
        ii.properties = params
        return [incidentInstance: ii]
    }

    def save = {
        def ii = new AnalyzedIncident(params)
        if (ii.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), ii.id])}"
            redirect(action: "show", id: ii.id)
        }
        else {
            render(view: "create", model: [incidentInstance: ii])
        }
    }

    def show = {
        def ii = AnalyzedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
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
            ii = AnalyzedIncident.get(params.id)
        } else if ( params.cad ) {
            // specified as a cad search for it.
            def c = AnalyzedIncident.createCriteria()
            def theList = c.list {
                eq( "cad", params.cad )
            }
            if ( theList.size() == 1 ) {
                // Got it!
                ii = theList[0]
            }
        }
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
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
        def ii = AnalyzedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
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
        def ii = AnalyzedIncident.get(params.id)
        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentInstance: ii]
        }
    }

    def d3_tsd = {
	def ii = AnalyzedIncident.get(params.id)
        if ( params.id ) {
            ii = AnalyzedIncident.get(params.id)
        } else if ( params.cad ) {
            // specified as a cad search for it.
            def c = AnalyzedIncident.createCriteria()
            def theList = c.list {
                eq( "cad", params.cad )
            }
            if ( theList.size() == 1 ) {
                // Got it!
                ii = theList[0]
            }
        }

        if (!ii) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentInstance: ii]
        }
    }

    def update = {
        def ii = AnalyzedIncident.get(params.id)
        if (ii) {
            if (params.version) {
                def version = params.version.toLong()
                if (ii.version > version) {
                    
                    ii.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incident.label', default: 'AnalyzedIncident')] as Object[], "Another user has updated this Incident while you were editing")
                    render(view: "edit", model: [incidentInstance: ii])
                    return
                }
            }
            ii.properties = params
            if (!ii.hasErrors() && ii.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), ii.id])}"
                redirect(action: "show", id: ii.id)
            }
            else {
                render(view: "edit", model: [incidentInstance: ii])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def ii = AnalyzedIncident.get(params.id)
        if (ii) {
            try {
                ii.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incident.label', default: 'AnalyzedIncident'), params.id])}"
            redirect(action: "list")
        }
    }
}
