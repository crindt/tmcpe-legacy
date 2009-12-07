package edu.uci.its.testbed

import grails.test.*

class VdsTests extends GroovyTestCase {
    protected void setUp() {
        super.setUp()
    }

    protected void tearDown() {
        super.tearDown()
    }

    void testSomething() {
		def vds = Vds.findById( 1201052 )
		
		assert true

    }
}
