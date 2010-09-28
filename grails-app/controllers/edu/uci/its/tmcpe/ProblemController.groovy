package edu.uci.its.tmcpe

class ProblemController {
	
	// Get security service reference via dependency injection
	def springSecurityService

    static navigation = [
        [group: 'dashboard', order:97, title:'Report Problem', action: 'report', isVisible: { springSecurityService.isLoggedIn() }],
        ]

	def report = {
		redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/issues/new')
	}
	
	
}
