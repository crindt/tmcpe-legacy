//import org.codehaus.groovy.grails.plugins.starksecurity.PasswordEncoder

//import edu.uci.its.auth.Role
//import edu.uci.its.auth.User

class BootStrap {

    def authenticateService

     def init = { servletContext ->
         servletContext.setAttribute("newDataBinder", GlobalPropertyEditorConfig.&newDataBinder)
         servletContext.setAttribute("newBeanWrapper", GlobalPropertyEditorConfig.&newBeanWrapper)

/*
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
         grails.converters.JSON.registerObjectMarshaller(org.postgis.LineString, 1){ ls, json ->
             def ptlist = []
             ls?.getPoints()?.each() { ptlist.add( [ it?.x, it?.y ] ) }
             json.build{
                 "type(LineString)"
                 type("LineString")
                 coordinates( ptlist )
              }
          }

         grails.converters.JSON.registerObjectMarshaller(org.postgis.Point, 2 ){ p, json ->
              json.build{
                 "type(Point)"
                 type("Point")
                 coordinates( [ p?.x, p?.y ] )
              }
          }
         
         grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.FacilitySection, 3 ){ s, json ->
              json.build {
                 "class(FacilitySection)"
                 id(s.id)
                 name(s.name)
                 geom(s.geom)
                 segGeom(s.segGeom)
                 geometry(s.segGeom)
              }
         }


         grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident, 4 ){ inc, json ->
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
             }
         }

         grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.TmcLogEntry, 5 ){ le, json ->
             def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
             json.build{
                 "class(Incident)"
                 id(le.id)
                 cad(le.cad)
                 deviceNumber(le.device_number)
                 deviceFwy(le.device_fwy)
                 deviceName(le.device_name)
                 stampDateTime( le.getStampDateTime() )
                 status(le.status)
                 activitySubject( le.activitysubject )
                 memo(le.memo)
             }
         }
     }


     def destroy = {
     }
} 
