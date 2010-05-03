package edu.uci.its.testbed

class VdsData implements Serializable {

    // primary key
    Integer vdsid
    Date    stamp

    Integer cnt_all
    Float   occ_all
    Float   spd_all

    Integer samples_all
    Integer pct_obs_all

    // Methods for obtaining averages?


    // Get primary key for use by controller (from: grailsframework.blogspot.com/2008/05/composite-key-in-domain-class.html )
    def getPK() {
        [ "vdsid": vdsid, "stamp": stamp ]
    }

    static constraints = {
    }

    static mapping = {
       table name:   'pems_5min_mini'
       id composite: [ 'vdsid', 'stamp' ]
       version false
    }
}
