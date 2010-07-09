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
      dojo.require("dijit.form.FilteringSelect");
      dojo.require("dijit.form.HorizontalSlider");
      dojo.require("dijit.form.HorizontalRule");
      dojo.require("dijit.form.HorizontalRuleLabels");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dojo.date.locale");

      var incidentView;

      <!-- A function to format a javascript date object into short-format date/time string -->
      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };

      <!-- Fire up the application -->
      dojo.addOnLoad(function(){ 
         incidentView = new tmcpe.IncidentView( {jsId: 'incidentView', incidentId: ${incidentInstance.id}} );
         incidentView.startup();
      }
      );

      function popitup(url) {
	newwindow=window.open(url,'name','height=200,width=150');
	if (window.focus) {newwindow.focus()}
	return false;
      }

    </g:javascript>

  </head>

  <body class="tundra" onload="">
    <div dojoType="dijit.layout.BorderContainer" region="center" design="headline" splitter="false" >

      <!-- INFO PANE -->
      <div dojoType="dijit.layout.ContentPane" id="incidentSummary" region="top">
	Incident ${fieldValue(bean:incidentInstance, field:'cad')}.  Time to verify: ${incidentInstance.verifyDurationString()}. CAD duration: ${incidentInstance.cadDurationString()}.  Sigalert duration: ${incidentInstance.sigalertDurationString()}
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

	<!-- TSD SELECTION PANE -->
	<div dojoType="dijit.layout.ContentPane" region="top">

	  <!-- The store for the individual facility analyses performed for this incident -->
	  <div dojoType="dojo.data.ItemFileReadStore"
	       url=""
	       data="{}"
	       jsId="facilityStore" 
	       id="facilityStore"
	       >
	  </div>

	  <label class="firstLabel" for="facility" style="float:left">Facility</label>
	  <!-- NOTE: The use of filtering select here instead of combobox is critical to the functioning of the app -->
	  <select dojoType="dijit.form.FilteringSelect"
		  store="facilityStore"
		  searchAttr="fwydir"
		  autocomplete="true"
		  hasDownArrow="true"
		  id="facilityCombo"
		  jsId="facilityCombo"
                  onChange="incidentView.updateFacilityImpactAnalysis( facilityCombo.value )"
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

	<!-- TSD VIEW PANE -->
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
<!--
	    <div id="loadingAnalysisDiv" style="padding-top:3em;text-align:center;font-weight:bold;float:left;width:100%;z-index:0;">Loading Time-Space Diagram...</div>
	    <div id="noAnalysisDiv" style="padding-top:3em;text-align:center;font-weight:bold;color:red;float:left;width:100%;visibility:hidden;z-index:0;">No analyses of this incident has been performed.
	      <p>
		<a href="http://localhost/redmine/projects/tmcpe/issues/new?tracker_id=3" onclick="return popitup('http://localhost/redmine/projects/tmcpe/issues/new?tracker_id=3&issue[subject]=Perform%20analysis%20of%20Incident ${incidentInstance.cad} (id=${incidentInstance.id})&issue[description]=No%20analysis%20is%20available%20for%20incident ${incidentInstance.cad} (id=${incidentInstance.id}).  Need to explore why this is not in the database.')">
		  Click here to request support in finding out why.
		</a>
	      </p>
	    </div>
	    -->
	  </div>
	</div>
	<!-- TSD INFO PANE -->
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
