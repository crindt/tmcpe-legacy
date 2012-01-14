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

class SimpleIncidentModelServiceSpec extends TmcpeUnitSpec {

	def "Test that incident region problems are propertly computed"() {

	  given: "an ifpa and a simpleService"
		def simpleService = new SimpleIncidentModelService()
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa = basicIFPA()
		;

	  when: "There is no incident region identified"
		ifpa.modConditions = [[[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]]]
		;

	  and: "we try to computeStartTime"
		simpleService.computeStartTime(ifpa)
		;

	  then: "expect an exception"
		SimpleIncidentModelService.NoIncidentRegionIdentifiedException nrie = thrown()
		;


	  when: "we try to computeRestorationTime"
		simpleService.computeRestorationTime(ifpa)
		;

	  then: "expect an exception"
		nrie = thrown()
		;


	  when: "we try to computeIncidentSection"
		simpleService.computeIncidentSection(ifpa)
		;

	  then: "except an exception"
		nrie = thrown()


		when: "The incident region starts in the first time slice"
		ifpa.modConditions = [[[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:1],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]]]
		;

	  and: "we try to computeStartTime"
		simpleService.computeStartTime(ifpa)
		;

	  then: "expect an exception"
		SimpleIncidentModelService.IncidentRegionNotBoundedInTimeException nbite = thrown()
		;


