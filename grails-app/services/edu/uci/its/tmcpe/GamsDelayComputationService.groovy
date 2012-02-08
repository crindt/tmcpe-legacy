package edu.uci.its.tmcpe

import org.apache.commons.logging.LogFactory
import groovy.text.GStringTemplateEngine
import groovy.sql.Sql
import java.sql.SQLException;
import grails.converters.JSON

import java.security.MessageDigest // for md5sum

class GamsDelayComputationService {

	static datasource = 'vds_partitioned'
	static dataSource_vds_partitioned

    private static final log = LogFactory.getLog(this)

    static transactional = true

	def toFivemin(Date da) { 
		def cal = new GregorianCalendar()
		cal.time = da
		cal.set(Calendar.MINUTE, (int)Math.floor(cal.get(Calendar.MINUTE)/5)*5)
		cal.set(Calendar.SECOND, 0 )
		return cal.time
	}

	/**
	 * Create an IFPA object for a given section
	 *
	 * This should contain all necessary configuration parameters and data to run an analysis
	 */
	public IncidentFacilityPerformanceAnalysis generateAnalysis( 
		ProcessedIncident pi,
		GamsModelConfig config = new GamsModelConfig()
	) {
		def ifpa = new IncidentFacilityPerformanceAnalysis( config )
		// generate the input data

		assert pi != null
		assert ifpa.modelConfig != null

		ifpa.cad = pi.cad
		ifpa.modelConfig.section = pi.section
		ifpa.modelConfig.sectionId = pi.section.id
		ifpa.facility = pi.section.freewayId
		ifpa.direction = pi.section.freewayDir

		// override existing and defaults with passed config
		/*
		config.each{ key, value ->
			if ( ifpa.modelConfig.metaClass.hasProperty( ifpa, key ) ) {
				ifpa.modelConfig[ key ] = value
				log.info( "OVERRIDING modelConfig[${key}] = ${value}" )
			}
		}
		*/

		// grab sections adjacent and upstream from the target (possibly
		// based upon params
		// ifpa.sections[i] = { vdsid: , name: , pm: }
		
		// FIXME: should order 0->n downstream to upstream

		// pm on NB and EB facilities increase downstream, so 
		// we want to query between [incloc - (maxdist) ] and incloc
		def low
		def high
		if ( pi.section.freewayDir =~ /[NE]/ ) {
			low = pi.section.absPostmile  - 10 // look 10 mi US
			high = pi.section.absPostmile + 0.5 // look 0.5 mi DS
		} else {
			low = pi.section.absPostmile - 0.5 // look 0.5 mi DS
			high = pi.section.absPostmile + 10 // look 10 mi US
		}
		
		def sections = FacilitySection.withCriteria {
			eq('freewayId', pi.section.freewayId)
			eq('freewayDir', pi.section.freewayDir)
			eq('vdsType', 'ML')
			between('absPostmile',low,high)
		}
		
		// FIXME: make sure they're ordered correctly...
		ifpa.sections = sections.toList().collect { 
			[ vdsid: it.id, name: it.name, pm: it.absPostmile, len:it.segmentLength]
		}

		use ([groovy.time.TimeCategory]) {
			// determine the timesteps based upon params
			def startTimestamp = toFivemin(pi.startTime ?: new Date() /* default to now */ )
			def fromTime = startTimestamp - (ifpa.modelConfig.preWindow).minutes
			Integer timestepCount = ((ifpa.modelConfig.preWindow+ifpa.modelConfig.postWindow)/5)
			def toTime   = fromTime + (5*timestepCount).minutes
			ifpa.timesteps = (0..timestepCount).collect{ tsi ->
				fromTime + (tsi*5).minutes
			}
			
			// read the observed and average conditions from the database
			ifpa.obsConditions = []
			ifpa.avgConditions = []
			def sql = new Sql( dataSource_vds_partitioned )
			sections.eachWithIndex { sec, j ->
				// pull data from the database for the time range
				log.info("READING DATA FOR ${sec}")
				def m = 0
				ifpa.obsConditions[j] = []
				ifpa.avgConditions[j] = []
				sql.eachRow( 
					"select * from query_5min_obs_avg( ${sec.id}, CAST(${fromTime.format('yyyy-MM-dd HH:mm:ss')} AS timestamp), CAST(${toTime.format('yyyy-MM-dd HH:mm:ss')} AS timestamp), 50 )") {
					//log.info( "${it.vds_id} ($j), ${it.ts} ($m), ${it.obs_cnt_all}" )
					def pjm = 0.5  // unknown
					if ( it.avg_n >= ifpa.modelConfig.minAvgDays && it.pct_obs_all >= ifpa.modelConfig.minObsPct) { 
						if ( it.obs_spd_all != null ) { 
							if ( it.obs_spd_all < ( it.avg_spd_all - ifpa.modelConfig.band * it.std_spd_all )

								 // we won't flag speeds over some maximum as incidents,
								 // regardless of their relationship to averages
								 && ( it.obs_spd_all <= ifpa.modelConfig.maxIncidentSpeed ) 
							   ) { 
								pjm = 0.0
							} else { 
								pjm = 1.0
							}
						}
					}
								 
					ifpa.obsConditions[j][m] = [vol: it.obs_cnt_all, occ: it.obs_occ_all, spd: it.obs_spd_all, p:pjm]
					ifpa.avgConditions[j][m] = [vol: it.avg_cnt_all, occ: it.avg_occ_all, spd: it.avg_spd_all]
					m++
				}
			}
		}

		log.info( "IFPA.modelConfig: ${ifpa.modelConfig}" )

		return ifpa
	}


