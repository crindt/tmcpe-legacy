

package edu.uci.its.tmcpe

class TestbedLineController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ testbedLineInstanceList: TestbedLine.list( params ), testbedLineInstanceTotal: TestbedLine.count() ]
    }

    def show = {
        def testbedLineInstance = TestbedLine.get( params.id )

        if(!testbedLineInstance) {
            flash.message = "TestbedLine not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ testbedLineInstance : testbedLineInstance ] }
    }

    def delete = {
        def testbedLineInstance = TestbedLine.get( params.id )
        if(testbedLineInstance) {
            try {
                testbedLineInstance.delete()
                flash.message = "TestbedLine ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "TestbedLine ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "TestbedLine not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def testbedLineInstance = TestbedLine.get( params.id )

        if(!testbedLineInstance) {
            flash.message = "TestbedLine not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ testbedLineInstance : testbedLineInstance ]
        }
    }

    def update = {
        def testbedLineInstance = TestbedLine.get( params.id )
        if(testbedLineInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(testbedLineInstance.version > version) {
                    
                    testbedLineInstance.errors.rejectValue("version", "testbedLine.optimistic.locking.failure", "Another user has updated this TestbedLine while you were editing.")
                    render(view:'edit',model:[testbedLineInstance:testbedLineInstance])
                    return
                }
            }
            testbedLineInstance.properties = params
            if(!testbedLineInstance.hasErrors() && testbedLineInstance.save()) {
                flash.message = "TestbedLine ${params.id} updated"
                redirect(action:show,id:testbedLineInstance.id)
            }
            else {
                render(view:'edit',model:[testbedLineInstance:testbedLineInstance])
            }
        }
        else {
            flash.message = "TestbedLine not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def testbedLineInstance = new TestbedLine()
        testbedLineInstance.properties = params
        return ['testbedLineInstance':testbedLineInstance]
    }

    def save = {
        def testbedLineInstance = new TestbedLine(params)
        if(!testbedLineInstance.hasErrors() && testbedLineInstance.save()) {
            flash.message = "TestbedLine ${testbedLineInstance.id} created"
            redirect(action:show,id:testbedLineInstance.id)
        }
        else {
            render(view:'create',model:[testbedLineInstance:testbedLineInstance])
        }
    }

    def listAllAsKml = {
        //[ testbedLineInstanceList: TestbedLine.list( ), testbedLineInstanceTotal: TestbedLine.count() ]
        render(contentType:"text/xml",
               view:'listAllAsKml',
               model:[ testbedLineInstanceList: TestbedLine.list( ), testbedLineInstanceTotal: TestbedLine.count() ])
    }
}
