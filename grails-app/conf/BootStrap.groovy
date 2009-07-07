import edu.uci.its.auth.*
import org.apache.commons.codec.digest.DigestUtils as DU

/* registering custom marshallers in Bootstrap.groovy */
import grails.converters.JSON
import org.postgis.Point



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

         grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident){ inc, json ->
             def df = new java.text.SimpleDateFormat("yyyy-MMM-dd HH:mm")
//             def locjson = inc.location as JSON
             json.build{
                 "class(Incident)"
                 id(inc.id)
                 timestamp( inc.stampDateTime() )
                 locString( inc.section.toString() )
                 memo(inc.memo)
                 section(inc.section)
                 location( [ type: "Point", coordinates: [inc.location.x,inc.location.y] ] )
             }
         }
//           grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident){ inc, json ->
//               json.build{
//                   "class(Incident)"
//                   id(inc.id)
//                   vdsid(inc.vdsId)
//                  location{ 
//                      "type(Point)" 
//                      coordinates( [inc.location.x, inc.location.y] ) 
//                  }
//               }
//           }

//         grails.converters.JSON.registerObjectMarshaller(org.postgis.Point){ json ->
//              json.build{
//                  "type(Point)"
//                  id(inc.id)
//                  vdsid(inc.vdsId)
//                 coordinates( [ it?.x, it?.y ] )
//              }
//          }
     }
     def destroy = {
     }
} 
