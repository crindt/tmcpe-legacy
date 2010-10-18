package edu.uci.its.tmcpe

class HomeController {

    static navigation = [
        [group: 'tabs', order:1, title:'Home', action: 'index'],
        ]

    def index = {

        def types = Incident.executeQuery("select distinct i.eventType from Incident i")

        log.info( "****TYPES****" + types )

        def stats = [:]
        def df = new java.text.SimpleDateFormat( "MM/dd/yyyy" )

        types.each() { typ ->
//            log.info( typ + " ::::: " + typ.class )
            def tt = Incident.executeQuery( "select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i where i.eventType = '" + typ + "'" )
//            def ta = Incident.executeQuery("select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i where i.eventType = '" + typ + "' AND i.analyses.size > 0" )
            def ta = IncidentFacilityImpactAnalysis.executeQuery("select count(ifia.incidentImpactAnalysis.incident),min( ifia.incidentImpactAnalysis.incident.startTime ), max( ifia.incidentImpactAnalysis.incident.startTime ),sum(ifia.netDelay) from IncidentFacilityImpactAnalysis ifia where ifia.incidentImpactAnalysis.incident.eventType = '" + typ + "'" )
            stats[typ] = [
                "tot": tt[0],
                "analyzed": ta[0][0],
                "delay": ta[0][3],
                "savings": 0
            ]
        }
        log.info( stats )

        def ta = IncidentFacilityImpactAnalysis.executeQuery("select count(ifia.incidentImpactAnalysis.incident),min( ifia.incidentImpactAnalysis.incident.startTime ), max( ifia.incidentImpactAnalysis.incident.startTime ),sum(ifia.netDelay) from IncidentFacilityImpactAnalysis ifia" )
        def ta2 = IncidentFacilityImpactAnalysis.executeQuery("select count(ifia.incidentImpactAnalysis.incident),sum(ifia.netDelay) from IncidentFacilityImpactAnalysis ifia" )
        stats["tot"] = [
            "tot": Incident.executeQuery("select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i" )[0],
            "analyzed": ta[0],
            "delay": ta2[0][1],
            "savings": 0
            ]
/*
        stats.values().each() { 
            log.info( ">>>>>>>>>>>>>>" + it )
            it.analyzed[1..2].collect({ val -> 
                                          log.info( "VAL: " + val )
                                          df.format( val ) })
        }
*/

        return [ 
            test: 'test', 
            stats: stats
        ]
    }
}
