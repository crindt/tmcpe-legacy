package edu.uci.its.tmcpe

import org.apache.commons.logging.LogFactory
import groovy.text.GStringTemplateEngine

import java.security.MessageDigest // for md5sum

class GamsDelayComputationService {

    private static final log = LogFactory.getLog(this)

    static transactional = true

    /**
     * The main interface to the service
     *
     * GIVEN: 
     */
    public IncidentFacilityPerformanceAnalysis computeIncidentFacilityPerformance( Map config ) {
        def ifpa
        if ( !config.hasProperty( 'ifpa' ) ) {
            ifpa = new IncidentFacilityPerformanceAnalysis(config)
        } else {
            ifpa = map.ifpa
        }

        // At this point, we need to iterate until termination conditions are met
        while( !ifpa.modelIsOptimal() /* && terminationCriteriaAreNotMet */ ) {

            // generate the input data
            if ( ifpa.obsConditions == null ) {
                // FIXME: DOIT
                assert false
            }

            // generate the model params
            if ( ifpa.modParams == null ) {
                generateModelParams( ifpa )
            }

            // create datafile
            def gms = createGamsData(ifpa)

            // execute
            serverConfig.infile = gms
            def re = new RemoteExecutor(serverConfig)
            re.execute()

            // parse the results
            ifpa = parseGamsResults( re.infile, re.outfile, ifpa )

            // validate
        }

        return ifpa
    }

    public IncidentFacilityPerformanceAnalysis parseGamsResults(File gms, File lst, Object ifpa = new IncidentFacilityPerformanceAnalysis() ) { 
        parseGamsData(gms,ifpa)
        parseLstData(lst,ifpa)
        return ifpa
    }


    /**
     * Generate a GAMS input file
     */
    def createGamsData( 
        IncidentFacilityPerformanceAnalysis ifpa,

        // FIXME: crindt: select an appropriate directory for this
        File gms = new File('test/data/${ifpa.cad}_${ifpa.facility}-${ifpa.direction}.gms' )
    ) { 
        // use ifpa to specify conditions
        def f = new File('test/data/tst.gms.template')  // FIXME: crindt: this template should reside elsewhere (e.g., webapp/templates)
        def engine = new GStringTemplateEngine()
        //assert ( ifpa.validate() )

        // convert the ifpa.modelConfig into ifpa.modelParams
        generateModelParams(ifpa)

        //println ifpa.properties
        def template = engine.createTemplate(f).make(ifpa.properties)

        // the newWriter call destroys the existing gms file
        def w = gms.newWriter() 
        w << template.toString()
        w.close()

        return gms
    }

    def generateModelParams(IncidentFacilityPerformanceAnalysis ifpa) { 

        // reset
        ifpa.modelParams = [:]

        ifpa.modelParams.MAX_LOAD_SHOCK_DIST = (
            ifpa.modelConfig.opts.limit_loading_shockwave/12.0
        )
		
        ifpa.modelParams.MAX_CLEAR_SHOCK_DIST = (
            ifpa.modelConfig.opts.limit_clearing_shockwave/12.0
        )

        def shockdir = 1;
        if ( ifpa.direction =~ /S/ ||
             ifpa.direction =~ /W/ ) { 
            shockdir=-1;
        }

        ifpa.modelParams.incstart_index = ifpa.modelConfig.opts.prewindow/5
		
        ifpa.modelParams.weight_for_length = "L( J1 )"
        if ( !ifpa.modelConfig.opts.weight_for_length )
            ifpa.modelParams.weight_for_length = "1"

        ifpa.modelParams.weight_for_distance = "1"
        if ( ifpa.modelConfig.opts.weight_for_distance ) { 
            ifpa.modelParams.weight_for_distance = "1.0/power(1 + sqrt(sqr(5*(ORD(M1)-${ifpa.modelParams.incstart_index})/60.0)+sqr(PM(J1)-${ifpa.modelParams.incpm})),${ifpa.modelParams.weight_for_distance})"
        }
    }

