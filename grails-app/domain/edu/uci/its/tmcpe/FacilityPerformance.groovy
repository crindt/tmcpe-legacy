/* @(#)FacilityPerformance.groovy
 */
/**
 * A class encapsulating common characterizations of facility performance over a
 * time-space range
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

class FacilityPerformance {
	String id 
	String facility          // 
	String direction         // NSEW
	List sections            // as [vdsid,seclen] pairs
	List<Date> timesteps         // as 5-minute timesteps

	String badSolution       // report 
	Float totalDelay    = 0f // total veh-hrs spent on facilities during obs period
	Float avgDelay      = 0f // delay under normal conditions
	Float d35NetDelay   = 0f // delay per spd < 35
	Float tmcpeNetDelay = 0f // delay per spd < avg speed (total delay - avg delay)
	
	//static mapWith = "mongo"
	static embedded = ['sections', 'timesteps']
	static constraints = { 
		facility(nullable:false)
		direction(nullable:false,inList:['N','S','E','W'])
		sections(minSize:1)
		timesteps(minSize:1)

		badSolution(nullable:true)

		totalDelay(min:0f,default:0f)    // positive delays only
		avgDelay(min:0f,default:0f)
		d35NetDelay(min:0f,default:0f)
		tmcpeNetDelay(min:0f,default:0f)
	}

	Boolean matchesTimeSpaceDomainOf( FacilityPerformance other ) { 
		return sections == other.sections && timesteps == other.timesteps
	}

	Float savingsVersus( FacilityPerformance other ) { 
		def val = other.tmcpeNetDelay - tmcpeNetDelay
		return val > 0f ? val : 0f
	}

	public String toString() { 
		return "[id:${id},facility:${facility},direction:${direction},totalDelay:${totalDelay},avgDelay:${avgDelay},d35NetDelay:${d35NetDelay},tmcpeNetDelay:${tmcpeNetDelay}]"
	}

	static int fiveMinAsMillis = 5*60*1000

	def timestampIndex(Date stamp) {
		assert timesteps != null && timesteps.size() >= 0
		assert timesteps[0] instanceof Date
		assert stamp instanceof Date
		// jumping through hoops because a 0 TimeDuration isn't allowed
		if ( stamp.equals(timesteps[0]) ) return 0
		groovy.time.TimeDuration d = stamp-timesteps[0]
		int idx = Math.floor(d.toMilliseconds()/fiveMinAsMillis)
		
		if ( idx < 0 || 
			 idx >= timesteps.size() ) throw new java.lang.IndexOutOfBoundsException()
		
		return idx
	}

	public Boolean equals(FacilityPerformance other) {
		return (
			facility.equals(other.facility) &&
			direction.equals(other.direction) &&
			sections.equals(other.sections) &&
			timesteps.equals(other.timesteps) &&
			badSolution.equals(other.badSolution) &&
			totalDelay.equals(other.totalDelay) &&
			avgDelay.equals(other.avgDelay) &&
			d35NetDelay.equals(other.d35NetDelay) &&
			tmcpeNetDelay.equals(other.tmcpeNetDelay)
		)
	}
	

}
