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

<style type='text/css'> 

#maptext {
   border: 1px;
   background-color: yellow;
}
  #databox table {
  margin-top:1em;
}
 svg {
  border: solid 1px #aaa;
}
path.incidentBoundary {
  stroke: blue;
  stroke-width: 4px;
  fill: none;
}
rect {
  fill: lightsteelblue;
  stroke: #eee;
  stroke-width: 2px;
}
rect.d1 {
  fill: steelblue;
}
rect.d2 {
  fill: darkblue;
}

 
.rule line {
  stroke: #eee;
  shape-rendering: crispEdges;
}
 
.rule2 line {
  stroke: #eee;
  shape-rendering: crispEdges;
}
 
.rule line.axis {
  stroke: #000;
}
 
.rule2 line.axis {
  stroke: #000;
}
 
.area {
  fill: steelblue;
//    fill-opacity: 0.75;
}
 
.line, circle.area {
  fill: none;
  stroke: cyan;
  stroke-width: 1.5px;
}
 
.area2 path {
  fill: green;
//  fill-opacity: 0.75;
}

.line3 {
  fill: none;
  stroke: orange;
  stroke-width: 1.5px;
}
 
.area3 path {
  fill: red;
//  fill-opacity: 0.5;
}

.timebar {
    stroke: purple;
    stroke-width: 4px;
}
 
.line2, circle.area2 {
  fill: none;
  stroke: yellow;
  stroke-width: 1.5px;
}
 
circle.area {
  fill: #fff;
}

.ylabels, .xlabels {
   font-size: 8pt;
}

#scaleslider {
  width: 300px;
}
#maxspdslider {
  width: 300px;
}

td.label {
    text-align: right;
}

td.value {
    text-align: right;
    width: 4em;
}

td.unit {
    text-align: left;
}

.compass .back {
  fill: #256574;
}

.compass .fore, .compass .chevron {
  stroke: #1AA398;
}

#segments path {
  fill: none;
  stroke-linecap: round;
//  stroke-width: 4px;
}

#ends circle {
  fill: yellow;
  stroke: black;
  r: 1px;
}

#copy, #copy a {
  color: #1AA398;
}


</style> 

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery.min' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <p:javascript src='polymaps/polymaps' />
    <p:javascript src='protovis/protovis' />
    <p:javascript src='tmcpe/po' />
    
    <g:javascript>
      var i = 0;

      var themeScale=1.0;
      function updateData( json ) {
      json.timesteps = json.timesteps.map( function( d ) { return new Date(d); } ); // convert date strings to date objects
      tmcpe.tsd.redraw(json);
      tmcpe.cumflow.doChart( json )
      updateStats( json );
      doMap( json );
      }
      
      function handleFailure( e ) {
      return "poof";
      }

      function updateStats( json ) {
      /*
      var tsd = d3.select("#tsdbox");

      var delay2 = 0;
      $.each( tsd.data, function(i, d) {
      delay2 += (d.y3-d.y)*1000*5/60;
      });
      json.analysis["chartDelay2"] = delay2;
      */

      for ( var key in json.analysis ) {
      var val = json.analysis[key];
      $( '#'+key ).text( isNaN(val) ? val : val.toFixed(0) );
      }
      }

      function updateTsd() {
      
      var themeWid = $("#theme")[0];
      var theme = themeWid.options[themeWid.selectedIndex].value;

      var tsd = d3.select("#tsdbox");

      tsd.selectAll("g")
      .selectAll("rect")
      .attr("style", function(d) { 
      if ( theme == "stdspd" ) {
         var color = pv.Scale.linear(-$("#scaleslider").slider("option","value"),-($("#scaleslider").slider("option","value")/2),0 ).range("#ff0000","#ffff00","#00ff00");
	 var vv = Math.min(0,Math.max((d.spd-d.spd_avg)/d.spd_std,-4));
	 var col = "fill:"+color(vv).color+";stroke:#eee;"
	 return col;
      } else if ( theme == "spd" ) {
         var minspd = 15;
         var color = pv.Scale.linear(minspd,
	                             minspd+($("#maxspdslider").slider("option","value")-minspd)/2,
                                     $("#maxspdslider").slider("option","value")
                     ).range("#ff0000","#ffff00","#00ff00");
	 var col = "fill:"+color(d.spd).color+";stroke:#eee;"
	 return col;
      }
      });

      tsd.selectAll("g")
      .selectAll("circle")
      .attr("style", function(d) { 
      var v1 = $("#scaleslider").slider("option","value");
      var v2 = $("#maxspdslider").slider("option","value");
      var ev = tmcpe.util.evidenceOfIncident( d, v1, v2 );
      return ev ? "fill:black;" : "fill:none;";
      });
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
   	        updateTsd();
	     }
	  });
	  $("#alpha").text("1");

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
		});
		
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

      <div id="" class="grid_16 ">
	<div id="tsdbox" style="height:500px;text-align:right;" class="grid_8 alpha">
	</div>
	<div id="mapbox" style="height:500px;" class="grid_8 omega">
	  <div id="map" tabindex="1"></div>
	</div>
      </div>
      <div id="" class="grid_16 ">
	<div id="chartbox" style="text-align:right;" class="grid_8 alpha">
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
