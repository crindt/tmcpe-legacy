package edu.uci.its.tmcpe

import org.apache.commons.logging.LogFactory
import groovy.text.GStringTemplateEngine

class SimpleIncidentModelService {
    
    private static final log = LogFactory.getLog(this)
    
    static transactional = true

	static class IncidentRegionNotBoundedInTimeException extends java.lang.RuntimeException {}
	static class IncidentRegionNotBoundedInSpaceException extends java.lang.RuntimeException {}
	static class NoIncidentRegionIdentifiedException extends java.lang.RuntimeException {}

    // we need

    // avg conditions

    // observed conditions

    // modeled conditions (e.g., existing incident boundary)

	// critical events

	// parameters (e.g., tmcdivpct)


	/**
	 * For the given ifpa, section, and critical events compute the observed
	 * cumulative volume and the estimated upstream demand on the incident
	 * section as observed and in the absense of TMC diversion (as specified in
	 * the ifpa.modelParams)
	 */
	def doCumulativeFlowProjections( 
		IncidentFacilityPerformanceAnalysis ifpa,
		Integer section,
		List ce  // critical events t0,t1,t2,t3
	) { 
		// assertions
		assert ifpa != null
		assert section != null
		assert ( section >= 0 && section <= ifpa.sections.size() )
		assert ce.size() == 4

		use ( [groovy.time.TimeCategory] ) { // we do time calcs

			// determine the critical event cells

			// FIXME:REPORT-BUG: timestampIndex won't work unless the date 
			// is converted by adding a (zero) duration to it
			def t0Cell     = ifpa.timestampIndex( ce[0] + 0.minutes )
			def startCell  = ifpa.timestampIndex( ce[1] + 0.minutes )
			def t2Cell     = ifpa.timestampIndex( ce[2] + 0.minutes )
			def finishCell = ifpa.timestampIndex( ce[3] + 0.minutes )

			assert finishCell > startCell

			assert ( t0Cell >= 0 && t0Cell < ifpa.timesteps.size() )
			assert ( startCell >= 0 && startCell < ifpa.timesteps.size() )
			assert ( t2Cell >= 0 && t2Cell < ifpa.timesteps.size() )
			assert ( finishCell >= 0 && finishCell < ifpa.timesteps.size() )

			// define the summing function for cumulative flow since the start
			// of the incident
			def sfunc = { what,sumto,prop ->
				if ( sumto < startCell ) return 0
				def var = what[section][startCell..sumto].collect{ it."$prop" ?: 0 }.sum()
				return var
			}
		
			// some shorthand
			def obs = ifpa.obsConditions
			def avg = ifpa.avgConditions
			assert obs != null
			assert avg != null

			// compute the diversion as the difference between avg and obs
			// cumulative vols as the finishCell
			def avgCumflow = sfunc( avg, finishCell, "vol" )
			def obsCumflow = sfunc( obs, finishCell, "vol" )
			def totalDiversion = avgCumflow - obsCumflow

			// split the diversion into the portion divered by the TMC and the
			// portion that just diverted
			def tmcDiversion   = ifpa.modelParams.tmcDivPct/100.0*totalDiversion
			def nonTmcDiversion = totalDiversion-tmcDiversion

			
			def data = [
				t0Cell: t0Cell,
				startCell: startCell,
				t2Cell: t2Cell,
				finishCell: finishCell
			]

			// compute the observed and average cumulative flows for each cell
			def cumflow = (0..ifpa.timesteps.size()-1).collect{ j ->
				[obs:    sfunc(obs,j,"vol"),   // observed
				 avg:    sfunc(avg,j,"vol")    // average (expected), a.k.a demand
				]
			}
		
			// Here, we computed average cumulative flows to estimate demands.
			// We reduce them based upon the measured reduction in observed
			// cumulative flow as compared to average conditions
			// * compute the average adjusted for diversion
			// * and the average adjusted for TMC diversion only
			(0..ifpa.timesteps.size()-1).each{ j ->

				// average cumflow (demand) adjusted for diversion using linear
				// interpolation
				cumflow[j].divavg = 
				( j < startCell ? cumflow[j].avg 
				  : ( j > finishCell ? cumflow[j].obs
					  : ( cumflow[j].avg - 
						  totalDiversion*(j-startCell)/(finishCell-startCell))))

				// average cumflow (demand) adjusted for non-TMC diversion using
				// linear interpolation.  non-TMC diversion is diversion that would
				// occur whether or not the TMC managed the disruption.
				// This is the demand in the non-TMC case
				cumflow[j].adjdivavg = 
				( j < startCell ? cumflow[j].avg
				  : ( j > finishCell ? cumflow[j].obs + tmcDiversion
					  : ( cumflow[j].avg -
						  nonTmcDiversion*(j-startCell)/(finishCell-startCell)
						) ) )
				//println "ADJDIVAVG: $j, ${startCell}, $finishCell, ${cumflow[j].avg}, ${cumflow[j].divavg}, ${cumflow[j].adjdivavg}"
			}

			// at this point, cumflow should be array of cumulative volumes
			// associated with the incident section over time.  We'll store it
			// along with the diversion numbers and return them
			data.cumflow = cumflow
			data.totalDiversion = totalDiversion
			data.tmcDiversion   = tmcDiversion
			return data
		}
	}

