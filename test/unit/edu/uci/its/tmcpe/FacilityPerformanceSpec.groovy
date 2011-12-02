/**
 * Specification for FacilityPerformance
 *
 * A FacilityPerformance encapsulates the characterization of how a stretch of
 * freeway performs over some given time period.  The characterization can be
 * from a direct measurement or from some arbitrary model.  
 *
 * For now, this characterization is strictly based upon delay and net delay
 * (delay versus "normal" conditions)
 */

package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class FacilityPerformanceSpec extends UnitSpec {


    def "Test that FacilityPerformance can be persisted"() {

	  given: "a new FacilityPerformance object" 
        mockDomain(FacilityPerformance)
		;
		
	  when: "we save it"
		;
		
	  then: "it should be a valid object in the database"
		;

	  when: "we change it"
		;
		
	  then: "that should be reflected in the database too"
		;
    }



	def "Test that FacilityPerformance must have minimum fields defined"() {

      given: "a Facility Performance"
		mockForConstraintsTests(FacilityPerformance)
        ;

      when: "we set the data"
		def fp = new FacilityPerformance(totalDelay:td,avgDelay:ad,d35NetDelay:d35d,tmcpeNetDelay: tmcd)
		fp.sections = secs
		fp.times    = times
		;
		
      then: "we should get the expected validation result"
		fp.validate() == valid
		;
		
	  where: 
		secs    | times             | td | ad | d35d | tmcd | valid
		[1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |    1 | true
		[     ] | ['00:05','00:10'] |  1 |  1 |    1 |    1 | false
		[1,2,3] | [               ] |  1 |  1 |    1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |null|  1 |    1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 |null|    1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 |  1 | null |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 | null | false
    }



	def "Test that delays can only be positive numbers"() {

      given: "a FacilityPerformance object"
		mockForConstraintsTests(FacilityPerformance)
        ;

      when: "we set the data"
		def fp = new FacilityPerformance(totalDelay:td,avgDelay:ad,d35NetDelay:d35d,tmcpeNetDelay: tmcd)
		fp.sections = secs
		fp.times    = times
        ;

      then: "we should get the expected validation result"
		fp.validate() == valid
        ;

	  where:
		secs    | times             | td | ad | d35d | tmcd | valid
		[1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |    1 | true
		[1,2,3] | ['00:05','00:10'] | -1 |  1 |    1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 | -1 |    1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 |  1 |   -1 |    1 | false
		[1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |   -1 | false
    }



	def "Test that times are correctly parsed into dates"() { 

	  given:
		mockDomain(FacilityPerformance)
		;
		
	  when:
		def fp = new FacilityPerformance()
		fp.times = [ d('00:05'), d('00:10')]
		;

	  then:
		fp.times[0] instanceof Date
		
	}



	def "Test that time-space range compatibility is correctly compared"() { 
	  given: 
		mockDomain(FacilityPerformance)
		;
		
	  when: "we have two FacilityPerformance objects with the same time-space domain"
		def fp1 = new FacilityPerformance()
		fp1.sections = s1
		fp1.times    = t1
		def fp2 = new FacilityPerformance()
		fp2.sections = s2
		fp2.times    = t2
		;
		
	  then: "we correctly capture whether the time-space domain matches"
		fp1.matchesTimeSpaceDomainOf(fp2) == expected
		;

	  where:
		t1                | s1      | t2                | s2      | expected
		['00:05','00:10'] | [1,2,3] | ['00:05','00:10'] | [1,2,3] | true

		// increment each field to confirm failure
		['00:10','00:10'] | [1,2,3] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:15'] | [1,2,3] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [2,2,3] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,3,3] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,3,4] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:10','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05','00:15'] | [1,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05','00:10'] | [2,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05','00:10'] | [1,3,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05','00:10'] | [1,2,4] | false

		// remove one item from each list to confirm failure
		['00:05']         | [1,2,3] | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,2]   | ['00:05','00:10'] | [1,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05']         | [1,2,3] | false
		['00:05','00:10'] | [1,2,3] | ['00:05','00:10'] | [1,2]   | false
	}

	def "Test that savings is computed properly"() { 
	  given:
		mockDomain(FacilityPerformance)
		;
		
	  when: "we have two FacilityPerformance objects with differing delays"
		def withTMC    = new FacilityPerformance(tmcpeNetDelay: delay1)
		def withoutTMC = new FacilityPerformance(tmcpeNetDelay: delay2)
		;
		
	  then: "the savings computation is as expected"
		withTMC.savingsVersus(withoutTMC) == savings
		;
		
	  where:
		delay1  | delay2 | savings
		1000f   | 1500f  | 500f
		1500f   | 1000f  | 0f      // savings must be >= zero
		1000f   | 1000f  | 0f
	}

	def d(s) { 
		Date.parse('yyyy-MM-dd HH:mm','2011-01-01 '+s)
	}
}
