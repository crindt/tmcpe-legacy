package edu.uci.its.auth

import org.codehaus.groovy.grails.validation.Validateable

// A dummied up User class we'll fill from CAS

@Validateable
class User {

	String username
	String password
	boolean enabled
	boolean accountExpired
	boolean accountLocked
	boolean passwordExpired
	Set<Role> authorities
	
	
	static constraints = {
		username(blank:false, unique:true)
	}

	static mapping = {
	  table name: 'users'
	}

}
