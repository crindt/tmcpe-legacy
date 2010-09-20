/**
 * 
 */
package edu.uci.its.auth

import org.springframework.security.core.GrantedAuthority;
import org.springframework.ldap.core.ContextSource;
import org.springframework.security.ldap.userdetails.DefaultLdapAuthoritiesPopulator;
//import org.springframework.security.ldap.userdetails.LdapUserDetails;
import org.springframework.ldap.core.DirContextOperations;


/**
 * @author crindt
 *
 */
class CtmlabsLdapAuthoritiesPopulator extends DefaultLdapAuthoritiesPopulator {
	
	/**
	 * @param contextSource
	 * @param groupSearchBase
	 */
	public CtmlabsLdapAuthoritiesPopulator(ContextSource contextSource,
	String groupSearchBase) {
		super(contextSource, groupSearchBase);
	}
	
	public Set<GrantedAuthority> getGroupMembershipRoles( String userDn, String username )
	{
		super.getGroupMembershipRoles(userDn, username)
	}
	
	/**
	 * Create additional roles as necessary
	 * 
	 * In this case, we'll create additional roles based upon position in the organization.  
	 * If a user is in the d12 TMC, they'll be granted special role membership.
	 * @param user
	 * @param username
	 * @return
	 */
	protected Set<GrantedAuthority> getAdditionalRoles(DirContextOperations user, String username) {
		// NOT IMPLEMENTED YET
		return null;
	}


	
}