	/**
	 * Use the modeled results to identify the latest possible incident impact
	 */
	def computeRestorationTime( IncidentFacilityPerformanceAnalysis ifpa ) {
		assert ifpa.modConditions != null

		// This is a shortcut method compared to the original perl
		// implementation.  Basically, we assume that the incident is short
		// enough that the last point of impact at the critical section is the
		// latest point of impact on any section
		//
		// This approach sums the incident flags in the columns of the TSD (that
		// is counts how many cells (sections) in a particular time slice are
		// flagged as being in incident conditions.)
		def incsPerTimeslice = ifpa.modConditions.transpose().collect{ col -> col.collect{ it.inc }.sum() }
		
		// we want the latest non-zero timeslice
		int m = 0
		for ( m = incsPerTimeslice.size()-1; m >=0 && incsPerTimeslice[m] == 0; m-- );

		if ( m < 0 ) throw new NoIncidentRegionIdentifiedException()		

		// we'll assume the incident actually clears in the FOLLOWING timeslice
		m++;
		if ( m >= incsPerTimeslice.size() ) throw new IncidentRegionNotBoundedInTimeException()

		return ifpa.timesteps[m];
	}

	/**
	 * Use the modeled results to identify the first timeslice with incident
	 * impact
	 */
	def computeStartTime( IncidentFacilityPerformanceAnalysis ifpa ) {
		assert ifpa != null
		assert ifpa.modConditions != null

		// as in computeRestorationTime, we sum the incident flags in each time
		// slice (the column) to create an array of column totals
		def incsPerTimeslice = ifpa.modConditions.transpose().collect{ col -> col.collect{ it.inc }.sum() }
		
		// we want the earliest non-zero timeslice, since this represents the
		// first timeslice that any of the roadway sections have incident
		// conditions identified
		int m = 0
		for ( m = 0; m < incsPerTimeslice.size() && incsPerTimeslice[m] == 0; m++ );

		if ( m == incsPerTimeslice.size() ) 
			// Oops, didn't find any incident state
			throw new NoIncidentRegionIdentifiedException()

		if ( m == 0 ) 
			// As a rule, we don't want a boundary cell to have incident flag
			throw new IncidentRegionNotBoundedInTimeException()

		// If we got here, we've correctly identified the start time
		return ifpa.timesteps[m]
	}

	/**
	 * Use the modeled results to identify the furthest downstream section with
	 * incident impact
	 */
	def computeIncidentSection( IncidentFacilityPerformanceAnalysis ifpa ) {
		assert ifpa != null
		assert ifpa.modConditions != null

		// Sum the incident flags for each row (e.g., section)
		def incsPerSection = ifpa.modConditions.collect{ row -> row.collect{ it.inc }.sum() }

		// we want the non-zero section furthest downstream.  Sections are
		// numbered upstream to downstream.  Loop in reverse until a non-zero
		// row sum is found
		int j = 0
		for ( j = incsPerSection.size()-1; j >= 0 && incsPerSection[j] == 0; j-- );

		if ( j < 0 ) 
			// Oops, didn't find any incident state
			throw new NoIncidentRegionIdentifiedException()

		if ( j == incsPerSection.size()-1 ) 
			// As a rule, we don't want a boundary cell to have an incident flag
			throw new IncidentRegionNotBoundedInSpaceException()

		// If we got here, we've correctly identified the start section
		return j
	}

	def zeroOrBetter( v ) { v < 0 ? 0 : v }

