package edu.uci.its.tmcpe

class SimpleIncidentModel {

	String id

	List criticalEvents

	List cumulativeFlows

	Float totalDiversion
	Float tmcDiversion
	Float modeledDelay 
	Float tmcSavings

	Map stats

	static mapWith = 'mongo'
    static constraints = {
    }
}
