package edu.uci.its.tmcpe

import grails.plugins.springsecurity.Secured

@Secured(["ROLE_ADMIN","ROLE_TMCPE","ROLE_CALTRANS_D12_TMC"])
class SummaryController extends BaseController {

    static allowedMethods = []

    def index = {
    }
}
