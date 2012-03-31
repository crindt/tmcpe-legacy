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

	def "test that we can model a version 0 incident"() { 
	  given: "an ifpa that we read from the gams files"
		def ifpa = gamsDelayComputationService.parseGamsResults(
			new File( "test/data/${cad}-${fac}=${dir}.gms" ),
			new File( "test/data/${cad}-${fac}=${dir}.lst" ) )
		;

	  expect: "it should validate"
		assert ifpa.validate() == true
		;
		
	  when: "we try to determine the critical events"
		def ce = simpleIncidentModelService.determineCriticalEvents( ifpa )
		;

	  then: "that should work"
		ce[0] != null
		ce[1] != null
		ce[2] != null
		ce[3] != null
		;
		
	  when: "we model it"
		def sim = simpleIncidentModelService.modelIncident(ifpa)
		;
		
	  then: "we get the correct results"
		sim.tmcSavings > 0
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
		

	  where:
		//		'565-01222011' | 405 | 'N'
		cad            | fac | dir
		'409-04012011' | 57  | 'S'
	}

	def "test that we can compute a bunch of savings"() { 
	  given: "a list of incidents"

		def list = ProcessedIncident.withCriteria{ 
			def now = new Date()
			between('startTime',dstr('2010-11-01 00:00:00'),dstr('2011-01-01 00:00:00'))
			eq('eventType','INCIDENT')
			order('startTime','asc')
		}.grep { 
			assert it != null
			def bs = it.getActiveAnalysis()?.analysisForPrimaryFacility()?.badSolution;
			return bs == null || bs == "" 
		}
		def locatedList = list.grep{ it.section != null }
		log.info( "PROCESSING ${locatedList.size()} of ${list.size()} INCIDENTS" )
		locatedList.each{ pi ->
			log.info( "PROCESSING ${pi}" )
			try { 

				def ifpa = gamsDelayComputationService.parseGamsResults(
					new File( "data/actlog/gamsdata/${pi.cad}-${pi.section.freewayId}=${pi.section.freewayDir}.gms" ),
					new File( "data/actlog/gamsdata/${pi.cad}-${pi.section.freewayId}=${pi.section.freewayDir}.lst" ) 
				);

				if ( ! ifpa.validate() ) { 
					log.warn "COULD NOT VALIDATE IFPA FOR ${pi.cad} : "
					ifpa.errors.allErrors.each {
						log.warn( it )
					}
					log.warn "...SKIPPING ${pi.cad} : "
				} else { 

					def ce = simpleIncidentModelService.determineCriticalEvents( ifpa )

					def sim = simpleIncidentModelService.modelIncident(ifpa)

					sim.save(flush:true)
					def id = sim.id
					log.info "SIM ID: ${sim.id}"
				}
				
			} catch ( FileNotFoundException e ) { 
				log.warn "${pi.cad} HAS MISSING INPUT FILES: "
				log.warn stackTraceAsString(e)

			} catch ( SimpleIncidentModelService.NoIncidentRegionIdentifiedException e ) { 
				// OK, just let it go
				log.warn "${pi.cad} HAS NO INCIDENT REGION IDENTIFIED...SKIPPING"

			} catch ( GamsDelayComputationService.GamsFileParseException e ) { 
				log.warn "${pi.cad} HAS A GAMS FILE PARSE EXCEPTION...SKIPPING: ${e.message}"

			} catch ( SimpleIncidentModelService.IncidentRegionNotBoundedInTimeException e ) { 
				log.warn "${pi.cad}-${pi.section.freewayId}-${pi.section.freewayDir} IS UNBOUNDED IN TIME...SKIPPING"

			} catch ( SimpleIncidentModelService.IncidentRegionNotBoundedInSpaceException e ) { 
				log.warn "${pi.cad}-${pi.section.freewayId}-${pi.section.freewayDir} IS UNBOUNDED IN SPACE...SKIPPING"

			} catch ( SimpleIncidentModelService.UndeterminedCriticalEventsException e ) {
				log.warn "${pi.cad}-${pi.section.freewayId}-${pi.section.freewayDir} HAS UNDETERMINED CRITICAL EVENTS"

			} catch ( SimpleIncidentModelService.InconsistentCriticalEventCellsException e ) {
				log.warn "${pi.cad}-${pi.section.freewayId}-${pi.section.freewayDir} HAS INCONSISTENT CRITICAL EVENTS: ${e}"
			} catch ( GamsDelayComputationService.IncompleteDataException e ) { 
				log.warn "INCOMPLETE DATA FOR ${pi?.cad}: ${e.message}"
			}
			
			/*
			catch ( Exception e ) { 
				log.warn "CAUGHT UNKNOWN EXCEPTION ${e}: ${stackTraceAsString( e ) }"

				}*/
			

		}
		

	  expect:
		true


	}

	def stackTraceAsString(Throwable t) { 
		StringWriter sw = new StringWriter()
		PrintWriter pw = new PrintWriter(sw)
		org.codehaus.groovy.runtime.StackTraceUtils.printSanitizedStackTrace(t,pw)
		return sw.toString()
	}

	Date dstr(String s) { 
		return Date.parse("yyyy-MM-dd HH:mm:ss", s)
	}

}
