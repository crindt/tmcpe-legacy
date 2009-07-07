<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Testbed Network View Using Openlayers</title>
    <meta name="layout" content="main" />
    <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dojox/grid/resources',file:'Grid.css')}" />
    <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dojox/grid/resources',file:'tundraGrid.css')}" />
    <g:javascript library="tmcpe/tmcpe" />
    <g:javascript>
	 var myFormatDate = function(inDatum){
            var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
	    return ret;
	 };
    </g:javascript>
    <tmcpe:testbedMap />
  </head>
  <body onload="mapInit();
		incidentsLayerInit('${createLink(controller:'incident',action:'list.kml')}');
		" 
	class="tundra"
	role="application">

    <!-- Incident Data -->
    <div dojoType="dojo.data.ItemFileReadStore" url="${createLink(controller:'incident',action:'list.json')}" jsId="incidentStore" id="incidentStoreNode" />

    <div dojoType="dijit.layout.BorderContainer" id="main" design="headline" gutters="false">
      <div dojoType="dijit.layout.ContentPane" region="top">
	<g:render template="/mainmenu" />
      </div>
      <div dojoType="dijit.layout.ContentPane" region="left" splitter="true" style="width: 200px;background:red;">
      </div>
      <div dojoType="dijit.layout.BorderContainer" id="mapView" region="center" design="headline" gutters="false">
	<div dojoType="dijit.layout.BorderContainer" id="incidentList" region="top" 
	     splitter="true"
	     design="headline" 
	     gutters="false"
	     style="background:yellow;height:20%;">
	  <div dojoType="dijit.layout.ContentPane" region="top" id="incidentSearch">
	  </div>  
	  <table id="incidentGridNode" 
		 jsId="incidentGrid" 
		 dojoType="dojox.grid.DataGrid" 
		 store="incidentStore"
		 region="center"
		 rowSelector="20px"
		 onRowClick="centerOnIncident"
		 >
	    <thead>
	      <tr>
		<th field="id" dataType="String" width="100px">CAD ID</th>
		<th field="timestamp" dataType="Date" formatter="myFormatDate" width="150px">Timestamp</th>
		<th field="locString" dataType="String" width="200px">Section</th>
		<th field="memo" dataType="String" width="auto">Description</th>
	      </tr>
	    </thead>
	  </table>
	</div>
	<div dojoType="dijit.layout.ContentPane" id="map" region="center" role="region" style="background:yellow;"></div>
    </div>
</div>
  </body>
</html>
