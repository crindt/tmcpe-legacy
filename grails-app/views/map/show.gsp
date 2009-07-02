<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Testbed Network View Using Openlayers</title>
<!--
    <script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAjpkAC9ePGem0lIq5XcMiuhR_wWLPFku8Ix9i2SXYRVK3e45q1BQUd_beF8dtzKET_EteAjPdGDwqpQ'></script>
-->
    <style>
      html, body, #main{	
	padding: 0 0 0 0;
	margin: 0 0 0 0;
	font: 10pt Arial,Myriad,Tahoma,Verdana,sans-serif;
      height:97%;
      }
    </style>
     
    <meta name="layout" content="main" />
    <g:javascript library="tmcpe/tmcpe">
    </g:javascript>
    <!-- defines the map -->
    <tmcpe:testbedMap>
    </tmcpe:testbedMap>
  </head>
  <body onload="mapInit();
		incidentsLayerInit();
		">
    <div id="main" dojoType="dijit.layout.BorderContainer" design="headline" gutters="false">
      <div id="menu" dojoType="dijit.layout.ContentPane" region="top" style="height=100px;">
	<g:render template="/mainmenu" />
      </div>
<!--
      <div dojoType="dijit.layout.ContentPane" region="left"
	   style="background-color:lightblue;width: 120px;">
	Table of Contents
      </div>
-->
      <div id="mapcont" dojoType="dijit.layout.ContentPane" region="center" >
	<div id="map" style="display:block; border:1px black solid;height=90%;">
	</div>
      </div>

      <div id="footer" dojoType="dijit.layout.ContentPane" region="bottom" 
	   style="height=100px;">
	The bottom.
      </div>
    </div>            
  </body>
</html>
