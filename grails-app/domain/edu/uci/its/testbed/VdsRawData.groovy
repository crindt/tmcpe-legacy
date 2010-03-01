package edu.uci.its.testbed

class VdsRawData implements Serializable {

    Integer vdsid
    Date    fivemin
    Integer intervals
    Integer volume
    Float occ
    Time    fivemin_tod
/*
    Integer laneVolumes[]
    Integer laneOccs[]
*/

    static mapping = {
//        table name: 'pems_raw_5minute_aggregates_two'
        table name: 'pems_raw_agg_tmcpe'

        version false

        id composite: ['vdsid','fivemin']
        vdsid column: 'vds_id'
        fivemin column: 'fivemin'
        intervals column: 'intervals'
        volume column: 'nsum'
        occ column: 'oave'
        fivemin_tod column: 'fivemin_tod'
/*
        laneVolumes column: 'nlanes'
        laneOccs column: 'olanes'
*/
    }

    static constraints = {
    }
}
