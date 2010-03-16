security {

	// see DefaultSecurityConfig.groovy for all settable/overridable properties

	active = true
	loginUserDomainClass = "edu.uci.its.auth.TestbedUser" 
	authorityDomainClass = "edu.uci.its.auth.TestbedRole"
	requestMapClass = "edu.uci.its.auth.TmcpeRequestmap"

    userName = 'username'
    usernameFieldName = 'username'
    password = 'passwd'
    relationalAuthorities = 'authorities'
    authorityField = 'authority'
    
    useRequestMapDomainClass = false
    useControllerAnnotations = true
    useCAS = true
}


environments {
    development {
        security {
            cas.casServer = 'parsons.its.uci.edu'
            cas.casServerPort = '443'
            cas.fullLoginURL = 'https://parsons.its.uci.edu/cas/login'
            cas.fullServiceURL = 'https://parsons.its.uci.edu/cas'
            cas.server.port=443
            cas.server.host="parsons.its.uci.edu"
            cas.localhostSecure = false
            cas.authenticationProviderKey = 'cas_key_test_grails'
            cas.proxyReceptorUrl = null
        }
    }
    production {
        security {
            cas.fullLoginURL = 'https://parsons.its.uci.edu/cas/login'
            cas.fullServiceURL = 'https://parsons.its.uci.edu/cas'
            cas.server.port=443
            cas.server.host="parsons.its.uci.edu"
            cas.localhostSecure = false
            cas.authenticationProviderKey = 'cas_key_test_grails'
            cas.proxyReceptorUrl = null
        }
    }
}
