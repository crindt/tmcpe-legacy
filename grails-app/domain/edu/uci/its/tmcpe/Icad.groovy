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
        // FIXME: mongodb doesn't like it with id's have a different name
        //table name: 'icad', schema: 'actlog'
        table name:'icad_with_id', schema: 'actlog'
        //id column: 'keyfield'
        version false
    }

    int compareTo( obj ) {
      int ret = 0
      if ( ( ret = id.compareTo( obj.id ) ) != 0 ) return ret

      return ret
    }

}
