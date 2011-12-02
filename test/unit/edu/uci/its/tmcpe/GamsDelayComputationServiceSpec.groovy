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

class GamsDelayComputationServiceSpec extends UnitSpec {

	def "Test that the getMatch method works as expected"() {
      given: "a GamsDelayComputationService"
		def gamsService = new GamsDelayComputationService()
        ;

      when:  "we parse a line for data"
		def result = gamsService.getMatch( lines, re, 0, pos )
		;

	  then: "we grab it properly"
		result == val
		;

	  where:
		lines               | re                 | pos | val
		[ "Simple Data 1" ] | /Simple Data (\d)/ | 1   | "1"
		[ "aSD 1", "SD 2" ] | /^SD (\d)/         | 1   | "2"
		;
	}

	def "Test that the getMatchAndContinue method works as expected"() {
      given: "a GamsDelayComputationService"
		def gamsService = new GamsDelayComputationService()
        ;

      when:  "we parse a line for data"
		gamsService.getMatchAndContinue( lines, reskip )
		def result = gamsService.getMatch( lines, re, 0, pos )
		;

	  then: "we grab it properly"
		result == val
		;

	  where:
		lines                                 | reskip           | re         | pos | val
		[ "SD 0", "Skip this line", "SD 1" ]  | /Skip this line/ | /^SD (\d)/ | 1   | "1"
		[ "aSD 1", "Skip this line", "SD 2" ] | /Skip this line/ | /^SD (\d)/ | 1   | "2"
		;
	}
		

	def "Test that the GamsDelayComputationService can parse GAMS LST files"() {

      given: "a GamsDelayComputationService"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def gamsService = new GamsDelayComputationService()
        ;

	  and:   "a properly formatted GAMS LST file"
		def gms = new File("test/data/${test}.gms")
		def lst = new File("test/data/${test}.lst")
		;
		
      when:  "we tell the service to parse the file"
		def ifpa = gamsService.parseGamsResults(gms, lst)
		if ( ifpa.validate() != true ) {
			ifpa.errors.allErrors.each {
				println it
			}
		}
        ;

      then:  "it reads it successfully"
		ifpa != null
        ;

	  and:   "creates a valid IncidentFacilityPerformanceAnalysis"
		ifpa.validate() == true
		;

	  and: "and the data read is correct"
		ifpa.modelStats.solver_status   == sstat
		ifpa.modelStats.model_status    == mstat
		ifpa.modelStats.objective_value == obj
		ifpa.modelStats.cputime         == cputime
		ifpa.modConditions[5][5].inc    == inc55
		;

	  where:
		test    |  sstat               | mstat     | obj     | cputime  | inc55
		1       |  'NORMAL COMPLETION' | 'OPTIMAL' | 2.8624f | 8.562f   | 0
    }

	def "Test that a LST file with improper indices will fail"() {
	  given: "A GamsDelayCompuationService parsing a GamsFile"
		;
	  when: "the lst file D indices don't match what's expected"
		;
 	  then: "the read should fail"
		//gamsService.parseGamsResults( gms, lst )
		;

	  and: "but this hasn't been defined"
		;
	  then: "it must fail"
		false
		;
	}
}
