<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="bare" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1' />
    <p:javascript src='underscore' />

    <!-- formatting -->
    <p:javascript src='jquery.format-1.2.min' />
    <p:javascript src='jquery.dataTables' />
    <p:javascript src='jquery.tipsy' />
    <p:javascript src='jquery.svg' />    <!-- plugins for manipulating svg using jquery -->
    <p:javascript src='jquery.svgdom' /> <!-- plugins for manipulating svg using jquery -->

    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='polymaps_cluster' />
    <p:javascript src='d3' />
    <p:javascript src='d3.time' />
    <p:javascript src='protovis' />

    <!-- app code -->
    <p:javascript src='tmcpe/summary-index' />

    <!-- supporting css -->
    <p:css name="tipsy" />
    <p:css name="tmcpe-summary-index" />


  </head>
  <body>
    <div id='tmcpeapp'>
      <div class='content'>
	<div id='leftbox'>
	  <h1>Aggregates</h1>
	</div>
	<div id='content'>
	  <input type="text" id='querybox' value='groups=year&stackgroups=eventType' style="width:30em"></input>
	  <div id='aggchart'></div>
	</div>
      </div>
      <div id='loading'>
	<div id='loading_block'>Loading data...</div>
      </div>
    </div>
  </body>
</html>