	  when: "The incident region ends in the last time slice"
		ifpa.modConditions = [[[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:1]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]]]
		;

	  and: "we try to computeRestorationTime"
		simpleService.computeRestorationTime(ifpa)
		;

	  then: "expect an exception"
		nbite = thrown()
		;


	  when: "The incident region is unbounded in space"
		ifpa.modConditions = [[[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:1]],
							  [[inc:0],[inc:1],[inc:0],[inc:0]]]
		;

	  and: "we try to computeIncidentSection"
		simpleService.computeIncidentSection(ifpa)
		;

	  then: "expect an exception"
		SimpleIncidentModelService.IncidentRegionNotBoundedInSpaceException nbise = thrown()
		;
	}

	def "Test that we can compute a model"() {

	  given: "a simple model service and the necessary inputs"
		def simpleService = new SimpleIncidentModelService()
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa = basicIFPA()
		ifpa.modelParams = [ tmcDivPct: 20 ]
		ifpa.sections = [1,2,3,5]
		Date now = new Date(0)
		use ( [groovy.time.TimeCategory] ) {
			ifpa.timesteps = (0..14).collect{ now + (it * 5).minutes }
		}
		println ifpa.timesteps
		ifpa.obsConditions = [[[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:1],[vol:1],[vol:1],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:2],[vol:1],[vol:1],[vol:1],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:2],[vol:2],[vol:1],[vol:1],[vol:1],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							 ].reverse()
		ifpa.avgConditions = [[[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]],
							  [[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2],[vol:2]]
							 ].reverse()
		ifpa.modConditions = [[[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:1],[inc:1],[inc:1],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:1],[inc:1],[inc:1],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0]],
							  [[inc:0],[inc:0],[inc:0],[inc:1],[inc:1],[inc:1],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0],[inc:0]]
							 ].reverse()
		def criticalEvents = [0,1,3,5].collect{ ifpa.timesteps[it] }
		;

	  when: "we compute the incident clear time"  /* restoration */
		def restoration = simpleService.computeRestorationTime(ifpa)
		;

	  then: "we get the correct result"
		restoration == ifpa.timesteps[6]
		;

	  when: "we make a cumulative flow projections"
		println ifpa.obsConditions
		def data = simpleService.doCumulativeFlowProjections(ifpa,2/*section*/,criticalEvents)
		;

	  then: "they match what the correct answer should be"
		data.totalDiversion == 3
		//data.cumflow[0].obs  == 0
		data.cumflow[1].obs  == 1
		data.cumflow[2].obs  == 2
		data.cumflow[3].obs  == 3
		data.cumflow[4].obs  == 5
		data.cumflow[5].obs  == 7
		data.cumflow[6].obs  == 9
		data.cumflow[7].obs  == 11
		data.cumflow[8].obs  == 13
		data.cumflow[9].obs  == 15
		data.cumflow[10].obs  == 17
		data.cumflow[11].obs  == 19
		data.cumflow[12].obs  == 21
		data.cumflow[13].obs  == 23
		data.cumflow[14].obs  == 25

		data.cumflow[0].avg  == 0
		data.cumflow[1].avg  == 2
		data.cumflow[2].avg  == 4
		data.cumflow[3].avg  == 6
		data.cumflow[4].avg  == 8
		data.cumflow[5].avg  == 10
		data.cumflow[6].avg  == 12
		data.cumflow[7].avg  == 14
		data.cumflow[8].avg  == 16
		data.cumflow[9].avg  == 18
		data.cumflow[10].avg  == 20
		data.cumflow[11].avg  == 22
		data.cumflow[12].avg  == 24
		data.cumflow[13].avg  == 26
		data.cumflow[14].avg  == 28

		data.cumflow[0].divavg == 0
		data.cumflow[1].divavg == 2
		data.cumflow[2].divavg == (data.cumflow[2].avg - 3*(2-1)/4)
		data.cumflow[3].divavg == (data.cumflow[3].avg - 3*(3-1)/4)
		data.cumflow[4].divavg == (data.cumflow[4].avg - 3*(4-1)/4)
		data.cumflow[5].divavg == (data.cumflow[5].avg - 3*(5-1)/4)
		data.cumflow[6].divavg == data.cumflow[6].obs
		data.cumflow[7].divavg == data.cumflow[7].obs
		data.cumflow[8].divavg == data.cumflow[8].obs
		data.cumflow[9].divavg == data.cumflow[9].obs
		data.cumflow[10].divavg == data.cumflow[10].obs
		data.cumflow[11].divavg == data.cumflow[11].obs
		data.cumflow[12].divavg == data.cumflow[12].obs
		data.cumflow[13].divavg == data.cumflow[13].obs
		data.cumflow[14].divavg == data.cumflow[14].obs		
		;

		data.cumflow[0].adjdivavg  == 0
		data.cumflow[1].adjdivavg  == 2
		data.cumflow[2].adjdivavg  == (data.cumflow[2].avg - 3*(2-1)/4 * 0.8)
		data.cumflow[3].adjdivavg  == (data.cumflow[3].avg - 3*(3-1)/4 * 0.8)
		data.cumflow[4].adjdivavg  == (data.cumflow[4].avg - 3*(4-1)/4 * 0.8)
		data.cumflow[5].adjdivavg  == (data.cumflow[5].avg - 3*(5-1)/4 * 0.8)
		data.cumflow[6].adjdivavg  == data.cumflow[6].obs + 3 * 0.2
		data.cumflow[7].adjdivavg  == data.cumflow[7].obs + 3 * 0.2
		data.cumflow[8].adjdivavg  == data.cumflow[8].obs + 3 * 0.2
		data.cumflow[9].adjdivavg  == data.cumflow[9].obs + 3 * 0.2
		data.cumflow[10].adjdivavg == data.cumflow[10].obs + 3 * 0.2
		data.cumflow[11].adjdivavg == data.cumflow[11].obs + 3 * 0.2
		data.cumflow[12].adjdivavg == data.cumflow[12].obs + 3 * 0.2
		data.cumflow[13].adjdivavg == data.cumflow[13].obs + 3 * 0.2
		data.cumflow[14].adjdivavg == data.cumflow[14].obs + 3 * 0.2
		;
	

	  when: "we make revised delay estimates with new critical events"
		println ifpa.obsConditions
		def altCriticalEvents = [0,2,5,-1].collect{ it<0?null:ifpa.timesteps[it] }
		def newdata = simpleService.doDelayProjections(
			ifpa,
			2, // section
			altCriticalEvents,
			1.0,//netDelayTarget
			data)
		print newdata.cumflow.collect{ [ it.incflow, it.obs, it.incflow - it.obs ] }
		;
		
	  then: "they match what is expected"
		;
	}



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

	  then: "it should be valid"
		ifpa.validate()
		ifpa.modelStats.netdelay == 653.6398f
		;


	  when: "we compute the incident section"
		def section = simpleService.computeIncidentSection(ifpa)
		;

	  then: "we get the expected result"
		section == 16
		;


	  when: "we compute the incident start time"
		def startTime = simpleService.computeStartTime(ifpa)
		;
		
	  then: "we get the expected result"
		println "ST: $startTime"
		startTime == Date.parse("yyyy-MM-dd HH:mm:ss","2011-07-07 18:00:00")
		;


	  when: "we compute the incident clear time"
		def restorationTime = simpleService.computeRestorationTime(ifpa)
		;

	  then: "we get the expected result"
		restorationTime == dstr("2011-07-07 20:00:00")
		;


	  when: "we use that ifpa to model the service with appropriate parameters"
		ifpa.modelParams = [ tmcDivPct: 20 ]
		def criticalEvents = [
			dstr("2011-07-07 18:00:00"),
			dstr("2011-07-07 18:11:00"),
			dstr("2011-07-07 18:48:00"),
			dstr("2011-07-07 20:00:00")
		]

		def altCriticalEvents
		use ( groovy.time.TimeCategory ) {
			altCriticalEvents = [
				criticalEvents[0],
				criticalEvents[1] + 15.minutes,
				criticalEvents[2] + 15.minutes + 15.minutes,
				null
			]
		}

		def data = simpleService.doCumulativeFlowProjections(
			ifpa, section, criticalEvents )

		println ifpa.modelStats
		data = simpleService.doDelayProjections(
			ifpa,section,altCriticalEvents, 
			ifpa.modelStats.netdelay, data )
		
		then: "we should get results consistent with the javascript version"
		data.tmcSavings == 565f
		;

	}



	Date dstr(String s) { 
		return Date.parse("yyyy-MM-dd HH:mm:ss", s)
	}

	def basicIFPA() {
		return new IncidentFacilityPerformanceAnalysis(
			cad:'123-123',
			facility: 5, direction: 'N',
			totalDelay:0f, avgDelay: 0f, d35NetDelay: 0f, tmcpeNetDelay: 0f);
	}

}
