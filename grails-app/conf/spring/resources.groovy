import net.ctmlabs.CasUserDetailsService

// Place your Spring DSL code here
beans = {
	// Use our own user details server to pull in CAS details
    authenticationUserDetailsService(CasUserDetailsService)
}
