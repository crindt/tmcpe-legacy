package edu.uci.its.tmcpe

import grails.plugins.springsecurity.Secured

class HelpController {
	
    def springSecurityService

    def userAgentIdentService

	
    static allowedMethods = []
	
    def index = {
		
	if ( springSecurityService.isLoggedIn() ) {
	    redirect( action: 'fullHelp' )
	} else {
	    redirect( action: 'anonymousUser' )
	}
    }
	
    def anonymousUser = {
    }
	
    // Only authenticated users will be automatically redirected to the user guide
    @Secured(['ROLE_USER'])
    def fullHelp = {
	redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/wiki/User_Guide')
    }

    def browserHelp = {
	flash.message = ["Your browser",
			 userAgentIdentService.getBrowserType(),
			 "version",
			 userAgentIdentService.getBrowserVersion(),
			 "is not supported"].join(" ")
    }

    def prezi = {
    }
	
}
