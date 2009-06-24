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

         grails.converters.JSON.registerObjectMarshaller(edu.uci.its.tmcpe.Incident){ inc, json ->
             json.build{
                 "class(Incident)"
                 id(inc.id)
                 vdsid(inc.vdsId)
                 longitude( inc.location.x )
                 latitude( inc.location.y )
             }
         }

     }
     def destroy = {
     }
} 