    /**
     * The main interface to the service
     *
     * GIVEN: 
	 *    * A facility section where the disruption is believed to have occured
	 *    * A startTime when the disruption is believed to have begun
	 *    * Any configuration parameters on the model
	 *
	 * THEN:
	 *    * Generate necessary input files
	 *    * Sync the files to the remote server
	 *    * Run the remote GAMS service to compute the incident boundary and delay, 
	 *    * Parse the results
     */
	public IncidentFacilityPerformanceAnalysis computeIncidentFacilityPerformance(
		ProcessedIncident pi,
		GamsModelConfig config = new GamsModelConfig()
	) {
		return computeIncidentFacilityPerformance( generateAnalysis( pi, config ) )
	}

    public IncidentFacilityPerformanceAnalysis computeIncidentFacilityPerformance( 
		IncidentFacilityPerformanceAnalysis ifpa
	) {
		assert ifpa != null

        // At this point, we need to iterate until termination conditions are met
        while( !ifpa.modelIsOptimal() /* && terminationCriteriaAreNotMet */ ) {			

            // generate the model params
            if ( ifpa.modelParams == null ) {
                generateModelParams( ifpa )
            } else {
				// if we have results, determine failure reason and update params as necessary
			}			

            // create datafile
            def gms = createGamsData(ifpa)

            // execute
			Map serverConfig = [:]
            serverConfig.infile = gms
			serverConfig.destroyExisting = true
            def re = new RemoteExecutor(serverConfig)
            re.execute()

            // parse the results
			parseLstData( re.outfile, ifpa )
            //ifpa = parseGamsResults( re.infile, re.outfile, ifpa )

            // validate
        }

        return ifpa
    }

    public IncidentFacilityPerformanceAnalysis parseGamsResults(File gms, File lst, Object ifpa = new IncidentFacilityPerformanceAnalysis() ) { 
        parseGamsData(gms,ifpa)
		if ( !ifpa.validate() ) { 
			backfillLegacyData( gms, ifpa )
		}
        parseLstData(lst,ifpa)
        return ifpa
    }


