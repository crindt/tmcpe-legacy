package edu.uci.its.testbed

import grails.converters.*
import org.hibernate.criterion.*

class VdsController {
    
    def index = { redirect(action:list,params:params) }

     // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        //def myList = Vds.list( params );
        def _params = params
        def c = Vds.createCriteria()
        def max = Math.min( _params.max ? _params.max.toInteger() : 10,  100)
        def theList = c.list {
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
                if ( _params.type && _params.type != '' ) {
                    eq( "vdsType", _params.type )
                }
                if ( _params.idIn && _params.type != '' ) {
                    'in'( "id", _params.idIn.split(',')*.toInteger() )
                }
                if ( _params.bbox && _params.bbox != '' ) {
                    def bbox = params.bbox.split(",")
                    def valid = 0;
                    log.debug("============BBOX: " + bbox.join(","))
                    def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                    addToCriteria(Restrictions.sqlRestriction( "st_transform(seg_geom,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+")" ))
                }
                firstResult( _params.offset ? _params.offset.toInteger() : 0 )
                maxResults( max )
                order( "freeway" )
                order( "freewayDir" )
                if ( _params.freewayDir && _params.freewayDir != '' && ["S","W"].grep(_params.freewayDir) ) {
		    order( 'absPostmile','desc' )
		} else {
		    order( 'absPostmile','asc' )
		}

	    }
	};
        c = Vds.createCriteria()
        def theFullList = c.list {
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
                if ( _params.type && _params.type != '' ) {
                    eq( "vdsType", _params.type )
                }
                if ( _params.idIn && _params.type != '' ) {
                    'in'( "id", _params.idIn.split(',')*.toInteger() )
                }
                if ( _params.bbox && _params.bbox != '' ) {
                    def bbox = params.bbox.split(",")
                    def valid = 0;
                    log.debug("============BBOX: " + bbox.join(","))
                    def proj = ( params.proj =~ /^EPSG\:(\d+)/ )
                    addToCriteria(Restrictions.sqlRestriction( "st_transform(seg_geom,"+proj[0][1]+") && st_setsrid( ST_MAKEBOX2D(ST_MAKEPOINT(" + bbox[0] + ", " + bbox[1] + "),ST_MAKEPOINT( "  + bbox[2] + ", " + bbox[3] + ")), "+proj[0][1]+")" ))
                }
                order( "freeway" )
                order( "freewayDir" )
                if ( _params.freewayDir && _params.freewayDir != '' && ["S","W"].grep(_params.freewayDir) ) {
		    order( 'absPostmile','desc' )
		} else {
		    order( 'absPostmile','asc' )
		}
                    }
                }
        def fullTot = theFullList.size()
        withFormat {
            kml {
                [vdsInstanceList: theFullList]
            }
            geojson {
                def json = []
                theFullList.sort().each() { json.add( [ id: it.id, geometry: it.segGeom, properties: it ] ) }
                def fjson = [ type: "FeatureCollection", features: json ]
                render fjson as JSON;
            }
            html { 
                [ vdsInstanceList: theList.sort(), 
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
