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
    static transients = [ "stampDateTime", "deviceSummary" ]

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

    String getDeviceSummary() {
        def ret = ""
        if ( device_number && device_number != "" ) ret += "#" + device_number
        if ( device_fwy && device_fwy != "" ) {
            ret += " (" + device_fwy
            if ( device_name && device_name != "" ) ret += " @ " + device_name
            ret += ")"
        }
        return ret
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

    def getMemoHash() {
        def pieces = memo.split(/:DOSEP:/)
        def hash = [:]
        if ( pieces.size() == 0 ) return hash
        System.err.println( "PIECES: " + pieces )
        hash['memo'] = pieces[0]
        pieces.eachWithIndex() { obj,i ->
            if ( i == 0 ) {
                hash['memo'] = obj
            } else {
                def subp = obj.split(/:/)
                if (subp.size()>1) {
                    def key = subp[0]
                    def val = subp[1..subp.size()-1].join(":")
                    hash[key] = val
                }
            }
        }
        return hash
    }

    // return the first portion of the memo
    def getMemoOnly() {
        return getMemoHash()['memo']
    }

    def getRouteDirLocation() {
        return getMemoHash()['Route/Dir/Location']
    }

    def getPerformanceMeasures() {
        return getMemoHash()['PerformanceMeasures']
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
