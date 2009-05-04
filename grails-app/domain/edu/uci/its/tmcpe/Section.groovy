package edu.uci.its.tmcpe

class Section {

    String facility
    String direction
    Float startPostmile
    Float endPostmile
    VDS vds

    static constraints = {
    }
    static mapping = {
        // Sections must map to sensor tables
    }
}
