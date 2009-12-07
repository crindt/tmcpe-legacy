<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main" />
    <title>Show Incident</title>
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'tmcpe.css')}" />
    <script type="text/javascript" djConfig="parseOnLoad: true"
	    src="${createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js')}"></script> 
    <script src="${createLinkTo(dir:'js/tmcpe',file:'/tmcpe.js')}" djConfig="parseOnLoad: true"></script>
    <script src="${createLinkTo(dir:'js/tmcpe',file:'/fwyplot.js')}" djConfig="parseOnLoad: true"></script>

    <meta name="layout" content="main" />

    <!-- Load the map javascript -->
    <tmcpe:testbedMap />

    <g:javascript>
      dojo.require("dojo.date.locale");
      dojo.require("dojo.date.stamp");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dijit.form.ComboBox");
      dojo.require("dijit.form.HorizontalSlider");
      dojo.require("dijit.form.HorizontalRule");
      dojo.require("dijit.form.HorizontalRuleLabels");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dojo._base.json");

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
      var incidentData;
      dojo.addOnLoad(function(){
         incidentData = ${incidentInstance.hackToJSON()};
         updateData();
         redraw();
      });
    </g:javascript>

  </head>
  <body class="tundra" onload="mapInit();mySegmentsLayerInit();">
    <!-- Log Data -->
    <div id="logStore"
         dojoType="dojo.data.ItemFileReadStore" 
	 url="${resource(dir:'tmcLogEntry', file:'list.json?max=500&cad='+incidentInstance.id)}" 
	 jsId="logStore" id="logStoreNode" defaultTimeout="20000"></div>

    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
	Incident ${fieldValue(bean:incidentInstance, field:'id')}.  CAD duration: ${incidentInstance.cadDurationString()}.  Sigalert duration: ${incidentInstance.sigalertDurationString()}
	<g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
	</g:if>
      </div>
      <div dojoType="dijit.layout.BorderContainer" design="headline" region="center" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.ContentPane" id="map" region="center" style="background:yellow;" splitter="false" liveSplitters="false"></div>
	<div dojoType="dijit.layout.ContentPane" id="plot" region="right" style="background:blue;width:50%;" splitter="false" liveSplitters="false">



	  <div dojoType="dijit.layout.BorderContainer" design="headline">
	    <div dojoType="dijit.layout.ContentPane" region="top">
	      <!--		    query="{cad: dojo.byId('incidentCombo').value }" -->
	      <!--
		  <option>5-N</option>
	      <option>5-S</option>
	      -->
	      
	      <label class="secondLabel" for="theme" style="float:left">Theme</label>
	      <select id="mapTheme"
		      dojoType="dijit.form.ComboBox"
		      value=""
		      autocomplete="true"
		      hasDownArrow="true"
		      onChange="setTheme( dojo.byId( 'mapTheme' ).value ); updateView();"
		      style="float:left;"
		      >
		<option>stdspd</option>
		<option>spd</option>
		<option>avgspd</option>
		<option>inc</option>
		<option>pjm</option>
	      </select>
	      
	      <div id="scaleSlider" style="float:left" visibility="true">
		<label class="secondLabel" for="school" style="float:left">Scale</label>
		<div dojoType="dijit.form.HorizontalSlider" id="bandSlider" name="school"
		     minimum="0"
		     value="0.25"
		     maximum="10"
		     showButtons="false"
		     discreteValues="41"
		     style="width:200px; height: 40px; float:left;"
		     onLoad="changeThemeScale( dojo.byId( 'scaleValue' ) );"
		     onChange="dojo.byId( 'scaleValue' ).textContent=arguments[0]; changeThemeScale( arguments[ 0 ] );"
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
		<label id="scaleValue" style="vertical-align:top;float:left;">0.25</label>
	      </div>

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
	    </div>

	    <div dojoType="dijit.layout.ContentPane" region="center">
	      <div id="incidentplot" style="width: 100%; height: 100%;margin:0;border:0"></div>
	    </div>
	  </div>
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
      </div>
    </div>

  </body>
</html>
