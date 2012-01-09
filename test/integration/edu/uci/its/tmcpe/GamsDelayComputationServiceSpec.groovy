/* @(#)GamsDelayComputationServiceSpec.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */

package edu.uci.its.tmcpe

import grails.plugin.spock.*
import grails.datastore.test.DatastoreUnitTestMixin

class GamsDelayComputationServiceSpec extends IntegrationSpec {

	def "Test that the we can run the GAMS solver"() {
      given: "a GamsDelayComputationService remove executor and a Gams input file"
		def remexec = new GamsDelayComputationService.GamsRemoteExecutor()
        def gms = new File('test/data/1-send.gms')
        ;

      when:  "we sync the file to the GAMS server"
		def result = remexec.syncGmsFile()
		;

	  then: "we don't get an rsync exception"
        notThrown GamesDelayComputationService.RsyncFailedException
        ;
        
      and: "we don't get any other exception"
        notThrown Exception
		;
	}
}
