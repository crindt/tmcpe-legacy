package edu.uci.its.tmcpe

class IncidentImpactAnalysis implements Comparable {
    Integer id

    String analysisName

    // should have core parameters that define the analysis so we can
    // cache results

    // Also, should support derived classes that use different methods
    // for computing impact.  Thus, the above will be
    // implementation-specific

    SortedSet incidentFacilityImpactAnalyses
    static hasMany = [
        incidentFacilityImpactAnalyses: IncidentFacilityImpactAnalysis
    ]

    ProcessedIncident incident;
    static belongsTo = [incident:ProcessedIncident] // This causes cascade delete

	def analysisForPrimaryFacility() { 
		return analysisForFacility( "${incident.section?.freewayId}",
									incident.section?.freewayDir )
	}

	def analysisForFacility( String fac, String dir ) { 
		log.debug( "SEARCHING FOR ${fac}-${dir} AMONG ${incidentFacilityImpactAnalyses.size()} analyses" )
		def ifia
		incidentFacilityImpactAnalyses?.each{ 
			println it
			if ( "${it.location?.freewayId}" == fac && it.location?.freewayDir == dir )  {
				log.debug( "LOOKS GOOD, RETURNING IT" )
				ifia = it
				  } else { 
				def res1 = "${it.location?.freewayId}" == fac
				def res2 =  it.location?.freewayDir == dir
				log.debug( "res1 is ${res1}, res2 is ${res2}" )
			}
		}
		return ifia
	}

    Float d12Delay() {
        def f = 0
        def defined = false
        incidentFacilityImpactAnalyses?.collect{ 
			if ( it?.d12Delay != null ) { defined = true }
			f += (it?.d12Delay?: 0) 
        }
        if ( defined ) {
			return f
        } else {
			return null
        }
    }

    Float samplePercent() {
		def cnt = (incidentFacilityImpactAnalyses.sum() { it.minMilesObserved });
		def tot = (incidentFacilityImpactAnalyses.sum() { it.minMilesTotal });
		if ( tot == 0 || tot == null ) return null;
		return ( cnt / tot );
    }

    Float netDelay() {
        def f = 0
        incidentFacilityImpactAnalyses?.collect{ 
			def d = (it?.netDelay?: 0);
			f += (d<0?0:d);
		}
        return f
    }


    String toString() {
        if ( analysisName != null && analysisName != "" ) {
            return analysisName + " analysis"
        } else {
            return super.toString()
        }
    }

    static mapping = {
        table name: 'incident_impact_analysis', schema: 'tmcpe'
        version false
    }

    int compareTo( Object o ) {
        int ret = 0;
        if ( analysisName == 'Default' ) {
			if ( o.analysisName == 'Default' ) {
				return id.compareTo( o.id )
			} else {
				return -1
			}
        } else {
			if ( o.analysisName == 'Default' ) {
				return 1
			} else {
				return id.compareTo( o.id )
			}
        } 
        return 0
    }
}
