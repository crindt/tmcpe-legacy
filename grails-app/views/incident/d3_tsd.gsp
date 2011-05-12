<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="thin" />
    <title>Incident ${incidentInstance.cad} Detail</title>

    <p:css name="tmcpe-common" />
    <p:css name="d3-tsd" /> <!-- Load the openlayers css -->
    <p:css name="jquery-tooltip/jquery.tooltip" /> <!-- Load the openlayers css -->

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery.min' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <p:javascript src='jquery-format/dist/jquery.format-1.2.min' />
<!--    <p:javascript src='jquery-dateFormat/jquery.dateFormat-1.0' /> -->
    <p:javascript src='jquery-tooltip/jquery.tooltip' />
    <p:javascript src='polymaps/polymaps' />
    <p:javascript src='protovis/protovis' />
    <p:javascript src='datatables/jquery.dataTables' />

<!--    <p:javascript src='tmcpe/po' /> -->
    
    <g:javascript>


  var i = 0;
  var tsd;
  var cumflow;
  var map;

  var themeScale=1.0;


  function cellStyle(d) {
     var themeWid = $("#theme")[0];
     var theme = themeWid.options[themeWid.selectedIndex].value;
     var scale  = $("#scaleslider").slider("option","value");
     var maxSpd = $("#maxspdslider").slider("option","value");

     // return grey if evidence is uncertain (imputed data)
     if ( d.p_j_m > 0 && d.p_j_m < 1 ) {
        return "fill:#999;stroke:#eee;"
     } 

     if ( theme == "stdspd" ) {
        var color = pv.Scale.linear(-scale,
                  -(scale/2),0 ).range("#ff0000","#ffff00","#00ff00");
        var vv = Math.min(0,Math.max((d.spd-d.spd_avg)/d.spd_std,-4));
        var col = "fill:"+color(vv).color+";stroke:#eee;"
        return col;
     } else if ( theme == "spd" ) {
        var minspd = 15;
        var color = pv.Scale.linear(minspd,
                                    minspd+(maxSpd-minspd)/2,
                                    maxSpd)
                      .range("#ff0000","#ffff00","#00ff00");
        var col = "fill:"+color(d.spd).color+";stroke:#eee;"
        return col;
     }
  }

  function evidenceOfIncident( d, scale, maxIncidentSpeed ) {
      var stdlev = (d.spd - d.spd_avg)/d.spd_std;
      var tmppjm = 1; // no incident probability is default
      if ( d.p_j_m != 0 && d.p_j_m != 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	  tmppjm = 0.5;
      else if ( stdlev < 0 
		&& stdlev < -scale
		&& d.spd < maxIncidentSpeed
	      )
      {
	  tmppjm = 0.0;
      }
      return tmppjm == 0.0;
  }


  function cellAugmentStyle(d) {
     var v1 = $("#scaleslider").slider("option","value");
     var v2 = $("#maxspdslider").slider("option","value");
     var ev = evidenceOfIncident( d, v1, v2 );
     return ev ? "fill:black;" : "fill:none;";
  }


  function syncchart(tsd,cumflow) {
      return function( d, i ) { 
	  tsd.selectedTime( d.i );

          // updates the chart's data
	  cumflow.section( d.i );
      };
  };


  function updateData( json ) {
      json.timesteps = json.timesteps.map( function( d ) { return new Date(d); } ); // convert date strings to date objects

      // create the tsd
      tsd = tmcpe.tsd()
                 .container( $("#tsdbox")[0] )
                 .data(json)
		 .cellStyle( cellStyle )
		 .cellAugmentStyle( cellAugmentStyle );

      // create the cumulative flow chart
      cumflow = tmcpe.cumflow()
                     .container( $("#chartbox")[0] )
                     .data(json);

      syncchart(tsd,cumflow)({i:cumflow.section()})

      d3.select(tsd.container()).selectAll("rect").on("click", syncchart( tsd, cumflow ));

      updateStats( json );

      updateLog( json );

      // update the $$ calc
      cumflow.tmcDivPct( $("#tmcpct").text() );

      // update the band and max speed sliders
      $('#maxspdslider').slider('value',json.parameters.maxIncidentSpeed);
      $('#maxspd').text(json.parameters.maxIncidentSpeed);


      // create the map
      //doMap( json );
      map = tmcpe.segmap().container( $("#mapbox")[0] ).data( json ).redraw();

      $(window).resize(function() { 
         tsd.resize(); 
         tsd.redraw(); 
	 cumflow.resize( );
	 cumflow.redraw( );
	 updateStats( json );
	 updateLog( json );
//	 doMap( json );
         map.data(json).redraw();
	 
      });
  }

  function rotateMap( v ) {
     map.rotate( v.value );
  }

  function handleFailure( e ) {
      return "poof";
  }

  function updateStats( json ) {
      if ( json.analysis.badSolution != null ) {
          //$( '#generalStats td' ).text( "" );   // clear everything
	  $( '#generalStats_wrapper').remove();
	  $( '#generalStatsContainer').append("<p>ANALYSIS FOR THIS FACILITY FAILED: "+json.analysis.badSolution+"</p>");
      } else {
	  // FIXME: This dups a similar function in tsd.js
	  $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
              if ( json.analysis[v] != null  && v != 'computedMaxqTime' ) {
		  var val = json.analysis[v].toFixed(0);
		  d3.select("#"+v).html( val < 0 ? 0 : val  );
              }
	  });

	  // Update the download analysis link
	  $('#tmcpe_tsd_download_link').html( 'Download XLS for facility analysis ' + json.id );
	  $('#tmcpe_tsd_download_link').attr( 'href', "${resource(dir:'/',absolute:true)}"+'incidentFacilityImpactAnalysis/show.xls?id='+json.id );


	  // Update the report problem link
	  $('#tmcpe_report_analysis_problem_link').html( 'Report problem with this analysis' );
	  url = "http://tracker.ctmlabs.net/projects/tmcpe/issues/new?tracker_id=3&"
		+ encodeURIComponent( "issue[subject]=Problem with analysis of Incident "+json.cad+"["+json.id+"]" )
		+ "&" + encodeURIComponent( "issue[description]=Bad analysis for available for ["+json.cad+"["+json.id+"]"+"]("
					    +window.location.href
					    +")\n\n"
					    +"User Agent: " + navigator.userAgent
					  )
	  $('#tmcpe_report_analysis_problem_link').attr('href',url);
	  $('#tmcpe_report_analysis_problem_link').attr('target', "_blank" );
      }
  }

  function updateLog( json ) {
      // clear existing
      var container = d3.select( '#logtableContainer' );

      $('#logtableContainer').children().remove();

      // select table element (for d3)
      var tab = container
	  .append("table")
	  .attr("id","activityLog");

      function renderLogTimestamp(obj) {
	  dd = new Date( obj );
	  return $.format.date(dd,'yyyy-MM-dd kk:mm');
      };

      var fields = [ {key:"stampDateTime",title:"Time",render:renderLogTimestamp}, 
		     {key:"activitySubject",title:"Activity"}, 
		     {key:"memoOnly",title:"Description"}, 
		   ];

      var head = tab.append("thead");


      head.append("tr").selectAll("th").data(fields).enter()
	  .append("th")
	  .attr("class",function(d){return d.key ? d.key : d;})
	  .html(function(d){return d.title ? d.title : d});


      var body = tab.append("tbody");

      function raiseLogEntry( d ) {
	  // In SVG, the z-index is the element's index in the dom.  To raise an
	  // element, just detach it from the dom and append it back to its parent
	  var targets = $("g[logid="+d.id+"]");
	  var target = targets[0];
	  var parent = target.parentNode;
	  targets.detach().appendTo( parent );
	  return 
      }

      // create log rows
      var rows = body.selectAll("tr")
	  .data(json.log,function(d) {return d.id})
	  .enter().append("tr")
	  .attr("id", function( d ) { return ["log",d.id].join("-"); })
	  .attr("logid", function( d ) { return d.id; })
	  .attr("class", function( d, i ) { return ( i % 2 ? "even" : "odd" ) + " " + d.type } )
	  .on("mouseover",function(d,e) {
	      // placehold, should highlight on TSD
	      d3.selectAll('g.activitylog').attr("class","logtimebar activitylog hidden");
	      d3.selectAll('g.activitylog[logid="'+d.id+'"]')
		  .attr("class",function(dd,e){
		      raiseLogEntry(dd);
		      return "logtimebar activitylog";
		  });
	  } );
      
      // now populate rows
      rows.selectAll("td")
	  .data(function(d) {
	      var props = [];
	      $.each( fields, function( i, dd ) {
		  var item = d[dd.key];
		  props.push( dd.render ? dd.render( item ) : item );
	      });
	      return props;
	  })
	  .enter().append("td")
	  .attr("class", function(d,i) { return fields[i].key } )
	  .text( function(dd) { return dd; } );

      $("#activityLog").dataTable({ 
	  bPaginate: false, sScrollY:"300px","bAutoWidth":false,
	  "aoColumns": [
	      {"sWidth": "20%", "sType":"date" },
	      {"sWidth": "20%", "sType":"string" },
	      {"sWidth": "60%", "sType":"string" }
	  ]});
      
      
  }

  function updateTsd() {
     tsd.updateCellStyle( ); // update style
     tsd.updateCellAugmentation( ); // update style
  }

  function updateCumFlowStats() {
     cumflow.tmcDivPct( $("#tmcpct").text() );

     var unit = $('input[name=delayUnit]:checked').val();
     var vot = $("#valueOfTime")[0];

     if ( unit == 'usd' ) {
        $('#valueOfTime').attr("disabled","");

        if ( vot != "" ) {
	$(".delayValue").each(function() { 
	   var val = this.innerText*vot.value;
	   this.innerHTML = val.toFixed();
	});
        $(".delayUnit").each(function() { 
	   this.innerHTML = "USD";
	});
        }
     } else {
        $('#valueOfTime').attr("disabled","disabled");
        $(".delayUnit").each(function() { 
	   this.innerHTML = "veh-hr";
	});
     }
  }

  function changeUnit(v) {
     updateCumFlowStats();
  }

  function updateAnalysis( id ) {
      //	     new Ajax.Request('/tmcpe/incidentFacilityImpactAnalysis/tsdData/'+id,{asynchronous:false,evalScripts:true,onSuccess:function(e){updateData(e)},onFailure:function(e){handleFailure(e)},method:'get'});
      d3.json('incidentFacilityImpactAnalysis/tsdData/'+id.value,function(e){updateData(e)});
      $('#generalStats #facility').html(id.children[0].innerHTML);
      
  }



      $(document).ready(function(){

         var settings = $("#settings").detach();
         settings.appendTo('#header');
	  
         // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD

	  $("#ifia").each(function() {
	     if ( this.value != "" ) {
  	        updateAnalysis( this ); 
 	     } else {
		 $("#msgtxt").text("NO ANALYSES AVAILABLE");
	     }
	  });

	  $("#scaleslider").slider({
	     value:1,
	     min: 0,
	     max: 10,
	     step: 0.25,
	     slide: function(event,ui) {
  	        $("#alpha").text( $("#scaleslider").slider("option","value") );
   	        updateTsd();
	     },
	     change: function( event, ui ) { 
  	        $("#alpha").text( $("#scaleslider").slider("option","value") );
//   	        updateTsd();
	     }
	  });
	  $("#alpha").text($("#scaleslider").slider("option","value"));

	  $("#maxspdslider").slider({
	     value:60,
	     min: 0,
	     max: 85,
	     step: 5,
	     slide: function(event,ui) {
  	        $("#maxspd").text( $("#maxspdslider").slider("option","value") );
		updateTsd();
		},
		change: function( event, ui ) { 
		$("#maxspd").text( $("#maxspdslider").slider("option","value") );
		updateTsd() ;
		}
		});
	  $("#maxspd").text("60");
		
	  $("#tmcpctslider").slider({
	     value:50,
	     min: 0,
	     max: 100,
	     step: 1,
	     slide: function(event,ui) {
  	           $("#tmcpct").text( $("#tmcpctslider").slider("option","value") );
		   updateCumFlowStats();
		},
		change: function( event, ui ) { 
		   $("#tmcpct").text( $("#tmcpctslider").slider("option","value") );
		   updateCumFlowStats();
		}
		});
	  $("#tmcpct").text("50");
	  $("#tabs").tabs( {
	      // hack to resize columns in a tab: http://datatables.net/examples/api/tabs_and_scrolling.html
		"show": function(event, ui) {
			var oTable = $('div.dataTables_scrollBody>table', ui.panel).dataTable();
			if ( oTable.length > 0 ) {
				oTable.fnAdjustColumnSizing();
			}
		}
	  } );
	  $("#generalStats").dataTable({
	      "bPaginate": false,
	      "sScrollY": "300px",
	      "bLengthChange": false,
	      "bFilter": false,
	      "bSort": false,
	      "bInfo": false,
	      "aoColumns": [
	      {"sWidth": "60%", "sType":"string", "sClass":"right" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" }
	  ]
	       } );

      });

    </g:javascript>     

  </head>
  <body>

    <div class="container_16">

      <div id="settings" style="display:inline;float:left;margin-left:10px;">
	<table style="float:left;">
	  <tr>
	    <th>Facility:</th>
	    <td>
	      <select id="ifia" onchange="updateAnalysis(this.options[this.selectedIndex]);">
		<g:each in="${incidentInstance.analyses}">
		  <g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
		    <option selected="true" value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</option>
		  </g:each>
		</g:each>	      
	      </select>
	    </td>
	  </tr>
	</table>
	<table style="float:left">
	  <tr>
	    <th>Cell theme:</th>
	    <td>
	      <select id="theme" onChange="updateTsd()">
		<option value="stdspd">Standard Deviation of Speed from Mean</option>
		<option selected="true" value="spd">Speed Scaled between max speed and jam speed</option>
	      </select>
	    </th>
	  </tr>
	  <tr>
	    <th id="speed_parameter">Scale:</th>
	    <td>
	      <div id="scaleslider"></div>
	    </td>
	    <td>
	      <span id="alpha">1.0</span>
	    </td>
	  </tr>
	  <tr>
	    <th>Max Speed:</th>
	    <td>
	      <div id="maxspdslider"></div>
	    </td>
	    <td>
	      <span id="maxspd">60</span>
	    </td>
	  </tr>
	</table>
	<table style="float:left;border:solid 1px white">
<!--
	  <tr >
	    <th>Align map to:</th>
	    <td>
	      <form style="display:inline;">
		<input type="radio" name="align" checked="true" value="cardinal" onclick="rotateMap(this);">Cardinal directions</option>
		<input type="radio" name="align" value="incident" onclick="rotateMap(this)">Incident</option>
	      </form>
	    </td>
-->
	  </tr>
	  <tr>
	    <th>TMC Diversion %:</th>
	    <td>
	      <div id="tmcpctslider"></div>
	    </td>
	    <td>
	      <span id="tmcpct">50</span>
	    </td>
	  </tr>
	  <tr>
	    <th>Display delay as:</th>
	    <td>
	      <form style="display:inline;">
		<input type="radio" name="delayUnit" checked="true" value="vehhr" onclick="changeUnit(this)">veh-hr</option>
		<input type="radio" name="delayUnit" value="usd" onclick="changeUnit(this)">USD</option>
	      </form>
	    </td>
	  </tr>
	  <tr>
	    <th>Value of Time</th>
	    <td>
	      <input disabled="disabled" type="text" value="13.11" onChange="updateCumFlowStats()" id="valueOfTime"/>
	    </td>
	  </tr>
	</table>
<!--
      <div id="menu" style="float:right;">
        <ul>
          <li><a href="#">test</a></li>
        </ul>
      </div>
-->
      </div>
    </div>

    <div id="msg" class="container_16">
      <div id="" class="grid_16 alpha omega ">
        <p><h3 style="display:inline;color:yellow;">Incident ${incidentInstance.cad}:&nbsp;</h3><span id="msgtxt">&nbsp;</span></p>
      </div>
    </div>

    <div id="content" class="container_16">

      <div style="height:40%;">
	<div id="tsdcontainer" class="grid_8 alpha">
	  <div id="tsdbox">
	  </div>
	</div>
	<div id="mapbox" class="grid_8 omega">
	  <div id="map" tabindex="1"></div>
	</div>
      </div>
      
      <div style="height:40%">
	<div id="chartcontainer" class="grid_8 alpha">
	  <div id="chartbox" style="height:90%;"></div>
	  <h3>Cumulative Vehicle Count at <span id="chart_location"></span></h3>	  
	</div>
	<div id="databox" style="height:100%" class="grid_8 omega">
	  <div id="tabs">
	    <ul>
	      <li><a href="#generalStatsContainer">General Statistics</a></li>
	      <li><a href="#logtableContainer">Activity Log</a></li>
	    </ul>
	    <div id="generalStatsContainer">
	      <table id="generalStats">
    <thead>
		<tr>
		  <th class="label">Facility</th>
		  <th class="label">&Delta;<sub>d12</sub></th>
		  <th class="label">&Delta;<sub>tmcpe</sub></th>
<!--
		  <th class="label">&Delta;q</th>
		  <th class="label">max(q)</th>
-->
		  <th class="label">&Delta;<sub>"what-if"</sub></th>
		  <th class="label">&Delta;<sub>TMC</sub></th>
		</tr>
    </thead>
    <tbody>
		<tr>
		  <td class="facilityName" id="facility"></td>
		  <td class="delayValue" id="d12Delay"></td>
<!--		  <td class="unit delayUnit" id="d12DelayUnit">veh-hr</td> -->

		  <td class="delayValue" id="netDelay"></td>
<!--		  <td class="unit delayUnit" id="netDelayUnit">veh-hr</td> -->

<!--		  <td class="value" id="computedDiversion"></td> -->
<!--		  <td class="unit" id="computedDiversionUnit">veh</td> -->

<!--		  <td class="value" id="computedMaxq"></td> -->
<!--		  <td class="unit" id="computedMaxqUnit">veh</td> -->

		  <td class="delayValue" id="whatIfDelay"></td>
<!--		  <td class="unit delayUnit" id="whatIfDelayUnit">veh-hr</td> -->

		  <td class="delayValue" id="tmcSavings"></td>
<!--		  <td class="unit delayUnit" id="tmcSavingsUnit">veh-hr</td> -->
		</tr>
    </tbody>
	      </table>
	       <a id="tmcpe_tsd_download_link"></a>
	       &nbsp;|&nbsp;
	       <a id="tmcpe_report_analysis_problem_link"></a>
	    </div>
	    <div id="logtableContainer">
	      <table id="activityLog">
	      </table>
	    </div>
	</div>
      </div>
    </div>

    <div id="footer" class="container_16">

      <div id="" class="grid_1 ">
      </div>

      <div id="" class="grid_14 ">
      </div>

    </div>

  </body>

</html>
