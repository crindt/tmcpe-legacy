package edu.uci.its.tmcpe

import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class IncidentFacilityPerformanceAnalysisSpec extends TmcpeUnitSpec {

	def "Test our 'valid' IFPA is actually valid"() {
	  given:
		mockForConstraintsTests(IncidentFacilityPerformanceAnalysis )
		def ifpa = validIncidentFacilityPerformanceAnalysis()
		;

	  expect:
		validationStatusMatches( ifpa, true )
		;
	}

	def "Test that IncidentFacilityPerformanceAnalysis can be persisted"() {

      given: "a new (valid) IncidentFacilityPerformanceAnalysis object"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa = validIncidentFacilityPerformanceAnalysis()
        ;

	  when: "we create an ifpa but don't save it"
		;

	  then: "It shouldn't be in the database"
		IncidentFacilityPerformanceAnalysis.get(ifpa.id) == null

      when: "we save it"
		ifpa.save()
        ;

      then: "it should be a valid object in the database"
		IncidentFacilityPerformanceAnalysis.get(ifpa.id) != null
        ;

	  and: "when we search for it by CAD we should get a result"
		IncidentFacilityPerformanceAnalysis.findByCad(ifpa.cad) != null
		;
		

	  when: "we change it"
		ifpa.tmcpeNetDelay = 1f
		ifpa.save()
		def ifpa2 = IncidentFacilityPerformanceAnalysis.get(ifpa.id)
		;
		
	  then: "that should be reflected in the database too"
		ifpa2.tmcpeNetDelay == 1f
    }



	def "Test that IncidentFacilityPerformanceAnalysis must have minimum fields defined"() {

      given: "a valid IncidentFacilityPerformanceAnalysis"
		mockForConstraintsTests(IncidentFacilityPerformanceAnalysis)
		def ifpa = validIncidentFacilityPerformanceAnalysis()
        ;

      when: "we tweak the data"
		ifpa.obsConditions = obs
		ifpa.avgConditions = avg
		;
		
      then: "we should get the expected validation result"
		validationStatusMatches( ifpa, expected )
		;
		
	  where:
		obs << [
			[[[spd:11f,flow:11],[spd:12f,flow:12]],
			 [[spd:21f,flow:21],[spd:22f,flow:22]]
			],
			// missing data for one section (should fail)
			[[[spd:11f,flow:11]],
			 [[spd:21f,flow:21],[spd:22f,flow:22]]
			]
		]
		avg << [
			[[[spd:11f,flow:11],[spd:12f,flow:12]],
			 [[spd:21f,flow:21],[spd:22f,flow:22]]
			],
			[[[spd:11f,flow:11],[spd:12f,flow:12]],
			 [[spd:21f,flow:21],[spd:22f,flow:22]]
			],
		]
		expected << [true,false]
    }


	def "Test that modConditions is validated property"() {
  	  given: "an IncidentFacilityPerformanceAnalysis"
		mockForConstraintsTests(IncidentFacilityPerformanceAnalysis)
		def ifpa = validIncidentFacilityPerformanceAnalysis()
		;

	  when: "we set the data with modConditions from an analysis"
		ifpa.modConditions = mod
		;

	then: "validation should match expected"
		validationStatusMatches( ifpa, expected )
		;

	where: 
		mod << [
			// nothing (succeed)
			null,

			// same dimensions (succeed)
			[[[inc:1],[inc:1]],
			 [[inc:1],[inc:1]]
			],
			// different dimensions (fail)
			[[[inc:1]],
			 [[inc:1],[inc:1]]
			]
			]
		expected << [ true, true, false ]
		;

	}


	def "Test that tmcpeNetDelay is computed properly"() { 

	  given: "an IncidentFacilityPerformanceAnalysis"
		//mockDomain(IncidentFacilityPerformanceAnalysis)  /* FIXME: Seems like we can only call "mockdomain" once in a test class */
		def ifpa = validIncidentFacilityPerformanceAnalysis()
		;

	  when: "we have particular data"
		ifpa.sections = [[id:1,len:0.5f],[id:2,len:0.75f]]
		ifpa.timesteps = [1,2]
		ifpa.obsConditions = obs
		ifpa.avgConditions = avg
		ifpa.modConditions = mod

	  then: "it should be valid"
		validationStatusMatches( ifpa, true )

	  when: "we compute net delay"
		ifpa.computeNetDelays()
		;

	  then: "netDelay matches expected"
		ifpa.tmcpeNetDelay.round(5) == result.round(5)
		;

	  where:
		obs << [
			[[[spd:35f,flow:100,inc:1],[spd:25f,flow:300,inc:1]],
			 [[spd:40f,flow:300,inc:1],[spd:50f,flow:200,inc:0]]
			]
		]
		avg << [
			[[[spd:45f,flow:500],[spd:50f,flow:500]],
			 [[spd:50f,flow:500],[spd:70f,flow:500]]
			]
		]
		mod << [
			[[[inc:1],[inc:1]],
			 [[inc:1],[inc:0]]]
		]
		result << [(float)(0.5f*(1f/35f-1/45f)*100+0.5*(1f/25f-1f/50f)*300+0.75f*(1f/40f-1f/50f)*300)]
	}


	def "Test if model characterizations are correctly evaluated"() {
	  given:
		//mockDomain(IncidentFacilityPerformanceAnalysis)  /* FIXME: Seems like we can only call "mockdomain" once in a test class */
		def ifpa = validIncidentFacilityPerformanceAnalysis()
		;

  	  when: "an ifpa has various model_status values"
		ifpa.modelStats = ms
	    ;

  	  then: "the modelIsOptimal method will return the correct result"
		ifpa.modelIsOptimal() == expected_optimal
		;

	  and: "the modelIsInfeasible method will return the correct result"
		ifpa.modelIsInfeasible() == expected_infeasible

	  where:
		ms << [[:],
			   [dog:'cat'],  // it has a modelStats, but not model_status
			   [model_status:'INFEASIBLE'],
			   [model_status:'OPTIMAL']
			  ]
		expected_optimal    << [false,false,false,true]
		expected_infeasible << [false,false,true,false]
	}

	def validIncidentFacilityPerformanceAnalysis() { 
		def ifpa = new IncidentFacilityPerformanceAnalysis(
			cad:'123-123',
			facility: 5,direction: 'N',
			totalDelay:0f,avgDelay:0f,d35NetDelay:0f,tmcpeNetDelay: 0f)
		ifpa.sections = [1,2]
		ifpa.timesteps = [1,2]
		ifpa.obsConditions = [
			[[spd:11f,flow:11,inc:1],[spd:12f,flow:12,inc:1]],
			[[spd:21f,flow:21,inc:1],[spd:22f,flow:22,inc:1]]
		]
		ifpa.avgConditions = [
			[[spd:11f,flow:11,inc:1],[spd:12f,flow:12,inc:1]],
			[[spd:21f,flow:21,inc:1],[spd:22f,flow:22,inc:1]]
		]
		return ifpa
	}
}
