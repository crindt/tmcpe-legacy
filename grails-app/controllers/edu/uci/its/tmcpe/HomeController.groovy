package edu.uci.its.tmcpe

class HomeController {

    static navigation = [
        [group: 'tabs', order:1, title:'Home', action: 'index'],
        [group: 'tabs', order:98, title:'Report Problem', id: 'problemButton', action: 'report'],
        [group: 'tabs', order:99, title:'Help', action: 'help']
        ]

    def report = {
        redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/issues/new')
    }

    def help = {
        redirect(target:"_blank", url:'http://localhost/redmine/projects/tmcpe/wiki/User_Guide')
    }

    def index = {

        def types = Incident.executeQuery("select distinct i.eventType from Incident i")

        log.info( "****TYPES****" + types )

        def stats = [:]
        def df = new java.text.SimpleDateFormat( "MM/dd/yyyy" )

        types.each() { typ ->
            log.info( typ + " ::::: " + typ.class )
            def tt = Incident.executeQuery( "select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i where i.eventType = '" + typ + "'" )
            def ta = Incident.executeQuery("select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i where i.eventType = '" + typ + "' AND i.analyses.size > 0" )
            stats[typ] = [
                "tot": tt[0],
                "analyzed": ta[0]
            ]
        }
        log.info( stats )

        stats["tot"] = [
            "tot": Incident.executeQuery("select distinct count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i" )[0],
            "analyzed": Incident.executeQuery("select distinct  count(i.cad),min( i.startTime ), max( i.startTime ) from Incident i where i.analyses.size > 0" )[0]
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
