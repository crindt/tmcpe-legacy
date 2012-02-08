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

class GamsDelayComputationServiceSpec extends TmcpeIntegrationSpec {

	def gamsDelayComputationService

    def "Test that the we can run the GAMS solver"() {
      given: "a GamsDelayComputationService remote executor and a Gams input file"
        File gms = new File('test/data/1-send.gms')

        // push a method on to create a scoped inner class
        def remexec = new GamsDelayComputationService.RemoteExecutor( infile:gms, destroyExisting:true )
        ;

      when:  "we sync the file to the GAMS server"
        remexec.syncGmsFile()
        ;

      then: "we don't get an rsync exception"
        notThrown GamsDelayComputationService.RemoteExecutor.RsyncFailedException
        ;
        
      and: "we don't get any other exception"
        notThrown Exception
        ;


      when: "we tell GAMS to run"
        remexec.execGams()
        ;

      then: "it completes successfully"
        notThrown GamsDelayComputationService.RemoteExecutor.GamsFailedException
        ;
        
      and: "we don't get any other exception"
        notThrown Exception
        ;


      when:  "we sync the LST result file from the GAMS server"
	remexec.syncLstFile()
        ;

      then: "we don't get an rsync exception"
        notThrown GamsDelayComputationService.RemoteExecutor.RsyncFailedException
        ;
        
      and: "we don't get any other exception"
        notThrown Exception
        ;


      when: "we read the result"
        ;

      then: "we get equivalence with the original data"
        ;
    }


    def "Test that sync errors are caught properly"() {

      given: "a Gams input file"
        File gms = new File('test/data/1-send.gms')
        ;

      when: "The target exists and we haven't set destroyExisting"
        // make sure the LST file already exists

        def ff = new File('test/data/1-send.lst')
        ff.withWriter('UTF-8') { it.writeLine 'this file exists' }
        ;

      and: "We try to set up a remoteexecutor"
        remexec = new GamsDelayComputationService.RemoteExecutor( infile:gms, destroyExisting:false )
        ;
        
      then: "The remote executor won't run"
        GamsDelayComputationService.RemoteExecutor.LstFileExistsException e = thrown()
        ;
		}


    def "Test that we can save an ifpa into the test mongo db"() {
      given: "A gamsComputationService and particular LST file"
        def gamsService = new GamsDelayComputationService()
		def gms = new File("test/data/1.gms")
        def lst = new File("test/data/1.lst")
        ;

      when: "we parse the file"
        def ifpa = gamsService.parseGamsResults(gms, lst)
		ifpa.modelConfig.sectionId = 0  // to prevent validation failure
        if ( ifpa.validate() != true ) {
            ifpa.errors.allErrors.each {
                println it
            }
        }
        ;

      then:  "it reads it successfully"
        ifpa != null
        ifpa instanceof IncidentFacilityPerformanceAnalysis
        ;

      and:   "creates a valid IncidentFacilityPerformanceAnalysis"
        ifpa.validate() == true
        ;

      when:  "we write it to the database"
        ifpa.save(flush:true)
        ;
        
      then: "it should be a valid object in the database"
        IncidentFacilityPerformanceAnalysis.get(ifpa.id) != null
        ;

      and: "when we search for it by CAD we should get a result"
        IncidentFacilityPerformanceAnalysis.findByCad(ifpa.cad) != null
        ;
    }

	def "Test that we can compute a new delay analysis"() { 
	  given: "A GamsDelayComputationService and a processed incident"
		def pi = ProcessedIncident.findByCad( '267-11062010' )
		assert pi != null
		;
		
	  when: "We generate an analysis that is successful"
		def ifpa = gamsDelayComputationService.generateAnalysis( pi )
		;

	  and: "WE compute the facility performance"
		ifpa = gamsDelayComputationService.computeIncidentFacilityPerformance( ifpa )
		;
		
	  then: "That completes successfully"
		ifpa.modelIsOptimal() == true
		;

	  when: "We save it"
		log.info("COMPUTED IFPA: ${ifpa.id}: ${ifpa}")
		ifpa.modelStats = [:]
		ifpa.avgConditions = []
		ifpa.obsConditions = []
		ifpa.save(flush:true)
		;
		
	  then: "Everyone's happy"
		IncidentFacilityPerformanceAnalysis.get(ifpa.id) != null
		
		
		
	}


    def "Test that we can generate a new IFPA from an incident section and time range"() {
      given: "A GamsDelayComputationService, a location, and a time range"
		ProcessedIncident pi = new ProcessedIncident(
			cad: "123-123456",
			section: FacilitySection.get(1204091),
			startTime: Date.parse('yyyy-MM-dd HH:mm', '2011-10-01 08:00'),
			preWindow: 20,
			postWindow: 120
		)

        ;

	  when: "We generate an analysis"
		def ifpa = gamsDelayComputationService.generateAnalysis( pi, new GamsModelConfig(preWindow:20, postWindow: 120))

		;

      then:
		ifpa.timesteps[0] == dstr('2011-10-01 07:40')
		ifpa.timesteps[ifpa.timesteps.size()-1] == dstr('2011-10-01 10:00')
		ifpa.obsConditions[ifpa.sectionIndex(FacilitySection.get(1204091))][ifpa.timestampIndex(dstr('2011-10-01 08:40'))] == [vol: 321, occ: 0.0691, spd: 65, p: 1.0]
		ifpa.avgConditions[ifpa.sectionIndex(FacilitySection.get(1204091))][ifpa.timestampIndex(dstr('2011-10-01 08:40'))] == [vol: 385.1346153846153846, occ: 0.07910769230769230769, spd: 71.0884615384615385 ]
		println ifpa.toString()
      ;

	  when: "We use that analysis to run gams"
	    def newifpa = gamsDelayComputationService.computeIncidentFacilityPerformance( ifpa )
	  ;

	  then: "it works!"
	    newifpa.modelStats.objective_value == 100
	  ;
	}

	def dstr(String s) { Date.parse('yyyy-MM-dd HH:mm', s) }
}
