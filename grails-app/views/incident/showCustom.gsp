<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident ${incidentInstance.cad} Detail</title>

    <!-- This layout adds the menu and inserts the body defined below into a content pane -->
    <meta name="layout" content="main" />

    <!-- Load the map javascript and css -->
    <tmcpe:openlayers />
    <tmcpe:tmcpe />

    <g:javascript>
      <!-- Here are the custom widgets -->
      dojo.require("tmcpe.IncidentView"); <!-- This is the application (behavioral) widget -->
      dojo.require("tmcpe.TestbedMap");
      dojo.require("tmcpe.TimeSpaceDiagram");
      
      <!-- Here are all the dojo widgets we use -->
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dijit.form.ComboBox");
      dojo.require("dijit.form.HorizontalSlider");
      dojo.require("dijit.form.HorizontalRule");
      dojo.require("dijit.form.HorizontalRuleLabels");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dojo.date.locale");

      <!-- A function to format a javascript date object into short-format date/time string -->
      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };

      <!-- Fire up the application -->
      dojo.addOnLoad(function(){ 
          if ( fia ) {
	     incidentView.updateFacilityImpactAnalysis( fia );
          } else {
	     alert( "No analysis data available for incident ${incidentInstance.cad}" );
	  }
      }
      );

    </g:javascript>

  </head>


  <body class="tundra" onload="">
    <div dojoType="tmcpe.IncidentView" jsId="incidentView" id="incidentView"></div>
    <div dojoType="dijit.layout.BorderContainer" region="center" design="headline" splitter="false" >

      <!-- INFO PANE -->
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
	Incident ${fieldValue(bean:incidentInstance, field:'cad')}.  CAD duration: ${incidentInstance.cadDurationString()}.  Sigalert duration: ${incidentInstance.sigalertDurationString()}
	<g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
	</g:if>
      </div>

      <!-- MAP PANE -->
      <div dojoType="dijit.layout.ContentPane" id="mapPane" region="center" splitter="false" style="width:50%;">
	<div dojoType="tmcpe.TestbedMap" id="map" jsId="map"></div>
      </div>

      <!-- TIME SPACE DIAGRAM PANE -->
      <div dojoType="dijit.layout.BorderContainer" id="tsdPane" design="headline" region="right" style="width:50%;">

	<div dojoType="dijit.layout.ContentPane" region="top">

	  <div dojoType="dojo.data.ItemFileReadStore"
	       <g:if test="fia!=null">
		 url="${resource(dir:'incidentImpactAnalysis', file:'showAnalyses?id='+fia)}" 
	       </g:if>
	       <g:if test="fia==null">
		 data="{}"
	       </g:if>
	       jsId="facilityStore" 
	       id="facilityStoredom"
	       >
	     </div>
	  <label class="firstLabel" for="facility" style="float:left">Facility</label>
	  <select dojoType="dijit.form.ComboBox"
		  store="facilityStore"
		  searchAttr="fwydir"
		  <g:if test="fia!=null">
		    value="${incidentInstance.section.freewayId}-${incidentInstance.section.freewayDir}"
		  </g:if>
		  autocomplete="true"
		  hasDownArrow="true"
		  id="id"
		  jsId="facilityCombo"
                  onChange="tsd.updateFacilityImpactAnalysis( value )} )"
		  style="float:left;width:7em;"
		  >
	  </select>
	  
	  <label class="secondLabel" for="theme" style="float:left">Theme</label>
	  <select id="mapTheme"
		  dojoType="dijit.form.ComboBox"
		  value=""
		  autocomplete="true"
		  hasDownArrow="true"
		  onChange="tsd.setTheme( dojo.byId( 'mapTheme' ).value );"
		  style="float:left;width:7em;"
		  >
	    <option>stdspd</option>
	    <option>spd</option>
	    <option>avgspd</option>
	    <option>inc</option>
	    <option>pjm</option>
	  </select>
	  
	  <div id="scaleSlider" style="float:left" visibility="true">
	    <label class="secondLabel" for="school" style="float:left">Scale</label>
	    <div dojoType="dijit.form.HorizontalSlider" jsid="bandSlider" id="bandSlider" name="school"
		 minimum="0"
		 value="${band ? band : 0}"
		 maximum="10"
		 showButtons="false"
		 discreteValues="41"
		 style="width:200px; height: 40px; float:left;"
		 onLoad="bandSlider.setValue( dojo.byId( 'scaleValue' ) ); tsd.setThemeScale( dojo.byId( 'scaleValue' ) );"
		 onChange="dojo.byId( 'scaleValue' ).textContent=arguments[0]; tsd.setThemeScale( arguments[ 0 ] );"
		 >
	      <div dojoType="dijit.form.HorizontalRule" container="bottomDecoration"
		   count=11 style="height:5px;">
	      </div>
	      <ol dojoType="dijit.form.HorizontalRuleLabels" container="bottomDecoration"
		  style="height:1em;font-size:75%;color:gray;">
		<li>0</li>
		<li>1</li>
		<li>2</li>
		<li>3</li>
		<li>4</li>
		<li>5</li>
		<li>6</li>
		<li>7</li>
		<li>8</li>
		<li>9</li>
		<li>10</li>
	      </ol>
	    </div>
	    <label id="scaleValue" style="vertical-align:top;float:left;">${band ? band : 0}</label>
	  </div>
	  
<!--
	  <input id="activityCheck" dojotype="dijit.form.CheckBox"
		 name="activityLogCheckBox" checked="false"
		 type="checkbox"
		 onClick="displayActivityLog( dojo.byId( 'activityCheck' ).checked ? 'visible' : 'hidden' );" />
	  <label for="activityCheck"> Show activity log entries? </label> 	    
	  <input id="stationCheck" dojotype="dijit.form.CheckBox"
		 name="stationCheckBox" checked="false"
		 type="checkbox"
		 onClick="displayStations( dojo.byId( 'stationCheck' ).checked ? 'visible' : 'hidden' );" />
	  <label for="stationCheck"> Show stations? </label> 	    
-->
	</div>

	<div dojoType="dijit.layout.ContentPane" region="center" splitter="false">
	  <div dojoType="tmcpe.TimeSpaceDiagram" 
	       jsid="tsd" 
	       id="tsd" 
	       style="width:100%;height:100%;"
	       incident="'${incidentInstance.id}'"
	       facility="'${incidentInstance.section?.freewayId}'"
	       direction="'${incidentInstance.section?.freewayDir}'"
	       colorDataAccessor="stdspd"
	       >
	  </div>
	</div>
	<div dojoType="dijit.layout.ContentPane" region="bottom" splitter="false">
	  <div class="tmcpe_tsd_cellinfo" id="tmcpe_tsd_cellinfo">Mouseover time-space diagram for location/time information.</div>
	</div>
      </div>

      <div dojoType="dijit.layout.ContentPane" region="bottom" id="logPane" splitter="true" liveSplitters="false" style="height:200px;">
	<!-- Log Data -->
	<div id="logStore"
             dojoType="dojo.data.ItemFileReadStore" 
	     url="${resource(dir:'tmcLogEntry', file:'list.json?max=500&cad='+incidentInstance.cad)}" 
	     jsId="logStore" id="logStoreNode" defaultTimeout="20000"></div>

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
    </div>
  </body>
</html>
