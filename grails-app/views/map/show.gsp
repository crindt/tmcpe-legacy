<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Incident List</title>
    <meta name="layout" content="main" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->

    <!-- Load the css, then the js -->
    <tmcpe:tmcpe_styles />       <!-- Loads openlayers from the common project source -->
    <tmcpe:openlayers />         <!-- Loads openlayers from the common project source -->
    <tmcpe:init_g_map_api />     <!-- Init the google map api key -->
    <tmcpe:tmcpe />              <!-- This loads the tmcpe (dojo-based) interface framework -->

    <g:javascript>
      <!-- Here are all the dojo widgets we use -->
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dijit.InlineEditBox");
      dojo.require("dijit.form.NumberTextBox");
      dojo.require("dijit.form.Form");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dijit.form.FilteringSelect");
      dojo.require("dijit.Tooltip");
      dojo.require("dojox.form.RangeSlider");
      dojo.require("dojox.layout.RadioGroup");
      dojo.require("dijit.form.RadioButton");
      dojo.require("dijit.form.Form");
      dojo.require("dojo._base.json");
      dojo.require("dojo.date");
      dojo.require("tmcpe.IncidentList");
      dojo.require("tmcpe.MyDateTextBox");
      dojo.require("tmcpe.MyTimeTextBox");

      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };

      var myFormatNumber = function( inNum ) {
        if ( inNum != null ) {
           return dojo.number.format(inNum, {places:0});
        } else {
           return null;
        }
      };

      var myFormatDateOnly = function( inDate ) {
        if ( inDate == null ) return "";
        var ret = dojo.date.locale.format( inDate, {selector:'date', formatLength:'short'} );
        return ret;
      };

      dojo.addOnLoad(function(){ incidentList ? incidentList.initApp() : alert( "NO INCIDENT LIST!" );});
    </g:javascript>
  </head>

  <body onload="" 
	class="tundra">
    <!-- Application -->
    <div dojoType="tmcpe.IncidentList" jsId="incidentList" id="incidentList"></div>

    <!-- Viewport -->
    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <!-- Query Pane -->
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">

	<!-- Long Query Form -->
	<div dojoType="dijit.form.Form" id="queryForm">
	  <script type="dojo/method" event="onSubmit" args="evt">
	    evt.preventDefault()
	    // It's valid, update the map query
	    var il = dijit.byId( 'incidentList' );
	    il.updateIncidentsQuery();
	  </script>

	  <!-- Facility Data for the query form -->
	  <div dojoType="dojo.data.ItemFileReadStore" data="{items:[]}" id="facilityStoreNode" jsId="facilityStore" url="incident/listFacilities/"></div>
	  <div dojoType="dojo.data.ItemFileReadStore" data="{items:[]}" id="eventTypeStoreNode" jsId="eventTypeStore" url="incident/listEventTypes/"></div>

	  <table>
	    <tr>
	      <th>Time Options</th>
	      <th>Incident Options</th>
	      <th>Other Options</th>
	    </tr>
	    <tr>
	      <td style="width:33%;">
		<table style="padding:0.5em;">
		  <tr>
		    <td><label id="dateRangeLabel" for="startDate">Date Range:</label></td>
		    <td>
		      <input type="text" style="width:8em;" name="startDate" id="startDate" jsId="startDate"
			     dojoType="tmcpe.MyDateTextBox"
			     value="-3 months"
			     required="false" />
		      <label for="endDate">&nbsp;to:</label>
		      <input type="text" style="width:8em;" name="endDate" id="endDate" value="" dojoType="tmcpe.MyDateTextBox"
			     required="false" />
		    </td>
		  </tr>
		  <tr>
		    <td><label id="timeRangeLabel" style="width:10em;" for="earliestTime">Time of Day:</label></td>
		    <td>
		      <input type="text" style="width:8em;" name="earliestTime" id="earliestTime" value="" dojoType="tmcpe.MyTimeTextBox"
			     required="false" />
		      <label for="endTime">&nbsp;to:</label>
		      <input type="text" style="width:8em;" name="latestTime" id="latestTime" value="" dojoType="tmcpe.MyTimeTextBox"
			     required="false" />
		    </td>
		  </tr>
		  <tr>
		    <td><label id="dayOfWeekLabel">Day of Week</label></td>
		    <td>
		      <label for="mon">Mon</label>
		      <input id="mon" name="mon" dojoType="dijit.form.CheckBox" value="1" checked="checked"/>
		      <label for="tue">Tue</label>
		      <input id="tue" name="tue" dojoType="dijit.form.CheckBox" value="2" checked="checked"/>
		      <label for="wed">Wed</label>
		      <input id="wed" name="wed" dojoType="dijit.form.CheckBox" value="3" checked="checked"/>
		      <label for="thu">Thu</label>
		      <input id="thu" name="thu" dojoType="dijit.form.CheckBox" value="4" checked="checked"/>
		      <label for="fri">Fri</label>
		      <input id="fri" name="fri" dojoType="dijit.form.CheckBox" value="5" checked="checked"/>
		      <label for="sat">Sat</label>
		      <input id="sat" name="sat" dojoType="dijit.form.CheckBox" value="6" checked="checked"/>
		      <label for="sun">Sun</label>
		      <input id="sun" name="sun" dojoType="dijit.form.CheckBox" value="0" checked="checked"/>
		    </td>
		  </tr>
		</table>
		<!-- Query Tooltips -->
		<span dojoType="dijit.Tooltip"
		  connectId="dateRangeLabel" id="dateRangeTooltip">
		  Select the date range of incidents you want to view.
		  For instance, you can select incidents from 2007 by specifying a date range of 1/1/2007 to 1/1/2008
		</span>
		<span dojoType="dijit.Tooltip" connectId="timeRangeLabel" id="timeRangeTooltip"> 
		  Select the time-of-day range you want to consider (e.g., 7:00am--10:00am.)
		</span>
		<span dojoType="dijit.Tooltip" connectId="dayOfWeekLabel" id="dayOfWeekTooltip"> 
		  Select the days of the week you want to include (e.g., M-F or Sat and Sun)
		</span>
		<span dojoType="dijit.Tooltip" connectId="fwydirLabel"
		  id="fwydirTooltip"> You can limit the results to a
		  single facility defined by route and direction
		  (e.g., 5-N).  The input will autocomplete based upon
		  available analyses (i.e., it will suggest any
		  facility that has an analyzed incident on it in the
		  database).  You can also select from a list of
		  available facilities.
		</span>
		<span dojoType="dijit.Tooltip" connectId="eventTypeLabel"
		  id="eventTypeTooltip">Use this to limit the results to specific event types
		</span>
	      </td>

	      <!-- Facility Data -->
              <td style="width:33%;">
		<table style="padding:0.5em;border-style=none;">
		  <tr>
		    <td>
		      <label for="fwydir" id="fwydirLabel">
			Facility
		      </label>
		    </td>
		    <td>
		      <input id="fwydir" 
			     jsId="fwydir"
			     type="text" 
			     style="width:15em;" 
			     dojoType="dijit.form.FilteringSelect" 
			     autoComplete="true"
			     name="freewayDir"
			     value="<Show All>" 
			     invalidMessage="No such facility exists in the database."
			     store="facilityStore"
			     searchAttr="facdir"
			     labelAttr="facdir"
			     />
		    <td>
		  </tr>
		  <tr>
		    <td>
		      <label for="eventType" id="eventTypeLabel">
			Event Type
		      </label>
		    </td>
		    <td>
		      <input id="eventType" 
			     jsId="eventType"
			     type="text" 
			     style="width:15em;" 
			     dojoType="dijit.form.FilteringSelect" 
			     autoComplete="true"
			     name="eventType"
			     value="<Show All>" 
			     invalidMessage="No such event type exists in the database."
			     store="eventTypeStore"
			     searchAttr="evtype"
			     labelAttr="evtype"
			     />
		    </td>
		  </tr>
		</table>
	      </td>
	      <td style="width:33%;">
		<table style="padding:0.5em;">
		  <tr>
		    <td>
		      <input type="radio" dojoType="dijit.form.RadioButton" id="analyzed" name="Analyzed" checked="checked" value = "onlyAnalyzed" />
		      <label for="analyzed" id="limitToAnalyzedLabel">Limit to Analyzed</label><br/>
		      <input type="radio" dojoType="dijit.form.RadioButton" id="unanalyzed" name="Analyzed" value = "unAnalyzed" />
		      <label for="unanalyzed" id="limitToUnanalizedLabel">Limit to Unanalyzed</label><br/>
		      <input type="radio" dojoType="dijit.form.RadioButton" id="allanalyzed" name="Analyzed" value = "all" />
		      <label for="allanalyzed" id="limitToAllLabel">Show all incidents</label><br/>
		      <hr/>
		      <input type="checkbox" dojoType="dijit.form.CheckBox" id="geographic" name="Geographic" checked="checked" value="geo"/>
		      <label for="geographic" id="geographicLabel">Limit to viewport</label><br/>
		    </td>
		  </tr>
		</table>
		<span dojoType="dijit.Tooltip" connectId="limitToAnalyzedLabel">
		  Use this to limit the query to only incidents that
		  have been analyzed.  Use this option for reporting on TMC performance.
		</span>
		<span dojoType="dijit.Tooltip" connectId="limitToUnanalizedLabel">
		  Use this to limit the query to only incidents
		  that <strong>haven't</strong> yet been
		  analyzed.  Use this option for identifying missing
		  incidents for analysis.
		</span>
		<span dojoType="dijit.Tooltip" connectId="limitToAll">
		  Use this if you don't want to limit the query based
		  on whether the incident has been analyzed or not.
		</span>
		<span dojoType="dijit.Tooltip" connectId="geographicLabel">
		  Check this box if you want to limit the query to
		  incidents that are visible in the map.  Uncheck it
		  if you want the query to be based only on the query
		  form whether they're visible in the viewport or not.
		  <div class="alert">(Warning: unchecking
		  this could crash the browser as it will generate a
		  large query result)</div>
		</span>
	      </td>
	    <tr>
	      <td colspan="3">
		<button dojoType="dijit.form.Button" type="submit" name="submitButton"
			value="Submit">
		  Submit
		</button>
		<button dojoType="dijit.form.Button" type="reset">
		  Reset
		</button>
	      </td>
	    </tr>
	  </table>
	</div> <!-- Form -->
      </div> <!-- Query Pane -->
      <!-- Map and Details Pane -->
      <div dojoType="dijit.layout.BorderContainer" id="mapgrid" region="center" design="sidebar" style="background:green;" splitter="false" liveSplitters="false">

	<!-- Map Pane -->
	<div dojoType="dijit.layout.ContentPane" id="mapPane" region="center" style="background:yellow;" splitter="false" liveSplitters="false">
	  <div dojoType="tmcpe.TestbedMap" id="map" jsId="map"></div>
	</div>

	<!-- Incident Details Pane -->
	<div dojoType="dijit.layout.BorderContainer" gutters="false" region="right" style="width: 500px;background:white;">
	  <!-- Detail Box -->
	  <div dojoType="dijit.layout.ContentPane" id="incidentDetailPane" gutters="true" region="center" >
	    <div id="incidentDetails" style="margin-top:3em;">Select an incident on the map to view its details here.</div>
	  </div>

	  <!-- Detail Button Box -->
	  <div dojoType="dijit.layout.ContentPane" id="incidentDetailsControllerPane" gutters="true" region="bottom">
	    <div id="incidentDetailsController" class="centered-div centered" style="width:12em;visibility:hidden;">
	      <button id="previousIncident" 
		      dojoType="dijit.form.Button"
		      onClick="dijit.byId('incidentStackContainer').back();incidentList.updateIncidentCluster();"
		      >
		&lt;
	      </button>
	      <span id="incidentIndex">0 of 0</span>
	      <button id="nextIncident" 
		      dojoType="dijit.form.Button"
		      onClick="dijit.byId('incidentStackContainer').forward();incidentList.updateIncidentCluster();"
		      >
		&gt;
	      </button>
	    </div>
	  </div>
	</div>


      </div>

      <!-- Incident List Pane -->
      <div dojoType="dijit.layout.BorderContainer" id="gridRegion" region="bottom" design="sidebar" splitter="true" liveSplitters="false" gutters="false" style="height:15em;">
	<div dojoType="dijit.layout.ContentPane" id="gridContainer" region="center" style="background:purple;padding:0px;" splitter="false" liveSplitters="false" style="height:50%">
	  <table id="incidentGrid" 
		 jsId="incidentGrid" 
		 dojoType="dojox.grid.DataGrid" 
		 sortInfo=2
		 region="center"
		 onRowClick="incidentList.simpleSelectIncident(event)"
		 style="width:100%;height:4em;"
		 >
	    <thead>
	      <tr>
		<th field="cad" tooltip="Check" dataType="String" styles="padding-left:5px;padding-right:5px;" width="6%">CAD ID</th>
		<th field="timestamp" dataType="Date" styles="padding-left:5px;padding-right:5px;" formatter="myFormatDate" width="7%">Timestamp</th>
		<th field="locString" dataType="String" styles="padding-left:5px;padding-right:5px;" width="15%">Section</th>
		<th field="memo" dataType="String" styles="padding-left:5px;padding-right:5px;" width="35%">Description</th>
		<th field="d12_delay" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">D<sub>35</sub></th>
		<th field="tmcpe_delay" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">D<sub>tmcpe</sub></th>
		<th field="savings" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">TMC Savings</th>
	      </tr>
	    </thead>
	  </table>
	</div>
	<div dojoType="dijit.layout.ContentPane" id="gridSummaryContainer" region="bottom" style="background:purple;" splitter="false" liveSplitters="false" style="padding:0px;">
	  <div dojoType="dojo.data.ItemFileReadStore" 
	       data="{items:[
		     {'cad':'','timestamp':'',locString:'','memo':'Totals for Analyzed:','d12_delay':'0','tmcpe_delay':'0','savings':'0'},
		     ]}" 
	       jsId="incidentSummaryStore" 
	       id="incidentSummaryStoreNode"
	       style="visibility:hidden;">
	  </div>
	  <table id="incidentSummaryGrid" 
		 jsId="incidentSummaryGrid" 
		 dojoType="dojox.grid.DataGrid"
		 onRowClick=""
		 style="width:100%;height:2.5em;background-color:#eeeeee;margin:0px;margin-top:3px;"
		 store="incidentSummaryStore"
		 >
	    <thead>
	      <tr>
		<th field="cad" dataType="String" styles="padding-left:5px;padding-right:5px;" width="6%">CAD ID</th>
		<th field="timestamp" dataType="Date" styles="padding-left:5px;padding-right:5px;" width="7%">Timestamp</th>
		<th field="locString" dataType="String" styles="padding-left:5px;padding-right:5px;" width="15%">Section</th>
		<th field="memo" dataType="String" styles="padding-left:5px;padding-right:5px;text-align:right;font-weight:bold;" width="35%">Description</th>
		<th field="d12_delay" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">Delay (veh-hr)</th>
		<th field="tmcpe_delay" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">Delay (veh-hr)</th>
		<th field="savings" dataType="Float" formatter="myFormatNumber" styles="padding-left:5px;padding-right:5px;text-align:right;" width="10%">TMC Savings (veh-hr)</th>
		<th field="dummy" dataType="Integer" width="19px"></th>
	      </tr>
	    </thead>
	  </table>
	</div>
      </div>
    </div>
     
   <!-- Incident Data -->
   <div dojoType="dojo.data.ItemFileReadStore" data="{items:[]}" jsId="incidentStore" id="incidentStoreNode" defaultTimeout="20000"></div>
  </body>
</html>
