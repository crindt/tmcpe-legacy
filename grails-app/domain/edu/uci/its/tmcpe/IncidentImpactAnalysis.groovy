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

    Incident incident;
    static belongsTo = [incident:Incident]

    Float d12Delay() {
        def f = 0
        incidentFacilityImpactAnalyses?.collect{ f += (it?.d12Delay?: 0) }
        return f
    }

    Float netDelay() {
        def f = 0
        incidentFacilityImpactAnalyses?.collect{ f += (it?.netDelay?: 0) }
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
