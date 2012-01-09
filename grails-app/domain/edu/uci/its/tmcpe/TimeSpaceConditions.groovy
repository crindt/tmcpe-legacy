/* @(#)TimeSpaceConditions.groovy
 */
/**
 * 
 *
 * @author <a href="mailto:crindt@gmail.com">Craig Rindt</a>
 */
package edu.uci.its.tmcpe

public class TimeSpaceConditions { 
	String id
	List spds
	List flows
	List occs
	List incidents   // incident flag for each time-space cell

        //static mapWith = 'mongo'
	static embedded = ['spds','flows','occs']
	static constraints = { 
		spds(validator: { val, obj -> 
			val != null &&
			val.size > 0               &&
			val.size == obj.flows.size &&
			val.size == obj.occs.size  &&
			val[0].size > 0            &&
			// make sure each row is the same size
			val.findAll{ row -> row.size == val[0].size }.size==val.size
			 })
		flows(validator: { val, obj -> 
			val != null &&
			val.size > 0               && 
			val.size == obj.spds.size  && 
			val.size == obj.occs.size  && 
			val[0].size > 0			   && 
			val.findAll{ row -> row.size == val[0].size }.size==val.size
			  })
		occs(validator: { val, obj -> 
			val != null &&
			val.size > 0               && 
			val.size == obj.flows.size && 
			val.size == obj.occs.size  && 
			val[0].size > 0			   && 
			val.findAll{ row -> row.size == val[0].size }.size==val.size
			 })
		incidents(validator: { val, obj -> 
			val != null &&
			val.size > 0               && 
			val.size == obj.spds.size  && 
			val.size == obj.flows.size && 
			val.size == obj.occs.size  && 
			val[0].size > 0			   && 
			val.findAll{ row -> row.size == val[0].size }.size==val.size
			 })
	}

	def dimensions() { 
		assert spds.size > 0
		return [spds.size,spds[0].size]
	}
}
