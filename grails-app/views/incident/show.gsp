<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main" />
    <title>Show Incident</title>
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'tmcpe.css')}" />
    <script type="text/javascript" djConfig="parseOnLoad: true"
	    src="${createLinkTo(dir:'js/dojo/dojo-release-1.3.2/dojo',file:'dojo.js.uncompressed.js')}"></script>
    <script src="${createLinkTo(dir:'js/tmcpe',file:'/tmcpe.js')}" djConfig="parseOnLoad: true"></script>

    <meta name="layout" content="main" />

    <!-- Load the map javascript -->
    <tmcpe:testbedMap />

    <g:javascript>
      dojo.require("dojo.date.locale");
      dojo.require("dojo.date.stamp");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dojo.data.ItemFileReadStore");

      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };
      var myFormatDateOnly = function( inDate ) {
        if ( inDate == null ) return "";
        return myFormatDate( inDate );
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDate), {selector:'date', formatLength:'short'} );
        return ret;
      }
      var myFormatTimeOnly = function( inDate ) {
        if ( inDate == null ) return "";
        return myFormatDate( inDate );
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDate), {selector:'time', formatLength:'short'} );
        return ret;
      }
    </g:javascript>

  </head>
  <body class="tundra" onload="mapInit();">
    <!-- Log Data -->
    <div id="logStore"
         dojoType="dojo.data.ItemFileReadStore" 
	 url="${resource(dir:'tmcLogEntry', file:'list.json?max=500&cad='+incidentInstance.id)}" 
	 jsId="logStore" id="logStoreNode" defaultTimeout="20000"></div>

    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
	This is the queryspec: 
	<g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
	</g:if>
      </div>
      <div dojoType="dijit.layout.BorderContainer" design="sidebars" region="center" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.BorderContainer" design="sidebars" region="center" splitter="false" liveSplitters="false">
	  <div dojoType="dijit.layout.ContentPane" id="map" region="center" style="background:yellow;" splitter="false" liveSplitters="false"></div>
	  <div dojoType="dijit.layout.ContentPane" id="plot" region="right" style="background:blue;width:50%;" splitter="false" liveSplitters="false"></div>
	</div>
	<div dojoType="dijit.layout.ContentPane" region="bottom" id="incidentSearch" splitter="true" liveSplitters="false" style="height:200px;">
	  <table id="logGridNode" 
		 jsId="logGrid" 
		 dojoType="dojox.grid.DataGrid" 
		 region="center"
		 rowSelector="20px"
		 store="logStore"
		 >
	    <thead>
	      <tr>
		<!--
		    <th field="stampDateTime" dataType="Date" formatter="myFormatDate" width="10em">Timestamp</th>
		    -->
		<th field="id" dataType="Integer" width="10em">Id</th>
		<th field="stampDateTime" dataType="Date" formatter="myFormatDate" width="15em">Date</th>
		<th field="status" dataType="String" width="10em">Status</th>
		<th field="deviceNumber" dataType="String" width="10em">Device #</th>
		<th field="deviceFwy" dataType="String" width="10em">Device Fwy</th>
		<th field="deviceName" dataType="String" width="10em">Device Name</th>
		<th field="activitySubject" dataType="String" width="15em">Subject</th>
		<th field="memo" dataType="String" width="auto">Memo</th>
	      </tr>
	    </thead>
	  </table>

	</div>
	<div dojoType="dijit.layout.ContentPane" gutters="true" region="right" style="width: 300px">
          <table>
            <tbody>
              <tr class="prop">
		<td valign="top" class="name">Id:</td>
		
		<td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'id')}</td>
		
              </tr>
	      
              
              <tr class="prop">
		<td valign="top" class="name">Section:</td>
		
		<td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'section')}</td>
		
              </tr>
	      <tr class="prop">
		<td valign="top" class="name">CAD Duration:</td>
		<td valign="top" class="value">${incidentInstance.cadDurationString()}</td>
	      </tr>
	      <tr class="prop">
		<td valign="top" class="name">Sigalert Duration:</td>
		<td valign="top" class="value">${incidentInstance.sigalertDurationString()}</td>
	      </tr>
              
            </tbody>
          </table>
	</div>
      </div>
    </div>

  </body>
</html>
