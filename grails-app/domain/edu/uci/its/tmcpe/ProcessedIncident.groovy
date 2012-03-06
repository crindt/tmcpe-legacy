package edu.uci.its.tmcpe

/* FIXME:JODA
   import org.joda.time.DateTime
   import org.joda.time.Period
*/
import com.vividsolutions.jts.geom.Point
/*
  import java.sql.Time
  import grails.converters.JSON
  import java.util.Calendar
*/
import org.hibernate.criterion.*

/**
 * A Incident that has impacted the capacity of the roadway
 * 
 * For the purposes of TMCPE, an Incident is one that has been recorded in the 
 * TMC Activity Log and has been given a CAD ID.
 * 
 * NOTE: The list of incidents will be generated via an external service (or using a saved 
 * query/view in the database).  The TMCPE application will /not/ be able to create new incidents 
 * for analysis.  At present, this query limits incidents to SIGALERTs
 */
class ProcessedIncident {

    // cad
    Integer id
    
    String cad
    //    SortedSet tmcLogEntries

    Date startTime

    TmcLogEntry sigalertBegin
    TmcLogEntry sigalertEnd

    TmcLogEntry firstCall        // equivalent to t0
    TmcLogEntry verification     // equivalent to t1
    TmcLogEntry lanesClear       // equivalent to t2
    TmcLogEntry incidentClear // equivalent to t3
    
    
    // The estimated freeway section where the incident occurred (the
    // location of the capacity reduction)
    FacilitySection section

    Point locationGeom
    
    String eventType

    // Should really move to AnalyzedIncident, but that will break import-al.pl
    // so just stick it here for now.
    SortedSet analyses
    static hasMany = [analyses:IncidentImpactAnalysis]

    static transients = [ 'year', 'activeAnalysis' ]
    
    static constraints = {
        // Only allow one Incident object per cadid
        cad(unique:true)
    }
    
    static mapping = {
        //table 'sigalert_locations_grails'
        table name: 'actlog.incidents' //, schema: 'actlog'
        // FIXME: mongodb doesn't like it with id's have a different name
        //id column: 'id'
        cad column: 'cad'
        startTime column: 'start_time'
        firstCall column: 'first_call'
        sigalertBegin column: 'sigalert_begin'
        sigalertEnd column: 'sigalert_end'
        locationGeom column: 'location_geom'
        section column: 'location_vdsid'
        eventType column: 'event_type'

        verification  column: 'verification'
        lanesClear    column: 'lanes_clear'    // equivalent to t2
        incidentClear column: 'incident_clear' // equivalent to t3

        // turn off optimistic locking, i.e., versioning.  This class is mapped to an externally generated table
        version false
        //        cache usage:'read-only' 
    }
    
    List getTmcLogEntries()
    {
        return TmcLogEntry.findAllByCad( cad );
    }

    SortedSet getIcadEntries()
    {
        def icad = Icad.findAllByD12cad( cad )
        if ( icad.size() == 0 ) icad = Icad.findAllByD12cadalt( cad )

        if ( icad.size() > 0 ) {
            return icad.first().details
        } else {
            return new TreeSet()  // empty list
        }
    }

    IcadDetail computeFirstChpOnScene() {
        SortedSet entries = getIcadEntries()
        for ( icad in entries ) {
            if ( icad.detail.toLowerCase() ==~ /chp unit on scene/ ) return icad 
        }
        return null
    }

    
    IncidentImpactAnalysis getActiveAnalysis()
    {
        return analyses.size() > 0 ? analyses.first() : null;
    }

    SimpleIncidentModel pullModel()
    { 
        def model = SimpleIncidentModel.withCriteria{ eq 'cad', cad} //SimpleIncidentModel.findByCad(cad)
        //log.info("GOT MODEL ${model} for ${cad}")
        if (model && model.size() > 0)
            return model?.first()
        else
            return null
    }
    
    

    /* FIXME:JODA
       public Period computeTimeToVerify()
       {
       List entries = getTmcLogEntries()
       def start = entries.first().getStampDateTime()
       def startj = new DateTime( start )
       def verif = entries.find() { it.activitysubject == 'VERIFICATION' }
       def verifj = null
       if ( verif )
       verifj = new DateTime(verif.getStampDateTime())
       def verif2 = entries.find() { it.memo =~ /VERIFIED BY CCTV/ }
       if ( verif2 != null ) {
       def verifj2 = new DateTime(verif2.getStampDateTime())
       if ( verifj == null || verifj2.compareTo(verifj) < 0 ) {
       verif = verif2
       verifj = verifj2
       }
       }
        
       verif2 = entries.find() { it.memo =~ /PER CCTV/ }
       if ( verif2 != null ) {
       def verifj2 = new DateTime(verif2.getStampDateTime())
       if ( verifj == null || ( verifj2 && verifj2.compareTo(verifj) < 0 ) ) {
       verif = verif2
       verifj = verifj2
       }
       }

       verif2 = entries.find() { it.memo =~ /TMC HAS VISUAL/ }
       if ( verif2 != null ) {
       def verifj2 = new DateTime(verif2.getStampDateTime())
       if ( verifj == null || ( verifj2 && verifj2.compareTo(verifj) < 0 ) ) {
       verif = verif2
       verifj = verifj2
       }
       }

       if ( verif && verifj ) {
       return new Period( startj, verifj )
       } else {
       return null
       }
       }
    
       public Period computeCadDuration()
       {
       List entries = getTmcLogEntries()
       def start = entries.first().getStampDateTime()
       def startj = new DateTime( start )
       def end = entries.last().getStampDateTime()
       def endj = new DateTime( end )
       return new Period( startj, endj )
       }
    
       public Period computeSigalertDuration()
       {
       def start;
       def end;
       getTmcLogEntries().each() {
       if ( it.activitysubject == 'SIGALERT BEGIN' ) {
       start = it.getStampDateTime()
       } else if ( it.activitysubject == 'SIGALERT END' ) {
       end = it.getStampDateTime()
       }
       }
       if ( start && end ) {
       return new Period( new DateTime( start ), new DateTime( end ) )
       } else {
       return null
       }
       }
    */
    
