package edu.uci.its.auth

import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserDetailsService
import org.springframework.dao.DataAccessException
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.ldap.userdetails.LdapUserDetailsService
import org.springframework.security.ldap.userdetails.LdapAuthoritiesPopulator
import org.springframework.security.ldap.search.LdapUserSearch



class MyLdapUserDetailsService extends LdapUserDetailsService implements GrailsUserDetailsService {
	
	public UserDetails loadUserByUsername(String username)
	throws UsernameNotFoundException, DataAccessException {
                UserDetails ud = super.loadUserByUsername( username );
		String pw = ud.getPassword();
		if ( pw == null || "".equals( pw ) )
			pw = "*secret*";
		return new MyLdapUserDetails( ud.getUsername(), pw, ud.isEnabled(), ud.isAccountNonExpired(), ud.isCredentialsNonExpired(), ud.isAccountNonLocked(), ud.getAuthorities() );
	}
	
	public UserDetails loadUserByUsername(String username, boolean loadRoles /* ignored */ )
	throws UsernameNotFoundException, DataAccessException {
		// TODO Auto-generated method stub
                return super.loadUserByUsername( username )
	}

    public MyLdapUserDetailsService(LdapUserSearch userSearch ) {
        super( userSearch )
    }

    public MyLdapUserDetailsService(LdapUserSearch userSearch, LdapAuthoritiesPopulator authoritiesPopulator) {
        super( userSearch, authoritiesPopulator )
    }

}
