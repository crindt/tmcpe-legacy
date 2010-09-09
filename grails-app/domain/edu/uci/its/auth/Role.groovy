package edu.uci.its.auth

import org.codehaus.groovy.grails.validation.Validateable
import org.springframework.security.core.GrantedAuthority;

@Validateable
class Role implements GrantedAuthority {

	String authority
	static constraints = {
		authority blank: false, unique: true
	}
	
	public Role(String authority) {
		super();
		this.authority = authority;
	}
	public Role() {
		super();
		this.authority = "ROLE_ANY";
	}

}
