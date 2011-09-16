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
    <script type="text/javascript" src="http://cdn.jquerytools.org/1.2.5/jquery.tools.min.js" />

    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='polymaps_cluster' />
    <p:javascript src='d3' />
    <p:javascript src='d3.time' />
    <p:javascript src='protovis' />

    <!-- app code -->
    <p:javascript src='tmcpe/summary-index' />

    <!-- supporting css -->
    <p:css name="debug" />
<!--
    <p:css name="tst" />
-->

    <!-- less stylesheets -->
    <less:stylesheet name="tmcpe-summary-index" />
    <less:stylesheet name="tabs-no-images" />

   <!-- note: less:scripts loaded by base.gsp -->

  </head>
  <body>
    <!-- Main body of TMCPE Summary/Index -->
    <div id='tmcpeapp'>
      <!-- Start of content block -->
      <div class='content'>
	<!-- Start of left info box -->
	<div id='leftbox' class="">
	  <h1>Aggregates</h1>
	</div>
	<div id='content'>
	  <div class='querybox'>
	    <!-- the tabs -->
	    <ul class="tabs">
	      <li><a href="#">Basic Query</a></li>
	      <li><a href="#">Advanced Query</a></li>
	    </ul>
	    
	    <!-- tab "panes" -->
	    <div class="panes">
	      <div>Test</div>
	      <div><input type="text" id='advancedqueryinput' value='groups=year&stackgroups=eventType' style="width:30em"></input></div>
	    </div>
	  </div>
	  <div id='aggchart'></div>
	  <div id='aggchartdetail'></div>
	</div>
      </div>
      <div id='loading'>
	<div id='loading_block'>Loading data...</div>
      </div>
    </div>
  </body>
</html>
