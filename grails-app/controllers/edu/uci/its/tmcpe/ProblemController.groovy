package edu.uci.its.tmcpe

import java.net.URLEncoder
import org.codehaus.groovy.grails.plugins.codecs.URLCodec

class ProblemController {
	
	// Get security service reference via dependency injection
	def springSecurityService

    static navigation = [
        [group: 'dashboard', order:97, title:'Report Problem', action: 'report', isVisible: { springSecurityService.isLoggedIn() }],
        ]

	def report = {
	    def url = URLEncoder.encode( "issue[description]=User Agent: "+request.getHeader("User-Agent") +'\n\n', URLCodec.getEncoding()) 
		redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/issues/new?'+url)
	}
	
	
}
