package edu.uci.its.tmcpe

import org.codehaus.groovy.grails.plugins.springsecurity.Secured

class MapController {


    static navigation = [
        group:'tabs',
        order:1,
        title:'Home'
        ]
    
    @Secured(['ROLE_ADMIN'])
    def index = { redirect(action:show,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    @Secured(['ROLE_ADMIN'])
    def show = {
        return [ ]
    }
}
