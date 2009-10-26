import edu.uci.its.auth.*
import org.apache.commons.codec.digest.DigestUtils as DU

/* registering custom marshallers in Bootstrap.groovy */
import grails.converters.JSON
import org.postgis.Point
import org.postgis.LineString



class BootStrap {

    def authenticateService

     def init = { servletContext ->
         servletContext.setAttribute("newDataBinder", GlobalPropertyEditorConfig.&newDataBinder)
         servletContext.setAttribute("newBeanWrapper", GlobalPropertyEditorConfig.&newBeanWrapper)

         def encodedPassword = authenticateService.encodePassword("d0996e")
         def adminUser = new TmcpeUser( username: 'crindt',
                                        userRealname: 'Craig Rindt',
                                        passwd: encodedPassword,
                                        email: 'crindt@uci.edu',
                                        emailShow: false, 
                                        description: 'none')
         adminUser.save()

         def adminRole = new TmcpeRole( authority: 'ROLE_ADMIN',
                                        description: 'Administrator' )
         adminRole.addToPeople( adminUser ).save()

         def requestMap = new TmcpeRequestmap( url: '/secure/**',
                                               configAttribute: 'ROLE_ADMIN' ).save()
         requestMap = new TmcpeRequestmap( url: '/tmcperequestmap/**',
                                           configAttribute: 'ROLE_ADMIN' ).save()
         requestMap = new TmcpeRequestmap( url: '/tmcperole/**',
                                           configAttribute: 'ROLE_ADMIN' ).save()
         requestMap = new TmcpeRequestmap( url: '/tmcpeuser/**',
                                           configAttribute: 'ROLE_ADMIN' ).save()


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
                 timestamp( inc.stampDateTime() )
                 locString( inc.section.toString() )
                 memo(inc.memo)
                 section(inc.section)
                 location( inc.location )
                 geometry(inc.section?.segGeom)
             }
         }
     }
     def destroy = {
     }
} 
