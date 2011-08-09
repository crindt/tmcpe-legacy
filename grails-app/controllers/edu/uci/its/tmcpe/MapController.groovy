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
    
    def index = { redirect(action:show,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def show = {
        return [ ]
    }

    def d3_show = {
	return [ ]
    }

    def backbone_map = {
	return [ ]
    }

    def revamp_map = {
	return [ ]
    }

    def simple = {
        return [ ]
    }
}
