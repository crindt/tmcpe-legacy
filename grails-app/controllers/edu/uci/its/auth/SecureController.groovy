package edu.uci.its.auth

import grails.plugins.springsecurity.Secured


class SecureController {

	@Secured(['ROLE_ADMIN'])
    def index = { 
       render 'Secure access only'
    }
	
	def receptor = {
		render "You're Back!"
	}
}
