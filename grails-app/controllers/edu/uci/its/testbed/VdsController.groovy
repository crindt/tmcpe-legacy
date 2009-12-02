package edu.uci.its.testbed

class VdsController {
    
    def index = { redirect(action:list,params:params) }

     // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        def myList = Vds.list( params );
        def _params = params
        withFormat {
            kml {
                def c = Vds.createCriteria()
                def res = c.list {
                    and {
                        if ( _params.district && _params.district != '' ) {
                            eq( "district", _params.district.toInteger() )
                        }
                        if ( _params.freeway && _params.freeway != '' ) {
                            eq( "freeway", _params.freeway.toInteger() )
                        }
                        if ( _params.freewayDir && _params.freewayDir != '' ) {
                            eq( "freewayDir", _params.freewayDir )
                        }
                        order( "freeway" )
                        order( "freewayDir" )
                    }
                }
                [vdsInstanceList: res]
            }
            html { 
                def max = Math.min( _params.max ? _params.max.toInteger() : 10,  100)
                def c = Vds.createCriteria()
                def resCnt = c.list {
                    and {
                        if ( _params.district && _params.district != '' ) {
                            eq( "district", _params.district.toInteger() )
                        }
                        if ( _params.freeway && _params.freeway != '' ) {
                            eq( "freeway", _params.freeway.toInteger() )
                        }
                        if ( _params.freewayDir && _params.freewayDir != '' ) {
                            eq( "freewayDir", _params.freewayDir )
                        }
                        firstResult( _params.offset ? _params.offset.toInteger() : 0 )
                        order( "freeway" )
                        order( "freewayDir" )
                    }
                }
                def fullTot = resCnt.size()
                c = Vds.createCriteria()
                def res = c.list {
                    and {
                        if ( _params.district && _params.district != '' ) {
                            eq( "district", _params.district.toInteger() )
                        }
                        if ( _params.freeway && _params.freeway != '' ) {
                            eq( "freeway", _params.freeway.toInteger() )
                        }
                        if ( _params.freewayDir && _params.freewayDir != '' ) {
                            eq( "freewayDir", _params.freewayDir )
                        }
                        firstResult( _params.offset ? _params.offset.toInteger() : 0 )
                        maxResults( max )
                        order( "freeway" )
                        order( "freewayDir" )
                    }
                }
                [ vdsInstanceList: res, 
                  vdsInstanceTotal: fullTot ] 
            }
        }
    }

    def show = {
        def vdsInstance = Vds.get( params.id )

        if(!vdsInstance) {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ vdsInstance : vdsInstance ] }
    }

    def delete = {
        def vdsInstance = Vds.get( params.id )
        if(vdsInstance) {
            try {
                vdsInstance.delete()
                flash.message = "Vds ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "Vds ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def vdsInstance = Vds.get( params.id )

        if(!vdsInstance) {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ vdsInstance : vdsInstance ]
        }
    }

    def update = {
        def vdsInstance = Vds.get( params.id )
        if(vdsInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(vdsInstance.version > version) {
                    
                    vdsInstance.errors.rejectValue("version", "vds.optimistic.locking.failure", "Another user has updated this Vds while you were editing.")
                    render(view:'edit',model:[vdsInstance:vdsInstance])
                    return
                }
            }
            vdsInstance.properties = params
            if(!vdsInstance.hasErrors() && vdsInstance.save()) {
                flash.message = "Vds ${params.id} updated"
                redirect(action:show,id:vdsInstance.id)
            }
            else {
                render(view:'edit',model:[vdsInstance:vdsInstance])
            }
        }
        else {
            flash.message = "Vds not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def vdsInstance = new Vds()
        vdsInstance.properties = params
        return ['vdsInstance':vdsInstance]
    }

    def save = {
        def vdsInstance = new Vds(params)
        if(!vdsInstance.hasErrors() && vdsInstance.save()) {
            flash.message = "Vds ${vdsInstance.id} created"
            redirect(action:show,id:vdsInstance.id)
        }
        else {
            render(view:'create',model:[vdsInstance:vdsInstance])
        }
    }
//    def listAllAsKml = {
//        //[ testbedLineInstanceList: TestbedLine.list( ), testbedLineInstanceTotal: TestbedLine.count() ]
//        def vdsList = Vds.withCriteria { eq("district", 12 ) }
//        render(contentType:"text/xml",
//               view:'listAllAsKml',
//               model:[ vdsInstanceList: vdsList, vdsInstanceTotal: vdsList.count() ])
//    }
}
