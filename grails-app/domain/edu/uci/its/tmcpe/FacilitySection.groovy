package edu.uci.its.tmcpe

import org.postgis.Geometry
import org.postgis.Point
import org.postgis.hibernate.GeometryType


// This needs to map into spatialvds
class FacilitySection {
    
    Integer id
    
    String  name

    Integer lanes
    Float   segmentLength
    Integer freewayId
    String  freewayDir
    Integer district
    String  vdsType

    Float   absPostmile

    static constraints = {
    }

    String toString() {
        return [ freewayId, freewayDir, "@", absPostmile, "[" + name + "]" ].join( " " )
    }

    static mapping = {
        table 'temp_vds_data'
        id column: 'id'
        name column: 'name'
        lanes column: 'lanes'
        segmentLength column: 'segment_length'
        freewayId column: 'freeway_id'
        freewayDir column: 'freeway_dir'
        district column: 'district'
        vdsType column: 'vdstype'
        absPostmile column: 'abs_pm'
        version false
    }
}
