package edu.uci.its.auth

/**
 * TestbedUser domain class.
 */
class TestbedUser {
	static transients = ['pass']
	static hasMany = [authorities: TestbedRole]
	static belongsTo = TestbedRole

	/** Username */
	String username
	/** User Real Name*/
	String userRealName
	/** MD5 Password */
	String passwd
	/** enabled */
	boolean enabled

	String email
	boolean emailShow

	/** description */
	String description = ''

	/** plain password to create a MD5 password */
	String pass = '[secret]'

	static constraints = {
		username(blank: false, unique: true)
		userRealName(blank: false)
		passwd(blank: false)
		enabled()
	}
}
