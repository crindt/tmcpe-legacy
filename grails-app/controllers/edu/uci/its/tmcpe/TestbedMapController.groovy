

package edu.uci.its.tmcpe

class TestbedMapController {
    
    def index = { redirect(action:show,params:params) }

    // the delete, save and update actions only accept POST requests
//    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def show = {
        def testbedLineInstance = TestbedLine.find

        if(!testbedLineInstance) {
            flash.message = "TestbedMap not found with id ${params.id}"
            redirect(action:index)
        }
        else { return [ testbedLineInstance : testbedLineInstance ] }
    }
}
