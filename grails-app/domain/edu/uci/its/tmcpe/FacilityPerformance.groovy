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
	List<Date> times         // as 5-minute timesteps

	String badSolution       // report 
	Float totalDelay    = 0f // total veh-hrs spent on facilities during obs period
	Float avgDelay      = 0f // delay under normal conditions
	Float d35NetDelay   = 0f // delay per spd < 35
	Float tmcpeNetDelay = 0f // delay per spd < avg speed (total delay - avg delay)
	
	static mapWith = "mongo"
	static embedded = ['sections', 'times']
	static constraints = { 
		facility(nullable:false)
		direction(nullable:false,inList:['N','S','E','W'])
		sections(minSize:1)
		times(minSize:1)

		badSolution(nullable:true)

		totalDelay(min:0f,default:0f)    // positive delays only
		avgDelay(min:0f,default:0f)
		d35NetDelay(min:0f,default:0f)
		tmcpeNetDelay(min:0f,default:0f)
	}

	Boolean matchesTimeSpaceDomainOf( FacilityPerformance other ) { 
		return sections == other.sections && times == other.times
	}

	Float savingsVersus( FacilityPerformance other ) { 
		def val = other.tmcpeNetDelay - tmcpeNetDelay
		return val > 0f ? val : 0f
	}

	public String toString() { 
		return "[id:${id},facility:${facility},direction:${direction},totalDelay:${totalDelay},avgDelay:${avgDelay},d35NetDelay:${d35NetDelay},tmcpeNetDelay:${tmcpeNetDelay}]"
	}

	public Boolean equals(FacilityPerformance other) {
		return (
			facility.equals(other.facility) &&
			direction.equals(other.direction) &&
			sections.equals(other.sections) &&
			times.equals(other.times) &&
			badSolution.equals(other.badSolution) &&
			totalDelay.equals(other.totalDelay) &&
			avgDelay.equals(other.avgDelay) &&
			d35NetDelay.equals(other.d35NetDelay) &&
			tmcpeNetDelay.equals(other.tmcpeNetDelay)
		)
	}
	

}
