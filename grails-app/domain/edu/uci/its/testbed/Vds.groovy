package edu.uci.its.testbed

import org.postgis.Geometry
import org.postgis.hibernate.GeometryType

class Vds {

    //  --with foreign key constraint and on delete prevent
    Integer id
    String name

    //      -- best here, not in freeway table because versioning
    String calPostmile

    //      -- ditto 
    Float absPostmile

    // latitude,  -- redundant with vds_geom table, because lat lon are
    // longitude, -- meaningless without srid


    Integer lanes

    Float segmentLength

    Date versionTs

    Integer freeway

    String freewayDir

    String vdsType

    Integer district

    Integer gid

    Geometry geom


    //  --should be a field in the vds_freeway table really *
    //Route route


//    static hasMany = [ 
//    ]

    //length

    static constraints = {
    }

    static mapping = {
        table 'vds_current_view'
        id column: 'id'
        name column: 'name'
        calPostmile column: 'cal_pm'
        absPostmile column: 'abs_pm'
        lanes column: 'lanes'
        segmentLength column: 'segment_length'
        versionTs column: 'version'
        freeway column: 'freeway_id'
        freewayDir column: 'freeway_dir'
        vdsType column: 'vdstype'
        district column: 'district'

        geom column: 'geom'
        geom type:GeometryType

        // turn off optimistic locking, i.e., versioning
        version false
    }
}
