<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="bare" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1' />
    <p:javascript src="jquery.tools.min" />
    <p:javascript src='underscore' />
    <p:javascript src='mustache' />

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
    <p:javascript src='tmcpe/incident-summary' />

    <!-- supporting css -->

    <!-- less stylesheets -->
    <less:stylesheet name="tmcpe-incident-summary" />
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
	  <!--
	      <h1>Aggregates</h1>
	  -->
	  <p>
	    The TMC Performance Evaluation project is designed to offer measures
	    of effectiveness for Caltrans Traffic Management centers by
	    analyzing the delay impacts of accidents, maintenance activities,
	    construction activities, and special events.
	  </p>
	  <p>
	    The analyses compute delays for incidents using an optimization
	    algorithm to bound the range of incident-induced delay and infer
	    savings attributable to TMC activity by projecting the likely
	    impacts of the same events if TMC management actions weren't taken.
	  </p>
	  <p>
	    The chart to the right offers a summary of the analyses.  Clicking
	    on the bars will open a new window providing the details of the
	    associated group of incidents.
	  </p>
	</div>
	<div id='content'>
	  <h3>Performance Summary (total number of incidents)</h3>
	  <div class='querybox'>
	    <!-- the tabs -->
	    <ul class="tabs">
	      <li><a href="#">Basic Query</a></li>
	      <li><a href="#">Advanced Query</a></li>
	    </ul>
	    
	    <!-- tab "panes" -->
	    <div class="panes">
	      <div id="basicQueryPane" class="queryPane">
		<table>
		  <tr>
		    <th>
		      Group vertically by:
		    </th>
		    <th>
		      Stack horizontally by:
		    </th>
		    <th>
		      Filter by:
		    </th>
		  </tr>
		  <tr>
		    <td>
		      <div style="display:inline;" id='groupby'>
			<g:select name="groups"
				  from="${formData}"
				  optionKey="key" 
				  optionValue="pretty"
				  title="Select the parameter for the vertical groupings in the chart"
				  />
		      </div>
		    </td>
		    <td>
		      <div style="display:inline;" id='stackby'>
			<g:select name="stackgroups"
				  from="${formData}"
				  optionKey="key" 
				  optionValue="pretty"
				  title="Select the parameter for the horizontal groupings in the chart"
				  />
		      </div>
		    </td>
		    <td>
		      <div style="display:inline;" id='filterby'>
			<g:select name="filters"
				  from="${filterData}"
				  optionKey="key"
				  optionValue="text"
				  title="Select any filters you'd like to apply"
				  />
		      </div>
		    </td>
		  </tr>
		</table>
	      </div>
	      <div class="queryPane">
		<table>
		  <tr>
		    <th>
		      Enter in custom query terms...
		    </th>
		  </tr>
		  <tr>
		    <td>
		      <input type="text" id='advancedqueryinput' value='groups=year&stackgroups=eventType' style="width:30em"></input>
		    </td>
		  </tr>
		</table>
	      </div>
	    </div>
	  </div>
	  <div id='aggchart'></div>
	</div>
      </div>
    </div>
    <!-- tooltips -->
    <div id="chartTip" style="display:none" class="tooltip left"></div>
  </body>
</html>
