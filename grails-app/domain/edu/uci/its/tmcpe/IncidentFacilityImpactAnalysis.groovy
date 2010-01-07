package edu.uci.its.tmcpe

import edu.uci.its.testbed.Vds

class IncidentFacilityImpactAnalysis {

    // owner

    //FacilitySection startSection
    //FacilitySection endSection

    Integer facility
    String direction

    List possibleFacilitySection

    Double totalDelay

    static hasMany = [ possibleFacilitySection: FacilitySection ]
    static belongsTo = [incidentImpactAnalysis:IncidentImpactAnalysis]


    // time discontinuities
    // space discontinuities

    static constraints = {
        totalDelay( min:(Double)0.0, nullable: true )
    }

    static mapping = {
        table name: 'incident_facility_impact_analysis', schema: 'tmcpe'
    }

    String shortAnalysisSummary() {
        return [ 
            possibleFacilitySection.first().freewayDir,
            possibleFacilitySection.first().freewayId, 
            "[ DELAY =", totalDelay, "]" 
        ].join( " " );
    }

    String toString() {
        def incident = getIncident()
        return ["Analysis of incident ", incident.section.freewayDir, incident.section.freewayId, "@", incident.section.name,
            "from", possibleFacilitySection?.first(), "to", possibleFacilitySection?.last(),
            "between", incident.getTmcLogEntries()?.first().stampDateTime(), "and", incident.getTmcLogEntries()?.last().stampDateTime()
        ].join(" ")
    }

    def getIncident() { incidentImpactAnalysis.incident }

    def String getFileName() {
        return [getIncident().id, facility, direction].join( "-" )
    }

    static transients = [ "fileName", "incident" ]
}
