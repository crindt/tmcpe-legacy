package edu.uci.its.tmcpe

import spock.lang.*
import grails.plugin.spock.*
import groovy.time.*

import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class IncidentResponseSpec extends TmcpeUnitSpec {

    def "Test that IncidentResponse can be persisted "() {

      given: "a new IncidentResponse object"
        mockDomain(IncidentResponse)
        def ir
        ;
        
      when: "we create an ir bu don't save it"
        ir = validIncidentResponse()
        ;
        
      then: "It shouldn't be in the database"
        IncidentResponse.get(ir.id) == null
        ;

      when: "we save it"
        ir.save(flush:true)
        ;
        
      then: "it should be a valid object in the database"
        IncidentResponse.get(ir.id) != null
        ;
        
      when: "we change it"
        use ( [ groovy.time.TimeCategory ]) { 
            ir.t3Clear.stamp += 30.minutes
        }
        
        ir.save(flush:true)
        def ir2 = IncidentResponse.get(ir.id)
        ;
        
      then: "that should be reflected in the database too"
        ir2.t3Clear == ir.t3Clear
        ;

    }

    def "Test validation"() { 
      given: "an IncidentResponse"
		mockForConstraintsTests(IncidentResponse)
        ;
        
      when:
        println createir(10,20,40)
        ;
        

      then: "we should get the expected validation result"
        createir(10,20,40).validate() == true
        createir(10,5,40).validate() == false
        createir(10,20,15).validate() == false
    }
    

    def now() {  return new Date() }

    def validIncidentResponse() { 
        use ( [ groovy.time.TimeCategory ]) { 
            Date now = new Date()
            return new IncidentResponse(
                t0Onset: now, 
                t1Verification: now + 10.minutes, 
                t2CapacityRestored: now + 40.minutes,
                t3Clear: now + 120.minutes
            )
        }
    }

    def createir(dt1,dt2,dt3) { 
        def ir
        use ( [ groovy.time.TimeCategory ]) { 
            Date now = new Date(0)
            ir = new IncidentResponse(
                t0Onset: new IncidentResponse.CriticalEvent(now), 
                t1Verification: new IncidentResponse.CriticalEvent(now + dt1.minutes), 
                t2CapacityRestored: new IncidentResponse.CriticalEvent(now + dt2.minutes),
                t3Clear: new IncidentResponse.CriticalEvent(now + dt3.minutes)
            )
            println "IR " + ir
        }
        return ir
    }
}