    def verifyDurationString() {
        /* FIXME:JODA
           log.info( "TTTTTTTTTTTTTTTTTTTTTTTTT" )
           def ttv = computeTimeToVerify();
           if ( ttv == null ) { 
           log.info( "UNKNOWN" )
           return( "<UNKNOWN>" )
           }
           log.info( "TTTTTTTTTTTTTTTTTTTTTTTTT" + ttv )
           org.joda.time.format.PeriodFormatter fmt = 
           new org.joda.time.format.PeriodFormatterBuilder().
           printZeroAlways().
           appendHours().
           appendSeparator(":").
           printZeroAlways().
           minimumPrintedDigits( 2 ).
           appendMinutes().toFormatter()
           return fmt.print( ttv )
        */
        return "N/A"
    }

    public String cadDurationString() {
        /* FIXME:JODA
           org.joda.time.format.PeriodFormatter fmt = 
           new org.joda.time.format.PeriodFormatterBuilder().
           printZeroAlways().
           appendHours().
           appendSeparator(":").
           printZeroAlways().
           minimumPrintedDigits( 2 ).
           appendMinutes().toFormatter()
           return fmt.print( computeCadDuration() )
        */
        return "N/A"
    }

    
    public String sigalertDurationString() {
        /* FIXME:JODA
           org.joda.time.format.PeriodFormatter fmt = 
           new org.joda.time.format.PeriodFormatterBuilder().
           printZeroAlways().
           appendHours().
           appendSeparator(":").
           printZeroAlways().
           minimumPrintedDigits( 2 ).
           appendMinutes().toFormatter()
           return fmt.print( computeSigalertDuration() )
        */
        return "N/A"
    }
    
    def stampDateTime = {
        def cal = Calendar.getInstance( )
        cal.clear()
        cal.setTimeZone( java.util.TimeZone.getTimeZone( "America/Los_Angeles" ) )
        cal.set( Calendar.YEAR, startTime.getYear() + 1900)
        cal.set( Calendar.MONTH, startTime.getMonth() )
        cal.set( Calendar.DAY_OF_MONTH, startTime.getDate() )
        cal.set( Calendar.HOUR_OF_DAY, startTime.getHours() )
        cal.set( Calendar.MINUTE, startTime.getMinutes() )
        return cal.getTime();
    }
    
    def toKml( radius = 0.01 ) {
        if ( ! locationGeom ) return
        
        if ( radius == 0 ) {
            return [ "<Point><coordinates>",
                     locationGeom.getX()+","+locationGeom.getY(),
                     "</coordinates></Point>"
                   ].join("\n")
            
        } else {
            // We want a circle
            String coords = ""
            Point p = locationGeom
            Float x = p.getX()
            Float y = p.getY()
            for ( i in 0..20 )
            {
                Float ff = i
                Float ang = ff*(2*3.14159)/20.0
                Float xx = (x+Math.cos(ang)*radius)
                Float yy = (y+Math.sin(ang)*radius)
                coords = coords + " " +  xx + "," + yy
            }
            
            
            return [ "<Polygon><outerBoundaryIs><LinearRing><coordinates>",
                     coords,
                     "</coordinates></LinearRing></outerBoundaryIs></Polygon>",
                     "<Point>",
                     p.getX()+","+p.getY(),
                     "</Point>"
                   ].join("\n")
        }
    }

    String toString() {
        return "CAD:${cad} @ ${stampDateTime} AT ${section}"
    }

