package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class IncidentFacilityImpactAnalysisSpec extends UnitSpec {

	def "Test that IncidentFacilityImpactAnalysis can be persisted"() {

      given: "a new IncidentFacilityImpactAnalysis object"
		mockDomain(IncidentFacilityImpactAnalysis)
        ;

      when: "we save it"
        ;

      then: "it should be a valid object in the database"
        ;


	  when: "we change it"
		;
		
	  then: "that should be reflected in the database too"
    }

}
