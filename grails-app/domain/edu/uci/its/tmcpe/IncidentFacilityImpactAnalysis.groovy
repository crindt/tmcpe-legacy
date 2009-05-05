package edu.uci.its.tmcpe

class IncidentFacilityImpactAnalysis {

    IncidentImpactAnalysis incidentImpactAnalysis
    String facilityName
    String facilityDirection
    Date   startTime
    Date   endTime
    FacilitySection startSection
    FacilitySection endSection

    // owner
    static belongsTo = IncidentImpactAnalysis


    // time discontinuities
    // space discontinuities

    static constraints = {
    }

    String toString() {
        return ["Analysis of", facilityDirection, facilityName, 
            "from", startSection, "to", endSection, 
            "between", startTime, "and", endTime].join(" ")
    }
}
