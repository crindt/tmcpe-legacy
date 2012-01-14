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

import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class FacilityPerformanceSpec extends TmcpeUnitSpec {


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
		def fp = validFacilityPerformance()
		fp.totalDelay = td
		fp.avgDelay = ad
		fp.d35NetDelay = d35d
		fp.tmcpeNetDelay = tmcd
		fp.sections = secs
		fp.timesteps    = timesteps
		;
		
      then: "we should get the expected validation result"
		validationStatusMatches( fp, expected )
		;
		
	  where: 
		secs    | timesteps             | td | ad | d35d | tmcd | expected
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
		def fp = validFacilityPerformance()
		fp.totalDelay = td
		fp.avgDelay = ad
		fp.d35NetDelay = d35d
		fp.tmcpeNetDelay = tmcd
		fp.direction = dir
		fp.sections = secs
		fp.timesteps    = timesteps
        ;

      then: "we should get the expected validation result"
		validationStatusMatches( fp, expected )
        ;

	  where:
		dir | secs    | timesteps         | td | ad | d35d | tmcd | expected
		'N' | [1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |    1 | true
		'N' | [1,2,3] | ['00:05','00:10'] | -1 |  1 |    1 |    1 | false
		'N' | [1,2,3] | ['00:05','00:10'] |  1 | -1 |    1 |    1 | false
		'N' | [1,2,3] | ['00:05','00:10'] |  1 |  1 |   -1 |    1 | false
		'N' | [1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |   -1 | false
		'H' | [1,2,3] | ['00:05','00:10'] |  1 |  1 |    1 |    1 | false
    }



	def "Test that timesteps are correctly parsed into dates"() { 

	  given:
		mockDomain(FacilityPerformance)
		;
		
	  when:
		def fp = validFacilityPerformance()
		fp.timesteps = [ d('00:05'), d('00:10')]
		;

	  then:
		fp.timesteps[0] instanceof Date
		
	}



	def "Test that time-space range compatibility is correctly compared"() { 
	  given: 
		mockDomain(FacilityPerformance)
		;
		
	  when: "we have two FacilityPerformance objects with the same time-space domain"
		def fp1 = new FacilityPerformance()
		fp1.sections = s1
		fp1.timesteps    = t1
		def fp2 = new FacilityPerformance()
		fp2.sections = s2
		fp2.timesteps    = t2
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

	def "Test that timestampIndex() works properly "() {
	given: "A Facility Performance with some timesteps"
		mockDomain(FacilityPerformance)
		def fp = new FacilityPerformance()
		def now = new Date(0) // start at epoch
		use ( [groovy.time.TimeCategory] ) {
			fp.timesteps = (0..9).collect{ now + (it * 5).minutes }
		}


	when: "we give timestamps in the range of the timesteps"
		def range = (0..fp.timesteps.size()-1)
		;

	then: "it converts timestamps to timestep indices propertly"
		use ( [groovy.time.TimeCategory] ) {
			range.each{ step -> 
				(0..4).each{ instep ->
					fp.timestampIndex( now + (instep).minute + (step * 5).minutes ) == step
				}
				fp.timestampIndex( now + (4.minutes + 59.seconds + 999.milliseconds) + (step * 5).minutes ) == step
			}
		}
		;


	when: "the timestamp is before the timesteps range"
		use ( [groovy.time.TimeCategory] ) {
			fp.timestampIndex( now - 1.minute )
		}
		;
		
	then: "we should get a bounds exception"
		java.lang.IndexOutOfBoundsException eminus = thrown()
		;


	when: "the timestep is after the timesteps range"
		use ( [groovy.time.TimeCategory] ) {
			fp.timestampIndex( now + (fp.timesteps.size()*5).minutes )
		}
		;
		
	then: "we should get a bounds exception"
		java.lang.IndexOutOfBoundsException eplus = thrown()
		;


	when: "the timestamp to index is a simple date"
		def idx = fp.timestampIndex( date )
		;

	then: "it should still work"
		idx == index
		;

	where:
		date                 | index
		new Date(0)          | 0
		new Date(5*60*1000)  | 1
		new Date(10*60*1000) | 2
		new Date(10*60*1000) | 3
		;
	}

	def d(s) { 
		Date.parse('yyyy-MM-dd HH:mm','2011-01-01 '+s)
	}

	def validFacilityPerformance() { 
		new FacilityPerformance(
			facility:5,direction:'N',
			totalDelay:0f,avgDelay:0f,d35NetDelay:0f,
			tmcpeNetDelay: 0f)
	}
}
