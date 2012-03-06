import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.codehaus.groovy.grails.plugins.springsecurity.ldap.SimpleAuthenticationSource
//import org.springframework.security.ldap.userdetails.DefaultLdapAuthoritiesPopulator
import edu.uci.its.auth.CtmlabsLdapAuthoritiesPopulator

import org.springframework.ldap.core.support.SimpleDirContextAuthenticationStrategy
import org.springframework.security.ldap.DefaultSpringSecurityContextSource
import org.springframework.security.ldap.authentication.BindAuthenticator
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider
import org.springframework.security.ldap.authentication.PasswordComparisonAuthenticator
import org.springframework.security.ldap.search.FilterBasedLdapUserSearch
import org.springframework.security.ldap.userdetails.InetOrgPersonContextMapper
import org.springframework.security.ldap.userdetails.LdapUserDetailsMapper
import edu.uci.its.auth.MyLdapUserDetailsService


	
def conf = SpringSecurityUtils.securityConfig
SpringSecurityUtils.loadSecondaryConfig 'DefaultCasSecurityConfig'
SpringSecurityUtils.loadSecondaryConfig 'DefaultLdapSecurityConfig'
// have to get again after overlaying DefaultLdapSecurityConfig
conf = SpringSecurityUtils.securityConfig

Class<?> contextFactoryClass = Class.forName(conf.ldap.context.contextFactoryClassName) // com.sun.jndi.ldap.LdapCtxFactory
Class<?> dirObjectFactoryClass = Class.forName(conf.ldap.context.dirObjectFactoryClassName) // org.springframework.ldap.core.support.DefaultDirObjectFactory


// Place your Spring DSL code here
beans = {

    // We want to look up user details using LDAP---not the GormUserDetailsService!
	contextSource(DefaultSpringSecurityContextSource, conf.ldap.context.server) {
		userDn = conf.ldap.context.managerDn
		password = conf.ldap.context.managerPassword
		contextFactory = contextFactoryClass
		dirObjectFactory = dirObjectFactoryClass
		baseEnvironmentProperties = conf.ldap.context.baseEnvironmentProperties // none
		cacheEnvironmentProperties = conf.ldap.context.cacheEnvironmentProperties // true
		anonymousReadOnly = conf.ldap.context.anonymousReadOnly // false
		referral = conf.ldap.context.referral // null
		authenticationSource = ref('ldapAuthenticationSource')
	}

	ldapAuthenticationSource(SimpleAuthenticationSource) {
		userDn = conf.ldap.context.managerDn
		password = conf.ldap.context.managerPassword
	}

	String[] searchAttributesToReturn = toStringArray(conf.ldap.search.attributesToReturn) // null - all
	ldapUserSearch(FilterBasedLdapUserSearch, conf.ldap.search.base, conf.ldap.search.filter, ref('contextSource')) {
		searchSubtree = conf.ldap.search.searchSubtree // true
		derefLinkFlag = conf.ldap.search.derefLink // false
		searchTimeLimit = conf.ldap.search.timeLimit // 0 (unlimited)
		returningAttributes = searchAttributesToReturn
	}
	
	ldapAuthoritiesPopulator(CtmlabsLdapAuthoritiesPopulator, ref( 'contextSource' ), conf.ldap.authorities.groupSearchBase ) {
		groupSearchFilter = conf.ldap.authorities.ldapGroupSearchFilter
		defaultRole = "ROLE_USER"  // make sure all authenticated users belong to ROLE_USER, the most basic role
	}


    userDetailsService(MyLdapUserDetailsService,ref('ldapUserSearch'),ref('ldapAuthoritiesPopulator'))
}
