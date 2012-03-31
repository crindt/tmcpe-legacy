/* @(#)IncidentFacilityPerformanceAnalysis.groovy
 */
/**
 * An encapsulation of the results of a TMCPE delay/performance compuation
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

import groovy.transform.InheritConstructors
import grails.validation.Validateable

@InheritConstructors
@Validateable
class IncidentFacilityPerformanceAnalysis extends FacilityPerformance {
    String id
    String cad

    // observations
    List obsConditions
    List avgConditions

    // model
    GamsModelConfig modelConfig

    Map modelStats
    Map modelParams
    List modConditions  // modeled conditions

	public IncidentFacilityPerformanceAnalysis() { 
		super()
		modelConfig = new GamsModelConfig()
	}

	public IncidentFacilityPerformanceAnalysis( GamsModelConfig modelConfigA ) { 
		super()
		modelConfig = modelConfigA
	}

    static mapWith = "mongo"
    // FIXME: making the lists embedded seems to prevent persistence
    //static embedded = ['obsConditions','avgConditions']
	static embedded = ['modelConfig']

    static constraints = {
        obsConditions( validator: { val, obj -> obj.conditionsSizeValidator( val, "obsConditions" ) } )
        avgConditions( validator: { val, obj -> obj.conditionsSizeValidator( val, "avgConditions" ) } )
		modConditions( validator: { val, obj -> val == null || obj.conditionsSizeValidator( val, "modConditions" ) } )
		modelConfig  ( validator: { val, obj -> if ( ! val.validate() ) return [ 'invalid.model.config', val.errors ] } )
    }

	def conditionsSizeValidator(val, name = "<unknown>") {
		if ( val == null ) {
			log.error( "${name} cannot be null" )
			return ['invalid.null']
		}
		if ( val.size() != sections.size() ) {
			log.error( "Number of sections in ${name} [${val.size()}] differs from number of sections in model [${sections.size()}]" )
			return ['invalid.sections']
		}
		// make sure each row is the same size
		def badlist = val.findAll{ row -> row.size() != timesteps.size() }
		if ( badlist.size() > 0 ) {
			log.error( "BADLIST" )
			log.error( "${timesteps.size} != ?")
			return [ 'invalid.timesteps.per.section', name, this.class, 
					 badlist.collect{ row -> "${row.size()} != ${timesteps.size()}"}
				   ]
		}
		return true
	}

    def clearModelResults() {
        modelStats = [:]
        modelParams = [:]
        modConditions = []
    }

    public Float computeNetDelays() { 
        tmcpeNetDelay = 0f
        for ( i in 0..(sections.size-1)) { 
            for ( j in 0..(timesteps.size-1)) { 
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
        if ( modelStats == null ) return false
        if ( modelStats.model_status == 'INFEASIBLE' )
            return true
        else
            return false
    }

    def modelIsOptimal() {
        if ( modelStats == null ) return false
        if ( modelStats.model_status == 'OPTIMAL' )
            return true
        else
            return false
    }

	public String incFacDirAsString() { 
		return "${cad} @ ${facility}-${direction}"
	}

    public String toString() { 
        return super.toString()+
            "[cad:${cad},modelConfig:${modelConfig},modelStats:${modelStats}]"
    }

    public Boolean equals( IncidentFacilityPerformanceAnalysis other ) { 
        return (
            super.equals( other ) &&
            cad.equals(other.cad) &&
            obsConditions.equals(other.obsConditions) &&
            avgConditions.equals(other.avgConditions) &&
            modelConfig.equals(other.modelConfig) &&
            modelStats.equals(other.modelStats) &&
            modConditions.equals(other.modConditions)
        ) 
    }
}
