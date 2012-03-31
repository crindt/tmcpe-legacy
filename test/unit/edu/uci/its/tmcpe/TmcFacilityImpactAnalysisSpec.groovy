package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

/**
 * The specification of TmcFacilityImpactAnalysis.
 *
 * A TmcFacilityImpactAnalysis encapsulates the results of a model of
 * TMC impacts.  In our case, we observe the performance of the system
 * with the TMC in operation in the form of point sensor data and
 * Activity Logs (TMC and CHP).  This performance is encapsulated by
 * the IncidentFacilityImpactAnalysis class.  The performance of the
 * system in the non-TMC case is modeled
 */
@Mixin(DatastoreUnitTestMixin)
class TmcFacilityImpactAnalysisSpec extends UnitSpec {
    def "Test that TmcFacilityImpactAnalysis can be persisted"() {
    given: "a new tfia object" 
        mockDomain(TmcFacilityImpactAnalysis)
        def tfia = new TmcFacilityImpactAnalysis( cad:"123-20110102", facility:"N-5")
        tfia.sections = [1,2,3,4,5]
        tfia.obsvol = [[11,12,13,14,15],
                       [21,22,23,24,25],
                       [31,32,33,34,35],
                       [41,42,43,44,45],
                       [51,52,53,54,55]]
        ;
        
    when: "we save it"
        tfia.save(flush:true)

    then: "it should be a valid object in the database"
        tfia.id != null
        TmcFacilityImpactAnalysis.get(tfia.id) != null
        TmcFacilityImpactAnalysis.get(tfia.id).cad == "123-20110102"
        TmcFacilityImpactAnalysis.get(tfia.id).facility == "N-5"
        TmcFacilityImpactAnalysis.get(tfia.id).sections[3] == 4
        TmcFacilityImpactAnalysis.get(tfia.id).obsvol[3][4] == 45
        ;
    }


}