package edu.uci.its.tmcpe

import java.net.URLEncoder
import org.codehaus.groovy.grails.plugins.codecs.URLCodec

class ProblemController {

	def report = {
	    def url = URLEncoder.encode( "issue[description]=User Agent: "+request.getHeader("User-Agent") +'\n\n', URLCodec.getEncoding()) 
	    redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/issues/new?'+url)
	}
	
	
}
