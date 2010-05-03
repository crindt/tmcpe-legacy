package edu.uci.its.testbed

import org.postgis.Geometry
import org.postgis.Point
import org.postgis.LineString
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

    Integer relation // this should link to Relation

    Geometry segGeom


    //  --should be a field in the vds_freeway table really *
    //Route route


//    static hasMany = [ 
//    ]

    //length

    static constraints = {
    }

    static mapping = {
        table name: 'vds_view', schema: 'tbmap'

        // turn off optimistic locking, i.e., versioning
        // this is a read-only table
        version false

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

        relation column: 'rel'

        segGeom column: 'seg_geom'
        segGeom type:GeometryType
    }

    public String toKml()  {
        // FIXME: should confirm its a linestring
        // Assume we can just dump the points in order
        String kml = "";

        if ( geom != null && geom.getTypeString() == "POINT" )
        {
           Point p = geom
           kml += "<Point><coordinates>" + p.getX() + "," + p.getY() + "</coordinates></Point>\n"
        }
        
        if ( segGeom != null && segGeom.getTypeString() == "LINESTRING" ) 
        {

           LineString line = segGeom

           String coords = ""
           for ( i in 0..line.numPoints()-1 )
           {
              Point p = line.getPoint( i )
              if ( p )
                 coords = coords + " " + p.getX()  + "," + p.getY()
           }

           kml +=
            [ "<LineString><coordinates>",
              coords,
              "</coordinates></LineString>" ].join("\n")
        }
        return kml
    }
}
