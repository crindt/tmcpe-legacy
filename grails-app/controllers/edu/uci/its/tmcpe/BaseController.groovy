package edu.uci.its.tmcpe


import org.geeks.browserdetection.UserAgentIdentService

class BaseController {

    // Handling dodgy user agents
    def userAgentIdentService

    def beforeInterceptor = {
	def ver = userAgentIdentService.getBrowserVersion().split("\\.")
	switch ( userAgentIdentService.getBrowserType() ) {
	case UserAgentIdentService.FIREFOX:
	    if ( (ver[0] < 3) || (ver[0].toInteger() == 3 && ver[1].toInteger() < 5) ) {
		redirect(controller:'help',action:'browserHelp');
	    }
	    break;
	case UserAgentIdentService.CHROME:
	    break;
	default:
	    redirect(controller:'help',action:'browserHelp');
	    break;
	}
    }

}

