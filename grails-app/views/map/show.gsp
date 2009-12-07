<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Testbed Network View Using Openlayers</title>
    <meta name="layout" content="main" />
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'tmcpe.css')}" />
<!--
    <script type="text/javascript" djConfig="parseOnLoad: true"
	    src="${createLinkTo(dir:'js/dojo/dojo-release-1.3.2/dojo',file:'dojo.js')}"></script>
-->
    <script type="text/javascript" djConfig="parseOnLoad: true"
	    src="${createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js')}"></script> 
    <!--    <g:javascript library="tmcpe/tmcpe" />  -->
    <script src="${createLinkTo(dir:'js/tmcpe',file:'/ItemVectorLayerReadStore.js')}" djConfig="parseOnLoad: true"></script>
    <script src="${createLinkTo(dir:'js/tmcpe',file:'/tmcpe.js')}" djConfig="parseOnLoad: true"></script>
    <g:javascript>
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dijit.InlineEditBox");
      dojo.require("dijit.form.DateTextBox");
      dojo.require("dijit.form.TimeTextBox");
      dojo.require("dijit.form.NumberTextBox");
      dojo.require("dijit.form.Form");
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
        alert( "DATE IS: " + ret );
        return ret;
      }

      dojo.declare("MyDateTextBox", dijit.form.DateTextBox, {
            myFormat: {
                selector: 'date',
                datePattern: 'yyyy-MM-dd',
                locale: 'en-us'
            },
            value: "",
            // prevent parser from trying to convert to Date object
            postMixInProperties: function() { // change value string to Date object
                this.inherited(arguments);
                // convert value to Date object
                this.value = dojo.date.locale.parse(this.value, this.myFormat);
            },
            // To write back to the server in Oracle format, override the serialize method:
            serialize: function(dateObject, options) {
                return dojo.date.locale.format(dateObject, this.myFormat).toUpperCase();
            }
        });

      dojo.declare("MyTimeTextBox", dijit.form.TimeTextBox, {
            myFormat: {
                selector: 'time',
                timePattern: 'HH:mm',
                locale: 'en-us'
            },
            value: "",
            // prevent parser from trying to convert to Date object
            postMixInProperties: function() { // change value string to Date object
                this.inherited(arguments);
                // convert value to Date object
                this.value = dojo.date.locale.parse(this.value, this.myFormat);
            },
            // To write back to the server in Oracle format, override the serialize method:
            serialize: function(dateObject, options) {
                return dojo.date.locale.format(dateObject, this.myFormat).toUpperCase();
            }
        });

      dojo.declare("DefaultSortableGrid", dojox.grid.DataGrid, {
         sortInfo: 1 // the index (1-based) of the column 
                     // to sort, + => asc, - => desc
      });

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

      dojo.addOnLoad(function(){});
    </g:javascript>

    <!-- Load the map javascript -->
    <tmcpe:testbedMap />

  </head>
  <body onload="initApp();" 
	class="tundra"><!--pees-->

    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
	From: 
	<input type="text" style="width:8em;" name="startDate" id="startDate" value="" dojoType="MyDateTextBox"
	       required="false" />
	To: 
	<input type="text" style="width:8em;" name="endDate" id="endDate" value="" dojoType="MyDateTextBox"
	       required="false" />
	Start Time:
	<input type="text" style="width:7em;" name="earliestTime" id="earliestTime" value="" dojoType="MyTimeTextBox"
	       required="false" />
	End Time:
	<input type="text" style="width:7em;" name="latestTime" id="latestTime" value="" dojoType="MyTimeTextBox"
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
	<button dojoType="dijit.form.Button" type="submit" name="submitButton"
		value="Submit">
          Submit
	  <script type="dojo/method" event="onClick" args="evt">
	    // It's valid, update the map query
	    updateIncidentsQuery();
	  </script>
	</button>
	<button dojoType="dijit.form.Button" type="reset">
          Reset
	</button>
      </div>
      <div dojoType="dijit.layout.BorderContainer" id="mapgrid" region="center" design="sidebar" style="background:green;" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.ContentPane" id="map" region="center" style="background:yellow;" splitter="false" liveSplitters="false">
	</div>
	<div dojoType="dijit.layout.BorderContainer" id="gridRegion" region="bottom" design="sidebar" splitter="true" liveSplitters="false" gutters="false" style="height:15em;">
	  <div dojoType="dijit.layout.ContentPane" id="gridContainer" region="center" style="background:purple;" splitter="false" liveSplitters="false" style="height:50%">
	    <table id="incidentGridNode" 
		   jsId="incidentGrid" 
		   dojoType="dojox.grid.DataGrid" 
		   sortInfo=2
		   region="center"
		   rowSelector="20px"
		   onRowClick="simpleSelectIncident"
		   style="width:100%;height:5em;"
		   >
	      <thead>
		<tr>
		  <th field="id" dataType="String" width="10%">CAD ID</th>
		  <th field="timestamp" dataType="Date" formatter="myFormatDate" width="10%">Timestamp</th>
		  <th field="locString" dataType="String" width="20%">Section</th>
		  <th field="memo" dataType="String" width="50%">Description</th>
		  <th field="delay" dataType="Float" width="10%">Delay</th>
		</tr>
	      </thead>
	    </table>
	  </div>
<!--
	  <div dojoType="dijit.layout.ContentPane" id="gridSummaryContainer" region="bottom" style="background:yellow;" splitter="false" liveSplitters="false">
	    <div dojoType="dojo.data.ItemFileReadStore" data="incidentSummaryData" jsId="incidentSummaryStore" id="incidentSummaryNode" defaultTimeout="20000"></div>
	    <table id="incidentSummaryGridNode" 
		   jsId="incidentSummaryGrid" 
		   dojoType="dojox.grid.DataGrid" 
		   sortInfo=2
		   region="center"
		   rowSelector="20px"
		   store="incidentSummaryStore"
		   style="width:100%;height:100%;"
		   structure="incidentSummaryLayout"
		   >
	    </table>
	  </div>
-->
	</div>
      </div>
      <div dojoType="dijit.layout.ContentPane" gutters="true" region="right" style="width: 300px">
	<!--Select an incident on the map to view its details here.-->
	<p id="incdet">Select an incident on the map to view its details here.</p>
	<!--
	    <div dojoType="dojox.layout.TableContainer" cols="1" id="tc1">
	      <div dojoType="dijit.form.TextBox" id="incdet.Cad" title="CAD:" value="">
	      </div>
	      <div dojoType="dijit.form.TextBox" id="incdet.DateTime" title="Timestamp:" value="">
	      </div>
	      <div dojoType="dijit.form.TextBox" id="incdet.Section" title="Section" value="">
	      </div>
	      <div dojoType="dijit.form.TextBox" id="incdet.Description" title="Description" value="">
	      </div>
	    </div>
	    -->
      </div>
    </div>
    
    <!-- Incident Data -->
    <div dojoType="dojo.data.ItemFileReadStore" data="{items:[]}" jsId="incidentStore" id="incidentStoreNode" defaultTimeout="20000"></div>
  </body>
</html>