    def toJSON( json ) {
        if ( !section )
            log.warn( "WARNING: emitting JSON incident cad:$cad [$id] without a section" );
        log.warn( "EMITTING PROCESSED INCIDENT $cad WITH LOCATION ${locationGeom.toString()}"  )
        return json.build{
            "class(Incident)"
            id(id)
            cad(cad)
            //timestamp( df.format( stampDateTime() ) )
            timestamp( stampDateTime() )
            locString( section?.toString() )
            memo(firstCall ? firstCall.memoOnly:sigalertBegin?sigalertBegin.memoOnly : "<NO MEMO>" )
            section( section 
                     ? [ id:section.id, 
                         // the following are used to in the facility analysis selector
                         freewayId:section.freewayId, freewayDir: section.freewayDir 
                       ] 
                     : []
                   )
            location( locationGeom )
            //geometry( section?.segGeom )
            d12_delay( activeAnalysis?.d12Delay() )
            tmcpe_delay( activeAnalysis?.netDelay() )
            savings( pullModel()?.tmcSavings ) // FIXME: update this.
            samplePercent( activeAnalysis?.samplePercent() )
            analysesCount( analyses?.size() )
        }
    }

	static namedQueries = { 
		idInList { listString ->
			if ( listString ) { 
				'in'( "id", listString.split(",")*.toInteger())
			}
		}

		// section can be defined in params as fwy+dir or by location_id (vdsid)
		sectionMatches { params ->
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

		startTimeDuringYear { yearstr ->
			if ( yearstr ) { 
				def year = yearstr.toInteger()
				def from = Date.parse("yyyy-MM-dd", "${year}-01-01")
				def to =   Date.parse("yyyy-MM-dd", "${year+1}-01-01")
				//log.info("============DATES: ${from} <<>> ${to}")
				between( 'startTime', from, to )
			}
		}

		startTimeDuringMonth { monthstr -> 
			if ( monthstr ) { 
				def month = monthstr.split(",").grep{ 
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
						) 
					)
				}
			}
		}
		
		startTimeDuringHour { hourstr ->
			if ( hourstr ) { 
				// grep out anything that's not 0..23
				def hour = hourstr.split(",").grep{ 
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
		}

		startTimeBetweenDate { startDateStr, endDateStr ->
			if ( startDateStr || endDateStr ) { 
				def early = startDateStr ? startDateStr : '0000-00-00'
				def from = Date.parse( "yyyy-MM-dd", early )
				def to = ( endDateStr
						   ? Date.parse( "yyyy-MM-dd", endDateStr ) 
						   : new Date() )
				log.info("============DATES: " + from + " <<>> "  + to )
				
				between( 'startTime', from, to )
			}
		}

		startTimeBetweenTimeOfDay {  earliestTimeStr, latestTimeStr ->
			if ( earliestTimeStr || latestTimeStr ) {
				def early = earliestTimeStr ? earliestTimeStr : '00:00'
				def late  = latestTimeStr ? latestTimeStr : '23:59'

				// We need an explicit query to do time of day restrictions
				addToCriteria(
					Restrictions.sqlRestriction(
						"""start_time::time between '${early}' AND '${late}'"""
					))

				//between( 'startTime', from.toString(), to.toString() )
			}
		}

		analysisStatusMatches { analyzedStr ->
			if ( analyzedStr == "ONLYANALYZED" || analyzedStr == "TRUE") {
				// Limit to analyzed...
				not { sizeEq("analyses", 0) }
	    
			} else if ( analyzedStr == "UNANALYZED" || analyzedStr == "FALSE" ) {
				// ...or unanalyzed incidents
				sizeEq("analyses", 0)
			}
		}

		startTimeDuringDayOfWeek { dowStr ->
			if ( dowStr ) {

				// grep out anything that's not 0..6
				def dow = dowStr.split(",").grep{ 
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
		}
		
		eventTypeMatches { eventTypeStr ->
			if ( eventTypeStr && eventTypeStr != '' && eventTypeStr != '<Show All>' ) {
				eq( 'eventType', eventTypeStr )
			}
		}

		incidentIsLocated { 
			or {
				isNotNull( 'locationGeom' )
				isNotNull( 'section' )
			}
		}

		incidentIsSigalert { 
			not { isNull ('sigalertBegin' ) }
		}

		solutionStatusMatches { solutionStatus ->
			if ( solutionStatus ) { 
				createAlias("analyses","a")
				createAlias("a.incidentFacilityImpactAnalyses", "ii");
				if ( solutionStatus != "bad" || solutionStatus == "good" ) {
					isNull( 'ii.badSolution' )
				}
				if ( solutionStatus == "notBounded" ) {
					and {
						isFalse( 'ii.solutionTimeBounded' )
						isFalse( 'ii.solutionSpaceBounded' )
					}
				}
				if ( solutionStatus == "bad" ) {
					not { isNull( 'ii.badSolution' ) }
				}
			}
		}

		incidentInBBOX { bboxstr, projstr ->
			if ( bboxstr != null && projstr != null ) { 
				def bbox = bboxstr.split(",")
				log.debug("============BBOX: " + bbox.join(","))

				// Parse out the projection
				def proj_re_res = ( projstr =~ /^EPSG\:(\d+)/ )
				def proj = proj_re_res[0][1]

				or {
					// This does a bounding box query around the iCAD
					// location. Note: postgresql specific implementation
					// here
					//addToCriteria(
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
					)
					//)
				}
			}
		}
	}

}
