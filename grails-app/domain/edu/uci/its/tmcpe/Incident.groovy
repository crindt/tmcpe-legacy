package edu.uci.its.tmcpe

import org.postgis.Point
import org.joda.time.DateTime
import org.joda.time.Period
import org.postgis.Geometry
import org.postgis.hibernate.GeometryType
/*
import java.sql.Time
import grails.converters.JSON
import java.util.Calendar
*/

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
class Incident {

    // cad
    Integer id
	
    String cad
//    SortedSet tmcLogEntries

    Date startTime

    TmcLogEntry sigalertBegin
    TmcLogEntry sigalertEnd

    Boolean     isSigalert

    TmcLogEntry firstCall        // equivalent to t0
    TmcLogEntry verification     // equivalent to t1
    TmcLogEntry lanesClear       // equivalent to t2
    TmcLogEntry incidentClear // equivalent to t3
    
    
    // The estimated freeway section where the incident occurred (the
    // location of the capacity reduction)
    FacilitySection section

    Integer verificationTimeInSeconds

    
    Point locationGeom = new Point( x: 0, y: 0 )
    Point bestGeom     = new Point( x: 0, y: 0 )
    
    String eventType

    SortedSet analyses
    static hasMany = [analyses:IncidentImpactAnalysis]

    static transients = [ 'samplePercent', 'year' ]
    
    static constraints = {
        // Only allow one Incident object per cadid
        cad(unique:true)
    }
    
    static mapping = {
        //table 'sigalert_locations_grails'
        table name: 'full_incidents_calcs', schema: 'actlog'
        id column: 'id'
        cad column: 'cad'
        startTime column: 'start_time'
        firstCall column: 'first_call'
        sigalertBegin column: 'sigalert_begin'
        sigalertEnd column: 'sigalert_end'
        locationGeom column: 'location_geom'
        locationGeom type:GeometryType 
        bestGeom column: 'best_geom'
        bestGeom type:GeometryType 
        section column: 'location_vdsid'
        eventType column: 'event_type'

	verification  column: 'verification'
	lanesClear    column: 'lanes_clear'    // equivalent to t2
	incidentClear column: 'incident_clear' // equivalent to t3

	verificationTimeInSeconds column: 'vertime'
        
        // turn off optimistic locking, i.e., versioning.  This class is mapped to an externally generated table
        version false
        //        cache usage:'read-only' 
    }
    
    List getTmcLogEntries()
    {
        return TmcLogEntry.findAllByCad( cad );
    }

    
    

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
    
    def verifyDurationString() {
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
    }

    public String cadDurationString() {
        org.joda.time.format.PeriodFormatter fmt = 
            new org.joda.time.format.PeriodFormatterBuilder().
            printZeroAlways().
            appendHours().
            appendSeparator(":").
            printZeroAlways().
            minimumPrintedDigits( 2 ).
            appendMinutes().toFormatter()
        return fmt.print( computeCadDuration() )
    }

    
    public String sigalertDurationString() {
        org.joda.time.format.PeriodFormatter fmt = 
            new org.joda.time.format.PeriodFormatterBuilder().
            printZeroAlways().
            appendHours().
            appendSeparator(":").
            printZeroAlways().
            minimumPrintedDigits( 2 ).
            appendMinutes().toFormatter()
        return fmt.print( computeSigalertDuration() )
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
        if ( ! bestGeom ) return
        
        if ( radius == 0 ) {
            return [ "<Point><coordinates>",
                bestGeom.getX()+","+bestGeom.getY(),
                "</coordinates></Point>"
            ].join("\n")
            
        } else {
            // We want a circle
            String coords = ""
            Point p = bestGeom
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
    
    def toJSON( json ) {
	if ( !section )
	    log.warn( "WARNING: emitting JSON incident cad:$cad [$id] without a section" );
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
            location( bestGeom )
            //geometry( section?.segGeom )
            d12_delay( analyses.size() > 0 ? analyses?.first().d12Delay() : null )
            tmcpe_delay( analyses.size() > 0 ? analyses?.first().netDelay() : null )
            savings( 0 ) // FIXME: update this.
	    samplePercent( analyses.size() > 0 ? analyses?.first().samplePercent() : null )
            analysesCount( analyses?.size() )
        }
    }

    public Float getSamplePercent() {
	if ( analyses == null  || analyses.size() < 1 ) return null
	return analyses.first()?.samplePercent();
    }

    String toString() {
        return "CAD:${cad} @ ${stampDateTime} AT ${section}"
    }

    String hackToJSON() {
        return new grails.converters.JSON( this ).toString()
    }
}
