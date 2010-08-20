package edu.uci.its.auth

import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserDetailsService
import org.springframework.dao.DataAccessException
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.GrantedAuthority;


class CASUserDetailsService implements GrailsUserDetailsService {
	
	public UserDetails loadUserByUsername(String username)
	throws UsernameNotFoundException, DataAccessException {
		Collection<GrantedAuthority> ss = new ArrayList<GrantedAuthority>()
		ss.add( new Role( "ROLE_ADMIN" ) )
		return new CASUserDetails( username, "", true, true, true, true, ss )
	}
	
	public UserDetails loadUserByUsername(String username, boolean loadRoles)
	throws UsernameNotFoundException, DataAccessException {
		// TODO Auto-generated method stub
		return loadUserByUsername( username )
	}
}
