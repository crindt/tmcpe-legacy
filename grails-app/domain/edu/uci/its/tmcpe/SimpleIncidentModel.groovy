package edu.uci.its.tmcpe

class SimpleIncidentModel {

	String id

	List criticalEvents

	List cumulativeFlows

	Float conversionFactor

	Float totalDiversion
	Float tmcDiversion
	Float modeledDelay 
	Float tmcSavings

	String cad
	String facility
	String direction

	Map stats

	Map params

	static mapWith = 'mongo'
    static constraints = {
		cad index:true, indexAttributes: [unique:true, dropDups:true]
    }
}
