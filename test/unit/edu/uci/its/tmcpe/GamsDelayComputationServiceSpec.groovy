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

class GamsDelayComputationServiceSpec extends TmcpeUnitSpec {

	def "Test that GMS file versioning is working"() {
	  when: "we set it up"
		;
	  then: "it shouldn't fail"
		false
		;
	}

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
		ifpa.cad                        == cad
		ifpa.facility                   == fac
		ifpa.direction                  == dir
        ifpa.modelStats.solver_status   == sstat
        ifpa.modelStats.model_status    == mstat
        ifpa.modelStats.objective_value == obj
		ifpa.modelStats.netdelay        == netdelay
        ifpa.modelStats.cputime         == cputime
        ifpa.modConditions[5][5].inc    == inc55
        ;

      where:
        test               | cad                 | fac | dir | sstat               | mstat     | obj     | cputime | netdelay  | inc55
        1                  | '123-20110102'      | '5' | 'N' | 'NORMAL COMPLETION' | 'OPTIMAL' | 2.8624f | 8.562f  | 454.8622f | 0
		'498-07072011-5=N' | '498-07072011'      | '5' | 'N' | 'NORMAL COMPLETION' | 'OPTIMAL' | 1.6730f | 2.781f  | 653.6398f | 0
    }

	def "Test that we can read a legacy GMS file (pre version 1) even if it doesn't validate"() { 
      given: "a GamsDelayComputationService"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def gamsService = new GamsDelayComputationService()
        ;

	  and: "a version 0 GAMS file"
		def gms0 = new File('test/data/565-01222011-405=N.gms')
		;
		
	  when: "we parse it"
		def ifpa = gamsService.parseGamsData( gms0 )
		;
		
	  then: "we don't crash, but it doesn't validate"
		ifpa.validate() == false
		ifpa.timesteps == null || ifpa.timesteps.size() == 0
	}

    def "Test that a LST file missing various features will fail to parse"() { 
      given: "a GamsDelayComputationService"
        def gamsService = new GamsDelayComputationService()
        ;
		
      when: "we define flawed input files"
        def gms = new File("test/data/1.gms")
        def lst = new File("test/data/${file}.lst")
        ;
		
      and: "parse them"
        def ifpa = gamsService.parseGamsResults(gms, lst)
        ;
		
      then: "the parse should fail with the proper exception"
        thrown(except)
        ;
		
      where:
        file                 | except
        '1-no-sections'      | GamsDelayComputationService.GamsFileParseException
        '1-no-timesteps'     | GamsDelayComputationService.GamsFileParseException
        '1-no-solver-status' | GamsDelayComputationService.GamsFileParseException
        '1-no-model-status'  | GamsDelayComputationService.GamsFileParseException
        '1-no-objective'     | GamsDelayComputationService.GamsFileParseException
        '1-no-cputime'       | GamsDelayComputationService.GamsFileParseException
        '1-no-totdelay'      | GamsDelayComputationService.GamsFileParseException
        '1-no-avgdelay'      | GamsDelayComputationService.GamsFileParseException
        '1-no-netdelay'      | GamsDelayComputationService.GamsFileParseException
    }

    def "Test that a LST file with improper indices will fail"() {
      given: "A GamsDelayCompuationService parsing a GamsFile"
        def gamsService = new GamsDelayComputationService()
        ;
        
      when: "the lst file D indices don't match what's expected"
        def gms = new File("test/data/1.gms")
        def lst = new File(lstf)
        ;
        
      and:  "we read the GAMS GMS file"
        def ifpa = gamsService.parseGamsResults(gms, lst)
        ;
		
      then: "the read should fail with the proper exception"
        GamsDelayComputationService.MismatchedIndicesException e = thrown()
        ;

      when: "create need to create more tests"
        ;

      and:  "they havn't been defined so"
        ;

      then: "it must fail"
        false  // FIXME: crindt: define this condition
        ;

      where: "the lst files are"
        lstf << ["test/data/1-bad-indices-1.lst",
                 "test/data/1-bad-indices-2.lst"]
        
    }

    def "Test that we can create a valid GAMS input file"() { 
            
      given: "A GamsDelayComputationService and an existing GMS file"
        def gamsService = new GamsDelayComputationService()
        def gms = new File('test/data/1.gms')
        def lst = new File('test/data/1.lst')
        ;

      when: "we parse the existing GMS file to create an ifpa"
        def ifpa = gamsService.parseGamsResults(gms, lst)
        ;

      then:
        //validationStatusMatches( ifpa, true )
        true
        ;
		
      when: "we use that ifpa to generate a new GMS file"
        def gms2 = new File('test/data/1-created.gms')
        gamsService.createGamsData( ifpa, gms2 )
        ;
		
      and: "we parse the new GMS file"
        def ifpa2 = gamsService.parseGamsResults(gms2, lst)
        ;

      then: "the new ifpa2 should match the old ifpa exactly"
        //validationStatusMatches( ifpa2, true )
        ifpa == ifpa2
		  ;
    }


    def "Test that the main API works properly"() {

      given: "An existing scenario that we read an IFPA from and clear the results" 
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def gamsService = new GamsDelayComputationService()
		def gms = new File("test/data/1-created.gms")
        def ifpa = gamsService.parseGamsData(gms)
        ;

      when:  "we run the compute method"
        ifpa = gamsService.computeIncidentFacilityPerformance( 
            ifpa: ifpa 
        )
        ;

      then: 
        notThrown( Exception )
        ifpa.modelIsOptimal()
        ;
    }

	def "Test that we can parse a gams file name for incident and facility"() { 
	  given: "A Gams service and A GAMS filename"
		def gamsService = new GamsDelayComputationService()
		File gms = new File( filename )
		;

	  when: "we parse it"
		def res = gamsService.parseFileName( gms )
		;
		
	  then: "we get the proper cad, facility, and direction"
		res == ( cad == null ? null : [cad:cad, fac:facility,dir:direction] )
		;

	  where:
		filename                 | cad            | facility | direction
		"422-052609-57=S.gms"    | "422-052609"   | "57"     | "S"
		"242-03212011-405=S.gms" | "242-03212011" | "405"    | "S"
		"sdjfalksdf-.gms"        | null           | null     | null
		;
	}
}
