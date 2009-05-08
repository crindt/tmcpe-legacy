package edu.uci.its.tmcpe

import org.postgis.Geometry
import org.postgis.hibernate.GeometryType

class TestbedLine {
    Geometry geom
    String kml

    static constraints = {
    }

    static mapping = {
        table 'testbed_lines'
        id column:'id'
        columns {
        }
        geom type:GeometryType
        version false
    }
}
