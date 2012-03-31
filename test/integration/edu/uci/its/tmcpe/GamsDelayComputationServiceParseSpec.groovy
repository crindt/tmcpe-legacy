/* @(#)GamsDelayComputationServiceSpec.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */

package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

class GamsDelayComputationServiceParseSpec extends TmcpeIntegrationSpec {

	def gamsDelayComputationService

	def "Test that we can parse a legacy datafile using IFPA data"() { 
	  given: "A GAMS file"
		def gms = new File(file)
		;
		
	  when: "we migrate the file"
		def ifpa = gamsDelayComputationService.backfillLegacyData(gms)
		println "CAD: ${ifpa.cad}"
		;

	  then: "the data should validate"
		file && validationStatusMatches( ifpa, valid )
		;

	  where:
		file                               | valid
		'test/data/498-07072011-5=N.gms'   | true
		'test/data/565-01222011-405=N.gms' | true
		;
		
	}

	def dstr(String s) { Date.parse('yyyy-MM-dd HH:mm', s) }
}