    def parseGamsData( File gms, IncidentFacilityPerformanceAnalysis ifpa = new IncidentFacilityPerformanceAnalysis() ) { 
        
        def lines = gms.readLines()

		def version = 0
		try {
			version = getMatch(lines, /^\*\*\* FILEVERSION:\s*(\d+)\s*$/, 0, 1 )
			println "FILEVERSION: $version"
		} catch ( GamsFileParseException e ) {
			// no version header, leave at zero and reread
			e.printStackTrace()
			println "BAD VERSION, ASSUMING 0 AND RE-READING"
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

        // read command line
        ifpa.modelConfig = [:]
        ifpa.modelConfig.cmd = getMatch(lines, /^\*\*\* COMMAND LINE \[(.*)\]\s*$/, 0, 1 )

        // read options
        ifpa.modelConfig.opts = [ // DEFAULTS
            weight_for_length:1,
            height_for_distance:3,
            limit_loading_shockwave:20,    // mi/hr
            limit_clearing_shockwave:60,   // mi/hr
            prewindow:10,                  // minutes
            postwindow:120                 // minutes
        ]
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

        // read the timesteps
        ifpa.timesteps = []
		if ( version >= 1 ) {
			for ( j in timerange[0]..(timerange[1]-1)) { 
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
                if ( ifpa.sections[i].vdsid != sechead[0][1] )
                    throw new MismatchedIndicesException()
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
                throw new GamsFileParseException()
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
                throw new GamsFileParseException()
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
                    throw new GamsFileParseException()
                }
            }
        }


        // read the computed delays
		['Y':'totdelay','A':'avgdelay','N':'netdelay',
		 'STB':'solutionTimeBounded','SSB':'solutionSpaceBounded'].each{ var, name ->
            def str = "^---- VAR ${var}\\s+(.*?)\\s*\$"
            def match = getMatch( lines, /$str/ )
            if ( match.size() > 0 )
                ifpa.modelStats[name] = parseGamsLevelLine(match[0][1])
            else
                throw new GamsFileParseException()
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

    /**
     * Scans lines until the re is found
     */
    def getMatchAndContinue(lines, re) {
        def m = getMatch( lines, re )
        if ( m.size() == 1 )
            return m
        else
            // didn't find what we were expecting
            throw new GamsFileParseException()
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


    // Some exceptions

    public class GamsFileParseException extends Exception { }
    public class LstFileParseException extends Exception { }
    public class MismatchedIndicesException extends LstFileParseException { }


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
            println "EXECUTING: ${procstr}"
            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
                System.err << "RSYNC EXIT VALUE IS: ${proc.exitValue()}"
                if ( out ) proc.in.text << "\n"
                if ( err ) proc.err.text << err << "\n"
                throw new RsyncFailedException( )
            } else { 
                println proc.in.text
            }
        }

        def execGams() { 
            def procstr = "ssh ${gamsUser}@${gamsHost} cd tmcpe/work \\&\\& /cygdrive/c/Progra~1/GAMS22.2/gams.exe ${infile.name}"
            
            println "EXECUTING: ${procstr}"

            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
                System.err << "RSYNC EXIT VALUE IS: ${proc.exitValue()}"
                if ( out ) proc.in.text << "\n"
                if ( err ) proc.err.text << err << "\n"
                throw new GamsFailedException( )
            } else { 
                println proc.in.text
            }
        }

        def syncLstFile() { 
            def procstr = "rsync -avz ${gamsUser}@${gamsHost}:tmcpe/work/${outfile.name} ${infile.parent}" 
            println "EXECUTING: ${procstr}"
            def proc = procstr.execute()

            proc.waitFor()
            if ( proc.exitValue() ) { 
                System.err << "RSYNC EXIT VALUE IS: ${proc.exitValue()}"
                if ( out ) proc.in.text << "\n"
                if ( err ) proc.err.text << err << "\n"
                throw new RsyncFailedException( )
            } else { 
                println proc.in.text
            }
        }

        public static class RsyncFailedException   extends Exception { }
        public static class GamsFailedException    extends Exception { }
        public static class LstFileExistsException extends Exception { }
    }
}
