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

class GamsDelayComputationServiceSpec extends IntegrationSpec {

	def gamsDelayComputationService

	def "Test that we can parse a legacy datafile using IFPA data"() { 
	  given: "A GAMS file"
		def gms = new File(file)
		;
		
	  when: "we migrate the file"
		def ifpa = gamsDelayComputationService.backfillLegacyData(gms)
		println "CAD: ${ifpa.cad}"
		def isvalid = ifpa.validate()
        if ( isvalid != true ) {
            ifpa.errors.allErrors.each {
                println it
            }
        }
		;

	  then: "the data should validate"
		file && ( isvalid == valid )
		;

	  where:
		file                               | valid
		'test/data/498-07072011-5=N.gms'   | true
		'test/data/565-01222011-405=N.gms' | true
		;
		
	}

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
        println(ifpa.avgConditions)
        ifpa.save(flush:true)
        ;
        
      then: "it should be a valid object in the database"
        IncidentFacilityPerformanceAnalysis.get(ifpa.id) != null
        ;

      and: "when we search for it by CAD we should get a result"
        IncidentFacilityPerformanceAnalysis.findByCad(ifpa.cad) != null
        ;
    }
}
