//import org.codehaus.groovy.grails.plugins.starksecurity.PasswordEncoder

import edu.uci.its.auth.Role
import edu.uci.its.auth.User

import javax.servlet.http.HttpServletRequest

class BootStrap {
    
    def springSecurityService
    
    def init = { servletContext ->
        servletContext.setAttribute( "newDataBinder",  GlobalPropertyEditorConfig.&newDataBinder )
        servletContext.setAttribute( "newBeanWrapper", GlobalPropertyEditorConfig.&newBeanWrapper )
        
	// Here, we register a bunch of converters to emit json for various objects
	def cc = 1  // the object marshallers must have a distinct index, we
		    // just create a variable and increment it
	grails.converters.JSON.registerObjectMarshaller( org.postgis.LineString, cc++ ) { 
	    ls, json ->
		def ptlist = []
		ls?.getPoints()?.each() { ptlist.add( [ it?.x, it?.y ] ) }
		json.build{
		    "type(LineString)"
		    type("LineString")
		    coordinates( ptlist )
		}	
	}
		
	grails.converters.JSON.registerObjectMarshaller( org.postgis.Point, cc++ ) { 
	    p, json ->
		json.build{
		    "type(Point)"
		    type("Point")
		    coordinates( [ p?.x, p?.y ] )
		}
	}
    
	grails.converters.JSON.registerObjectMarshaller( edu.uci.its.tmcpe.FacilitySection, cc++ ) { 
	    s, json ->
		json.build {
		    "class(FacilitySection)"
		    id(s.id)
		    name(s.name)
		    freewayId(s.freewayId)
		    freewayDir(s.freewayDir)
		    geom(s.geom)
		    segGeom(s.segGeom)
		    geometry(s.segGeom)
		    postmile(s.absPostmile)
		}
	}
		
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident, cc++ ){ 
	    inc, json ->
		inc?.toJSON( json )
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.AnalyzedIncident, cc++ ){ 
	    inc, json ->
		inc?.toJSON( json )
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.ProcessedIncident, cc++ ){ 
	    inc, json ->
		inc?.toJSON( json )
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.TmcLogEntry, cc++ ){ 
	    le, json ->
		def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
		json.build{
		    "class(TmcLogEntry)"
		    id(le.id)
		    cad(le.cad)
		    deviceSummary( le.getDeviceSummary() )
		    stampDateTime( le.getStampDateTime() )
		    status(le.status)
		    activitySubject( le.activitysubject )
		    memo(le.memo)
		    memoOnly(le.memoOnly)
		    type("activityLog")
		}
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.CommLogEntry, cc++ ){ 
	    le, json ->
		def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
		json.build{
		    "class(CommLogEntry)"
		    id(le.id)
		    cad(le.cad)
		    deviceSummary( le.getDeviceSummary() )
		    stampDateTime( le.getStampDateTime() )
		    status(le.status)
		    activitySubject( le.activitysubject )
		    memo(le.memo)
		    memoOnly(le.memoOnly)
		    type("commLog")
		}
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.testbed.Vds, cc++ ){ 
	    vds, json ->
		def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
		json.build{
		    "class(Vds)"
		    id(vds.id)
		    //timestamp( df.format( inc.stampDateTime() ) )
		    name(vds.name)
		    calPostmile(vds.calPostmile)
		    absPostmile(vds.absPostmile)
		    lanes(vds.lanes)
		    segmentLength(vds.segmentLength)
		    versionTs(vds.versionTs)
		    freeway(vds.freeway)
		    freewayDir(vds.freewayDir)
		    vdsType(vds.vdsType)
		    district(vds.district)
		    osmRelation(vds.relation)
		    vdsLocation(vds.geom)
		}
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.AnalyzedSection, cc++ ) { 
	    asec, json ->
		json.build{
		    section(asec.section?.id)
		    timesteps(asec.analyzedTimestep)
		}
	}
		
	grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.IncidentSectionData, cc++ ) { 
	    secdat, json ->
		json.build{
		    stamp( secdat.fivemin )
		    vol(secdat.vol)
		    spd(secdat.spd)
		    occ(secdat.occ)
		    inc(secdat.incident_flag)
		    delay(secdat.tmcpe_delay)
		}
	}


	// Identify AJAX requests
	// per http://stackoverflow.com/questions/665067/identifying-ajax-request-or-browser-request-in-grails-controller
	HttpServletRequest.metaClass.isXhr = {->
         'XMLHttpRequest' == delegate.getHeader('X-Requested-With')
	}
    }

    def destroy = {
    }
	
}