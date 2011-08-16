<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="bare" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1.min' />
    <p:javascript src='underscore' />

    <!-- formatting -->
    <p:javascript src='jquery.format-1.2.min' />
    <p:javascript src='jquery.dataTables' />
    <p:javascript src='jquery.svg' />    <!-- plugins for manipulating svg using jquery -->
    <p:javascript src='jquery.svgdom' /> <!-- plugins for manipulating svg using jquery -->

    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='polymaps_cluster' />
    <p:javascript src='d3' />
    <p:javascript src='d3.time' />
    <p:javascript src='protovis' />

    <!-- app code -->
    <p:javascript src='tmcpe/tmcpe-revamp' />
  </head>
  <body>
    <div id='tmcpeapp'>
      <div class='content'>
	<div id='leftbox'>
	  <div id='mapview'></div>
	  <div id='cluster-detail'>
	    <ul id='cluster-list'>
	    </ul>
	    <p id='cluster-stats'></p>
	  </div>
	</div>
	<div id='content'>
	  <!--
	  <div class='input-block'>
	    <input id='new-incident' placeholder='What data do you want?' type='text' />
	    <span class='ui-tooltip-top'>Press Enter to search</span>
	  </div>
-->
	  <div id='incident-table'></div>
	  <div id='incident-stats' style="height:200px"></div>
	</div>
      </div>
      <div id='loading'>
	<div id='loading_block'>Loading data...</div>
      </div>
    </div>
  </body>
</html>
