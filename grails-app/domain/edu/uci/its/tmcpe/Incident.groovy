package edu.uci.its.tmcpe

import java.sql.Time
import org.postgis.Geometry
import org.postgis.Point
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

    def toKml( radius = 0.01 ) {
        if ( ! location ) return

        if ( radius == 0 ) {
            return [ "<Point><coordinates>",
                location.getX()+","+location.getY(),
                "</coordinates></Point>"
            ].join("\n")

        } else {
            // We want a circle
            String coords = ""
            Point p = location
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

}
