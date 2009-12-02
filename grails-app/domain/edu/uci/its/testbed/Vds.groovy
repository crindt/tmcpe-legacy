package edu.uci.its.testbed

import org.postgis.Geometry
import org.postgis.Point
import org.postgis.LineString
import org.postgis.hibernate.GeometryType
import edu.uci.its.testbed.vds.SummaryData
import org.jcouchdb.db.Database
import org.jcouchdb.db.Options;
import org.jcouchdb.document.ViewResult;
import org.jcouchdb.document.ValueRow;
import org.jcouchdb.document.ViewAndDocumentsResult;

import org.codehaus.groovy.grails.commons.ApplicationHolder



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
    
    public SummaryData getSummaryData( Integer year, String startTime, String endTime )
    {
        // create a database object pointing to the database "mycouchdb" on the local host    
        def conf = ApplicationHolder.application.config.vdsdata;
        
        SummaryData sd = new SummaryData()
        
        for ( int i = 0; i < 12; ++i ) {
            Database db = new Database(conf.couchdb.host, [ "d12", year, String.format( "%02d", (i+1) ) ].join("_") + conf.couchdb.db_suffix );
            Options o = new Options();
            o.putUnencoded("startkey","[\""+id+"\",\""+startTime+"\"]")
            o.putUnencoded("endkey","[\""+id+"\",\""+endTime+"\"]")
/*            o.putUnencoded("include_docs","false")*/
            o.putUnencoded("reduce","true")
            o.putUnencoded("group","true") 
            o.putUnencoded("group_level","3") 
/*
                                                  .startKey(Arrays.asList(""+id,""+startTime))
                                                  .endkey(Arrays.asList(""+id,""+endTime))                                                  
                                                  .group(true), null)
*/

            ViewResult<Object,SummaryData> result = 
        		db.queryView ("summary/fivemin", 
                                      SummaryData.class, 
                                      o, null )

        	
            for (ValueRow<SummaryData> sdir : result.rows) {
                SummaryData sdi = sdir.getValue()
                int ii =  ( sd.intrvls + sdi.intrvls )
            	sd.o += ( sd.o * sd.intrvls + sdi.o * sdi.intrvls)
                if ( ii > 0 ) sd.o /= ii
            	sd.n += sdi.n
            	sd.intrvls += sdi.intrvls
            	sd.pct += ( sd.pct * sd.intrvls + sdi.pct * sdi.intrvls)
                if ( ii > 0 ) sd.pct /= ii
            }
        }
        return sd
    }
}
