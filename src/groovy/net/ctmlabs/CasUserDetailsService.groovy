package net.ctmlabs

import org.springframework.security.core.userdetails.User
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser
import org.springframework.security.core.GrantedAuthority

import org.springframework.security.cas.userdetails.GrantedAuthorityFromAssertionAttributesUserDetailsService
import org.springframework.security.core.authority.GrantedAuthorityImpl
import org.springframework.security.cas.userdetails.AbstractCasAssertionUserDetailsService
import org.springframework.security.core.userdetails.UserDetails
import org.jasig.cas.client.validation.Assertion
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils

class CasUserDetailsService extends AbstractCasAssertionUserDetailsService {
    private static final List NO_ROLES = [new GrantedAuthorityImpl(SpringSecurityUtils.NO_ROLE)]

    // Custom attribute names that should be mapped over into Spring Security roles
    private static final String[] authorityAttribNamesFromCas = ["groups"]

    private GrantedAuthorityFromAssertionAttributesUserDetailsService grantedAuthoritiesService = new GrantedAuthorityFromAssertionAttributesUserDetailsService(authorityAttribNamesFromCas)

    @Override
    protected UserDetails loadUserDetails(Assertion casAssert) {
		def casAuthorities = []
        casAssert.principal.attributes.each { key, value ->
            log.info("CUSTOM ATTRIBUTE FROM CAS: ${key} = ${value}")
            // TODO - do something intelligent with the attributes

			if ( key == 'groups' ) { 
				log.info("SHOWING GROUPS:")
				def m = value =~ /cn=([^,]+),ou=groups,dc=ctmlabs,dc=org/
				def roles = [:]
				m.each {
					def role = "ROLE_${it[1].toUpperCase()}"
					roles[role] = role
				}
				roles.each { k, v -> 
					log.info( "ADDING TO GROUP ${k}")
					casAuthorities.add(new GrantedAuthorityImpl(k))
				}
			}
        }

        // Load the authorities from CAS
		/*
        def casUser = grantedAuthoritiesService.loadUserDetails(casAssert)
        def casAuthorities = casUser.authorities ?: NO_ROLES
		*/

		casAuthorities.each { 
			log.info("AUTHORITY: ${it}")
		}

        def casUsername = casAssert.getPrincipal().getName()
		/* IGNORE LOCAL USER FOR NOW
        def localUser = User.findByUsername(casUsername)

        //Create the user profile if it does not already exist
        if (!localUser) {
            localUser = new User(username: casUsername)
        }
		*/

        return new GrailsUser(casUsername, "no_password", true, true, true, true, casAuthorities, /*localUser.id*/-1)
    }
}

/*
class CasUserDetailsService extends AbstractCasAssertionUserDetailsService {
    private static final List NO_ROLES = [new GrantedAuthorityImpl(SpringSecurityUtils.NO_ROLE)]

    // Custom attribute names that should be mapped over into Spring Security roles
    private static final String[] authorityAttribNamesFromCas = ["cas_authority"]

    private GrantedAuthorityFromAssertionAttributesUserDetailsService grantedAuthoritiesService = new GrantedAuthorityFromAssertionAttributesUserDetailsService(authorityAttribNamesFromCas)

    @Override
    protected UserDetails loadUserDetails(Assertion casAssert) {
        casAssert.principal.attributes.each { key, value ->
            log.info("CUSTOM ATTRIBUTE FROM CAS: ${key} = ${value}")
            // TODO - do something intelligent with the attributes
        }

        def casUsername = casAssert.getPrincipal().getName()
        def localUser = CtmlabsUser.findByUsername(casUsername)

        //Create the user profile if it does not already exist
        if (!localUser) {
            localUser = new CtmlabsUser(username: casUsername)
        }

        // Load the authorities from CAS
        def casUser = grantedAuthoritiesService.loadUserDetails(casAssert)
        def casAuthorities = casUser.authorities ?: NO_ROLES

		return new CtmlabsUser(username: casUser.username,
							   password: "no_password",
							   authorities: casAuthorities,
							   id: localUser.id )
    }
}
*/