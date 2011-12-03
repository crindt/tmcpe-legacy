package edu.uci.its.tmcpe

import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class IncidentFacilityPerformanceAnalysisSpec extends TmcpeUnitSpec {

	def "Test that IncidentFacilityPerformanceAnalysis can be persisted"() {

      given: "a new IncidentFacilityPerformanceAnalysis object"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa
        ;

	  when: "we create an ifpa but don't save it"
		ifpa = validIncidentFacilityPerformanceAnalysis()
		ifpa.sections = [1,2]
		ifpa.times = [1,2]
		ifpa.obsConditions = [[[spd:11f,flow:11,inc:1],[spd:12f,flow:12,inc:1]],
							  [[spd:21f,flow:21,inc:1],[spd:22f,flow:22,inc:1]]
							 ]
		ifpa.avgConditions = [[[spd:11f,flow:11,inc:1],[spd:12f,flow:12,inc:1]],
							  [[spd:21f,flow:21,inc:1],[spd:22f,flow:22,inc:1]]
							 ]
		;

	  then: "It shouldn't be in the database"
		IncidentFacilityPerformanceAnalysis.get(ifpa.id) == null

      when: "we save it"
		ifpa.save(flush:true)
        ;

      then: "it should be a valid object in the database"
		IncidentFacilityPerformanceAnalysis.get(ifpa.id) != null
        ;

	  and: "when we search for it by CAD we should get a result"
		IncidentFacilityPerformanceAnalysis.findByCad(ifpa.cad) != null
		;
		

	  when: "we change it"
		ifpa.tmcpeNetDelay = 1f
		ifpa.save(flush:true)
		def ifpa2 = IncidentFacilityPerformanceAnalysis.get(ifpa.id)
		;
		
	  then: "that should be reflected in the database too"
		ifpa2.tmcpeNetDelay == 1f
		
    }



	def "Test that IncidentFacilityPerformanceAnalysis must have minimum fields defined"() {

      given: "a IncidentFacilityPerformanceAnalysis"
		mockForConstraintsTests(IncidentFacilityPerformanceAnalysis)
		def ifpa
		//mockDomain(IncidentFacilityPerformanceAnalysis)
        ;

      when: "we set the data"
		ifpa = validIncidentFacilityPerformanceAnalysis()
		ifpa.sections = [1,2]
		ifpa.times = [1,2]
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

	def "Test that tmcpeNetDelay is computed properly"() { 

	  given: "an IncidentFacilityPerformanceAnalysis"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa
		;
		
	  when: "we have particular data and compute"
		ifpa = validIncidentFacilityPerformanceAnalysis()
		ifpa.sections = [[id:1,len:0.5f],[id:2,len:0.75f]]
		ifpa.times    = [1,2]
		ifpa.obsConditions = obs
		ifpa.avgConditions = avg
		ifpa.modConditions = mod
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

	def "Test that modConditions is validated property"() {
  	  given: "an IncidentFacilityPerformanceAnalysis"
		mockDomain(IncidentFacilityPerformanceAnalysis)
		;

	  when: "we set the data with modConditions from an analysis"
		;

  	  and: "those modConditions have different dimensions than obs/avgConditions"
		;

	  then: "validation should fail"
		false  // FIXME: WRITE THIS CONDITION
		;

	  when: "those modConditions have the same dimensions as obs/avgConditions"
		;

  	  then: "validation should succeed"
		false  // FIXME: WRITE THIS CONDITION
		;
	}

	def "Test if model characterizations are correctly evaluated"() {
	  given:
		mockDomain(IncidentFacilityPerformanceAnalysis)
		def ifpa = new IncidentFacilityPerformanceAnalysis()
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
		return new IncidentFacilityPerformanceAnalysis(
			cad:'123-123',
			facility: 5,direction: 'N',
			totalDelay:0f,avgDelay:0f,d35NetDelay:0f,tmcpeNetDelay: 0f)

	}
}
