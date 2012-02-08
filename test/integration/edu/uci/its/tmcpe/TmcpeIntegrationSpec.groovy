/* @(#)TmcpeUnitSpec.groovy
 */
/**
 * A common unit test class with some helper methods
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

import grails.plugin.spock.*

class TmcpeIntegrationSpec extends IntegrationSpec {

	/**
	 * This method is a wrapper for spock validation tests that prints out
	 * validation problems if they occur
	 */
	def validationStatusMatches(var,status) { 
		if ( var.validate() == status ) { 
			return true
		} else { 
			if ( status == true ) { 
				println "Validation errors found when not expected:"
				var.errors.allErrors.each {
					println it
				}
			} else { 
				println "No validation errors found when expected:"
			}
			println "VAR IS: ${var}"
			return false
		}
	}

    def reportExceptionWithTrue(e) { 
        println "RECEIVED EXCEPTION: "+e.getMessage()
        return true
    }
}
