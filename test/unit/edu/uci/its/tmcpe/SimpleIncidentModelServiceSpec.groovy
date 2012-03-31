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
		def sim = simpleService.doCumulativeFlowProjections(ifpa,2/*section*/,criticalEvents, [tmcDivPct: 20])
		;

	  then: "they match what the correct answer should be"
		sim.totalDiversion == 3
		//sim.cumulativeFlows[0].obs  == 0
		sim.cumulativeFlows[1].obs  == 1
		sim.cumulativeFlows[2].obs  == 2
		sim.cumulativeFlows[3].obs  == 3
		sim.cumulativeFlows[4].obs  == 5
		sim.cumulativeFlows[5].obs  == 7
		sim.cumulativeFlows[6].obs  == 9
		sim.cumulativeFlows[7].obs  == 11
		sim.cumulativeFlows[8].obs  == 13
		sim.cumulativeFlows[9].obs  == 15
		sim.cumulativeFlows[10].obs  == 17
		sim.cumulativeFlows[11].obs  == 19
		sim.cumulativeFlows[12].obs  == 21
		sim.cumulativeFlows[13].obs  == 23
		sim.cumulativeFlows[14].obs  == 25

		sim.cumulativeFlows[0].avg  == 0
		sim.cumulativeFlows[1].avg  == 2
		sim.cumulativeFlows[2].avg  == 4
		sim.cumulativeFlows[3].avg  == 6
		sim.cumulativeFlows[4].avg  == 8
		sim.cumulativeFlows[5].avg  == 10
		sim.cumulativeFlows[6].avg  == 12
		sim.cumulativeFlows[7].avg  == 14
		sim.cumulativeFlows[8].avg  == 16
		sim.cumulativeFlows[9].avg  == 18
		sim.cumulativeFlows[10].avg  == 20
		sim.cumulativeFlows[11].avg  == 22
		sim.cumulativeFlows[12].avg  == 24
		sim.cumulativeFlows[13].avg  == 26
		sim.cumulativeFlows[14].avg  == 28

		sim.cumulativeFlows[0].divavg == 0
		sim.cumulativeFlows[1].divavg == 2
		sim.cumulativeFlows[2].divavg == (sim.cumulativeFlows[2].avg - 3*(2-1)/4)
		sim.cumulativeFlows[3].divavg == (sim.cumulativeFlows[3].avg - 3*(3-1)/4)
		sim.cumulativeFlows[4].divavg == (sim.cumulativeFlows[4].avg - 3*(4-1)/4)
		sim.cumulativeFlows[5].divavg == (sim.cumulativeFlows[5].avg - 3*(5-1)/4)
		sim.cumulativeFlows[6].divavg == sim.cumulativeFlows[6].obs
		sim.cumulativeFlows[7].divavg == sim.cumulativeFlows[7].obs
		sim.cumulativeFlows[8].divavg == sim.cumulativeFlows[8].obs
		sim.cumulativeFlows[9].divavg == sim.cumulativeFlows[9].obs
		sim.cumulativeFlows[10].divavg == sim.cumulativeFlows[10].obs
		sim.cumulativeFlows[11].divavg == sim.cumulativeFlows[11].obs
		sim.cumulativeFlows[12].divavg == sim.cumulativeFlows[12].obs
		sim.cumulativeFlows[13].divavg == sim.cumulativeFlows[13].obs
		sim.cumulativeFlows[14].divavg == sim.cumulativeFlows[14].obs		
		;

		sim.cumulativeFlows[0].adjdivavg  == 0
		sim.cumulativeFlows[1].adjdivavg  == 2
		sim.cumulativeFlows[2].adjdivavg  == (sim.cumulativeFlows[2].avg - 3*(2-1)/4 * 0.8)
		sim.cumulativeFlows[3].adjdivavg  == (sim.cumulativeFlows[3].avg - 3*(3-1)/4 * 0.8)
		sim.cumulativeFlows[4].adjdivavg  == (sim.cumulativeFlows[4].avg - 3*(4-1)/4 * 0.8)
		sim.cumulativeFlows[5].adjdivavg  == (sim.cumulativeFlows[5].avg - 3*(5-1)/4 * 0.8)
		sim.cumulativeFlows[6].adjdivavg  == sim.cumulativeFlows[6].obs + 3 * 0.2
		sim.cumulativeFlows[7].adjdivavg  == sim.cumulativeFlows[7].obs + 3 * 0.2
		sim.cumulativeFlows[8].adjdivavg  == sim.cumulativeFlows[8].obs + 3 * 0.2
		sim.cumulativeFlows[9].adjdivavg  == sim.cumulativeFlows[9].obs + 3 * 0.2
		sim.cumulativeFlows[10].adjdivavg == sim.cumulativeFlows[10].obs + 3 * 0.2
		sim.cumulativeFlows[11].adjdivavg == sim.cumulativeFlows[11].obs + 3 * 0.2
		sim.cumulativeFlows[12].adjdivavg == sim.cumulativeFlows[12].obs + 3 * 0.2
		sim.cumulativeFlows[13].adjdivavg == sim.cumulativeFlows[13].obs + 3 * 0.2
		sim.cumulativeFlows[14].adjdivavg == sim.cumulativeFlows[14].obs + 3 * 0.2
		;
	

	  when: "we make revised delay estimates with new critical events"
		println ifpa.obsConditions
		def altCriticalEvents = [0,2,5,-1].collect{ it<0?null:ifpa.timesteps[it] }
		def newsim = simpleService.doDelayProjections(
			ifpa,
			2, // section
			altCriticalEvents,
			1.0,//netDelayTarget
			sim)
		print newsim.cumulativeFlows.collect{ [ it.incflow, it.obs, it.incflow - it.obs ] }
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

		def sim = simpleService.doCumulativeFlowProjections(
			ifpa, section, criticalEvents, [tmcDivPct: 20] )

		println ifpa.stats
		sim = simpleService.doDelayProjections(
			ifpa,section,altCriticalEvents, 
			ifpa.modelStats.netdelay, sim )

		(0..sim.cumulativeFlows.size()-1).each{ m ->
			println "${ifpa.timesteps[m]}, ${sim.cumulativeFlows[m]}"
		}
		
		then: "we should get results consistent with the javascript version"
		Math.round(sim.tmcSavings) == 519f
		;

	}

	def "test ability to pull in critical events"() {
	given:
		def simpleService = new SimpleIncidentModelService()
		def gamsService = new GamsDelayComputationService()
		mockDomain(IncidentFacilityPerformanceAnalysis)
		mockDomain(ProcessedIncident)
		mockDomain(TmcLogEntry)
		mockDomain(FacilitySection)
		;

	when: "we read the gams file"
		def gms = new File("test/data/498-07072011-5=N.gms")
		def lst = new File("test/data/498-07072011-5=N.lst")
        def ifpa = gamsService.parseGamsResults(gms, lst)
        if ( ifpa.validate() != true ) {
            ifpa.errors.allErrors.each {
                println it
            }
        }
		;

	and: "we create a processed incident"
		def cele = [
			new TmcLogEntry( cad: '498-07072011',     stamp: dstr("2011-07-07 18:00:00"), activitysubject: 'FIRST CALL' ).save(flush:true),
			new TmcLogEntry( cad: '498-07072011',  stamp: dstr("2011-07-07 18:11:00"), activitysubject: 'VERIFICATION' ).save(flush:true), 
			new TmcLogEntry( cad: '498-07072011',    stamp: dstr("2011-07-07 18:48:00"), activitysubject: 'LANES CLEAR' ).save(flush:true),
			new TmcLogEntry( cad: '498-07072011', stamp: dstr("2011-07-07 20:00:00"), activitysubject: 'INCIDENT CLEAR' ).save(flush:true),
			]
		ProcessedIncident pi = new ProcessedIncident(
			cad: '498-07072011',
			startTime: dstr("2011-07-07 18:00:00"),
			firstCall:     cele[0],
			verification:  cele[1],
			lanesClear:    cele[2],
			incidentClear: cele[3]
		)
		pi.save(flush:true)

		List pil = ProcessedIncident.list()

		println "PI: ${pi.id} == ${pi} == ${pil}"
		;

	and: "we try to read the critical events"
		def ce = simpleService.determineCriticalEvents( ifpa )
		println "CE: ${ce}"
		;

	then:
		ce == [
			dstr("2011-07-07 18:00:00"),
			dstr("2011-07-07 18:11:00"),
			dstr("2011-07-07 18:48:00"),
			dstr("2011-07-07 20:00:00")
		]
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