    /**
     * Generate a GAMS input file
     */
    def createGamsData( 
        IncidentFacilityPerformanceAnalysis ifpa,

        // FIXME: crindt: select an appropriate directory for this
        File gms = null
    ) { 

		// make sure that cad, facility, and direction are set
		if ( ifpa.facility == null && ifpa.modelConfig?.section != null ) {
			// see if we can set it from section
			ifpa.facility = ifpa.modelConfig.section.freewayId
		}
		if ( ifpa.direction == null && ifpa.modelConfig?.section != null ) {
			ifpa.direction = ifpa.modelConfig.section.freewayDir
		}

		if ( gms == null ) gms = new File("data/newcomp/${ifpa.cad}-${ifpa.facility}=${ifpa.direction}.gms" )

        if ( !ifpa.validate() ) {
			throw new RuntimeException("IFPA not valid because [\n"+ifpa.errors.allErrors.join("\n")+"\n]")
		}

        // use ifpa to specify conditions
        def f = new File('test/data/tst.gms.template')  // FIXME: crindt: this template should reside elsewhere (e.g., webapp/templates)
        def engine = new GStringTemplateEngine()

        //println ifpa.properties
		def jsonstr = new JSON( target: ifpa.modelConfig ).toString()
		log.info("JSON:${jsonstr}")
        def template = engine.createTemplate(f).make([ifpa:ifpa.properties,modelConfigStr: jsonstr,incstartIndex:ifpa.modelConfig.preWindow/5])

        // the newWriter call destroys the existing gms file
        def w = gms.newWriter() 
        w << template.toString()
        w.close()

        return gms
    }

    def generateModelParams(IncidentFacilityPerformanceAnalysis ifpa) { 
		assert ifpa.modelConfig != null

        // reset
        ifpa.modelParams = [:]

		log.info( "MODELCONFIG: [${ifpa.modelConfig}]" )

        ifpa.modelParams.MAX_LOAD_SHOCK_DIST = (
            ifpa.modelConfig.limitLoadingShockwave/12.0
        )
		
        ifpa.modelParams.MAX_CLEAR_SHOCK_DIST = (
            ifpa.modelConfig.limitClearingShockwave/12.0
        )

        ifpa.modelParams.shockdir = 1;
        if ( ifpa.direction =~ /S/ ||
             ifpa.direction =~ /W/ ) { 
            ifpa.modelParams.shockdir=-1;
        }

        ifpa.modelParams.incstart_index = (int)Math.floor(ifpa.modelConfig.preWindow/5)
		ifpa.modelParams.incpm = ifpa.modelConfig.section.absPostmile
		
        ifpa.modelParams.weight_for_length = "L( J1 )"
        if ( !ifpa.modelConfig.weightForLength )
            ifpa.modelParams.weight_for_length = "1"

        ifpa.modelParams.weight_for_distance = "1"
        if ( ifpa.modelConfig.weightForDistance ) { 
            ifpa.modelParams.weight_for_distance = "1.0/power(1 + sqrt(sqr(5*(ORD(M1)-${ifpa.modelParams.incstart_index})/60.0)+sqr(PM(J1)-${ifpa.modelParams.incpm})),${ifpa.modelParams.weight_for_distance})"
        }
    }

	def parseGamsFile( File gms ) { 
		return backfillLegacyData( gms )
	}

