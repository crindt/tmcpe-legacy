package edu.uci.its.tmcpe

class TmcFacilityImpactAnalysis {

    //static mapWith = "mongo"

    String id
    String cad
    String facility
    List timesteps
    List sections
    List obsvol

    //static embedded = ['timesteps', 'sections', 'obsvol']
    static embedded = ['sections']
    static constraints = {
    }
}
