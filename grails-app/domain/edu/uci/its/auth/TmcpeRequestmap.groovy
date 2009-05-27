package edu.uci.its.auth

/**
 * Request Map domain class.
 */
class TmcpeRequestmap {

	String url
	String configAttribute

	static constraints = {
		url(blank: false, unique: true)
		configAttribute(blank: false)
	}
}
