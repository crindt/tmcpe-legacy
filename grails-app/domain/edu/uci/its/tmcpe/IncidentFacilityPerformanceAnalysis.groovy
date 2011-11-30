/* @(#)IncidentFacilityPerformanceAnalysis.groovy
 */
/**
 * An encapsulation of the results of a TMCPE delay/performance compuation
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

import groovy.transform.InheritConstructors

@InheritConstructors
class IncidentFacilityPerformanceAnalysis extends FacilityPerformance {
	String id
    String cad

	TimeSpaceConditions obsConditions
	TimeSpaceConditions avgConditions

	static mapWith = "mongo"
	static embedded = ['obsConditions','avgConditions']
	static constraints = {
		obsConditions(validate: { val, obj ->
			obsConditions != null                        && 
			obsConditions.validate()                     &&
			obsConditions.dimensions[0] == sections.size &&
			obsConditions.dimensions[1] == times.size
					  })
		avgConditions(validate: { val, obj ->
			avgConditions != null                        && 
			avgConditions.validate()                     &&
			avgConditions.dimensions[0] == sections.size &&
			avgConditions.dimensions[1] == times.size
					  })
	}
}


