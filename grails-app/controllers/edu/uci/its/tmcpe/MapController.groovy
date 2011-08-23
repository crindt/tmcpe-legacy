package edu.uci.its.tmcpe

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class MapController extends BaseController {
	
    // Get the authenticateService bean
    def springSecurityService

    static navigation = [
        group:'tabs',
        order:2,
        title:'Query Incidents',
	isVisible: { org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils.ifAnyGranted("ROLE_ADMIN,ROLE_TMCPE,ROLE_CALTRANS_D12_TMC") }
    ]

    // the delete, save and update actions are not allowed
    static allowedMethods = []
    
    // The default action for the map controller is show
    def index = { redirect(action:show,params:params) }

    // Shows the map
    def show = {}
}
