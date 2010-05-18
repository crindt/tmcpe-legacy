package edu.uci.its.tmcpe

import java.sql.Time
import java.text.DateFormat

class TmcLogEntry implements Comparable {

    Integer id
    String cad
    String unitin
    String unitout
    String via
    String op
    Integer device_number
    String device_extra
    Character device_direction
    Integer device_fwy
    String device_name
    String status
    String activitysubject
    String memo
    Date   stamp

    static hasMany = [ pMeas: TmcPerformanceMeasures ]

    Date stampDateTime
    static transients = [ "stampDateTime" ]

    static mapping = {
//        table 'ct_al_backup_2007'
        table name: 'd12_activity_log', schema: 'actlog'
        id column: 'keyfield'
//        cache usage:'read-only'
        // turn off optimistic locking, i.e., versioning
        version false
    }

    static constraints = {
    }

    String toString() {
        return DateFormat.getDateTimeInstance().format(stamp) + ": " + activitysubject + " | " + memo 
    }

    public java.util.Date getStampDateTime() {
//        new java.util.Date( stampdate.getTime() + stamptime.getTime() )
        // Do a locale convertion to our time zone---FIXME: should do based upon incident location...
        def cal = Calendar.getInstance( )
        cal.clear()
        cal.setTimeZone( java.util.TimeZone.getTimeZone( "America/Los_Angeles" ) )
        cal.set( Calendar.YEAR, stamp.getYear() + 1900)
        cal.set( Calendar.MONTH, stamp.getMonth() )
        cal.set( Calendar.DAY_OF_MONTH, stamp.getDay() )
        cal.set( Calendar.HOUR_OF_DAY, stamp.getHours() )
        cal.set( Calendar.MINUTE, stamp.getMinutes() )
        return cal.getTime();

    }

    Incident computeIncident( ) {
        List is = Incident.findAllByCad( cad )
        return is?.first();
    }

    // order by cad, stampdate, stamptime
    int compareTo( obj ) {
        int ret
        if ( ( ret = cad.compareTo( obj.cad ) ) != 0 ) return ret
        if ( ( ret = stamp.compareTo( obj.stamp ) ) != 0 ) return ret
        if ( ( ret = id.compareTo( obj.id ) ) != 0 ) return ret
        // more?

        return ret
    }
}
