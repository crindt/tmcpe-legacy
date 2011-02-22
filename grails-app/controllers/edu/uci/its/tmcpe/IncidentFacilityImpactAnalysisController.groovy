package edu.uci.its.tmcpe

import grails.converters.*
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Workbook
import org.apache.poi.hslf.model.Sheet;
import org.apache.poi.hssf.util.CellReference;

class IncidentFacilityImpactAnalysisController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [incidentFacilityImpactAnalysisInstanceList: IncidentFacilityImpactAnalysis.list(params), incidentFacilityImpactAnalysisInstanceTotal: IncidentFacilityImpactAnalysis.count()]
    }

    def create = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis()
        incidentFacilityImpactAnalysisInstance.properties = params
        return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
    }

    def save = {
        def incidentFacilityImpactAnalysisInstance = new IncidentFacilityImpactAnalysis(params)
        if (incidentFacilityImpactAnalysisInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), incidentFacilityImpactAnalysisInstance.id])}"
            redirect(action: "show", id: incidentFacilityImpactAnalysisInstance.id)
        }
        else {
            render(view: "create", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
        }
    }

    def show = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (!incidentFacilityImpactAnalysisInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
        else {
            withFormat {
                html {
                    return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
                }
                json {
                    def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
                    def timesteps = null
                    incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
                        if ( it.analyzedTimestep != null && ( timesteps == null || ( it.analyzedTimestep.size() > timesteps.size() ) ) ) {
                           timesteps = it.analyzedTimestep
                        }
                    }
                    def cnt = timesteps.size();
                    System.err.println( "A total of " + incidentFacilityImpactAnalysisInstance.analyzedSections.size() + " analyzed sections!\n" )
                    def json = [
                        id: incidentFacilityImpactAnalysisInstance.id,
                        incidentImpactAnalysis: incidentFacilityImpactAnalysisInstance.incidentImpactAnalysis.id,
                        location: incidentFacilityImpactAnalysisInstance.location,
                        startTime: incidentFacilityImpactAnalysisInstance.startTime,
                        endTime: incidentFacilityImpactAnalysisInstance.endTime,
                        timesteps: timesteps.collect { df.format( it?.fivemin ) },
                        sections: incidentFacilityImpactAnalysisInstance.analyzedSections.collect { 
                           [ vdsid: it.section.id, 
                             fwy: it.section.freewayId,
                             dir: it.section.freewayDir,
                             pm:  it.section.absPostmile,
                             name: it.section.name,
                             seglen: it.section.segmentLength,
                             analyzedTimesteps: it.analyzedTimestep.size() > 0 ? it.analyzedTimestep.collect { 
				   [ fivemin: it.fivemin, vol: it.vol, spd: it.spd, occ: it.occ, 
                                    days_in_avg: it.days_in_avg, vol_avg: it.vol_avg, spd_avg: it.spd_avg, spd_std: it.spd_std, pct_obs_avg: it.pct_obs_avg, 
				     p_j_m: it.p_j_m, inc: it.incident_flag, tmcpe_delay: (it.tmcpe_delay>=0?it.tmcpe_delay:0), d12_delay: it.d12_delay ] 
                                } : [ 1..cnt ].collect {
                                      [ vol: 0, spd: 0, occ: 0, vol_avg: 0, spd_avg: 0, spd_std: 0, pct_obs_avg: 0, p_j_m: 0, inc: 0, tmcpe_delay: 0, d12_delay: 0 ] }
                           ]
                        }
                        ]
                    render json as JSON
                }
		xls {
			Workbook wb = new HSSFWorkbook()
			def fname = [ "incident",
				      incidentFacilityImpactAnalysisInstance?.incidentImpactAnalysis?.incident?.cad,
				      incidentFacilityImpactAnalysisInstance.location.freewayId + "-" + incidentFacilityImpactAnalysisInstance.location.freewayDir,
				      "data.xls" ].join("_")
			
                        // Get the timesteps
                        def timesteps = null
                        incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
                            if ( it.analyzedTimestep != null && ( timesteps == null || ( it.analyzedTimestep.size() > timesteps.size() ) ) ) {
                                timesteps = it.analyzedTimestep
                            }
                        }

                        def firstcol=2
                        def firstrow=4

                        for ( dt in ["spd", "vol", "occ", "spd_avg", "vol_avg", "occ_avg", "p_j_m", "incident_flag", 
				     "cap", "dem", 
				     //				     "q", "spdkm", "alpha", 
				     "tmcpe_delay", "d12_delay"
				     //				     "E(v^2)", "SMS(mph)", "den(vplm)"
				    ] ) {

                            // create sheet
                            def sheet = wb.createSheet( dt )

                            // if we're doing "alpha", dump out the alpha parameters we're using
                            if ( dt == "E(v^2)" ) {
                                def param_row = sheet.createRow((short)firstrow-firstrow)
                                param_row.createCell((short)1).setCellValue( 1.22 )
                                param_row.createCell((short)2).setCellValue( -15.21 )
                                param_row.createCell((short)3).setCellValue( 207.95 )
                            }
                            
                            // create row header
                            def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
                            def rcount = firstrow
                            for ( it4 in timesteps ) { 
                                def hrow = sheet.createRow((short)rcount)
                                hrow.createCell( (short)0 ).setCellValue( df.format( it4?.fivemin ) ) 
                                if ( dt == "cap" || dt == "dem" ) {
                                   def cs_start = new CellReference(rcount,firstcol)
                                   def cs_end = new CellReference(rcount,230)
                                   hrow.createCell((short)(firstcol-1)).setCellFormula( "max("+cs_start.formatAsString()+":"+cs_end.formatAsString()+")")
                                 } else if ( dt == "q" ) {
                                   // 
                                   def cap = new CellReference('cap',rcount,firstcol-1,false,false)
                                   def den = new CellReference('dem',rcount,firstcol-1,false,false)
                                   def lcap = new CellReference(rcount,firstcol)
                                   def lden = new CellReference(rcount,firstcol+1)
                                   hrow.createCell((short)(firstcol)).setCellFormula( cap.formatAsString() )
                                   hrow.createCell((short)(firstcol+1)).setCellFormula( den.formatAsString() )
                                   hrow.createCell((short)(firstcol+2)).setCellFormula( lcap.formatAsString() + "-" + lden.formatAsString() )
                                 }
                               rcount++
                            }

                            def ccount = 0
                            def pm_col = sheet.createRow((short)(firstrow-3))
                            def seglen_col = sheet.createRow((short)(firstrow-2))
                            def nlanes_col = sheet.createRow((short)(firstrow-1))
                            def tcnt = incidentFacilityImpactAnalysisInstance.analyzedSections.size()
                            for ( it2 in incidentFacilityImpactAnalysisInstance.analyzedSections ) {
                                def colnum = tcnt-ccount+firstcol
                                if ( dt != "q" ) {
                                    // create col header for everything but the "q" page
                                    pm_col.createCell((short)(colnum)).setCellValue(it2.section.absPostmile)
                                    seglen_col.createCell((short)(colnum)).setCellValue(it2.section.segmentLength)
                                    nlanes_col.createCell((short)(colnum)).setCellValue(it2.section.lanes)
                                }
                                
                                // now put in all timestamps
                                rcount = firstrow
                                for ( it3 in it2.analyzedTimestep ) {
                                    def row = sheet.getRow((short)rcount)
                                    if ( row == null ) { row = sheet.createRow((short)rcount) }

                                    if ( dt == "spdkm" ) {
                                        def cs1 = new CellReference("spd",rcount,colnum,false,false);
                                        def form = "1.6093*"+cs1.formatAsString()
                                        row.createCell((short)(colnum)).setCellFormula( form )

                                    } else if ( dt == "alpha" ) {
                                        def co1 = new CellReference("occ",rcount,colnum,false,false);
                                        def cv1 = new CellReference("vol",rcount,colnum,false,false);
                                        def form = "1000*100*"+co1.formatAsString()+"/(12*"+cv1.formatAsString()+")"
                                        row.createCell((short)(colnum)).setCellFormula( form )

                                    } else if ( dt == "E(v^2)" ) {
                                        def p1 = new CellReference("E(v^2)",firstrow-firstrow,1,true,true);
                                        def p2 = new CellReference("E(v^2)",firstrow-firstrow,2,true,true);
                                        def p3 = new CellReference("E(v^2)",firstrow-firstrow,3,true,true);
                                        def cs1 = new CellReference("spdkm",rcount,colnum,false,false);
                                        // =1.22*spdkm!B3^2-15.21*spdkm!B3+207.95
                                        def form = "min("+p1.formatAsString()+"*"+cs1.formatAsString()+"^2"+
                                            "+"+p2.formatAsString()+"*"+cs1.formatAsString()+
                                            "+"+p3.formatAsString()+","+cs1.formatAsString()+")"
                                        row.createCell((short)(colnum)).setCellFormula( form )

                                    } else if ( dt == "SMS(mph)" ) {
                                        //=(3*spdkm!B3+(9*spdkm!B3^2-8*'ev2'!B3)^0.5)/4
                                        def ev2 = new CellReference("E(v^2)",rcount,colnum,false,false);
                                        def cs1 = new CellReference("spdkm",rcount,colnum,false,false);
                                        def form = "(3*"+cs1.formatAsString()+
                                            "+(9*"+cs1.formatAsString()+"^2-8*"+ev2.formatAsString()+")^0.5)/4/1.6093"
                                        row.createCell((short)(colnum)).setCellFormula( form )

                                    } else if ( dt == "den(vplm)" ) {
                                        //=12*vol!B3/SMS!B3
                                        def cv1 = new CellReference("vol",rcount,colnum,false,false);
                                        def nl = new CellReference("den(vplm)",firstrow-1,colnum,false,true);
                                        def SMS = new CellReference("SMS(mph)",rcount,colnum,false,false);
                                        def form = "12*"+cv1.formatAsString()+"/"+nl.formatAsString()+"/"+SMS.formatAsString()
                                        row.createCell((short)(colnum)).setCellFormula( form )

                                    } else if ( dt == "cap" ) {
                                        def if1 = new CellReference("incident_flag",rcount,colnum,false,false);
                                        def if2 = new CellReference("incident_flag",rcount,colnum-1,false,false)
                                        def v = new CellReference("vol",rcount,colnum-1,false,false)
                                        //=if(and(incident_flag!C5=1,incident_flag!B5=0),vol!B5,0)
                                        row.createCell((short)(colnum)).setCellFormula( "if(and("+if1.formatAsString()+"=1,"+if2.formatAsString()+"=0),"+v.formatAsString()+",0)" )

                                    } else if ( dt == "dem" ) {
                                        def if1 = new CellReference("incident_flag",rcount,colnum,false,false);
                                        def if2 = new CellReference("incident_flag",rcount,colnum-1,false,false)
                                        def v = new CellReference("vol",rcount,colnum,false,false)
                                        //=if(and(incident_flag!C5=1,incident_flag!B5=0),vol!B5,0)
                                        row.createCell((short)(colnum)).setCellFormula( "if(and("+if1.formatAsString()+"=0,"+if2.formatAsString()+"=1),"+v.formatAsString()+",0)" )
                                    } else if ( dt == "q" ) {
                                        // do nothing
                                    } else {
                                        row.createCell((short)(colnum)).setCellValue( it3."$dt" )
                                    }
                                    rcount++
                                }
                                ccount++
                            }
                        }

			// render the output (without a view)
			response.setContentType("application/vnd.ms-excel")
			response.setHeader("Content-disposition", "attachment;filename=${fname}") 

			// write the workbook to the response output stream					
			wb.write ( response.outputStream )

                        // Close the outputstream or the grails
                        // architecture won't try to render the
                        // conventional view, which will cause an
                        // error
                        response.outputStream.close()
		}
            }
        }
    }

    def tsdData = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (!incidentFacilityImpactAnalysisInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
        else {
            withFormat {
                json {
                    def df = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm")
                    def timesteps = null
                    incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
                        if ( it.analyzedTimestep != null && ( timesteps == null || ( it.analyzedTimestep.size() > timesteps.size() ) ) ) {
                           timesteps = it.analyzedTimestep
                        }
                    }
                    def cnt = timesteps.size();
                    System.err.println( "A total of " + incidentFacilityImpactAnalysisInstance.analyzedSections.size() + " analyzed sections!\n" )
		    def i = 0;
		    def json = [ 
			sections: incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
			    [ vdsid: it.section.id,
			      fwy: it.section.freewayId,
			      dir: it.section.freewayDir,
			      pm:  it.section.absPostmile,
			      name: it.section.name,
			      seglen: it.section.segmentLength
			    ]
			},
			sec: incidentFacilityImpactAnalysisInstance.computedStartLocation.id,
			t0: incidentFacilityImpactAnalysisInstance.computedStartTime,
			t1: incidentFacilityImpactAnalysisInstance.verification?:null,
			t2: incidentFacilityImpactAnalysisInstance.lanesClear?:null,
			t3: incidentFacilityImpactAnalysisInstance.computedIncidentClearTime?:null,
                        timesteps: timesteps.collect { it?.fivemin /*df.format( it?.fivemin )*/ },
			data: incidentFacilityImpactAnalysisInstance.analyzedSections.collect {
			    def j = 0
			    def a = it.analyzedTimestep.size() > 0 ? it.analyzedTimestep.collect { 
				[ i: i,
				  j: j++,
				  vol: it.vol, 
				  spd: it.spd, 
				  occ: it.occ, 
				  days_in_avg: it.days_in_avg, 
				  vol_avg: it.vol_avg, 
				  spd_avg: it.spd_avg, 
				  spd_std: it.spd_std, 
				  pct_obs_avg: it.pct_obs_avg, 
				  p_j_m: it.p_j_m, 
				  inc: it.incident_flag, 
				  tmcpe_delay: (it.tmcpe_delay>=0?it.tmcpe_delay:0), 
				  d12_delay: it.d12_delay 
				]
			    } : []
			    i++;
			    a;
			}
		    ]

                    render json as JSON
                }
	    }
	}
    }

    def edit = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (!incidentFacilityImpactAnalysisInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance]
        }
    }

    def update = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (incidentFacilityImpactAnalysisInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (incidentFacilityImpactAnalysisInstance.version > version) {
                    
                    incidentFacilityImpactAnalysisInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis')] as Object[], "Another user has updated this IncidentFacilityImpactAnalysis while you were editing")
                    render(view: "edit", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
                    return
                }
            }
            incidentFacilityImpactAnalysisInstance.properties = params
            if (!incidentFacilityImpactAnalysisInstance.hasErrors() && incidentFacilityImpactAnalysisInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), incidentFacilityImpactAnalysisInstance.id])}"
                redirect(action: "show", id: incidentFacilityImpactAnalysisInstance.id)
            }
            else {
                render(view: "edit", model: [incidentFacilityImpactAnalysisInstance: incidentFacilityImpactAnalysisInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def incidentFacilityImpactAnalysisInstance = IncidentFacilityImpactAnalysis.get(params.id)
        if (incidentFacilityImpactAnalysisInstance) {
            try {
                incidentFacilityImpactAnalysisInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis'), params.id])}"
            redirect(action: "list")
        }
    }
}
