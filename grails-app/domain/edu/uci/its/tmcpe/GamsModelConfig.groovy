package edu.uci.its.tmcpe

import grails.validation.Validateable

@Validateable
class GamsModelConfig {

	Integer resourceLimit   = 300

	FacilitySection section
	Integer sectionId               // vdsid
	
	Float   weightForLength        = 1    // How much to weight section length by (set to 1)
	Float   weightForDistance      = 3    // Exponent to reduce the importance
										  // of evidence further from the
										  // incident start
	Float   bias                   = 0.0f // tuning factor for objective function (set to zero)
	Float   limitLoadingShockwave  = 20   // mi/hr
	Float   limitClearingShockwave = 60   // mi/hr
	Integer preWindow              = 10   // time in minutes to consider before reported incident start
	Integer postWindow             = 120  // time minutes after incident start to initially model

	Float band                     = 1    // number of spd stddevs below which a section is evidence of incident
	Integer minAvgDays             = 20   // minimum number of days for valid annual data
	Float   minObsPct              = 5
	Float maxIncidentSpeed         = 60

	static transients = ['section']

    static constraints = {
		preWindow(min: 0)
		postWindow(min: 0)
		section(nullable:true)                // FIXME: shouldn't be nullable
		resourceLimit(nullable:false,min:1)   // 1 second minimum
		bias(nullable:false)
    }

    public String toString() {
		return "[" + ["resourceLimit","section","weightForLength","weightForDistance",
					  "bias","limitLoadingShockwave","limitClearingShockwave",
					  "preWindow","postWindow"].collect{ "${it}:"+this."$it" }.join(",") + "]"
    }
}
