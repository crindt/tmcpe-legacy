package edu.uci.its.tmcpe

import java.sql.Time
import org.postgis.Geometry
import org.postgis.Point
import org.postgis.hibernate.GeometryType
import grails.converters.JSON
import org.joda.time.DateTime
import org.joda.time.Period
import java.util.Calendar
import grails.converters.JSON

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


    TmcLogEntry firstCall
    TmcLogEntry sigalertBegin
    TmcLogEntry sigalertEnd
    
    
    /**
     * The estimated freeway section where the incident occurred (the location of the capacity reduction)
     */
    FacilitySection section
    
    Point locationGeom = new Point( x: 0, y: 0 )
    Point bestGeom     = new Point( x: 0, y: 0 )
    
    SortedSet analyses
    static hasMany = [analyses:IncidentImpactAnalysis]
    
    static constraints = {
        // Only allow one Incident object per cadid
        cad(unique:true)
    }
    
    static mapping = {
        //table 'sigalert_locations_grails'
        table name: 'full_incidents', schema: 'actlog'
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
        
        // turn off optimistic locking, i.e., versioning.  This class is mapped to an externally generated table
        version false
        //        cache usage:'read-only' 
    }
    
    List getTmcLogEntries()
    {
        return TmcLogEntry.findAllByCad( cad );
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
    
    public String cadDurationString() {
        org.joda.time.format.PeriodFormatter fmt = 
            new org.joda.time.format.PeriodFormatterBuilder().
            printZeroAlways().
            appendHours().
            appendSeparator(":").
            printZeroAlways().
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
            appendMinutes().toFormatter()
        return fmt.print( computeSigalertDuration() )
    }
    
    def stampDateTime = {
        def cal = Calendar.getInstance( )
        cal.clear()
        cal.setTimeZone( java.util.TimeZone.getTimeZone( "America/Los_Angeles" ) )
        cal.set( Calendar.YEAR, startTime.getYear() + 1900)
        cal.set( Calendar.MONTH, startTime.getMonth() )
        cal.set( Calendar.DAY_OF_MONTH, startTime.getDay() )
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
        def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
        return json.build{
            "class(Incident)"
            id(id)
            cad(cad)
            //timestamp( df.format( stampDateTime() ) )
            timestamp( stampDateTime() )
            locString( section.toString() )
            memo(firstCall?firstCall.memo:sigalertBegin?sigalertBegin.memo:"<NO MEMO>")
            section(section)
            location( bestGeom )
            geometry( section?.segGeom )
            delay( analyses.size() ? analyses.first().netDelay() : null )
            analysesCount( analyses?.size() )
        }
    }

    String toString() {
        return "CAD:${cad} @ ${stampDateTime} AT ${section}"
    }

    String hackToJSON() {
        return new grails.converters.JSON( this ).toString()
    }

    List listAnalyses() {
        return [];
        /*
        def fname = [ id, section.freewayId, section.freewayDir ].join( "-" )
        def p = ~/^${id}-\d+-[NSEW].json/
        System.out.println( p )
        
        def ret = []
        
        new File( 'web-app/data' ).eachFileMatch( p ) {
            f ->
            System.out.println( f )
            def vals = f.name.split( /[\.-]/ )
            def data = [ id: f.name, cad: this.id, fwy: vals[ vals.size()-3 ], dir: vals[ vals.size()-2 ], facility: [ vals[ vals.size()-3 ], vals[ vals.size()-2 ] ].join( "-" ) ]
            System.out.println( data )
            ret.add ( data )
        }
        
        return ret
        */
    }
}
