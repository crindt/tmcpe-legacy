package edu.uci.its.tmcpe

class IncidentImpactAnalysisService {

    boolean transactional = true

    static scope = "request"

    void analyzeIncidentImpact( Incident i,
                               // should have parameters here that define the incident analysis,
                               // we'll just use name for now
                               String name
                               )
    {
        log.debug "In AnalysisService"

//        if ( i == null ) return

        // theoretically, an 

        // *** grab copy of existing incident analyses for this incident
        def analyses = IncidentImpactAnalysis.findByIncidentAndAnalysisName( i, name )

//        log.debug "Deleting " + analyses?.size() + " analyses of incident " + i + " named " + name

        // delete them, we'll create a new version
        analyses.each { it.delete() }
      


        // *** analyze immediate impact

        IncidentImpactAnalysis analysis = new IncidentImpactAnalysis( analysisName: name, incident: i )
        log.debug "Created new analysis"


        IncidentFacilityImpactAnalysis facilityAnalysis = new IncidentFacilityImpactAnalysis()

        // Select incident region, starting from location

        // compute max shockwave speed

        // compute max upstream distance based upon incident duration
        Float maxQueueLength = 10f    // currently, this is a hack

        // Get a list of all facility sections matching criteria

        def results
        def c = FacilitySection.createCriteria()

        // postmiles ascend northbound and eastbound
        if ( i.section.freewayDir == "N" || i.section.freewayDir == "E" )
        {
            log.debug "Searching for sections on ${i.section.freewayDir} ${i.section.freewayId} between [${i.section.absPostmile-10f}, ${i.section.absPostmile+0.5f}]"
            results = c.list {
                eq ( "freewayId", i.section.freewayId )
                eq ( "freewayDir", i.section.freewayDir )
                eq ( "vdsType", "ML" )
                between( "absPostmile", i.section.absPostmile-10f, i.section.absPostmile+0.5f )
                order( "absPostmile", "asc" )
            }
        } 
        else
        {
            log.debug "Searching for sections on ${i.section.freewayDir} ${i.section.freewayId} between [${i.section.absPostmile-0.5f}, ${i.section.absPostmile+10f}]"
            results = c.list {
                eq ( "freewayId", i.section.freewayId )
                eq ( "freewayDir", i.section.freewayDir )
                eq ( "vdsType", "ML" )
                between( "absPostmile", i.section.absPostmile-0.5f, i.section.absPostmile+10f )
                order( "absPostmile", "desc" )
            }
        }

        results.each { facilityAnalysis.addToPossibleFacilitySection( it ) }

        facilityAnalysis.incidentImpactAnalysis = analysis

        log.debug "Created new facility analysis" + facilityAnalysis



        analysis.addToIncidentFacilityImpactAnalyses( facilityAnalysis )

        log.debug "Added to " + analysis



        // Now add reverse direction
        def facilityAnalysis2 = new IncidentFacilityImpactAnalysis()
        def results2
        c = FacilitySection.createCriteria()
        def facility = i.section.freewayId
        def dir = i.section.freewayDir
        switch ( dir ) {
            case 'N': dir = 'S'; break
            case 'S': dir = 'N'; break
            case 'E': dir = 'W'; break
            case 'W': dir = 'E'; break
        }

        // postmiles ascend northbound and eastbound
        if ( dir == "N" || dir == "E" )
        {
            log.debug "Searching for sections on ${dir} ${facility} between [${i.section.absPostmile-10f}, ${i.section.absPostmile+0.5f}]"
            results2 = c.list {
                eq ( "freewayId", facility )
                eq ( "freewayDir", dir )
                eq ( "vdsType", "ML" )
                between( "absPostmile", i.section.absPostmile-10f, i.section.absPostmile+0.5f )
                order( "absPostmile", "asc" )
            }
        } 
        else
        {
            log.debug "Searching for sections on ${dir} ${facility} between [${i.section.absPostmile-0.5f}, ${i.section.absPostmile+10f}]"
            results2 = c.list {
                eq ( "freewayId", facility )
                eq ( "freewayDir", dir )
                eq ( "vdsType", "ML" )
                between( "absPostmile", i.section.absPostmile-0.5f, i.section.absPostmile+10f )
                order( "absPostmile", "desc" )
            }
        }
        
        log.debug "Found ${results2?.size()} sections"

        results2.each { facilityAnalysis2.addToPossibleFacilitySection( it ) }

        facilityAnalysis2.incidentImpactAnalysis = analysis

        log.debug "Created reverse facility analysis" + facilityAnalysis2

        analysis.addToIncidentFacilityImpactAnalyses( facilityAnalysis2 )

        log.debug "Added to " + analysis + ".  Total now = ${analysis.incidentFacilityImpactAnalyses?.size()}."

        try {

            if ( !analysis.save(flush:true) )
            {
                log.error "=====Failed to save:"
                analysis.errors.each {
                    log.error "\t" + it
                }
            } 
            else 
            {
                log.debug "Saved " + analysis + " [id = " + analysis.id + "]"
                
                def iia = IncidentImpactAnalysis.findByIncident( i )
                log.debug "Total number of analyses for incident ${i} = ${iia?.size()}"
            }
        }
        catch(Exception e) {
            // deal with exception
            log.error "=====Failed to save: ${e}"
        }
        
        return
    }
}