    def parseGamsData( File gms, IncidentFacilityPerformanceAnalysis ifpa = new IncidentFacilityPerformanceAnalysis() ) { 
        
		def lines

		try { 
			lines = gms.readLines()
		} catch( FileNotFoundException e) { 
			throw new GamsFileParseException( "Gams file [${gms.name}] does not exist" )
		}
		 

		def version = 0
		try {
			version = getMatch(lines, /^\*\*\* FILEVERSION:\s*(\d+)\s*$/, 0, 1 )
			log.info "FILEVERSION: $version"
		} catch ( GamsFileParseException e ) {
			// no version header, leave at zero and reread
			//e.printStackTrace()
			log.info "BAD VERSION, ASSUMING 0 AND RE-READING"
			lines = gms.readLines()
		}

        // parse CAD
		if ( version >= 1 )
			ifpa.cad = getMatch(lines, /^\*\*\* CAD:\s*([^\s]+)\s*$/, 0, 1 )
		else
			ifpa.cad = "UNKNOWN"

        // parse Facility
		if ( version >= 1 ) {
			def facdir = getMatch(lines, /^\*\*\* FACILITY:\s*(\d+-[^\s]+)\s*$/, 0, 1)
			facdir = facdir.split('-')
			ifpa.facility = facdir[0]
			ifpa.direction = facdir[1]
		} else {
			ifpa.facility = "UNKNOWN"
			ifpa.direction = "UNKNOWN"
		}

        // read config
        ifpa.modelConfig = new GamsModelConfig()
		if ( version >= 1 ) { 
			def cmd = getMatch(lines, /^\*\*\* COMMAND LINE \[(.*)\]\s*$/, 0, 1 )
			def json = JSON.parse(cmd)
			json.each{ key, value ->
				ifpa.modelConfig[key] = value
			}
		}
		

        ifpa.modelConfig.resourceLimit = Integer.parseInt( getMatch(lines, /\s*OPTIONS RESLIM = (\d+)/, 0, 1) )

        // read SETS
        def secrange = getMatch(lines, /J1\s*Sections\s*\/S(\d+)\*S(\d+)\// )
        if ( secrange.size() > 0 ) { 
            secrange = [ Integer.parseInt(secrange[0][1]), 
                         Integer.parseInt(secrange[0][2])]
        } else { 
            throw new GamsFileParseException("UNABLE TO PARSE SECTION INDICES")
        }

        
        def timerange = getMatch(lines, /M1\s*Time Steps\s*\/(\d+)\*(\d+)\//)
        if ( timerange.size() > 0 ) { 
            timerange = [ Integer.parseInt(timerange[0][1]), 
                          Integer.parseInt(timerange[0][2])]
        } else { 
            throw new GamsFileParseException("UNABLE TO PARSE TIMESTAMP INDICES")
        }

        // read the timesteps
        ifpa.timesteps = []
		if ( version >= 1 ) {
			for ( j in timerange[0]..(timerange[1])) { 
				ifpa.timesteps[j] = Date.parse("yyyy-MM-dd HH:mm:ss",
											   getMatch(lines, /^\*\s+(.*?)\s*$/, 0, 1))
			}
		}

        
        // read postmiles (and vdsids)
        getMatchAndContinue(lines, /^\s*PM.*section postmile/)  // pm head
        getMatchAndContinue(lines, /^\s*\/\s*$/) // start block
    
        ifpa.sections = []
        for( i in secrange[0]..secrange[1]) { 
            def sechead = getMatch(lines,/^\s*\*\s*S\d+\s+=\s+(\d+)\s+(.*?)\s*$/)
            if ( sechead.size() == 1 ) { 
                ifpa.sections[i] = [vdsid:sechead[0][1],name:sechead[0][2]]
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE POSTMILE FOR SECTION ${i}")
            }
            def secpm = getMatch(lines,/^\s*S\d+\s+([^\s]+)\s*$/)
            if ( secpm.size() == 1 ) { 
                ifpa.sections[i].pm = Float.parseFloat(secpm[0][1])
            }
        }

        // read section lengths
        getMatchAndContinue(lines, /^\s*L\(/)  // pm head
        getMatchAndContinue(lines, /^\s*\/\s*$/) // start block
        for( i in secrange[0]..secrange[1]) { 
            def sechead = getMatch(lines,/^\s*\*\s*S\d+\s+=\s+(\d+)\s+(.*?)\s*$/)
            if ( sechead.size() == 1 ) { 
                if ( ifpa.sections[i].vdsid != sechead[0][1] )
                    throw new MismatchedIndicesException()
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE SECTION LENGTH FOR SECTION ${i}")
            }
            def seclen = getMatch(lines,/^\s*S\d+\s+([^\s]+)\s*$/)
            if ( seclen.size() == 1 ) { 
                ifpa.sections[i].len = Float.parseFloat(seclen[0][1])
            }
        }


        // create blank obsConditions
        ifpa.obsConditions = []
        ifpa.avgConditions = []
        for ( i in secrange[0]..secrange[1]) { 
            ifpa.obsConditions[i] = []
            ifpa.avgConditions[i] = []
            for ( j in timerange[0]..timerange[1]) { 
                ifpa.obsConditions[i][j] = [:]
                ifpa.avgConditions[i][j] = [:]
            }
        }

        // read evidence
        getMatchAndContinue(lines, /^\s*TABLE P\(/ )  // pm head
        def tr = timerange[1]+1
        def patt = "^(\\s+\\d+){${tr}}\$"
        getMatchAndContinue(lines, /${patt}/) // start block

        for( i in secrange[0]..secrange[1]) { 
            patt = "^\\s+S${i}((\\s+[^\\s]+){${tr}})\$"
            def evrow = getMatch(lines, patt)
            if (evrow.size() == 1) { 
                def rowdat = evrow[0][1].trim().split(/\s+/)
                for ( j in timerange[0]..timerange[1]) { 
                    ifpa.obsConditions[i][j].p =  Float.parseFloat(rowdat[j]) 
                }
				
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE EVIDENCE FOR SECTION ${i} BECAUSE ROW REGEXP FAILED")
            }
        }

        // read observed speeds
        getMatchAndContinue(lines, /^\s*TABLE V\(/ )  // pm head
        tr = timerange[1]+1
        patt = "^(\\s+\\d+){${tr}}\$"
        getMatchAndContinue(lines, /${patt}/) // start block

        for( i in secrange[0]..secrange[1]) { 
            patt = "^\\s+S${i}((\\s+[^\\s]+){${tr}})\$"
            def evrow = getMatch(lines, patt)
            if (evrow.size() == 1) { 
                def rowdat = evrow[0][1].trim().split(/\s+/)
                for ( j in timerange[0]..timerange[1]) { 
                    ifpa.obsConditions[i][j].spd =  Float.parseFloat(rowdat[j]) 
                }
				
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE OBS SPEEDS FOR SECTION ${i} BECAUSE ROW REGEXP FAILED")
            }
        }

        // read avg speeds
        getMatchAndContinue(lines, /^\s*TABLE AV\(/ )  // pm head
        tr = timerange[1]+1
        patt = "^(\\s+\\d+){${tr}}\$"
        getMatchAndContinue(lines, /${patt}/) // start block

        for( i in secrange[0]..secrange[1]) { 
            patt = "^\\s+S${i}((\\s+[^\\s]+){${tr}})\$"
            def evrow = getMatch(lines, patt)
            if (evrow.size() == 1) { 
                def rowdat = evrow[0][1].trim().split(/\s+/)
                for ( j in timerange[0]..timerange[1]) { 
                    ifpa.avgConditions[i][j].spd =  Float.parseFloat(rowdat[j]) 
                }
				
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE AVG SPEEDS FOR SECTION ${i} BECAUSE ROW REGEXP FAILED")
            }
        }

        // read observed vols
        getMatchAndContinue(lines, /^\s*TABLE F\(/ )  // pm head
        tr = timerange[1]+1
        patt = "^(\\s+\\d+){${tr}}\$"
        getMatch(lines, /${patt}/) // start block

        for( i in secrange[0]..secrange[1]) { 
            patt = "^\\s+S${i}((\\s+[^\\s]+){${tr}})\$"
            def evrow = getMatch(lines, patt)
            if (evrow.size() == 1) { 
                def rowdat = evrow[0][1].trim().split(/\s+/)
                for ( j in timerange[0]..timerange[1]) { 
                    ifpa.obsConditions[i][j].vol =  Float.parseFloat(rowdat[j]) 
                }
				
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE OBS VOLS FOR SECTION ${i} BECAUSE ROW REGEXP FAILED")
            }
        }

        // read avg vols
        getMatch(lines, /^\s*TABLE AF\(/ )  // pm head
        tr = timerange[1]+1
        patt = "^(\\s+\\d+){${tr}}\$"
        getMatchAndContinue(lines, /${patt}/) // start block

        for( i in secrange[0]..secrange[1]) { 
            patt = "^\\s+S${i}((\\s+[^\\s]+){${tr}})\$"
            def evrow = getMatch(lines, patt)
            if (evrow.size() == 1) { 
                def rowdat = evrow[0][1].trim().split(/\s+/)
                for ( j in timerange[0]..timerange[1]) { 
                    ifpa.avgConditions[i][j].vol =  Float.parseFloat(rowdat[j]) 
                }
				
            } else { 
                throw new GamsFileParseException("UNABLE TO PARSE AVG VOLS FOR SECTION ${i} BECAUSE ROW REGEXP FAILED")
            }
        }

        return ifpa
    }
 
    // from: http://snipplr.com/view/8308/
    def generateMD5(final file) {
        MessageDigest digest = MessageDigest.getInstance("MD5")
        file.withInputStream(){is->
            byte[] buffer = new byte[8192]
            int read = 0
            while( (read = is.read(buffer)) > 0) {
                digest.update(buffer, 0, read);
            }
        }
        byte[] md5sum = digest.digest()
        BigInteger bigInt = new BigInteger(1, md5sum)
        return bigInt.toString(16)
    }

    def parseLstData( File lst, IncidentFacilityPerformanceAnalysis ifpa ) { 

        // update the id to match the md5sum of the file
        //ifpa.id = generateMD5(lst)

        def lines = lst.readLines()

        // read SETS
        def secrange = getMatch(lines, /J1\s*Sections\s*\/S(\d+)\*S(\d+)\// )
        if ( secrange.size() > 0 ) { 
            secrange = [ Integer.parseInt(secrange[0][1]), 
                         Integer.parseInt(secrange[0][2])]
        } else { 
            throw new LstFileParseException("UNABLE TO PARSE SECTION INDICES FROM LST DATA")
        }

        
        def timerange = getMatch(lines, /M1\s*Time Steps\s*\/(\d+)\*(\d+)\//)
        if ( timerange.size() > 0 ) { 
            timerange = [ Integer.parseInt(timerange[0][1]), 
                          Integer.parseInt(timerange[0][2])]
        } else { 
            throw new LstFileParseException("UNABLE TO PARSE TIMESTEP INDICES FROM LST DATA FOR ${ifpa.cad}")
        }

        // skip to relevant section
        //getMatch( lines, /^\s*S\s*O\s*L\s*V\s*E\s+S\s*U\s*M\s*M\s*A\s*R\s*Y/ )

        // read model stats
        ifpa.modelStats = [:]
        ifpa.modelStats.solver_status = getMatch( lines, /\*\*\*\*\s+SOLVER STATUS\s+\d+\s+(.*?)\s*$/, 0, 1 )
        ifpa.modelStats.model_status  = getMatch( lines, /\*\*\*\*\s+MODEL STATUS\s+\d+\s+(.*?)\s*$/, 0, 1 )
        def obj  = getMatch( lines, /\*\*\*\*\s+OBJECTIVE VALUE\s+(.*?)\s*$/, 0, 1 )
        ifpa.modelStats.objective_value = Float.parseFloat( obj )

        def cputime = getMatch( lines, /RESOURCE USAGE, LIMIT\s+([^\s]*)/, 0, 1 )
        ifpa.modelStats.cputime = Float.parseFloat( cputime )


        // read computed incident state
        def dataarray
        def level
        getMatchAndContinue( lines, /^---- VAR D/ )

        ifpa.modConditions = []  // clear existing
        for ( i in secrange[0]..secrange[1]) {
            // loop to read each value in the matrix
            ifpa.modConditions[i] = []  // reset this row
            for ( j in timerange[0]..timerange[1]) { 
                def match = getMatch( lines, /^\s*S(\d+)\s*\.(\d+)\s+(.*?)\s*$/ )
                if ( match.size() > 0 ) {
                    def si = Integer.parseInt(match[0][1])
                    def ti = Integer.parseInt(match[0][2])
                    // make sure the section and time 
                    // indices for this data match what we expect
                    if ( si != i  ||  ti != j ) throw new MismatchedIndicesException()
                    ifpa.modConditions[i][j] = [inc:(int)parseGamsLevelLine(match[0][3])]
                } else {
                    throw new LstFileParseException("UNABLE TO PARSE modConditions FROM LST FILE FOR ${ifpa.cad} BECAUSE TIME ROW DOESN'T MATCH")
                }
            }
        }


        // read the computed delays
		['Y':'totdelay','A':'avgdelay','N':'netdelay',
		 'STB':'solutionTimeBounded','SSB':'solutionSpaceBounded'].each{ var, name ->
            def str = "^---- VAR ${var}\\s+(.*?)\\s*\$"
            def match = getMatch( lines, /$str/ )
            if ( match != null && match.size() > 0 )
                ifpa.modelStats[name] = parseGamsLevelLine(match[0][1])
            else { 
				//throw new LstFileParseException("UNABLE TO PARSE modStats FOR ${var} FROM LST FILE BECAUSE TIME EXPRESSION DOESN'T MATCH")
				log.warn("UNABLE TO PARSE modStats FOR ${var} FROM LST FILE FOR ${ifpa.cad} BECAUSE MATCH FAILED")
			}
			
        }



        //println ifpa.modelStats
    }

    // Some helper method for parsing

    /**
     * Scans lines until the re is found and returns the indexed group
     */
    def getMatch(lines, re, i=-1, j=-1) { 
        def match = null
        def line = null
        //log.debug( "TRYING ${re} ON LINE: [${lines[0]}]" )
        while( lines && lines.size > 0 && 
               !(match = ( ( line = lines.remove(0) ) =~ re ))
             ) { 
            //log.debug( "TRYING ${re} ON LINE: [${lines[0]}]" )
        }
        if ( i == -1 || j == -1 ) return match
        
        if ( match.size() > i && match[i].size() > j ) { 
            return match[i][j]
        } else {
            throw new GamsFileParseException("REACHED END OF FILE BEFORE FINDING MATCH FOR RE ${re}")
        }
    }

    /**
     * Scans lines until the re is found
     */
    def getMatchAndContinue(lines, re) {
        def m = getMatch( lines, re )
        if ( m.size() == 1 )
            return m
        else
            // didn't find what we were expecting
            throw new GamsFileParseException("REACHED END OF FILE BEFORE FINDING MATCH FOR RE ${re}")
    }

    /**
     * Parses a GAMS line containing a variable value from a solution
     */
    def parseGamsLevelLine(str) {
        def dataarray = str.split(/\s+/)
        def level = dataarray[1]
        if ( level == '.' ) 
            level = 0f
        else
            level = Float.parseFloat( level )
        return level
    }

	def parseFileName( File gms ) { 
		def m = gms.name =~ /(.*)-(\d+)=([NSEW]).gms/
		
		if ( m ) { 
			return [cad:m[0][1],fac:m[0][2],dir:m[0][3]]
		} else { 
			throw new RuntimeException( "Invalid filename [${gms.name}] for parsing CAD, facility, and direction" )
		}
	}

	def backfillLegacyData( File gms, IncidentFacilityPerformanceAnalysis ifpa = parseGamsData( gms ) ) { 
		// pull in CAD, facility, and direction from the file name
		if ( ifpa.cad == null || ifpa.cad == "UNKNOWN"
			 || ifpa.facility == null || ifpa.facility == "UNKNOWN"
			 || ifpa.direction == null || ifpa.direction == "UNKNOWN" ) {
			log.info "NO CAD/FACILITY/DIR, BACKFILLING"

			def cfd = parseFileName( gms )
			
			cfd.cad != null
			cfd.fac != null
			cfd.dir != null
			
			// if cad is not defined pull it from the file name
			if ( ifpa.cad == null || ifpa.cad == 'UNKNOWN' )     ifpa.cad = cfd.cad
			else if ( ifpa.cad != cfd.cad ) throw new RuntimeException( "Mismatched CADs: ${ifpa.cad} != ${cfd.cad}")
			
			if ( ifpa.facility == null || ifpa.facility == 'UNKNOWN' )  ifpa.facility = cfd.fac
			else if ( ifpa.facility != cfd.fac ) throw new RuntimeException( "Mismatched facilities")
			
			if ( ifpa.direction == null || ifpa.direction == 'UNKNOWN' ) ifpa.direction = cfd.dir
			else if ( ifpa.direction != cfd.dir ) throw new RuntimeException( "Mismatched directions")
		}
		
		
		// if timesteps are undefined, pull them from the ifia
		if ( ifpa.timesteps == null || ifpa.timesteps.size() < 1) { 
			log.info "NO TIMESTEPS, BACKFILLING"
			//log.info "PROCESSED INCIDENTS...${ProcessedIncident.list().size()}"
			ProcessedIncident pi = ProcessedIncident.findByCad( ifpa.cad )
			if ( pi == null ) throw new IncompleteDataException("NO PROCESSED INCIDENT FOR ${ifpa.cad}")

			def iia = pi.getActiveAnalysis()
			if ( iia == null ) throw new IncompleteDataException("NO ACTIVE ANALYSIS FOR ${ifpa.cad}")

			def ifia = iia?.analysisForFacility( ifpa.facility, ifpa.direction ) 
			if ( ifia == null ) throw new IncompleteDataException("NO ANALYSIS FOR FACILITY ${ifpa.cad}: ${ifpa.facility} ${ifpa.direction}")

			def asec = ifia.analyzedSections.asList().first()
			if ( asec == null ) throw new IncompleteDataException("NO ANALYZED SECTION")

			ifpa.timesteps = asec.analyzedTimestep.collect{ it.fivemin } 
		}

		// if section is undefined, pull it from the ifia
		if ( ifpa.modelConfig?.section == null || ifpa.modelConfig.sectionId == null ) {
			log.info "NO SECTION, BACKFILLING"
			//log.info "PROCESSED INCIDENTS...${ProcessedIncident.list().size()}"
			ProcessedIncident pi = ProcessedIncident.findByCad( ifpa.cad )

			assert ifpa.modelConfig != null

			if ( pi != null ) { 
				ifpa.modelConfig.section = pi.section
				ifpa.modelConfig.sectionId = pi.section.id
			}
		}

		return ifpa
	}


	def backfillLegacyFile( File gms ) { 
		def ifpa = parseGamsData( gms )
		
	}

	
    // Some exceptions

    public class GamsFileParseException extends RuntimeException { 
		public GamsFileParseException() { super() }
		public GamsFileParseException( String s ) { super(s) }
	}
    public class LstFileParseException extends RuntimeException { 
		public LstFileParseException( ) { super() }
		public LstFileParseException( String s ) { super(s) }
	}
    public class MismatchedIndicesException extends LstFileParseException { }
	public class IncompleteDataException extends RuntimeException { 
		public IncompleteDataException() {super()}
		public IncompleteDataException( String s ) {super(s)}
	}


    // wrapper class for running GAMS 
    public static class RemoteExecutor { 
        File infile
        File outfile
        Boolean destroyExisting = false
        String gamsUser = "crindt"      // FIXME HARDCODE
        String gamsHost = "192.168.0.3" // FIXME HARDCODE

        private void init() { 
            if ( infile ) { 
                outfile = new File((infile.canonicalPath =~ /\.gms$/).replaceAll('.lst'))

                if ( !destroyExisting && outfile.exists() ) { 
                    throw new LstFileExistsException()
                }
            }
        }

        public RemoteExecutor() { 
            init()
        }
        
        public RemoteExecutor(Map map) { 
            // Simulate Groovy's 'map constructor'
            map.each { k,v -> 
                if (this.hasProperty(k)) { this[k] = v }
            }

            // Now we can do our initialization.
            init()
        }

        /**
         * Execute the GAMS job, including by doing sync-exec-sync
         */
        def execute() { 
            syncGmsFile()
            execGams()
            syncLstFile()
        }

        def syncGmsFile() { 
            def procstr = "rsync -avz ${infile.canonicalPath.toString()} ${gamsUser}@${gamsHost}:tmcpe/work"

			log.info( "SYNCING GAMS FILE USING: ${procstr}" )
            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
                log.error( "RSYNC EXIT VALUE IS: ${proc.exitValue()}" )
                //if ( proc.out ) proc.in.text << "\n"
                //if ( proc.err ) proc.err.text << err << "\n"
                throw new RsyncFailedException( )
            } else { 
                log.info proc.in.text
            }
        }

        def execGams() { 
            def procstr = "ssh ${gamsUser}@${gamsHost} cd tmcpe/work \\&\\& /cygdrive/c/Progra~1/GAMS22.2/gams.exe ${infile.name}"
            
			log.info( "EXECUTING GAMS USING: ${procstr}" )

            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
                log.error( "RSYNC EXIT VALUE IS: ${proc.exitValue()}" )
                //if ( out ) proc.in.text << "\n"
                //if ( err ) proc.err.text << err << "\n"
                throw new GamsFailedException( )
            } else { 
                log.info proc.in.text
            }
        }

        def syncLstFile() { 
            def procstr = "rsync -avz ${gamsUser}@${gamsHost}:tmcpe/work/${outfile.name} ${infile.parent}" 
			log.info( "SYNCING LST FILE USING: ${procstr}" )
            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
				log.error( "RSYNC EXIT VALUE IS: ${proc.exitValue()}" )
                //if ( out ) proc.in.text << "\n"
                //if ( err ) proc.err.text << err << "\n"
                throw new RsyncFailedException( )
            } else { 
                log.info proc.in.text
            }
        }

        public static class RsyncFailedException   extends Exception { }
        public static class GamsFailedException    extends Exception { }
        public static class LstFileExistsException extends Exception { }
    }
}
