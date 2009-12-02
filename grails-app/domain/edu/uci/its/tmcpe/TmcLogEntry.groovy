package edu.uci.its.tmcpe

import java.sql.Time
import java.text.DateFormat

class TmcLogEntry implements Comparable {

    Date   stampdate
    Time   stamptime
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
        return DateFormat.getDateInstance().format(stampdate) + " " + stamptime.toString() + ": " + activitysubject + " | " + memo 
    }

    public java.util.Date getStampDateTime() {
//        new java.util.Date( stampdate.getTime() + stamptime.getTime() )
        // Do a locale convertion to our time zone---FIXME: should do based upon incident location...
        def cal = Calendar.getInstance( )
        cal.clear()
        cal.setTimeZone( java.util.TimeZone.getTimeZone( "America/Los_Angeles" ) )
        cal.set( Calendar.YEAR, stampdate.getYear() + 1900)
        cal.set( Calendar.MONTH, stampdate.getMonth() )
        cal.set( Calendar.DAY_OF_MONTH, stampdate.getDay() )
        cal.set( Calendar.HOUR_OF_DAY, stamptime.getHours() )
        cal.set( Calendar.MINUTE, stamptime.getMinutes() )
        return cal.getTime();

    }

    // order by cad, stampdate, stamptime
    int compareTo( obj ) {
        int ret
        if ( ( ret = cad.compareTo( obj.cad ) ) != 0 ) return ret
        if ( ( ret = stampdate.compareTo( obj.stampdate ) ) != 0 ) return ret
        if ( ( ret = stamptime.compareTo( obj.stamptime ) ) != 0 ) return ret
        // more?

        return ret
    }
}
