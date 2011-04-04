<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident Detail</title>

<!--
    <p:css name="po" />
-->


    <p:css name="960-fluid" /> <!-- Load the 960 css -->
    <p:css name="jquery/themes/base/jquery-ui" /> <!-- Load the openlayers css -->
    <p:css name="d3-tsd" /> <!-- Load the openlayers css -->

<style type='text/css'> 

</style> 

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery.min' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <p:javascript src='jquery-format/dist/jquery.format-1.2.min' />
    <p:javascript src='polymaps/polymaps' />
    <p:javascript src='protovis/protovis' />
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

      // create the map
      //doMap( json );
      map = tmcpe.segmap().container( $("#mapbox")[0] ).data( json );

      $(window).resize(function() { 
         tsd.resize(); 
         tsd.redraw(); 
	 cumflow.resize( );
	 cumflow.redraw( );
	 updateStats( json );
//	 doMap( json );
         map.redraw();
      });
  }

  function handleFailure( e ) {
      return "poof";
  }

  function updateStats( json ) {
      for ( var key in json.analysis ) {
	  var val = json.analysis[key];
	  $( '#'+key ).text( val == null ? "n/a" : ( isNaN(val) ? val : val.toFixed(0) ) );
      }
  }

  function updateTsd() {
     tsd.updateCellStyle( ); // update style
     tsd.updateCellAugmentation( ); // update style
  }


  function updateAnalysis( id ) {
      //	     new Ajax.Request('/tmcpe/incidentFacilityImpactAnalysis/tsdData/'+id,{asynchronous:false,evalScripts:true,onSuccess:function(e){updateData(e)},onFailure:function(e){handleFailure(e)},method:'get'});
      d3.json('/tmcpe/incidentFacilityImpactAnalysis/tsdData/'+id,function(e){updateData(e)});
  }



      $(document).ready(function(){
	  
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD

	  $("#ifia").each(function() {
  	     updateAnalysis( this.value ); 
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
		}
		);
		
    </g:javascript>     

  </head>
  <body>

    <div id="header" class="container_16">

      <div id="" class="grid_1 ">
      </div>

      <div id="" class="grid_14 ">

	<select id="ifia" onchange="updateAnalysis(this.options[this.selectedIndex].value);">
	  <g:each in="${incidentInstance.analyses}">
	    <g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
	      <option selected="true" value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</option>
	      <option value="${ifia.id}">Bogus</option>
	    </g:each>
	  </g:each>
	</select>
	<select id="theme" onChange="updateTsd()">
	  <option selected="true" value="stdspd">Standard Deviation of Speed from Mean</option>
	  <option value="spd">Speed Scaled between max speed and jam speed</option>
	</select>
	<div id="scaleslider"></div><span id="alpha">1.0</span>
	<div id="maxspdslider"></div><span id="maxspd">60</span>
	<p id="msgtxt"></p>

      </div>

    </div>


    <div id="content" class="container_16">

      <div id="" style="height:400px" class="grid_16 ">
	<div id="tsdcontainer" class="grid_8 alpha">
	  <div id="tsdbox" style="height:100%;width:100%;" >
	  </div>
	</div>
	<div id="mapbox" style="height:100%" class="grid_8 omega">
	  <div id="map" tabindex="1"></div>
	</div>
      </div>
      <div id="" class="grid_16 ">
	<div id="chartcontainer" class="grid_8 alpha">
	  <div id="chartbox" style="height:300px;"></div>
	</div>
	<div id="databox" class="grid_8 omega">
	  <table>
	    <tr><td class="label">tmcpe delay:</td><td class="value" id="netDelay"></td><td class="unit" id="netDelayUnit">veh-hr</td></tr>
	    <tr><td class="label">tmcpe delay2:</td><td class="value" id="computedDelay2"></td><td class="unit" id="computedDelayUnit">veh-hr</td></tr>
	    <tr><td class="label">chart delay2:</td><td class="value" id="chartDelay2"></td><td class="unit" id="chartDelayUnit">veh-hr</td></tr>
	    <tr><td class="label">d12 delay:</td><td class="value" id="d12Delay"></td><td class="unit" id="d12DelayUnit">veh-hr</td></tr>
	    <tr><td class="label">diversion:</td><td class="value" id="computedDiversion"></td><td class="unit" id="computedDiversionUnit">veh</td></tr>
	    <tr><td class="label">maxq:</td><td class="value" id="computedMaxq"></td><td class="unit" id="computedMaxqUnit">veh</td></tr>
	    <tr><td class="label">maxq time:</td><td class="value" id="ComputedMaxqTime"></td><td class="unit" id="ComputedMaxqTimeUnit">hr</td></tr>
	    <tr><td class="label">TMC savings:</td><td class="value" id="tmcSavings"></td><td class="unit" id="tmcSavingsUnit">veh-hr</td></tr>
	  </table>
	</div>
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
