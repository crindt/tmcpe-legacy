package edu.uci.its.tmcpe

import edu.uci.its.testbed.Vds

class IncidentFacilityImpactAnalysis implements Comparable {

    ///////// INPUTS ////////

    // This is the expected location of the onset of disruption to THIS facility
    FacilitySection location

    // This defines the time bounds of this analysis
    Date            startTime
    Date            endTime

    // These come from the logs
    Date firstCall      // equivalent to t0
    Date verification   // equivalent to t1
    Date lanesClear     // equivalent to t2

    // This is computed as the furthest upstream disrupted section
    Date            computedStartTime
    FacilitySection computedStartLocation

    // This is computed based upon the last delayed vehicle
    Date            computedIncidentClearTime    // equivalent to t3
    

    //////// PARAMETERS ////////
    String commandLine       // The command line of the delay computation
    Double band
    Double bias
    Double downstreamWindow
    Double upstreamWindow
    Double preWindow
    Double postWindow
    byte[] gamsInputFile
    byte[] gamsOutputFile
    Double minObservationPercent
    Double limitLoadingShockwave
    Double limitClearingShockwave
    Double unknownEvidenceValue
    Double weightForDistance
    Boolean weightForLength
    Boolean BoundIncidentTime
    Double d12DelaySpeed
    Double maxIncidentSpeed

    // Treat this as a sorted set.  IncidentSectionData has an induced ordering
    // upstream to downstream by absolute postmile
    SortedSet       analyzedSections

    static hasMany = [ analyzedSections: AnalyzedSection ]

    static belongsTo = [ incidentImpactAnalysis: IncidentImpactAnalysis ]


    ///////// OUTPUTS ////////
    Boolean solutionTimeBounded
    Boolean solutionSpaceBounded
    Double d12Delay
    Double totalDelay
    Double netDelay
    Double avgDelay


    // time discontinuities
    // space discontinuities

    static constraints = {
        totalDelay( min:(Double)0.0, nullable: true )
	commandLine( maxSize:2048 )
	gamsInputFile( maxSize: 2000000 )  // 2 million bytes, or an megabyte in SI units
	gamsOutputFile( maxSize: 2000000 ) // 2 million bytes, or an megabyte in SI units, generally must be gzipped
	unknownEvidenceValue( min: (Double)0.0, max:(Double)1.0)
    }

    static mapping = {
        table name: 'incident_facility_impact_analysis', schema: 'tmcpe'
        version false
    }

    String shortAnalysisSummary() {
        return [ 
            analyzedSections?.first().section.freewayDir,
            analyzedSections?.first().section.freewayId, 
            "[ NET DELAY =", netDelay, "]" 
        ].join( " " );
    }

    String toString() {
        def incident = getIncident()
        return ["Analysis of incident ", incident.section.freewayDir, incident.section.freewayId, "@", incident.section.name,
            "from", analyzedSections?.first(), "to", analyzedSections?.last()
//            ,"between", incident.getTmcLogEntries()?.first().stampDateTime(), "and", incident.getTmcLogEntries()?.last().stampDateTime()
        ].join(" ")
    }

    def getIncident() { incidentImpactAnalysis.incident }

    def String getFileName() {
        return [getIncident().id, facility, direction].join( "-" )
    }

    static transients = [ "fileName", "incident" ]

    int compareTo( obj ) {
        if ( obj == null ) return 1

        // If the same freeway and dir, they're equal
        if ( location.freewayId == obj.location?.freewayId 
             && location.freewayDir == obj.location?.freewayDir ) return 0

        def ifw = incidentImpactAnalysis.incident.section?.freewayId
        def ifd = incidentImpactAnalysis.incident.section?.freewayDir

        // If this object is the same freeway and dir as the incident location, it comes first
        if (  ifw == location.freewayId 
             && ifd == location.freewayDir ) return -1

        // If the other is the same freeway as the incident loc and this one isn't, then other comes first
        if ( ifw == obj.location?.freewayId &&  ifw != location?.freewayId ) return 1

        // If we get here, neither this or other is matches the freewayid, so they're equal
        return 0
    }
}
