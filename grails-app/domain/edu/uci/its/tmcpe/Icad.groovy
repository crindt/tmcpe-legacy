package edu.uci.its.tmcpe

class Icad {

    Integer id
    String logId
    String logtime
    String logtype
    String location
    String thomasbrothers
    String tbxy
    String d12cad
    String d12cadalt

    SortedSet details

    static hasMany = [details:IcadDetail]

    static constraints = {
    }

    static mapping = {
        table name: 'icad', schema: 'actlog'
        id column: 'keyfield'
        version false
    }

    int compareTo( obj ) {
      int ret = 0
      if ( ( ret = id.compareTo( obj.id ) ) != 0 ) return ret

      return ret
    }

}
