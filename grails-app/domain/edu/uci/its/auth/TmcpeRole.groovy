package edu.uci.its.auth

import edu.uci.its.auth.TmcpeUser

/**
 * Authority domain class.
 */
class TmcpeRole {

	static hasMany = [people: TmcpeUser]

	/** description */
	String description
	/** ROLE String */
	String authority

	static constraints = {
		authority(blank: false, unique: true)
		description()
	}
}
