package edu.uci.its.tmcpe

class TmcPerformanceMeasures {

    Integer id
    TmcLogEntry logId
    String pmText
    String pmType
    String blockLanes
    String detail

    static belongsTo = TmcLogEntry

    static constraints = {
    }

    static mapping = {
        table name: 'performance_measures', schema: 'actlog'
        logId column: 'log_id'
        pmText column: 'pmtext'
        pmType column: 'pmtype'
        blockLanes column: 'block_lanes'
        version false
    }

    String toString () {
        return "" + pmType + ":" + pmText + "," + (blockLanes?:"") + "|" + detail
    }

}
