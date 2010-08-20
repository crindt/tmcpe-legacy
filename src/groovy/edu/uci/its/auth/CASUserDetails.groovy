package edu.uci.its.auth

import java.util.Collection;

import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserDetailsService;
import org.springframework.dao.DataAccessException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser;

class CASUserDetails extends GrailsUser implements UserDetails{
	
	private final long _id;
	private final String _username;
	
	public CASUserDetails(
		String username, String password, boolean enabled,
		boolean accountNonExpired, boolean credentialsNonExpired,
		boolean accountNonLocked,
		Collection<? extends GrantedAuthority> authorities) {
		super(username, password, enabled, accountNonExpired,
		credentialsNonExpired, accountNonLocked, authorities, 0);
		// TODO Auto-generated constructor stub
		_id = id
		_username=username
	}
	
	public Object getDomainClass() {
		return null
	}
	
}
