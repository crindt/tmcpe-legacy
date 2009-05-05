package edu.uci.its.tmcpe

import java.sql.Time
import org.postgis.Geometry
import org.postgis.hibernate.GeometryType

class Incident {

    String cad
//    SortedSet tmcLogEntries

    Geometry location

    String facilityName
    String facilityDirection

    static hasMany = [ 
//        tmcLogEntries: TmcLogEntry,
        analyses: IncidentImpactAnalysis
    ]

    static constraints = {
        // Only allow one Incident object per cadid
        cad(unique:true)
    }

    static mapping = {
        location type:GeometryType 
    }

    def afterLoad = {
        // fixme: this is a bit of a hack, but may be necessary if the
        //        CAD database is live
        // update tmcLogEntries
//        for ( logEntry in TmcLogEntry.findAllByCad( cad ) )
//        {
//            addToTmcLogEntries( logEntry )
//        }
    }

    List getTmcLogEntries()
    {
        return TmcLogEntry.findAllByCad( cad );
    }

    String toString() {
        return "Incident '" + cad + "'"
    }

}
