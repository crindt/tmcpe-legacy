package edu.uci.its.tmcpe

import org.postgis.hibernate.GeometryType

import org.postgis.Geometry
import org.postgis.LineString
import org.postgis.Point


class TestbedLine {
    Geometry geom

    static constraints = {
    }

    static mapping = {
        table 'testbed_lines'
        id column:'id'
        columns {
        }
//        geom column:'linestring'
        geom type:GeometryType
        version false
    }

    public String toKml()  {
        // FIXME: should confirm its a linestring
        // Assume we can just dump the points in order
        LineString line = geom

        String coords = ""
        for ( i in 0..geom.numPoints()-1 )
        {
            Point p = geom.getPoint( i )
            if ( p )
               coords = coords + " " + p.getX()  + "," + p.getY()
        }

        return [ 
            "<LineString><coordinates>",
            coords,
        "</coordinates></LineString>" ].join("\n")
    }
}
