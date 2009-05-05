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

    static mapping = {
        table 'actlog'
        id column: 'keyfield'
//        cache usage:'read-only'
    }

    static constraints = {
    }

    String toString() {
        return DateFormat.getDateInstance().format(stampdate) + " " + stamptime.toString() + ": " + activitysubject + " | " + memo 
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
