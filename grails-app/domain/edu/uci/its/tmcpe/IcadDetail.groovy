package edu.uci.its.tmcpe

class IcadDetail implements Comparable {
    
    Integer id
    Icad icad
    Date stamp
    String detail

    static constraints = {
    }

    static mapping = {
        // FIXME: mongodb doesn't like it with id's have a different name
        //table name: 'icad_detail', schema: 'actlog'
        table name: 'icad_detail_with_id', schema: 'actlog'
        //id column: 'keyfield'
        version false
    }

    int compareTo( obj ) {
        int ret = 0
        if ( ( ret = icad.compareTo( obj.icad ) ) != 0 ) return ret
        if ( ( ret = stamp.compareTo( obj.stamp ) ) != 0 ) return ret
        // more?

        return ret
    }
}
