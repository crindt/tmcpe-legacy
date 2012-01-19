package edu.uci.its.tmcpe

import org.apache.commons.logging.LogFactory
import groovy.text.GStringTemplateEngine

class SimpleIncidentModelService {
    
    private static final log = LogFactory.getLog(this)
    
    static transactional = true

	static class IncidentRegionNotBoundedInTimeException extends java.lang.RuntimeException {}
	static class IncidentRegionNotBoundedInSpaceException extends java.lang.RuntimeException {}
	static class NoIncidentRegionIdentifiedException extends java.lang.RuntimeException {}
	static class UndeterminedCriticalEventsException extends java.lang.RuntimeException {
		public UndeterminedCriticalEventsException( String s = "") { 
			super(s)
		}
		
	}
	static class UndeterminedIncidentSectionException extends java.lang.RuntimeException {
		public UndeterminedIncidentSectionException( String s = "") { 
			super(s)
		}
	}

	static class InconsistentCriticalEventCellsException extends java.lang.RuntimeException {
		public InconsistentCriticalEventCellsException( String s = "") { 
			super(s)
		}
	}

    // we need

    // avg conditions

    // observed conditions

    // modeled conditions (e.g., existing incident boundary)

	// critical events

	// parameters (e.g., tmcdivpct)

	def modelIncident(
		IncidentFacilityPerformanceAnalysis ifpa,
		Map params = [
			tmcDivPct: 20,
			verificationDelay: 15,
			responseDelay: 15
		]
	) {
		def ce      = determineCriticalEvents( ifpa )  // measured critical events
		if ( ce.grep { it != null }.size() < 4 )
			throw new UndeterminedCriticalEventsException( "CAN'T DETERMINE CRITICAL EVENTS for ${ifpa.incFacDirAsString()}")

		def section = computeIncidentSection( ifpa )
		if ( section == null )
			throw new UndeterminedIncidentSectionException( "CAN'T DETERMINE INCIDENT SECTION ${ifpa.incFacDirAsString()}")

		SimpleIncidentModel sim = doCumulativeFlowProjections( ifpa, section, ce, params )

		sim.params = params.clone()

		log.debug( "GOT SIM: ${sim.cumulativeFlows}" )

		def cep = ce.clone()

		use ( [groovy.time.TimeCategory] ) {
			cep[1] = cep[1] + (params.verificationDelay).minutes
			cep[2] = cep[2] + (params.verificationDelay).minutes + (params.responseDelay).minutes
		}

		return doDelayProjections(ifpa,section,cep,ifpa.modelStats.netdelay, sim )
	}

	def determineCriticalEvents( IncidentFacilityPerformanceAnalysis ifpa ) {
		// pull these from the import-al database right now
		assert ifpa.cad != null && ifpa.cad != ''
		def ce = []

		log.debug( "Looking for processed incident: ${ifpa.cad}" )
		ProcessedIncident pi = ProcessedIncident.findByCad( ifpa.cad )

		log.debug( "GOT ${pi}")

		// get the ifia (for critical events), using the first
		def iia = pi.analyses.asList().first()
		def ifia
		if ( iia ) {
			/* // reallly should search for correct ifia
			List ifia_list = iia.incidentFacilityImpactAnalyses.asList().grep{ 
				log.debug( "${it.location?.freewayId}-${it.location?.freewayDir} =?= ${ifpa.facility}-${ifpa.direction}" )
				"${it.location?.freewayId}" == "[${ifpa.facility}]" &&
				"${it.location?.freewayDir}" == "[${ifpa.direction}]"
			}
			*/
			ifia = iia.incidentFacilityImpactAnalyses.asList()
			ifia = ifia.first()
		}

		if ( ifia ) {
			log.debug( "USING IFIA: ${ifia}" )
			ce[0] = ce[0] ?: ifia.firstCall
			ce[1] = ce[1] ?: ifia.verification
			ce[2] = ce[2] ?: ifia.lanesClear
			ce[3] = null
		}

		/*
		use ( [groovy.time.TimeCategory]) {
			if ( ce[1] < ce[0] ) ce[1] = ce[0] + 5.minutes
			if ( ce[2] < ce[1] ) ce[2] = ce[1] + 5.minutes
		}
		*/

		if ( pi == null )
			throw new RuntimeException( "CAN'T FIND PROCESSED INCIDENT FOR ${ifpa.incFacDirAsString()}")
		else {
			// fill in with PI
			log.debug( "USING PI: ${pi}" )
			ce[0] = ce[0] ?: pi.firstCall?.stampDateTime
			ce[1] = ce[1] ?: pi.verification?.stampDateTime
			ce[2] = ce[2] ?: pi.lanesClear?.stampDateTime
			ce[3] = ce[3] ?: pi.incidentClear?.stampDateTime
		}

		// fallback to using projection
		if ( ce[3] == null && ifpa.modConditions != null ) {
			ce[3] = computeRestorationTime(ifpa)
		}

		return ce
	}


