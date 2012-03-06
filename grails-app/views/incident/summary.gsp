<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="tmcpe" />
    <title>Incident List</title>

    <!-- frameworks -->
    <r:require module="stdui" />
    <r:require module="datatables" />

    <!-- visualization toolkits -->
    <r:require module="polymaps" />
    <r:require module="dthree" />

    <!-- app code and stylesheets -->
    <r:require module="tmcpe-incident-summary" />
  </head>
  <body>
    <!-- Main body of TMCPE Summary/Index -->
    <div id="tmcpeapp" class="row-fluid">
	  <div id="content" class="span10">
		<h3>Performance Summary (total number of incidents)</h3>
		<div class='querybox tabbable'>
		  <!-- the tabs -->
		  <ul class="nav nav-tabs">
			<li class="active"><a href="#basicQueryPane" data-toggle="tab">Basic Query</a></li>
			<li><a href="#advancedQueryPane" data-toggle="tab">Advanced Query</a></li>
		  </ul>
	      
		  <!-- tab "panes" -->
		  <div class="tab-content">
			<div id="basicQueryPane" class="tab-pane active queryPane">
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
			<div id="advancedQueryPane" class="tab-pane queryPane">
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
	  <!-- Start of right info box -->
	  <aside class="span2">
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
	</div>
	<!-- tooltips -->
	<div id="chartTip" style="display:none" class="tooltip left"></div>
  </body>
</html>
