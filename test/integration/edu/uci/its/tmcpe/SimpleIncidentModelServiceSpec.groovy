/* @(#)SimpleIncidentModelServiceSpec.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */

package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

class SimpleIncidentModelServiceSpec extends IntegrationSpec {

	def simpleIncidentModelService
	def gamsDelayComputationService

	def "Test that we can determine the critical events by reading from the database"() {
	given: "A baseline ifpa"
		IncidentFacilityPerformanceAnalysis ifpa = new IncidentFacilityPerformanceAnalysis( cad: '498-07072011' )
		;
	when: "we try to read the critical events"
		def ce = simpleIncidentModelService.determineCriticalEvents( ifpa )
		println "CE: ${ce}"
		;

	then:
		ce == [dstr("2011-07-07 18:01:00"),
			   dstr("2011-07-07 18:11:00"),
			   dstr("2011-07-07 18:48:00"),	
			   null ]
		;
	}

	def "test that we can model this incident correctly"() {
	given: "an ifpa that we read from the gams files"
		//IncidentFacilityPerformanceAnalysis ifpa = new IncidentFacilityPerformanceAnalysis( cad: '498-07072011' )
		def ifpa = gamsDelayComputationService.parseGamsResults(
			new File( "test/data/498-07072011-5=N.gms" ),
			new File( "test/data/498-07072011-5=N.lst" ) )
		;

	expect: "it should validate"

		assert ifpa.validate() == true
		;

	when: "we try to determine the critical events"
		def ce = simpleIncidentModelService.determineCriticalEvents( ifpa )
		;

	then: "that should work too"
		ce == [
			dstr("2011-07-07 18:01:00"),
			dstr("2011-07-07 18:11:00"),
			dstr("2011-07-07 18:48:00"),
			dstr("2011-07-07 20:00:00")
		]
		;

	when: "we model it"
		def sim = simpleIncidentModelService.modelIncident( ifpa )
		;

	then: "we get the correct results"
		Math.round(sim.tmcSavings) == 519f
		;

	when: "we save it"
		sim.save(flush:true)
		def id = sim.id
		println "SIM ID: ${sim.id}"
		;

	and: "we try to retreive it"
		def sim2 = SimpleIncidentModel.get(id)
		;

	then: "it should be in the database"
		sim2 != null
		sim2.id == id
		;
		
	}

	Date dstr(String s) { 
		return Date.parse("yyyy-MM-dd HH:mm:ss", s)
	}

}
