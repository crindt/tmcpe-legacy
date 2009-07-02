package edu.uci.its.tmcpe

import java.sql.Time
import org.postgis.Geometry
import org.postgis.Point
import org.postgis.hibernate.GeometryType
import grails.converters.JSON

class Incident {

    // cad
    String id
//    SortedSet tmcLogEntries

    Date stampDate
    Time stampTime

    FacilitySection section

    String memo

    Point location = new Point( x: 0, y: 0 )

    static hasMany = [ 
//        tmcLogEntries: TmcLogEntry,
//        analyses: IncidentImpactAnalysis
    ]

    static constraints = {
        // Only allow one Incident object per cadid
//        cad(unique:true)
    }

    static mapping = {
        table 'sigalert_locations_grails'
        id column: 'cad'
        stampDate column: 'stampdate'
        stampTime column: 'stamptime'
        memo column: 'memo'
        location column: 'location'
        location type:GeometryType 
        section column: 'vdsid'
//        cache usage:'read-only'
        // turn off optimistic locking, i.e., versioning
        version false
    }

    List getTmcLogEntries()
    {
        return TmcLogEntry.findAllByCad( id );
    }

    def toJson() {
              json.build{
                  "class(Incident)"
                  id(id)
                  section(section)
                  longitude( location.x )
                  latitude( location.y )
              }

    }

    def stampDateTime = {
        new java.util.Date( stampDate.getTime() + stampTime.getTime() )
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
