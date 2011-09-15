<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
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
    <p:javascript src='jquery.tipsy' />
    <p:javascript src='jquery.svg' />    <!-- plugins for manipulating svg using jquery -->
    <p:javascript src='jquery.svgdom' /> <!-- plugins for manipulating svg using jquery -->

    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='polymaps_cluster' />
    <p:javascript src='d3' />
    <p:javascript src='d3.time' />
    <p:javascript src='protovis' />
    <p:javascript src='jquery.tools.min'/>
<!--
    <script type="text/javascript" src="http://cdn.jquerytools.org/1.2.5/jquery.tools.min.js" />
-->

    <!-- supporting css -->
    <p:css name="tipsy" />


    <!-- app code -->
    <p:javascript src='tmcpe/map-show' />

    <script type="text/javascript">
      var map_show_params = ${tparams};
    </script>

  </head>
  <body>
    <div id='tmcpeapp'>
      <div class='content'>
	<div id='leftbox'>
	  <div id='mapview' tabindex="1"></div>
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
	    <table style="float:right;">
	      <tr>
		<th>Year</th>
		<td>
		  <select id="year">
		    <option value="2011">2011</option>
		    <option selected="true" value="2010">2010</option>
		    <option value="2009">2009</option>
		  </select>
		</td>
	      </tr>
	    </table>
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
