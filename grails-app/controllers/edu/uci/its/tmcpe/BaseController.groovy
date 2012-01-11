package edu.uci.its.tmcpe


import org.geeks.browserdetection.UserAgentIdentService
import org.geeks.browserdetection.ComparisonType

class BaseController {

    // Handling dodgy user agents
    def userAgentIdentService

    def beforeInterceptor = {
	def ver = userAgentIdentService.getBrowserVersion().split("\\.")
	log.info( "BROWSER VERSION: " + ver.join("..") )
        log.info( "BROWSER TYPE:    " + userAgentIdentService.getBrowserName() + " " +  userAgentIdentService.getBrowserVersion())
        if ( userAgentIdentService.isChrome(ComparisonType.GREATER, "10") 
             || userAgentIdentService.isFirefox(ComparisonType.GREATER, "4.0") ) {
            //
        } else {
            redirect(controller:'help',action:'browserHelp')
        }
    }
}

