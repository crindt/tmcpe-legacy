package edu.uci.its.tmcpe

class IncidentImpactAnalysis {

    String analysisName
    static belongsTo = Incident

    // should have core parameters that define the analysis so we can
    // cache results

    // Also, should support derived classes that use different methods
    // for computing impact.  Thus, the above will be
    // implementation-specific

    static hasMany = [
        incidentFacilityImpactAnalyses: IncidentFacilityImpactAnalysis
    ]


    static constraints = {
    }

    String toString() {
        if ( analysisName != null && analysisName != "" ) {
            return analysisName
        } else {
            return super.toString()
        }
    }
}
