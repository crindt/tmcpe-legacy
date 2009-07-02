<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
<head>
  <meta name="layout" content="main" />
  <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dojox/grid/resources',file:'Grid.css')}" />
  <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dojox/grid/resources',file:'tundraGrid.css')}" />
</head>

<body class="tundra" role="application">
  <!--
  <div id="preLoader"><p></p></div>
  -->
  <div dojoType="dojo.data.ItemFileReadStore" url="/tmcpe/incident/list.json" jsId="incidentStore" id="incidentStoreNode" />

  <div id="main" dojoType="dijit.layout.BorderContainer" design="headline">

    <!-- TOP PANE/MENU -->
    <div dojoType="dijit.layout.ContentPane" region="top">
      <g:render template="/mainmenu" />
    </div>

    <!-- CENTER PANE -->
      <table id="incidentGridNode" 
	     jsId="incidentGrid" 
	     dojoType="dojox.grid.DataGrid" 
	     store="incidentStore"
	     region="center"
	     rowSelector="20px"
	     >
	<thead>
	  <tr>
	    <th field="id" width="100px">CAD ID</th>
	    <th field="timestamp" width="150px">Timestamp</th>
	    <th field="locString" width="200px">Section</th>
	    <th field="memo" width="auto">Description</th>
	  </tr>
	</thead>
      </table>
  </div>
</body>
</html>
