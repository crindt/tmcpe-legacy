<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident List</title>
    <base id="htmldom"  href="${resource(dir:'/',absolute:true)}" />


<!--
    <p:css name="po" />
-->


    <p:css name="960-fluid" /> <!-- Load the 960 css -->
    <p:css name="jquery/themes/base/jquery-ui" />
    <p:css name="d3-hacks" />
    <p:css name="tablescroll/jquery.tablescroll" />

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
    <p:javascript src='tablesorter/jquery.tablesorter.min' />
    <p:javascript src='tablescroll/jquery.tablescroll' />
    <g:javascript>
      var i = 0;

      var tsd;
      var qmap;
      var qtab;

      $(document).ready(function(){

	  
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD
      //doQueryMap();

      d3.json
      ("/incident/list.geojson"
      //	    +"?startDate=2009-01-01"
      //	    +"?startDate=2010-01-01"
      +"?startDate=2010-09-01"
      +"&Analyzed=onlyAnalyzed"
      +"&max=1000", 
      function(e){
         qmap = tmcpe.query.qmap()
	 .container($("#map")[0]).data(e.features);

	 qtab = tmcpe.query.table()
	 .container($("#inctableContainer")[0]).map(qmap.map).data(qmap.data());

	 qmap.table( qtab );
      });

	 $(window).resize(function() { 
//	    doQueryMap();
	 });


      });
		
    </g:javascript>     

  </head>
  <body>

    <div id="header" class="container_16">

      <div id="" class="grid_1 ">
      </div>

      <div id="" class="grid_14 ">

      </div>

    </div>


    <div id="content" class="container_16">

      <div id="" class="grid_16">

	<div id="mapbox" class="grid_8 alpha">
	  <div id="map" tabindex="1"></div>
	</div>
	

	<div id="infobox" class="grid_8 omega">
	  <div id="info">
	    <h3 id="incidentTitle">No incident selected</h3>
	    <div id="incidentDetailTableBox"></div>
	  </div>
	</div>
      </div>

      <div id="" class="grid_16">
	<div id="incidentListTablebox" class="grid_16 alpha omega">
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
