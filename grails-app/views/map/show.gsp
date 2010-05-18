<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Testbed Network View Using Openlayers</title>
    <meta name="layout" content="main" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->

    <!-- Load the map javascript and css -->
    <!-- <tmcpe:openlayers_latest /> --> <!--  brings in the openlayers stuff -->
    <tmcpe:openlayers />  
    <tmcpe:tmcpe />              <!-- This loads the tmcpe (dojo-based) interface framework -->

    <g:javascript>
      <!-- Here are all the dojo widgets we use -->
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dijit.InlineEditBox");
      dojo.require("dijit.form.NumberTextBox");
      dojo.require("dijit.form.Form");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dojo._base.json");
      dojo.require("tmcpe.IncidentList");
      dojo.require("tmcpe.MyDateTextBox");
      dojo.require("tmcpe.MyTimeTextBox");

      var myFormatDate = function(inDatum){
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDatum), {formatLength:'short'} );
        return ret;
      };

      var myFormatDateOnly = function( inDate ) {
        if ( inDate == null ) return "";
        return myFormatDate( inDate );
        var ret = dojo.date.locale.format(dojo.date.stamp.fromISOString(inDate), {selector:'date', formatLength:'short'} );
        alert( "DATE IS: " + ret );
        return ret;
      }

      var incidentSummaryData = {
      items: [
      { id: "min",
        timestamp: "",
        locString: "",
        memo: "",
        delay: "12.4"
      },
      { id: "mean",
        timestamp: "",
        locString: "",
        memo: "",
        delay: "12.4"
      },
      { id: "max",
        timestamp: "",
        locString: "",
        memo: "",
        delay: "12.4"
      }
      ]};

      var incidentSummaryLayout = [
      {field:'id',width:'10%'},
      {field:'timestamp',width:'10%'},
      {field:'locString',width:'20%'},
      {field:'memo',width:'50%'},
      {field:'delay',dataType:'Float', width:'10%'}
      ];

      dojo.addOnLoad(function(){ incidentList ? incidentList.initApp() : alert( "NO INCIDENT LIST!" );});
    </g:javascript>

  </head>
  <body onload="" 
	class="tundra">
    <div dojoType="tmcpe.IncidentList" jsId="incidentList" id="incidentList"></div>

    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
	From: 
	<input type="text" style="width:8em;" name="startDate" id="startDate" value="" dojoType="tmcpe.MyDateTextBox"
	       required="false" />
	To: 
	<input type="text" style="width:8em;" name="endDate" id="endDate" value="" dojoType="tmcpe.MyDateTextBox"
	       required="false" />
	Start Time:
	<input type="text" style="width:7em;" name="earliestTime" id="earliestTime" value="" dojoType="tmcpe.MyTimeTextBox"
	       required="false" />
	End Time:
	<input type="text" style="width:7em;" name="latestTime" id="latestTime" value="" dojoType="tmcpe.MyTimeTextBox"
	       required="false" />
	<label for="freeway">
	  Facility
	</label>
	<input id="fwy" type="text" style="width:3em;" dojoType="dijit.form.NumberTextBox" name="freeway" 
	       value="" invalidMessage="Invalid facility."/>
	<label for="dir">
	  Direction
	</label>
	<input id="dir" type="text" style="width:1.5em;" dojoType="dijit.form.TextBox" name="direction" 
	       value="" invalidMessage="direction"/>
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
	<label for="onlyAnalyzed">Limit to Analyzed</label>	
	<input id="onlyAnalyzed" name="Analyzed" 
	       dojoType="dijit.form.CheckBox" 
	       value="" 
	       checked=""
	       onChange="arguments[0] ? incidentGrid.setQuery({analysesCount:'1'}) : incidentGrid.filter({})"
	       onLoad="dojo.byId('onlyAnalyzed').value ? incidentGrid.setQuery({analysesCount:'1'}) : incidentGrid.filter({})"
	       />
	<button dojoType="dijit.form.Button" type="submit" name="submitButton"
		value="Submit">
          Submit
	  <script type="dojo/method" event="onClick" args="evt">
	    // It's valid, update the map query
	    var il = dijit.byId( 'incidentList' );
	    il.updateIncidentsQuery();
	  </script>
	</button>
	<button dojoType="dijit.form.Button" type="reset">
          Reset
	</button>
      </div>
      <div dojoType="dijit.layout.BorderContainer" id="mapgrid" region="center" design="sidebar" style="background:green;" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.ContentPane" id="mapPane" region="center" style="background:yellow;" splitter="false" liveSplitters="false">
	  <div dojoType="tmcpe.TestbedMap" id="map" jsId="map"></div>
	</div>
	<div dojoType="dijit.layout.ContentPane" gutters="true" region="right" style="width: 300px">
	  <p id="incidentDetails">Select an incident on the map to view its details here.</p>
	</div>
      </div>

      <div dojoType="dijit.layout.BorderContainer" id="gridRegion" region="bottom" design="sidebar" splitter="true" liveSplitters="false" gutters="false" style="height:15em;">
	<div dojoType="dijit.layout.ContentPane" id="gridContainer" region="center" style="background:purple;" splitter="false" liveSplitters="false" style="height:50%">
	  <table id="incidentGrid" 
		 jsId="incidentGrid" 
		 dojoType="dojox.grid.DataGrid" 
		 sortInfo=2
		 region="center"
		 rowSelector="20px"
		 onRowClick="incidentList.simpleSelectIncident"
		 style="width:100%;height:5em;"
		 >
	    <thead>
	      <tr>
		<th field="cad" dataType="String" width="10%">CAD ID</th>
		<th field="timestamp" dataType="Date" formatter="myFormatDate" width="10%">Timestamp</th>
		<th field="locString" dataType="String" width="20%">Section</th>
		<th field="memo" dataType="String" width="45%">Description</th>
		<th field="delay" dataType="Float" width="10%">Delay</th>
		<th field="analysesCount" dataType="Integer" width="5%">Analyses</th>
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