	/**
	 * For the given ifpa, section, and critical events compute the observed
	 * cumulative volume and the estimated upstream demand on the incident
	 * section as observed and in the absense of TMC diversion (as specified in
	 * the ifpa.modelParams)
	 */
	def doCumulativeFlowProjections( 
		IncidentFacilityPerformanceAnalysis ifpa,
		Integer section,
		List ce,  // critical events t0,t1,t2,t3
		Map params
	) { 
		// assertions
		assert ifpa != null
		assert section != null
		assert ( section >= 0 && section <= ifpa.sections.size() )
		assert ce.size() == 4

		use ( [groovy.time.TimeCategory] ) { // we do time calcs

			def t0Cell    
			def startCell 
			def t2Cell    
			def finishCell

			try { 
				// determine the critical event cells
				
				// FIXME:REPORT-BUG: timestampIndex won't work unless the date 
				// is converted by adding a (zero) duration to it
				t0Cell     = ifpa.timestampIndex( ce[0] + 0.minutes )
				startCell  = ifpa.timestampIndex( ce[1] + 0.minutes )
				t2Cell     = ifpa.timestampIndex( ce[2] + 0.minutes )
				finishCell = ifpa.timestampIndex( ce[3] + 0.minutes )
			} catch( IndexOutOfBoundsException e ) { 
				throw new InconsistentCriticalEventCellsException("FAILED INDEXING CRITICAL EVENT TIMESTAMPS ${ce.join(',')}")
			}

			if ( !(finishCell > startCell) )
				throw new InconsistentCriticalEventCellsException("FINISH CELL [${finishCell}] <= START CELL [${startCell}] IN ${ifpa.cad}")

			if ( !(t0Cell >= 0 && t0Cell < ifpa.timesteps.size()) )
				throw new InconsistentCriticalEventCellsException("t0Cell BOGUS [${t0Cell}] IN ${ifpa.cad}")				
			if ( !(startCell >= 0 && startCell < ifpa.timesteps.size()) )
				throw new InconsistentCriticalEventCellsException("startCell BOGUS [${startCell}] IN ${ifpa.cad}")				
			if ( !(t2Cell >= 0 && t2Cell < ifpa.timesteps.size()) )
				throw new InconsistentCriticalEventCellsException("t2Cell BOGUS [${t2Cell}] IN ${ifpa.cad}")				
			if ( !( finishCell >= 0 && finishCell < ifpa.timesteps.size() ) )
				throw new InconsistentCriticalEventCellsException("finishCell BOGUS [${finishCell}] IN ${ifpa.cad}")				

			// define the summing function for cumulative flow since the start
			// of the incident
			def sfunc = { what,sumto,prop ->
				def sumFrom = 0  // startCell
				if ( sumto < sumFrom ) return 0
				def var = what[section][sumFrom..sumto].collect{ it."$prop" ?: 0 }.sum()
				return var
			}
		
			// some shorthand
			def obs = ifpa.obsConditions
			def avg = ifpa.avgConditions
			assert obs != null
			assert avg != null

			// compute the diversion as the difference between avg and obs
			// cumulative vols at the finishCell
			def avgCumflow = sfunc( avg, finishCell, "vol" )
			def obsCumflow = sfunc( obs, finishCell, "vol" )
			def totalDiversion = avgCumflow - obsCumflow

			// split the diversion into the portion divered by the TMC and the
			// portion that just diverted
			def tmcDiversion   = params.tmcDivPct/100.0*totalDiversion
			def nonTmcDiversion = totalDiversion-tmcDiversion

			def sim = new SimpleIncidentModel()

			sim.criticalEvents = ce

			sim.cad = ifpa.cad
			sim.facility = ifpa.facility
			sim.direction = ifpa.direction

			sim.stats = [
				t0Cell: t0Cell,
				startCell: startCell,
				t2Cell: t2Cell,
				finishCell: finishCell
			]

			// compute the observed and average cumulative flows for each cell
			def cumflow = (0..ifpa.timesteps.size()-1).collect{ m ->
				[obs:    sfunc(obs,m,"vol"),   // observed
				 avg:    sfunc(avg,m,"vol")    // average (expected), a.k.a demand
				]
			}
		
			// Here, we computed average cumulative flows to estimate demands.
			// We reduce them based upon the measured reduction in observed
			// cumulative flow as compared to average conditions
			// * compute the average adjusted for diversion
			// * and the average adjusted for TMC diversion only
			(0..ifpa.timesteps.size()-1).each{ m ->

				// average cumflow (demand) adjusted for diversion using linear
				// interpolation
				cumflow[m].divavg = 
				( m < startCell 
				  ? cumflow[m].avg 
				  : ( m > finishCell 
					  ? cumflow[m].obs
					  : ( cumflow[m].avg - totalDiversion*(m-startCell)/(finishCell-startCell))))
				/*
				if ( m < startCell )
					log.debug( "DIVAVG($m)[${cumflow[m].divavg}] = avg[${cumflow[m].avg}]" )
				else 
					if ( m > finishCell ) 
						log.debug( "DIVAVG($m)[${cumflow[m].divavg}] = obs[${cumflow[m].obs}]" )
					else
						log.debug( "DIVAVG($m)[${cumflow[m].divavg}] = avg[${cumflow[m].avg}] - totalDiversion[${totalDiversion}]*(m[$m]-startCell[$startCell])/(finishCell[$finishCell]-startCell[$startCell])" )
				*/

				// average cumflow (demand) adjusted for non-TMC diversion using
				// linear interpolation.  non-TMC diversion is diversion that would
				// occur whether or not the TMC managed the disruption.
				// This is the demand in the non-TMC case
				cumflow[m].adjdivavg = 
				( m < startCell 
				  ? cumflow[m].avg
				  : ( m > finishCell ? cumflow[m].obs + tmcDiversion
					  : ( cumflow[m].avg -
						  nonTmcDiversion*(m-startCell)/(finishCell-startCell)
						) ) )
				/*
				if ( m < startCell )
					log.debug( "ADJDIVAVG($m)[${cumflow[m].adjdivavg}] = avg[${cumflow[m].avg}]" )
				else 
					if ( m > finishCell ) 
						log.debug( "ADJDIVAVG($m)[${cumflow[m].adjdivavg}] = obs[${cumflow[m].obs}] + tmcDiversion[$tmcDiversion]" )
					else
						log.debug( "ADJDIVAVG($m)[${cumflow[m].adjdivavg}] = avg[${cumflow[m].avg}] - nonTmcDiversion[${nonTmcDiversion}]*(m[$m]-startCell[$startCell])/(finishCell[$finishCell]-startCell[$startCell])" )
				*/
			}

			// at this point, cumflow should be array of cumulative volumes
			// associated with the incident section over time.  We'll store it
			// along with the diversion numbers and return them
			sim.cumulativeFlows = cumflow
			sim.totalDiversion = totalDiversion
			sim.tmcDiversion   = tmcDiversion
			return sim
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
		SimpleIncidentModel sim   // cumulative flow data (observed demand/capacity)
	) {
		use ( [groovy.time.TimeCategory] ) { // we do time calcs

			// shorthand
			def cumflow = sim.cumulativeFlows
			def t0Cell = sim.stats.t0Cell
			def startCell = sim.stats.startCell
			def t2Cell = sim.stats.t2Cell
			def finishCell = sim.stats.finishCell

			cumflow[t0Cell].ce = "t0"
			cumflow[startCell].ce = "t1"
			cumflow[t2Cell].ce = "t2"
			cumflow[finishCell].ce = "t3"

			// FIXME:REPORT-BUG: timestampIndex won't work unless the date 
			// is converted by adding a (zero) duration to it
			def t1pCell
			def t2pCell
			try { 
				t1pCell     = ifpa.timestampIndex( cep[1] + 0.minutes)
				t2pCell     = ifpa.timestampIndex( cep[2] + 0.minutes )
			} catch( IndexOutOfBoundsException e ) { 
				throw new InconsistentCriticalEventCellsException("FAILED INDEXING CRITICAL PRIME EVENT TIMESTAMPS ${cep.join(',')}")
			}

			cumflow[t1pCell].ce = [cumflow[t1pCell].ce,"t1p"].grep{ it }.join(" ")
			cumflow[t2pCell].ce = [cumflow[t2pCell].ce,"t2p"].grep{ it }.join(" ")


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

			//log.debug( "INCFLOWCALCS: ${t0Cell}:${cumflow[t0Cell].obs},${t2Cell}:${cumflow[t2Cell].obs},${t2pCell}:${cumflow[t2pCell]} == ${incflowrate}" )

			// Now, loop over each timestep and compute the projected cumflow for the event
			// using the alternative critical events (incident response)
			(0..cumflow.size()-1).each{ m ->
				def d = cumflow[m]
				if ( m < t2Cell ) {
					// before t2 (clearance), projected cumflow is equivalent to measured
					d.incflow = cumflow[m].obs // sfunc(obs,m,"vol")
				} else if ( m < t2pCell ) {
					// between t2 and t2p, projected cumflow is the base value plus the extrapolated incident flow rate
					d.incflow = base + incflowrate*(m-t2Cell)*60*5
				} else {
					// beyond t2p 
					d.incflow = base + incflowrate*(t2pCell-t2Cell)*60*5 + clearflowrate*(m-t2pCell)*60*5
				}

				// don't allow modeled cumflow to be greater than observed
				// FIXME:
				/*
				if ( d.incflow > d.obs ) {
					d.incflow = d.obs
				}
				*/

				// don't allow modeled cumflow to be greater than estimated
				// demand Also, the first time modeled cumflow exceeds demand,
				// call this t3'
				if ( d.incflow > d.adjdivavg && m > startCell ) {
					if ( cep[3] == null ) {
						cep[3] = ifpa.timesteps[m]
						cumflow[m].ce = [cumflow[m].ce,"t3p"].grep{ it }.join(" ")
					}
					d.incflow = d.adjdivavg;
				}
			}



			// at this point, we have incident cumflows projected, update the delays

			def cumflowObservedDelay = 0;
			def delay3 = 0;
			def delay4 = 0;
			def tmcSavings = 0;

			def jj = 0
			cumflow.each{ d ->
				cumflowObservedDelay += (d.divavg-d.obs)*5/60   // avg cumflow less diversion per timestep - obs * 5/60th hr = total delay
				delay3 += (d.adjdivavg-d.obs)*5/60      // avg cumflow - obs * 5/60th hr = total delay if there hadn't been TMC diversion
				//log.debug( "d3tmp[${jj++}] = ${(d.avg-d.obs)*5/60} == ${delay3}" )
				delay4 += (d.adjdivavg-d.incflow)*5/60; // avg cumflow less projected flow per timestep * 5/60th hr = projected delay
			}

			// scale to convert div adj avg to netdelay
			def factor = netDelayTarget/(cumflowObservedDelay) // +(delay3-cumflowObservedDelay)*(1-params.tmcDivPct/100.0))

			def holddelay4 = delay4

			delay4 *= factor
			delay4 = zeroOrBetter( delay4 )
		
			tmcSavings = zeroOrBetter( delay4 - zeroOrBetter( netDelayTarget ) )

			/*
			log.debug( "CUMFLOW: ${cumflow}" )
			log.debug( "RATES: ${incflowrate}, ${clearflowrate}" )
			log.debug( "DELAYS: ${factor},${netDelayTarget},${cumflowObservedDelay},${delay3},${holddelay4},${delay4},${tmcSavings}" )
			*/

            sim.conversionFactor = factor
			sim.modeledDelay = delay4
			sim.tmcSavings = tmcSavings

			return sim
		}
	}
}
