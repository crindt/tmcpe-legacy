package edu.uci.its.tmcpe

import org.apache.commons.logging.LogFactory

class GamsDelayComputationService {

	private static final log = LogFactory.getLog(this)

    static transactional = true

    class GamsFileParseException extends Exception { }
    class ListFileParseException extends Exception { }

    public IncidentFacilityPerformanceAnalysis parseGamsResults(File gms, File lst) { 
        def ifpa = new IncidentFacilityPerformanceAnalysis()
        parseGamsData(gms,ifpa)
        parseLstData(lst,ifpa)
        return ifpa
    }

    def getMatch(lines, re, i=-1, j=-1) { 
        def match = null
        def line = null
		log.debug( "TRYING ${re} ON LINE: [${lines[0]}]" )
        while( lines.size > 0 && 
               !(match = ( ( line = lines.remove(0) ) =~ re ))
             ) { 
			log.debug( "TRYING ${re} ON LINE: [${lines[0]}]" )
        }
        if ( i == -1 || j == -1 ) return match
        
        if ( match.size() > i && match[i].size() > j ) { 
            return match[i][j]
        } else {
            throw new GamsFileParseException()
        }
    }

	def getMatchAndContinue(lines, re) {
		def m = getMatch( lines, re )
		if ( m.size() == 1 )
			return m
		else
			// didn't find what we were expecting
			throw new GamsFileParseException()
	}

    def parseGamsData( File gms, IncidentFacilityPerformanceAnalysis ifpa ) { 
        
        def lines = gms.readLines()

		// parse CAD
		ifpa.cad = getMatch(lines, /^\*\*\* CAD:\s*([^\s]+)\s*$/, 0, 1 )

        // read command line
		ifpa.modelConfig = [:]
        ifpa.modelConfig.cmd = getMatch(lines, /^\*\*\* COMMAND LINE \[(.*)\]\s*$/, 0, 1 )

        // read options
        ifpa.modelConfig.opts = [:]
        ifpa.modelConfig.opts.reslim = getMatch(lines, /\s*OPTIONS RESLIM = (\d+)/, 0, 1)

        // read SETS
        def secrange = getMatch(lines, /J1\s*Sections\s*\/S(\d+)\*S(\d+)\// )
        if ( secrange.size() > 0 ) { 
            secrange = [ Integer.parseInt(secrange[0][1]), 
                         Integer.parseInt(secrange[0][2])]
        } else { 
            throw new GamsFileParseException()
        }

        
        def timerange = getMatch(lines, /M1\s*Time Steps\s*\/(\d+)\*(\d+)\//)
        if ( timerange.size() > 0 ) { 
            timerange = [ Integer.parseInt(timerange[0][1]), 
                          Integer.parseInt(timerange[0][2])]
        } else { 
            throw new GamsFileParseException()
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
                throw new GamsFileParseException()
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
                assert ifpa.sections[i].vdsid == sechead[0][1]
            } else { 
                throw new GamsFileParseException()
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
                throw new GamsFileParseException()
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
                throw new GamsFileParseException()
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
                throw new GamsFileParseException()
            }
        }

        // read observed flows
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
					ifpa.obsConditions[i][j].flow =  Float.parseFloat(rowdat[j]) 
				}
				
            } else { 
                throw new GamsFileParseException()
            }
        }

        // read avg flows
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
					ifpa.avgConditions[i][j].flow =  Float.parseFloat(rowdat[j]) 
				}
				
            } else { 
                throw new GamsFileParseException()
            }
        }
    }

    def parseLstData( File lst, IncidentFacilityPerformanceAnalysis ifpa ) { 
        def lines = lst.readLines()

        // read SETS
        def secrange = getMatch(lines, /J1\s*Sections\s*\/S(\d+)\*S(\d+)\// )
        if ( secrange.size() > 0 ) { 
            secrange = [ Integer.parseInt(secrange[0][1]), 
                         Integer.parseInt(secrange[0][2])]
        } else { 
            throw new GamsFileParseException()
        }

        
        def timerange = getMatch(lines, /M1\s*Time Steps\s*\/(\d+)\*(\d+)\//)
        if ( timerange.size() > 0 ) { 
            timerange = [ Integer.parseInt(timerange[0][1]), 
                          Integer.parseInt(timerange[0][2])]
        } else { 
            throw new GamsFileParseException()
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


		// read the computed delays
		for ( val in ['TOTDELAY','AVGDELAY','NETDELAY'] ) {
			def str = "^---- EQU ${val}\\s+(.*?)\\s*\$"
			def match = getMatch( lines, /$str/ )
			if ( match.size() > 0 )
				ifpa.modelStats[val.toLowerCase()] = parseGamsLevelLine(match[0][1])
			else
				throw new GamsFileParseException()
		}


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
					assert ( si == i  &&  ti == j )
					ifpa.modConditions[i][j] = [inc:(int)parseGamsLevelLine(match[0][3])]
				} else {
					throw new GamsFileParseException()
				}
			}
		}
		println ifpa.modelStats
    }

	def parseGamsLevelLine(str) {
		def dataarray = str.split(/\s+/)
		def level = dataarray[1]
		if ( level == '.' ) 
			level = 0f
		else
			level = Float.parseFloat( level )
		return level
	}
}
