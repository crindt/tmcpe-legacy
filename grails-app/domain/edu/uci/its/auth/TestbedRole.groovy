package edu.uci.its.auth

/**
 * Authority domain class.
 */
class TestbedRole {

	static hasMany = [people: TestbedUser]

	/** description */
	String description
	/** ROLE String */
	String authority

	static constraints = {
		authority(blank: false, unique: true)
		description()
	}
}
