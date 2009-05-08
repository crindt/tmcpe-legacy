package edu.uci.its.tmcpe

import org.postgis.Geometry
import org.postgis.hibernate.GeometryType

class Vds {

    String name
    Integer freewayId
    String freewayDir
    Integer lanes
    String calPostmile
    Double absPostmile
    Date   lastModified
    Geometry geom
    String type
    Integer district
    
    static mapping = {
        table 'vds_geoview_full'
//        cache usage:'read-only'
        id column:'vds_id'
        columns {
            freewayId column: 'freeway_id'
            freewayDir column: 'freeway_dir'
            calPostmile column: 'cal_pm'
            absPostmile column: 'abs_pm'
            lastModified column: 'last_modified'
            type column: 'type_id'
            district column: 'district_id'
        }
        geom type:GeometryType
        // turn off optimistic locking, i.e., versioning
        version false
    }

    static constraints = {
    }
    
}