	/**
	 * Project incident conditions for alternative critical events and estimate
	 * delays and associated savings versus baseline conditions
	 */
	def doDelayProjections(
		IncidentFacilityPerformanceAnalysis ifpa,
		int section,
		List cep,  // alternative critical events
		Double netDelayTarget,  // calibration factor
		Map data   // cumulative flow data (observed demand/capacity)
	) {
		use ( [groovy.time.TimeCategory] ) { // we do time calcs

			// shorthand
			def cumflow = data.cumflow
			def t0Cell = data.t0Cell
			def startCell = data.startCell
			def t2Cell = data.t2Cell
			def finishCell = data.finishCell

			// FIXME:REPORT-BUG: timestampIndex won't work unless the date 
			// is converted by adding a (zero) duration to it
			def t1pCell     = ifpa.timestampIndex( cep[1] + 0.minutes)
			def t2pCell     = ifpa.timestampIndex( cep[2] + 0.minutes )

			// estimate the service rate while capacity disruptions persist.
			// Here we just average the observed volume between the start of the
			// incident (t0) and the point at which capacity was restored (t2)
			def incflowrate = (cumflow[t2Cell].obs - cumflow[t0Cell].obs)/(5*60*(t2Cell-t0Cell))

			// Next, estimate the service rate after lanes have been cleared.
			// Here we use two methods and take the maximum:
			//   * the average rate between full restoration (t3) and capacity restoration (t2) 
			def clearflowrate = (cumflow[finishCell].obs - cumflow[t2Cell].obs)/(5*60*(finishCell-t2Cell))
			//   * the maximum rate duration a single 5 minute period between t2 and t3
			def maxclearflowrate = (t2Cell..(finishCell-1)).collect{ cumflow[it+1].obs - cumflow[it].obs }.max()/(5*60)
			if ( clearflowrate < maxclearflowrate )
				// take the max (FIXME: this is stupid, maxclearflowrate is
				// always >= clearflowrate so we should just use the former
				clearflowrate = maxclearflowrate
		

			// hold the obs cum flow at point road was cleared
			def base = cumflow[t2Cell].obs 

			// reset t3p
			cep[3] = null

			// Now, loop over each timestep and compute the projected cumflow for the event
			// using the alternative critical events (incident response)
			(0..cumflow.size()-1).each{ j ->
				def d = cumflow[j]
				if ( j < t2Cell ) {
					// before t2 (clearance), projected cumflow is equivalent to measured
					d.incflow = cumflow[j].obs // sfunc(obs,j,"vol")
				} else if ( j < t2pCell ) {
					// between t2 and t2p, projected cumflow is the base value plus the extrapolated incident flow rate
					d.incflow = base + incflowrate*(j-t2Cell)*60*5
				} else {
					// beyond t2p 
					d.incflow = base + incflowrate*(t2pCell-t2Cell)*60*5 + clearflowrate*(j-t2pCell)*60*5
				}
				if ( d.incflow > d.obs ) {
					if ( cep[3] == null ) {
						cep[3] = ifpa.timesteps[j]
					}
					d.incflow = d.obs;
				}
			}

			// at this point, we have incident cumflows projected, update the delays

			def delay2 = 0;
			def delay3 = 0;
			def delay4 = 0;
			def tmcSavings = 0;

			cumflow.each{ d ->
				delay2 += (d.divavg-d.obs)*5/60   // avg cumflow less diversion per timestep - obs * 5/60th hr = total delay
				delay3 += (d.avg-d.obs)*5/60      // avg cumflow - obs * 5/60th hr = total delay if there hadn't been TMC diversion
				delay4 += (d.avg-d.incflow)*5/60; // avg cumflow less projected flow per timestep * 5/60th hr = projected delay
			}

			// scale to convert div adj avg to netdelay
			def factor = netDelayTarget/(delay2+(delay3-delay2)*(1-ifpa.modelParams.tmcDivPct/100.0))

			delay4 *= factor
			delay4 = zeroOrBetter( delay4 )
		
			tmcSavings = zeroOrBetter( delay4 - zeroOrBetter( netDelayTarget ) )

			println "CUMFLOW: ${cumflow}"
			println "DELAYS: ${factor},${netDelayTarget},${delay2},${delay3},${delay4},${tmcSavings}"

			data.modeledDelay = delay4
			data.tmcSavings = tmcSavings

			return data
		}
	}
}
