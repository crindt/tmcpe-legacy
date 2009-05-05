package edu.uci.its.tmcpe

// This needs to map into spatialvds
class FacilitySection {
    
    String  facilityName
    String  facilityDirection
//    Vds     vdsId
    Integer vdsId
    Float   startPostmile
    Float   endPostmile

    static constraints = {
    }

    String toString() {
        return [ facilityName, facilityDirection, "@",(startPostmile + endPostmile)/2 ].join( " " )
    }
}
