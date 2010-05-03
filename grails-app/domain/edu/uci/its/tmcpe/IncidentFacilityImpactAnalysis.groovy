package edu.uci.its.tmcpe

import edu.uci.its.testbed.Vds

class IncidentFacilityImpactAnalysis {

    ///////// INPUTS ////////

    // This is the expected location of the onset of disruption to THIS facility
    FacilitySection location

    // This defines the time bounds of this analysis
    Date            startTime
    Date            endTime

    // Treat this as a sorted set.  IncidentSectionData has an induced ordering upstream to downstream by absolute postmile
    SortedSet       analyzedSections

    static hasMany = [ analyzedSections: AnalyzedSection ]

    IncidentFacilityImpactAnalysis incidentImpactAnalysis
    static belongsTo = [incidentImpactAnalysis: IncidentFacilityImpactAnalysis]


    ///////// OUTPUTS ////////
    Double totalDelay


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
