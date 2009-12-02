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
      <div dojoType="dijit.layout.BorderContainer" design="sidebars" region="center" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.ContentPane" id="map" region="center" style="background:yellow;" splitter="false" liveSplitters="false"></div>
	<div dojoType="dijit.layout.ContentPane" region="bottom" id="incidentSearch" splitter="true" liveSplitters="false" style="height:200px;">
	  <table id="incidentGridNode" 
		 jsId="incidentGrid" 
		 dojoType="dojox.grid.DataGrid" 
		 region="center"
		 rowSelector="20px"
		 onRowClick="simpleSelectIncident"
		 >
	    <thead>
	      <tr>
		<th field="id" dataType="String" width="100px">CAD ID</th>
		<th field="timestamp" dataType="Date" formatter="myFormatDate" width="150px">Timestamp</th>
		<th field="locString" dataType="String" width="300px">Section</th>
		<th field="memo" dataType="String" width="auto">Description</th>
	      </tr>
	    </thead>
	  </table>
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
