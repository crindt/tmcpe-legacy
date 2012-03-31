package edu.uci.its.testbed

import com.vividsolutions.jts.geom.Geometry
import com.vividsolutions.jts.geom.Point
import com.vividsolutions.jts.geom.LineString

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

    static transients = ['sortablePostmile'];

    static mapping = {
        table name: 'vds_view', schema: 'tbmap'

        // turn off optimistic locking, i.e., versioning
        // this is a read-only table
        version false

        // FIXME: mongodb doesn't like it with id's have a different name
        //id column: 'id'
        name column: 'name'
        calPostmile column: 'cal_pm'
        absPostmile column: 'abs_pm'
        lanes column: 'lanes'
        segmentLength column: 'length'
        versionTs column: 'last_modified' // 'version'
        freeway column: 'freeway_id'
        freewayDir column: 'freeway_dir'
        vdsType column: 'vdstype'
        district column: 'district'

        geom column: 'geom'

        relation column: 'rel'

        segGeom column: 'seg_geom'
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

    // A method to allow sorting of vds by postmile taking into consideration the freeway direction
    public Float getSortablePostmile() {
	if ( ['S', 'W'].grep(freewayDir) ) {
	    return -absPostmile;
	} else {
	    return absPostmile;
	}
    }

    public int compareTo( other ) {
	def res;
	def res2;
	return (res = this.freeway.compareTo(other.freeway) 
		? res 
		: ( res2 = this.freewayDir.compareTo(other.freewayDir)
		    ? other.getSortablePostmile() - this.getSortablePostmile()
		    : 0
		  ) );
    }

}
