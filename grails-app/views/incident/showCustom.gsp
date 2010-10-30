<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident ${incidentInstance.cad} Detail</title>

    <!-- This layout adds the menu and inserts the body defined below into a content pane -->
    <meta name="layout" content="main" />

    <!-- Load the css, then the js -->
    <p:css name="openlayers/style" /> <!-- Load the openlayers css -->

    <p:dependantJavascript>

      <p:javascript src='openlayers-bundle' /> <!-- Loads bundled openlayers -->
      <tmcpe:init_g_map_api />     <!-- Init the google map api key -->

      <g:javascript>

      var fireItUp = function() {

         incidentView = new tmcpe.IncidentView( {jsId: 'incidentView', incidentId: ${incidentInstance.id}} );
         incidentView.startup();
      };

      var incidentView;

      <!-- A function to format a javascript date object into short-format date/time string -->
      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };

      function popitup(url) {
	newwindow=window.open(url,'name','height=200,width=150');
	if (window.focus) {newwindow.focus()}
	return false;
      }

      <!-- Fire up the application -->
      dojo.addOnLoad(function(){ 
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

	 dojo.addOnLoad(function(){ 
  	    fireItUp();
	 });
      });

    </g:javascript>
    </p:dependantJavascript>

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
      <div dojoType="dijit.layout.ContentPane" class="dijitContentPaneLoading" id="mapPane" region="center" splitter="false" >
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
		  value="stdspd"
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
	  <div id="maxIncSpeedSliderBox" style="float:left" visibility="true">
	    <label class="secondLabel" for="maxIncSpeedSlider" style="float:left">IncSpeed</label>
	    <div dojoType="dijit.form.HorizontalSlider" jsid="maxIncSpeedSlider" id="maxIncSpeedSlider" name="school"
		 minimum="0"
		 value="${maxIncidentSpeed ? maxIncidentSpeed : 60}"
		 maximum="80"
		 showButtons="false"
		 discreteValues="17"
		 style="width:200px; height: 40px; float:left;"
		 onLoad="maxIncSpeedSlider.setValue( dojo.byId( 'maxIncSpeedValue' ) ); tsd.setMaxIncSpeed( dojo.byId( 'maxIncSpeedValue' ) );"
		 onChange="dojo.byId( 'maxIncSpeedValue' ).textContent=arguments[0]; tsd.setMaxIncSpeed( arguments[ 0 ] );"
		 >
	      <div dojoType="dijit.form.HorizontalRule" container="bottomDecoration"
		   count=9 style="height:5px;">
	      </div>
	      <ol dojoType="dijit.form.HorizontalRuleLabels" container="bottomDecoration"
		  style="height:1em;font-size:75%;color:gray;">
		<li>0</li>
		<li>10</li>
		<li>20</li>
		<li>30</li>
		<li>40</li>
		<li>50</li>
		<li>60</li>
		<li>70</li>
		<li>80</li>
	      </ol>
	    </div>
	    <label id="maxIncSpeedValue" style="vertical-align:top;float:left;">${maxIncidentSpeed ? maxIncidentSpeed : 60}</label>
	  </div>
	  <input id="incidentCheck" dojotype="dijit.form.CheckBox"
	         name="incidentCheckBox" checked="true"
		 type="checkbox"
                 onChange="tsd.toggleIncidentWindow( dojo.byId( 'incidentCheck' ).checked )" />
	  <label for="incidentCheck">Show Incident?</label> 	    
	  <input id="evidenceCheck" dojotype="dijit.form.CheckBox"
	         name="evidenceCheckBox" checked="false"
		 type="checkbox"
                 onChange="tsd.toggleEvidenceWindow( dojo.byId( 'evidenceCheck' ).checked )" />
	  <label for="evidenceCheck">Show Evidence?</label> 	    
	  <input id="tsdFlipCheck" dojotype="dijit.form.CheckBox"
	         name="tsdFlipCheckBox" checked="false"
		 type="checkbox"
                 onChange="incidentView.flipTimeSpaceDiagram( dojo.byId( 'tsdFlipCheck' ).checked )" />
	  <label for="tsdFlipCheck">Flip time axis?</label> 	    
	  
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
	<div dojoType="dijit.layout.ContentPane" region="center" splitter="false" style="text-align:center;">
	  <div dojoType="tmcpe.TimeSpaceDiagram" 
	       jsid="tsd" 
	       id="tsd" 
	       style="width:100%;height:100%;position:relative;"
	       themeScale="${band?band:0}"
	       incident="'${incidentInstance.id}'"
	       facility="'${incidentInstance.section?.freewayId}'"
	       direction="'${incidentInstance.section?.freewayDir}'"
	       colorDataAccessor="stdspd"
	       >
	  </div>
	</div>
	<!-- TSD INFO PANE -->
	<div dojoType="dijit.layout.ContentPane" region="bottom"  style="padding:0px;margin:0px" splitter="false">
	  <div dojoType="dijit.layout.BorderContainer" id="tsdInfoPane" style="padding:0px;margin:0px;height:4em;" design="headline" >	
	    <div dojoType="dijit.layout.ContentPane" region="top" style="padding:0px;margin:0px" >
	      <div class="tmcpe_tsd_cellinfo" id="tmcpe_tsd_cellinfo" style="height:2.5em";>Mouseover time-space diagram for location/time information.</div>
	    </div>
	    <div dojoType="dijit.layout.ContentPane" region="bottom" style="padding:0px;margin:0px" >
	       <a id="tmcpe_tsd_xls_link"></a>
	       &nbsp;|&nbsp;
	       <a id="tmcpe_report_problem_link"></a>
	    </div>
          </div>
	</div>
      </div>

      <div dojoType="dijit.layout.ContentPane" region="bottom" id="logPane" splitter="true" liveSplitters="false" 
	   style="height:200px;">
	<!-- Log Data -->
	<div id="logStore"
             dojoType="dojo.data.ItemFileReadStore" 
	     url="${resource(dir:'tmcLogEntry', file:'list.json?max=500&cad='+incidentInstance.cad)}" 
	     jsId="logStoreJs" defaultTimeout="20000"></div>

	<table id="logGridNode" 
	       jsId="logGrid" 
	       dojoType="dojox.grid.DataGrid" 
	       region="center"
	       store="logStoreJs"
	       width="95%"
	       >
	  <thead>
	    <tr>
	      <!--
		  <th field="stampDateTime" dataType="Date" formatter="myFormatDate" width="10em">Timestamp</th>
		  -->
	      <!--<th field="id" dataType="Integer" width="6em">Id</th>-->
	      <th field="stampDateTime" dataType="Date" formatter="myFormatDate" width="10%">Date</th>
	      <th field="status" dataType="String" width="10%">Status</th>
	      <th field="deviceSummary" dataType="String" width="15%">Resource</th>
	      <th field="activitySubject" dataType="String" width="15%">Subject</th>
	      <th field="memoOnly" dataType="String" width="40%">Memo</th>
	    </tr>
	  </thead>
	</table>
      </div>
    </div>
  </body>
</html>
