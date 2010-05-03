package edu.uci.its.tmcpe

class AnalyzedSection implements Comparable {

    FacilitySection section

    IncidentFacilityImpactAnalysis analysis;

    static belongsTo = [analysis: IncidentFacilityImpactAnalysis ]

    SortedSet  analyzedTimestep;
    static hasMany = [analyzedTimestep: IncidentSectionData];

    static mapping = {
        table name: 'analyzed_section', schema: 'tmcpe'
    }

    static constraints = {
    }

    // This induces an ordering on section lists.  Upstream sections come first
    int compareTo( obj ) {
        int dir = 1;
        if ( section.freewayDir == 'S' || section.freewayDir == 'E' ) dir = -1;
        return dir * ( section.absPostmile - obj.section.absPostmile );
    } 

}
