package edu.uci.its.tmcpe

class IncidentSectionData implements Comparable {

    // belongs to a particular analyzedSection
    static belongsTo = [section: AnalyzedSection]
    Date               fivemin

    // copied from main tables
    Integer         vol
    Float           spd
    Float           occ

    // cached from db
    Integer         days_in_avg
    Float           vol_avg
    Float           occ_avg
    Float           spd_avg
    Float           spd_std
    Float           pct_obs_avg

    // computed
    Float           p_j_m
    Float           incident_flag
    Float           tmcpe_delay
    Float           d12_delay

    static constraints = {
    }

    static mapping = {
        table name: 'incident_section_data', schema: 'tmcpe'
        version false
    }

    Boolean isValid() {
	// Basically, it's valid if p_j_m is 0 or 1.  We do the following to
	// handle precision issues
	return (p_j_m - 0.5).abs() > 0.45;
    }

    String toString() {
        def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
        return df.format( fivemin ) + ":[" + [ vol, spd, occ, incident_flag, tmcpe_delay, d12_delay ].join( ", " ) + "]"
    }

    // This induces an ordering on section data
    int compareTo( obj ) {
        return fivemin.compareTo( obj.fivemin );
    } 

}
