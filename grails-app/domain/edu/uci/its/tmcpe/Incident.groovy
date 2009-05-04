package edu.uci.its.tmcpe

class Incident {

    String cadid
    
    // an incident will have a set of data associated with it that
    // will provide certain evidence and or ground truthing.
    // Generally, this will consist of station-based sensor
    // measurements
    static hasMany = [ sections : Section ]

    // 

    static constraints = {
    }
}
