package edu.uci.its.tmcpe

import com.vividsolutions.jts.geom.Point
import com.vividsolutions.jts.geom.LineString


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

//    Float   absPostmile
    Double   absPostmile

    Point geom
    LineString segGeom

    static constraints = {
    }

    String toString() {
		return "$freewayId $freewayDir @ $absPostmile ($id) [$vdsType:$name]"
    }

    static mapping = {
        //        table 'temp_vds_data'
        table name: 'vds_view', schema: 'tbmap'

        // FIXME: mongodb doesn't like it with id's have a different name
        //id column: 'id'
        name column: 'name'
        lanes column: 'lanes'
        segmentLength column: 'length'
        freewayId column: 'freeway_id'
        freewayDir column: 'freeway_dir'
        district column: 'district'
        vdsType column: 'vdstype'
        absPostmile column: 'abs_pm'
        geom column: 'geom'
        segGeom column: 'seg_geom'

        version false
    }
    
}
