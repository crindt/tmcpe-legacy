package edu.uci.its.tmcpe

import groovy.time.*

class IncidentResponse {

    String id

    CriticalEvent t0Onset
    CriticalEvent t1Verification
    CriticalEvent t2CapacityRestored
    CriticalEvent t3FullRestoration

	CriticalEvent others = []

    static mapWith = "mongo"
	static transients = ['verificationTime','clearanceTime','restorationTime']
    static constraints = {
        t0Onset validator: { val, obj ->
            val.stamp <= obj.t1Verification.stamp || obj.t1Verification == null
        }
        t1Verification validator: { val, obj ->
            val.stamp <= obj.t2CapacityRestored.stamp || obj.t2CapacityRestored == null
        }
        t2CapacityRestored validator: { val, obj ->
            val.stamp <= obj.t3Clear.stamp || obj.t3Clear == null
        }
    }

	public TimeDuration getVerificationTime() { 
		return t1Verification.stamp - t0Onset
	}

	public TimeDuration getClearanceTime() { 
		return t2CapacityRestored.stamp - t0Onset
	}

	public TimeDuration getRestorationTime() { 
		return t3FullRestoration.stamp - t0Onset
	}

    public String toString() { 
        return "${t0Onset}, ${t1Verification}, ${t2CapacityRestored},${t3Clear}"
    }

	static class CriticalEvent { 
		Date stamp = new Date()
		def what   = "UNKNOWN"
		def source = "UNKNOWN"

		public CriticalEvent( Date theStamp ) { 
			stamp  = theStamp
		}

		String toString() { 
			return "${what} @ ${stamp}"
		}
	}
    
}
