package edu.uci.its.tmcpe

import grails.plugins.springsecurity.Secured
import grails.util.Environment

class HelpController {
	
    def springSecurityService

    def userAgentIdentService

	def grailsApplication
	
    static allowedMethods = []
	
    def index = {
		
		if ( springSecurityService.isLoggedIn() ) {
			redirect( action: 'fullHelp' )
		} else {
			redirect( action: 'anonymousUser' )
		}
    }

    def page = {
      // Load the mdown page matching the given term
      def theterm = "index"
      if ( params.term && params.term != "" ) {
        theterm = params.term
      }
	  def f = null
	  switch ( Environment.current ) { 
		case Environment.PRODUCTION:
			f = new File( grailsApplication.mainContext.servletContext.getRealPath("/WEB-INF/web-app/mdown/") + "/" + theterm + ".mdown" )
			break;
		case Environment.DEVELOPMENT:
		default:
			f = new File( "web-app/mdown" + "/" + theterm + ".mdown" )
	  }
	  
      if ( f != null && f.exists() ) {
        render(view: "helpRender", model: [content: f.getText()])
      } else {
        render(view: "helpMissingPage", model: [page: theterm, f: f.canonicalPath] )
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
	flash.message = """\
       Your browser <b>${userAgentIdentService.getBrowserName()}-${userAgentIdentService.getBrowserVersion()}</b> 
       is not supported."""
    }

    def prezi = {
    }
	
}
