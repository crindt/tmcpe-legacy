//import org.codehaus.groovy.grails.plugins.starksecurity.PasswordEncoder

import edu.uci.its.auth.Role
import edu.uci.its.auth.User

class BootStrap {
	
	def springSecurityService
	
	def init = { servletContext ->
		servletContext.setAttribute("newDataBinder", GlobalPropertyEditorConfig.&newDataBinder)
		servletContext.setAttribute("newBeanWrapper", GlobalPropertyEditorConfig.&newBeanWrapper)
/*		
		String password = springSecurityService.encodePassword('password')
		
		def roleAdmin = new Role(authority: 'ROLE_ADMIN').save()
		def roleUser = new Role(authority: 'ROLE_USER').save()
		
		def user = new User(username: 'user', password: password, enabled: true).save()
		def admin = new User(username: 'admin', password: password, enabled: true).save()
		
		UserRole.create user, roleUser
		UserRole.create admin, roleUser
		UserRole.create admin, roleAdmin, true
		
		 // Create some roles 
		 new Role(authority: 'ROLE_SUPER_USER', description: 'Super user').save()
		 new Role(authority: 'IS_AUTHENTICATED_ANONYMOUSLY', description: 'Anonymous').save()
		 System.err.println( "Added roles " + (Role.findAll().join(", ")) )
		 // Create a user, and add the super user role 
		 // You do this only if you're using the DAO implementation, for LDAP users don't live in your DB. 
		 def user = new User(username: 'crindt', password: PasswordEncoder.encode('d0996e', 'SHA-256', true)) 
		 user.save() 
		 user.addToRoles(Role.findByAuthority('ROLE_SUPER_USER')) 
		 user.save() 
		 System.err.println( "USER: " + user )
		 */
		
		//         grails.converters.JSON.registerObjectMarshaller( org.postgis.Point ) { p, json -> 
		//             json.build{
		//                 "type(Point)"
		//                 coordinates: [p.x, p.y]
		//             }
		//         }
		
		def cc = 1;
		grails.converters.JSON.registerObjectMarshaller(org.postgis.LineString, cc++){ ls, json ->
			def ptlist = []
			ls?.getPoints()?.each() { ptlist.add( [ it?.x, it?.y ] ) }
			json.build{
				"type(LineString)"
				type("LineString")
				coordinates( ptlist )
			}
		}
		
		grails.converters.JSON.registerObjectMarshaller(org.postgis.Point, cc++ ){ p, json ->
			json.build{
				"type(Point)"
				type("Point")
				coordinates( [ p?.x, p?.y ] )
			}
		}
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.FacilitySection, cc++ ){ s, json ->
			json.build {
				"class(FacilitySection)"
				id(s.id)
				name(s.name)
				freewayId(s.freewayId)
				freewayDir(s.freewayDir)
				geom(s.geom)
				segGeom(s.segGeom)
				geometry(s.segGeom)
			}
		}
		
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident, cc++ ){ inc, json ->
			inc?.toJSON( json )
			/*
			 def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
			 json.build{
			 "class(Incident)"
			 id(inc.id)
			 //timestamp( df.format( inc.stampDateTime() ) )
			 timestamp( inc.stampDateTime() )
			 locString( inc.section.toString() )
			 memo(inc.memo)
			 section(inc.section)
			 location( inc.location )
			 geometry(inc.section?.segGeom)
			 analyses( inc.listAnalyses() )
			 analysesCount( inc.listAnalyses()?.size() )
			 }
			 */
		}
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.TmcLogEntry, cc++ ){ le, json ->
			def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
			json.build{
				"class(TmcLogEntry)"
				id(le.id)
				cad(le.cad)
				deviceSummary( le.getDeviceSummary() )
				stampDateTime( le.getStampDateTime() )
				status(le.status)
				activitySubject( le.activitysubject )
				memo(le.memo)
			}
		}
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.testbed.Vds, cc++ ){ vds, json ->
			def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
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
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.AnalyzedSection, cc++ ) { asec, json ->
			json.build{
				section(asec.section?.id)
				timesteps(asec.analyzedTimestep)
			}
		}
		
		grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.IncidentSectionData, cc++ ) { secdat, json ->
			json.build{
				stamp( secdat.fivemin )
				vol(secdat.vol)
				spd(secdat.spd)
				occ(secdat.occ)
			}
		}
	}
	
	
	def destroy = {
	}
} 
