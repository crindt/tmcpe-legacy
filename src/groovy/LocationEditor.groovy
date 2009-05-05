import java.text.DateFormat
import java.beans.PropertyEditorSupport
import org.postgis.Geometry
import org.postgis.PGgeometry
import org.apache.log4j.Logger

class LocationEditor extends PropertyEditorSupport { 
    Logger log
    public LocationEditor() { 
        super() 
        log = Logger.getLogger( "LocationEditor" )
    }

    public void setAsText(String text) { 
        def mytext = text
        log.info( "===============> TEXT IS: " + mytext )
        value = PGgeometry.geomFromString( mytext )
    }

    public String getAsText() { 
        def value = this.value 
        if ( value == null ) {
            return NULL
        }
        else if (value instanceof Geometry) { 
            return value.toString()
        } 
        // FIXME: crindt: TODO: throw an exception here!
        return "<Wrong object type>"
    } 
}
