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
			def fwy = ( ( params.freeway ?: params.facility_id ) ?: params.freeway_id ) ?: '';
			if ( fwy != '' ) {
			    eq( "freewayId", fwy.toInteger() )
			}
			def dir = ( params.direction ?: params.freeway_dir ) ?: '';
			if ( dir != '' ) {
			    eq( "freewayDir", dir )
			}


			if ( params.location_id == '-' ) {
			    isNull( 'id' )
			} else if ( params.location_id ) {
			    'in'( 'id', params.location_id.split(',')*.toInteger() )
			}
		    }
		    
		    if ( params.year ) {
			def from = Date.parse("yyyy-MM-dd",  params.year.toInteger() + '-01-01')
			def to =   Date.parse("yyyy-MM-dd", (params.year.toInteger()+1) + '-01-01')
			log.info("============DATES: " + from + " <<>> "  + to )
			between( 'startTime', from, to )
		    }

		    if ( params.month ) {
			// grep out anything that's not 1..12
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

			if ( month.size() > 0 ) {
			    addToCriteria( 
				Restrictions.sqlRestriction( 
				    // fixme: the this_ prefix here is a HQL-specific modifier to avoid name ambiguity
				    "extract( month from this_.start_time ) IN ( ${month.join(',')} )"
				) )
			}
		    }

		    if ( params.hour ) {
			// grep out anything that's not 0..23
			def hour = params.hour.split(",").grep{ 
			    try {
				def val = it.toInteger(); 
				if ( val >= 0 && val <= 23 ) return true

			    } catch ( java.lang.NumberFormatException e ) {
				// oops, coverting to integer failed
				log.warn( "Invalid hour of day '${it}' passed as query argument" )
				return false
			    }
			    return false
			}

			if ( hour.size() > 0 ) {
			    addToCriteria( 
				Restrictions.sqlRestriction( 
				    // fixme: the this_ prefix here is a HQL-specific modifier to avoid name ambiguity
				    "extract( hour from this_.start_time ) IN ( ${hour.join(',')} )"
				) )
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
		    def a = (params.Analyzed?: params.analyzed?:"").toUpperCase();
		    if ( a == "ONLYANALYZED" || a == "TRUE") {
			// Limit to analyzed...
			not { sizeEq("analyses", 0) }
	    
		    } else if ( a == "UNANALYZED" || a == "FALSE" ) {
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
		    def et = ( params.eventType ?: params.event_type ) ?: ''
		    if ( et != '' && et != '<Show All>' ) {
			eq( 'eventType', et )
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
		    if ( params.sigalerts == "onlySigalerts" ) {
			not { isNull( 'sigalertBegin' ) }
		    }
		    if ( params.sigalerts == "noSigalerts" ) {
			isNull( 'sigalertBegin' )
		    }

		    // Finally, figured out how to do projections!
		    //projections {
		    /*
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
				if ( params.solution == "good" ) {
				    isNull( 'badSolution' )
				}
			    }
			}
		    }
		    */
		    if ( params.solution ) {
			// use aliases to force inner join (GORM/hibernate quirk
			//  http://adhockery.blogspot.com/search/label/criteria%20queries)
			//  because we only want results that match the
			//  following
			//  
			createAlias("analyses","a")
			createAlias("a.incidentFacilityImpactAnalyses", "ii");
			if ( params.solution != "bad" || params.solution == "good" ) {
			    isNull( 'ii.badSolution' )
			}
			if ( params.solution == "notBounded" ) {
			    and {
				isFalse( 'ii.solutionTimeBounded' )
				isFalse( 'ii.solutionSpaceBounded' )
			    }
			}
			if ( params.solution == "bad" ) {
			    not { isNull( 'ii.badSolution' ) }
			}
		    }

		    // }
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


    /**
     * Discussion of group/stackgroup/filter implementation for summary/index interface
     *
     * The problem here is that to create a good query interface, we need to be
     * able to present the user with the set of possible group/stack/filter
     * options.  The existing implementation hardcoded these in the controller
     * logic in a manner that would be difficult to maintain.  This commit
     * implements an approach that maps possible parameters to the backend
     * database implementations.  This mapping permits the possible parameters
     * to be offered to the UI via the controller and interpreted by the
     * controller when sent as part of a GET.
     * 
     * Below, we define a groupMap and a filtersMap that define the acceptable
     * parameters.  The groupMap is used to interpret the groups and stackgroups
     * parameters and the filtersMap is to interpret the filters parameter.
     */

    // mapping of group and stackgroup parameters to group strings for the query
    static groupMap = [
	year:  [ pretty: "Year", groupImpl: [ year: "extract( year from inc_start_time )" ] ],
	month: [ pretty: "Month", groupImpl: [ month: "extract( month from inc_start_time )" ] ],
	//month: [ pretty: "Month", groupImpl: [ month: "to_char( inc_start_time, 'Month' )" ] ],
	hour:  [ pretty: "Hour", groupImpl: [ hour: "extract( hour from inc_start_time )" ] ],
	district: [ pretty: "District", groupImpl: [ district: "district" ] ],
	facility: [ pretty: "Facility", groupImpl: [ facility_id: "freeway_id", freeway_dir: "freeway_dir" ] ],
	eventType: [ pretty: "Event Type", groupImpl: [ event_type: "event_type" ] ],
	sigAlert:  [ pretty: "Sigalerts", groupImpl: [ sigAlert: "(sigalert_begin IS NOT NULL)" ] ],
	analyzed:  [ pretty: "Has Been Analyzed", groupImpl: [analyzed: "(id IS NOT NULL)"] ],
	location:  [ pretty: "Location", groupImpl: [location_id: "location_id"] ],
    ];

    // mapping of filter parameters to where strings for the query
    static filtersMap = [
	none: [ pretty: "No Filter", deflt: "", type: "bool", filtImpl: {return ""} ],
	date: [ pretty: "Date", filtImpl: { match -> 
	    return "("+["inc_start_time", match[0][2],"'"+match[0][3]+"'"].join(" ")+")" 
	    } ],
	analyzed: [ pretty: "Analyzed", deflt: "analyzed=onlyAnalyzed", type: "bool", filtImpl: { match -> 
	    if ( match[0][3] =~ /(?i)onlyAnalyzed/ ) {
		return "(id IS NOT NULL)"   // in this query "id" is the id of the ifia
	    } else if ( match[0][3] =~ /(?i)unAnalyzed/ ) {
		return "(id IS NULL)"   // in this query "id" is the id of the ifia			    
	    } else {
		System.err.println( "   BOG A LOG" );
	    }
	    } ],
	"^sigalerts": [ pretty: "Sigalerts", filtImpl: { match ->
	    if ( match[0][3] =~ /(?i)onlySigalerts/ ) {
		return "(sigalert_begin IS NOT NULL)"
	    } else if ( match[0][3] =~ /(?i)noSigalerts/ ) {
		return "(sigalert_begin IS NULL)"
	    }
	    } ],
	"^validSolution": [pretty: "Solution is valid",  deflt: "solution=good", filtImpl: {
		return "(bad_solution IS NULL AND id IS NOT NULL)"; } 
	    ],
	"^solution": [ pretty: "Solution", filtImpl: { match ->
	    def not = ""
	    if ( match[0][2] == '<>' ) not = " NOT "
		    
	    if ( match[0][3] == 'good' ) {
		return "$not (bad_solution IS NULL AND id IS NOT NULL)"
	    } else if ( match[0][3] == 'bad' ) {
		return "$not (bad_solution IS NOT NULL)"
	    } else if ( match[0][3] == 'bounded' ) {
		return "$not (solution_time_bounded OR solution_space_bounded AND id IS NOT NULL)"
	    } else if ( match[0][3] == 'timeBounded' ) {
		return "$not (solution_time_bounded and id IS NOT NULL)"
	    } else if ( match[0][3] == 'spaceBounded' ) {
		return "$not (solution_space_bounded and id IS NOT NULL)"
	    } else if ( match[0][3] == 'resourceConstrained' ) {
		return "$not (bad_solution ~ 'RESOURCE')"
	    }
	    } ],
	eventType: [ pretty: "Event Type", filtImpl: { match ->
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
	    return "$not (event_type ~* '$type')"
	    } ],
	"^onlySigalerts": [ pretty: "Only Sigalerts", deflt: "onlySigalerts", filtImpl: { return "(sigalert_begin IS NOT NULL)" } ],
	"^noSigalerts": [ pretty: "No Sigalerts", deflt: "noSigalerts", filtImpl: { return "(sigalert_begin IS NULL)" } ],
	facility: [ pretty: "Facility", filtImpl: { match ->
	    def not = ""
	    if ( match[0][2] == '<>' ) not = " NOT "
	    def facarr = match[0][3].tokenize("-")
	    System.err.println( "FACARR: ${facarr}" )
	    if ( facarr.size() == 1 ) {
		// this is only a freeway or direction
		if ( facarr[0].isInteger() ) { // it's a freeway spec
		    return "$not ( freeway_id = ${facarr[0]} )"
		} else {
		    return "$not ( freeway_dir='${facarr[0].toUpperCase()}' )"
		}
	    } else if ( facarr.size() == 2 ) {
		if ( facarr[0].isInteger() && !facarr[1].isInteger() ) { // e.g., 5-N
		    return "$not ( freeway_id = ${facarr[0]} AND freeway_dir='${facarr[1].toUpperCase()}' )"		    
		} else if ( facarr[1].isInteger() && !facarr[0].isInteger() ) { // e.g., N-5
		    return "$not ( freeway_id = ${facarr[1]} AND freeway_dir='${facarr[0].toUpperCase()}' )"
		}
	    } else if ( facarr.size == 0 ) {
		return "$not ( freeway_id IS NULL AND freeway_dir IS NULL )"
	    }

	    } ],
	location_id: [ pretty: "Location VDSID", filtImpl: { match ->
	    def not = ""
	    if ( match[0][2] == '<>' ) not = " NOT "
	    if ( match[0][3] == '-' ) { // it's a freeway spec
		return "$not ( location_id IS NULL )"
	    } else {
		return "$not ( location_id = ${match[0][3]} )";
	    }
	    }],
	located: [ pretty: "Incidents with known locations", filtImpl: { return "( location_id IS NOT NULL )"; } ],
	notLocated: [ pretty: "Incidents with known locations", filtImpl: { return "( location_id IS NULL )"; } ],
    ];

    def summary = {
	return [ 
	    formData: groupMap.collect { [ key:it.key, pretty: it.value.pretty] }, 
	    filterData: filtersMap.grep { it.value.deflt != null }.collect { [ key:it.value.deflt, text: it.value.pretty] }
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

	// Get session from hibernate to perform raw query
	//def sessionFactory = com.burtbeckwith.grails.plugin.datasources.DatasourcesUtils.getSessionFactory('ds2_devel')
	def session = sessionFactory.getCurrentSession()

        log.debug("=============LISTING GROUPS: " + params )

	def orderby = []

	// columns to group by, specified as parameters
	def groupsraw = [:]

	// loop over groups parameters and convert them to group strings for the query
	params.groups.tokenize(",").each() { 
	    for ( e in groupMap ) {
		if ( it.toLowerCase() =~ "(?i)${e.key}" ) {
		    for ( ee in e.value.groupImpl ) {
			//System.err.println( "${it}: Adding GROUP ${ee.key} as ${ee.value}" )
			groupsraw[ ee.key ] = [val:ee.value, parent:e.value];
			orderby.push(ee.value);
		    }
		}
	    }
	}
	def groups = new TreeMap(groupsraw)  // creates and ordered map so we can retreive data from the query results

	// loop over stackgroups parameters and convert them to group strings for the query
	def stackgroupsraw = [:]
	def stackgroupsstr = params.stackgroups ?: "";
	stackgroupsstr.tokenize(",").each() { 
	    for ( e in groupMap ) {
		//System.err.println( "CHECKING ${it} VERSUS ${e.key}" )
		if ( it.toLowerCase() =~ "(?i)${e.key}" ) {
		    for ( ee in e.value.groupImpl ) {
			//System.err.println( "${it}: Adding STACKGROUP ${ee.key} as ${ee.value}" )
			stackgroupsraw[ ee.key ] = [val:ee.value, parent:e.value]
			orderby.push(ee.value);
		    }
		}
	    }
	}
	def stackgroups = new TreeMap(stackgroupsraw)

	
	// Define the data types to return.  These need to be aggregates
	def dataraw = ["cnt":"count(distinct cad)"]  // always return counts
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


	// Loop over the filters parameters and convert them to where criteria for the query
	def filtersraw = [:]
	System.err.println("FILTERS " + params.filters)
	def filt = params.filters ?: params.filter;
	if ( filt ) {
	    filt.tokenize(",").each() {
		System.err.println("FILTER " + it)

		// look for filter specified as an equation <key cmp value>
		def match = it =~ /^(.*?)(=|[<>]=*|<>)([^=<>].*$|$)/;
		if ( match.size() == 1 ) {
		    System.err.println("Adding filter " + match[0].join(" "))
		    def key = match[0][0]
		    System.err.println("FILTER KEY " + match[0][0])
		    System.err.println("FILTER KEY2 " + key)
		    filtersraw[key] = [:]
		    filtersraw[key].param = match[0][1]
		    filtersraw[key].cmp = match[0][2]
		    filtersraw[key].val = match[0][3]

		    for ( e in filtersMap ) {
			if ( it =~ "(?i)${e.key}" ) {
			    filtersraw[key].impl = e.value.filtImpl( match )
			}
		    }
		} else {
		    // assume single word filter
		    def key = it
		    filtersraw[key] = [:]
		    filtersraw[key].param
		    for ( e in filtersMap ) {
			if ( it =~ "(?i)${e.key}" ) {
			    filtersraw[key].impl = e.value.filtImpl( match )
			}
		    }
		}
	    }
	}	

	if ( groups.size() == 0 ) groups = [1];

	withFormat {

	    json {
		// create the query string from the processed parameters
		def qq = ("select "+
			  // sort groups by key
			  groups.entrySet().sort{it.key}.collect{ return it.value.val + " as " + it.key }
			  .join(",")
			  +( stackgroups.entrySet().size() > 0
			     // sort stackgroups by key
			     ? ","+stackgroups.entrySet().sort{it.key}.collect{ return it.value.val + " as " + it.key }.join(",")
			     : "" )
			  +","+data.entrySet().sort{it.key}.collect{ return it.value + " as " + it.key }
			  .join(",")+" from tmcpe.incall i "+
			  // where clause
			  (filtersraw.entrySet().size()>0?
			   " where " +
			   filtersraw.entrySet().collect{ 
			       return it.value.impl 
			   }
			  .join(" AND ") : "" )+
			  " group by "+groups.entrySet().sort{it.key}.collect{ return it.value.val }.join(",")+
			  ( stackgroups.entrySet().size() > 0 
			    ? ","+stackgroups.entrySet().sort{it.key}.collect{return it.value.val}.join(",")
			    : "" )+
			  " order by "+
			  groups.entrySet().sort{it.key}.collect{ return it.value.val }.join(",")+
			  ( stackgroups.entrySet().size() > 0
			    ? ","+stackgroups.entrySet().sort{it.key}.collect{return it.value.val}.join(",")
			    : "" )
			 )
  	        System.err.println(qq)
		
		System.err.println(groups)
		System.err.println(data)
		//		System.err.println(results)
		//qq = "select * from tvd"
		def ll = session.createSQLQuery(qq).list().collect{ 

		    // process the results by mapping things back to the appropriate location
		    // based upon the order they were selected.  Groups were first and were sorted by key
		    def retgroups = [:]
		    def i = 0;
		    for ( k in groups.keySet().sort() ) {
			//retgroups[groups[k].parent.pretty] = [retgroups[groups[k].parent.pretty]?:"",it[i]+""].join(" ");
			retgroups[k] = it[i]
			++i
		    }
		    
		    def retstackgroups = [:]
		    def j = groups.size()
		    i = 0;
		    for ( k in stackgroups.keySet().sort() ) {
			//retstackgroups[stackgroups[k].parent.pretty] = [retstackgroups[stackgroups[k].parent.pretty]?:"",it[j+i]+""].join(" ");
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

		    def retfilt = [:]
		    for ( e in filtersraw ) {
			retfilt[e.key] = [e.value.param,e.value.cmp,e.value.val].grep({it != null}).join("")
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
