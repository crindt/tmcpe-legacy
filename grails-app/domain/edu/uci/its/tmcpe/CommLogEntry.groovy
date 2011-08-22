package edu.uci.its.tmcpe

import java.sql.Time
import java.text.DateFormat

class CommLogEntry implements Comparable {

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
    String imms
    Boolean madeContact
    Date   stamp

    static hasMany = [ pMeas: TmcPerformanceMeasures ]

    Date stampDateTime
    static transients = [ "stampDateTime", "deviceSummary", "memoOnly", "performanceMeasures", "routeDirLocation" ]

    static mapping = {
//        table 'ct_al_backup_2007'
        table name: 'd12_comm_log_censored', schema: 'actlog'
        id column: 'keyfield'
//        cache usage:'read-only'
        // turn off optimistic locking, i.e., versioning
        version false
    }

    static constraints = {
    }

    String toString() {
        return DateFormat.getDateTimeInstance().format(stamp) + ": " + getDeviceSummary() + ":" + activitysubject + " | " + memo 
    }

    String getDeviceSummary() {
        def ret = ""
        if ( unitin && unitin != "" && unitout && unitout != "" ) {
            ret += "COMM: " + unitin + " ==[" + (via && via != "" ? via : "??" ) + "]==> " + unitout
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
        cal.set( Calendar.DAY_OF_MONTH, stamp.getDate() )
        cal.set( Calendar.HOUR_OF_DAY, stamp.getHours() )
        cal.set( Calendar.MINUTE, stamp.getMinutes() )
        return cal.getTime();

    }

    ProcessedIncident computeIncident( ) {
        List is = ProcessedIncident.findAllByCad( cad )
        return is?.first();
    }

    def getMemoHash() {
        def pieces = memo.split(/:DOSEP:/)
        def hash = [:]
        if ( pieces.size() == 0 ) return hash
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
    public String getMemoOnly() {
        return getMemoHash()['memo']
    }

    public String getRouteDirLocation() {
        return getMemoHash()['Route/Dir/Location']
    }

    public String getPerformanceMeasures() {
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
