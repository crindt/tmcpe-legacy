<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident Detail</title>

    <p:css name="jquery/themes/base/jquery-ui" /> <!-- Load the openlayers css -->

<style type='text/css'> 
 svg {
  border: solid 1px #aaa;
}
path {
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
    fill-opacity: 0.75;
}
 
.line, circle.area {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}
 
.area2 path {
  fill: red;
  fill-opacity: 0.5;
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

#slider {
  width: 300px;
}

</style> 

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery.min' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <g:javascript>
      $j = jQuery.noConflict();
    </g:javascript>
    <g:javascript library="prototype" />
    
    <g:javascript>
      var i = 0;

      var tsd;

      $j(document).ready(function(){
          var themeScale=1.0;
	  function updateData( e ) {
	      var json = e.responseJSON;
	      json.timesteps = json.timesteps.map( function( d ) { return new Date(d); } ); // convert date strings to date objects
	      tsd = tmcpe.tsd.redraw(json);
	      tmcpe.cumflow.doChart( json )
	  }
	  
	  function handleFailure( e ) {
	      return "poof";
	  }
	  
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD

          function updateAnalysis( id ) {
	     new Ajax.Request('/tmcpe/incidentFacilityImpactAnalysis/tsdData/'+id,{asynchronous:false,evalScripts:true,onSuccess:function(e){updateData(e)},onFailure:function(e){handleFailure(e)},method:'get'});
	  }

	  $j("#ifia").each(function() {
  	     updateAnalysis( this.value ); 
	  });

	  $j("#slider").slider({
	     value:1,
	     min: 0,
	     max: 10,
	     step: 0.25,
	     slide: function(event,ui) {
  	        $j("#alpha").text( $j("#slider").slider("option","value") );
	     },
	     change: function( event, ui ) {
	        tsd.selectAll("g")
		   .selectAll("rect")
		   .attr("style", function(d) { return "fill:"+tmcpe.util.color(d,$j("#slider").slider("option","value"))+";stroke:#eee;"; });
	     }
	  });
	  $j("#alpha").text("1");
      });
			
    </g:javascript>     

  </head>
  <body>
    <select id="ifia" onchange="updateAnalysis(this.options[this.selectedIndex].value);">
      <g:each in="${incidentInstance.analyses}">
	<g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
	  <option selected value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</option>
	</g:each>
      </g:each>
    </select>
    <div id="slider"></div><span id="alpha">1.0<span>
    <svg>
      <defs>
	<pattern id="hatch00" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10"> 
	  <g style="fill:none; stroke:black; stroke-width:1"> 
	    <path d="M0,0 l10,10"/> 
	  </g> 
	</pattern> 
      </defs>
    </svg>
  </body>

</html>
