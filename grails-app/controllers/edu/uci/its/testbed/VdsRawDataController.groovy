package edu.uci.its.testbed

import grails.converters.*
import org.hibernate.criterion.*
import org.apache.commons.logging.LogFactory

class VdsRawDataController {
    
    static log = LogFactory.getLog("edu.uci.its.testbed.VdsRawDataController")
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        def c = VdsRawData.createCriteria()
        def theList = c.list {
            and {
                eq( 'vdsid', params.vdsid.toInteger() )
                if ( params.from || params.to ) {
                    def from = Date.parse( "yyyy-M-d H:m:s", params.from ? params.from : '0000-00-00 00:00:00' )
                    def to = params.to ? Date.parse( "yyyy-M-d H:m:s", params.to ) : new Date()
                    if ( params.avg ) {
                       or {
                          for ( i in 1..52 ) {
                             between( 'fivemin', from-i*7, to-i*7 )
                          }
                       }
                    } else {
                       between( 'fivemin', from, to )
                    }
                }
                if ( params.at ) {
                    def at = Date.parse( "yyyy-M-d H:m:s", params.at ? params.at : '0000-00-00 00:00:00' )
                    def dates = []
                    1..52.each() { i -> dates.push(at - i*7) }

                    log.debug( dates )
                    'in'( 'fivemin', dates )  // must be in prior 52 weeks
                }
            }
            order( 'fivemin', 'asc' )
        }
        withFormat {
            html { 
                return [ vdsRawDataInstanceList: theList, vdsRawDataInstanceTotal: theList.count() ] 
            }
            json {
                def json = [ items: theList ]
                render json as JSON
            }
        }
    }

    def show = {
        def vdsRawDataInstance = VdsRawData.get( new VdsRawData( vdsid: params.vdsid, fivemin: new Date().parse( 'yyyy-M-d H:m:s', params.fivemin ) ) )

        if(!vdsRawDataInstance) {
            flash.message = "VdsRawData not found with id ${params.vdsid}, ${params.fivemin}"
            redirect(action:list)
        }
        else { return [ vdsRawDataInstance : vdsRawDataInstance ] }
    }

}
