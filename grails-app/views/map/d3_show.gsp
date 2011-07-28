<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="thin" />
    <title>Incident List</title>

    <p:css name="960-fluid" /> <!-- Load the 960 css -->
    <p:css name="d3-hacks" />
    <p:css name="jquery.svg" />
    <p:css name="pagination" />
    <p:css name="tipsy" />
    

    <p:javascript src='d3' />
    <p:javascript src='d3.geom.min' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery-1.6.1.min' />
    <p:javascript src='jquery-ui-1.8.13.custom.min' />
    <p:javascript src='jquery.format-1.2.min' />
    <p:javascript src='jquery.svg' />
    <p:javascript src='jquery.svgdom' />
    <p:javascript src='polymaps' />
    <p:javascript src='protovis.min' />
    <p:javascript src='tmcpe/map' />
    <p:javascript src='jquery.dataTables' />
    <p:javascript src='jquery.pagination' />
    <p:javascript src='jquery.tipsy' />

    <p:javascript src='numberformat/NumberFormat154' />
    <g:javascript>
      var i = 0;

      var tsd;
      var qmap;
      var qtab;

      function setToYear( year ) {

	  var load=$("#loading").detach();
	  load.text("Loading incidents for "+year );
	  load.appendTo("body");
	  $("#loading").css('visibility','visible');
	  
	  var query = tmcpe.query("incident/list.geojson"
				  //      	    +"?startDate="+(year)+"-01-01"
				  +"?startDate=2010-09-01"
      				  +"&endDate="+(parseInt(year)+1)+"-01-01"
				  +"&Analyzed=onlyAnalyzed"
				  +"&max=1000");
	  
	  $(window).resize(function() { 
	      query.qmap.resize();
	  });
      }

      $(document).ready(function(){


	  var settings = $("#settings").detach();
	  settings.appendTo('#header');
	  
	  // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD
	  //doQueryMap();

	  setToYear( 2010 );

      });
		
    </g:javascript>     

  </head>
  <body>
    <div id="loading" class="loading">Loading new data...</div>
    <div id="content" class="container_16 clearfix">

      <div id="settings" style="display:inline;float:left;margin-left:10px;>
	<table style="float:left;">
	  <tr>
	    <th>Year</th>
	    <td>
	      <select id="year" onchange="setToYear(this.options[this.selectedIndex].value);">
<!--		<option value="2011">2011</option>-->
		<option selected="true" value="2010">2010</option>
<!--		<option value="2009">2009</option>-->
	      </select>
	    </td>
	  </tr>
	</table>
      </div>

      <div id="mapbox" class="grid_8 alpha">
	<div id="map" tabindex="1"></div>
      </div>
      
      
      <div id="infobox" class="grid_8 omega clearfix">
	<div id="info">
	  <div id="incidentDetail"><h3>No incident selected</h3></div>
	  <div id="incidentDetailPager"></div>
	</div>
      </div>

      <div id="" class="grid_16 alpha omega">
	<div id="incidentListTablebox">
	  <div id="inctableContainer">
	  </div>
	</div>
      </div>
    </div>

    <div id="footer" class="container_16">
      
      <div id="" class="grid_1">
      </div>
      
      <div id="" class="grid_14">
      </div>
      
    </div>
    
  </body>

</html>
