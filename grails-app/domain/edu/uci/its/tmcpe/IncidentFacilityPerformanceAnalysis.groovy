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

	// observations
	List obsConditions
	List avgConditions

	// model
	Map modelConfig
	Map modelStats
	List modConditions  // modeled conditions

	static mapWith = "mongo"
	static embedded = ['obsConditions','avgConditions']
	static constraints = {
		obsConditions(
			validate: { val, obj ->
				val != null               && 
				val.size == sections.size &&
				// make sure each row is the same size
				val.findAll{ row -> row.size == times.size }.size==val.size
					  })
		avgConditions(
			validate: { val, obj ->
				val != null               && 
				val.size == sections.size &&
				// make sure each row is the same size
				val.findAll{ row -> row.size == times.size }.size==val.size 
					  })
		modConditions(
			validate: { val, obj ->
				val == null               ||
				( val.size == sections.size &&
				  // make sure each row is the same size
				  val.findAll{ row -> row.size == times.size }.size==val.size 
				) })
	}

	public Float computeNetDelays() { 
		tmcpeNetDelay = 0f
		for ( i in 0..(sections.size-1)) { 
			for ( j in 0..(times.size-1)) { 
				def obs = obsConditions[i][j]
				def avg = avgConditions[i][j]
				def mod = modConditions[i][j]
				def tmcpeNetDelayRaw = mod.inc * sections[i].len * (1f/obs.spd - 1f/avg.spd) * obs.flow
				if ( tmcpeNetDelayRaw < 0 ) tmcpeNetDelayRaw = 0
				tmcpeNetDelay += tmcpeNetDelayRaw
			}
		}
	}

	def modelIsInfeasible() {
		if ( !ifpa ||
			 !ifpa.modelStats ) return false
		if ( ifpa.modelStats.model_status == 'INFEASIBLE' )
			return true
		else
			return false
	}

	def modelIsOptimal() {
		if ( !ifpa ||
			 !ifpa.modelStats ) return false
		if ( ifpa.modelStats.model_status == 'OPTIMAL' )
			return true
		else
			return false
	}
}


