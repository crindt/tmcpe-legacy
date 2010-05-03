package edu.uci.its.tmcpe

class IncidentImpactAnalysis {
    Integer id

    String analysisName

    // should have core parameters that define the analysis so we can
    // cache results

    // Also, should support derived classes that use different methods
    // for computing impact.  Thus, the above will be
    // implementation-specific

    static hasMany = [
        incidentFacilityImpactAnalyses: IncidentFacilityImpactAnalysis
    ]

    Incident incident;
    static belongsTo = [incident:Incident]


    String toString() {
        if ( analysisName != null && analysisName != "" ) {
            return "analysis " + analysisName
        } else {
            return super.toString()
        }
    }

    static mapping = {
        table name: 'incident_impact_analysis', schema: 'tmcpe'
    }
}
