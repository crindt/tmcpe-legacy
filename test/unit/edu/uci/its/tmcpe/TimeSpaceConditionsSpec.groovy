/* @(#)TimeSpaceConditionsSpec.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

@Mixin(DatastoreUnitTestMixin)
class TimeSpaceConditionsSpec extends UnitSpec {
    
	def "Test that TimeSpaceConditions validation works"() {

      given: "A TimeSpaceConditions object"
		mockForConstraintsTests(TimeSpaceConditions)
        ;

      when: "data is all consistent"
		def tsc = new TimeSpaceConditions()
		tsc.spds  = [[11f,12f],[21f,22f]]
		tsc.flows = [[11,12],[21,22]]
		tsc.occs =  [[0.11f,0.12f],[0.21f,0.22f]]
		tsc.incidents = [[0,1],[1,0]]
        ;

      then: "validation should pass"
		tsc.validate() == true
        ;


      when: "the section/time dimensions of spds/flows/occs differs"
		tsc = new TimeSpaceConditions()
		tsc.spds  = spds
		tsc.flows = flows
		tsc.occs  = occs
		tsc.incidents = incs
        ;

      then: "validation should fail"
		tsc.validate() == false
        ;

	  where:
		// these should all fail because the dimensions of the arrays don't all match
		spds                  | flows             | occs                          | incs
		[[11f,12f]]           | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12]]         | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f]]               | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1]]
		[[11f],[21f,22f]]     | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f]]     | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11   ],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21   ]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f      ],[0.21f,0.22f]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f      ]] | [[0,1],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0  ],[1,0]]
		[[11f,12f],[21f,22f]] | [[11,12],[21,22]] | [[0.11f,0.12f],[0.21f,0.22f]] | [[0,1],[1  ]]
		;
    }

}
