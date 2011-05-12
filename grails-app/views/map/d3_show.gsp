<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="thin" />
    <title>Incident List</title>

    <p:css name="960-fluid" /> <!-- Load the 960 css -->
    <p:css name="jquery/themes/base/jquery-ui" />
    <p:css name="d3-hacks" />

    <p:javascript src='d3/d3.min' />
    <p:javascript src='d3/d3.geom.min' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery.min' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <p:javascript src='jquery-format/dist/jquery.format-1.2.min' />
    <p:javascript src='polymaps/polymaps' />
    <p:javascript src='protovis/protovis.min' />
    <p:javascript src='tmcpe/map' />
    <p:javascript src='datatables/jquery.dataTables' />

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

      d3.json
      ("incident/list.geojson"
      	    +"?startDate="+(year)+"-01-01"
      	    +"&endDate="+(parseInt(year)+1)+"-01-01"
//      +"?startDate=2010-09-01"
      +"&Analyzed=onlyAnalyzed"
      +"&max=1000", 
      function(e){
         qmap = tmcpe.query.qmap()
	 .container($("#map")[0]).data(e.features);

	 qtab = tmcpe.query.table()
	 .container($("#inctableContainer")[0]).map(qmap.map).data(qmap.data());

	 qmap.table( qtab );
	 $("#loading").css('visibility','hidden');
      });

	 $(window).resize(function() { 
	    qmap.resize();
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
	  <h3 id="incidentTitle">No incident selected</h3>
	  <div id="incidentDetailTableBox"></div>
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
