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


	def "Test that we can model a real dataset"() {

	given: "a GamsDelayComputationservice and SimpleIncidentModelService"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def gamsService = new GamsDelayComputationService()
		def simpleService = new SimpleIncidentModelService()
		;

	and: "a properly formatted set of GAMS files" 
		def gms = new File("test/data/498-07072011-5=N.gms")
		def lst = new File("test/data/498-07072011-5=N.lst")
		;

	when: "we process a real file"
        def ifpa = gamsService.parseGamsResults(gms, lst)
        if ( ifpa.validate() != true ) {
            ifpa.errors.allErrors.each {
                println it
            }
        }
		;

	and: "we compute the incident section"
		def section = simpleService.computeIncidentSection(ifpa)
		;

	then: "we get the expected result"
		section == 16
		;

	when: "we compute the incident start time"
		def startTime = simpleService.computeStartTime(ifpa)
		;
		
	then: "we get the expected result"
		startTime == Date.parse("yyyy-MM-dd HH:mm:ss","2011-07-07 18:00:00")
		;

	when: "we compute the incident clear time"
		def restorationTime = simpleService.computeRestorationTime(ifpa)
		;

	then: "we get the expected result"
		restorationTime == Date.parse("yyyy-MM-dd HH:mm:ss","2011-07-07 20:00:00")
		;

	and: "we use that ifpa to model the service with appropriate parameters"
		/*
		ifpa.modelParams = [ tmcDivPct: 20 ]
		def criticalEvents = //?

		def data = simpleService.doCumulativeFlowProjections
		*/
		
	then: "we should get results consistent with the javascript version"
		;

	}
}
