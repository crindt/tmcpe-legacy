package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class IncidentFacilityPerformanceAnalysisSpec extends UnitSpec {

	def "Test that IncidentFacilityPerformanceAnalysis can be persisted"() {

      given: "a new IncidentFacilityPerformanceAnalysis object"
		mockDomain(IncidentFacilityPerformanceAnalysis)
        ;

      when: "we save it"
        ;

      then: "it should be a valid object in the database"
        ;


	  when: "we change it"
		;
		
	  then: "that should be reflected in the database too"
    }



	def "Test that IncidentFacilityPerformanceAnalysis must have minimum fields defined"() {

      given: "a Facility Performance"
		mockForConstraintsTests(IncidentFacilityPerformanceAnalysis)
		//mockDomain(IncidentFacilityPerformanceAnalysis)
        ;

      when: "we set the data"
		def ifpa = new IncidentFacilityPerformanceAnalysis(cad:'123-123',totalDelay:0f,avgDelay:0f,d35NetDelay:0f,tmcpeNetDelay: 0f)
		ifpa.sections = [1,2]
		ifpa.times = [1,2]
		ifpa.obsConditions = new TimeSpaceConditions()
		ifpa.obsConditions.spds = ospd
		ifpa.obsConditions.flows = oflw
		ifpa.obsConditions.occs = oocc
		ifpa.obsConditions.incidents = [[1,0],[0,1]]
		ifpa.avgConditions = new TimeSpaceConditions()
		ifpa.avgConditions.spds = aspd
		ifpa.avgConditions.flows = aflw
		ifpa.avgConditions.occs = aocc
		ifpa.avgConditions.incidents = [[null,null],[null,null]]
		;
		
      then: "we should get the expected validation result"
		ifpa.validate() == valid
		;
		
	  where:
		ospd                  | oflw              | oocc                          | aspd                  | aflw              | aocc                          | valid
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | true

		// dimensions wrong
		[[11f,12f]]           | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | false

		// Underlying TimeSpaceConditions are invalid (wrong dimensions)
		[[11f],[21f,22f]]     | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | false

    }


}
