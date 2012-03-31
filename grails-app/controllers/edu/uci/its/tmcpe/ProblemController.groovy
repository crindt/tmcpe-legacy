package edu.uci.its.tmcpe

import java.net.URLEncoder
import org.codehaus.groovy.grails.plugins.codecs.URLCodec

class ProblemController {

	def report = {
		if ( params.description == null ) {
			params.description = "";  // force description
		}
		def paramstr = params.collect{ key, val -> 
			def s = "issue[${key}]=${val}" 
			if ( key == 'description' )
				s += "\r\rUser Agent: "+request.getHeader("User-Agent")
			URLEncoder.encode( s, URLCodec.getEncoding())
		}.join("&")
		
	    redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/issues/new?'+paramstr)
	}
	
	
}
