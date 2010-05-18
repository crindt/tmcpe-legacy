package edu.uci.its.tmcpe

class AnalyzedSection implements Comparable {

    FacilitySection section

    IncidentFacilityImpactAnalysis analysis;

    static belongsTo = [analysis: IncidentFacilityImpactAnalysis ]

    SortedSet  analyzedTimestep;
    static hasMany = [analyzedTimestep: IncidentSectionData];

    static mapping = {
        table name: 'analyzed_section', schema: 'tmcpe'
        version false
    }

    static constraints = {
    }

    String toString() {
        return section?.toString()
          +": ["+analyzedTimestep?.size()+" timesteps}"

    }

    // This induces an ordering on section lists.  Upstream sections come first
    int compareTo( obj ) {
        int dir = 1;
        if ( section.freewayDir == 'N' || section.freewayDir == 'E' ) dir = -1;
        float tmp = dir * ( section.absPostmile - obj.section.absPostmile );
        return tmp < 0 ? -1 : ( float == 0 ? 0 : 1 )
    } 

}
