<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="layout" content="tmcpe" />
	<title>TMC Performance Evaulation</title>

	<r:require modules="docs"/>
  </head>

  <body>
	<header class="hero-unit">
	  <hgroup>
		<h1>TMC Performance Evaluation</h1>
		<p>
		  A tool for evaluating the benefits of Traffic Management Centers using
		  observed incidents as a baseline for comparison.
		</p>
	  </hgroup>

	  <nav class="subnav">
		<ul class="nav nav-pills">
		  <li><a href="#intro">Intro</a></li>
		  <li><a href="#method">Method</a></li>
		  <li><a href="#web-application">Application</a></li>
		  <li><a href="#further-info">Further Info</a></li>
		  <li><a href="#current-stats">Current Stats</a></li>
		</ul>
	  </nav>
	</header>


	<section id="intro">
	  <header class="page-header">
		<h2>What is TMC Performance Evaulation (TMCPE)?</h2>
	  </header>
	  <div class="row-fluid">
		<div class="span1 columns">
		  &nbsp;
		</div>
		<div class="span11 columns">
		  The TMCPE website is an analysis tool that allows
		  users to estimate the benefit provided by Caltrans
		  Traffic Management Centers by estimating the actual
		  delay caused by managed events using Caltrans loop
		  detector data and modeling the delays that would have
		  occured had TMC mitigation efforts not occured.

		  <section id="benefits">
			<header>
			  <h3>What benefits can be estimated?</h3>
			</header>
			<p>
			  The TMCPE method uses as its primary performance
			  measure the delay associated with events that either
			  disrupt the capacity of the system (e.g., accidents,
			  construction, etc) or alter the demand placed on
			  particular facilities (e.g., a baseball game).  In
			  order to estimate the TMC benefits, we have to map the
			  actions of TMC personnel onto the inputs of the delay
			  estimation model that defines the performance
			  measures---in this case, the extent and degree of
			  congestion caused by the event under consideration.
			</p>
		  </section>

		  <section id="background">
			<header>
			  <h3 id="background">Background?</h3>
			</header>
			<p>
			  Caltrans has a significant investment in TMCs throughout the
			  state. These operations centers are tasked with maintaining
			  the safety and efficiency of California's highways by actively
			  managing disruptions to the system caused by anticipated and
			  unanticipated events that impact the available capacity and/or
			  the demand to use individual facilities.
			</p>
			<p>To date, however, no comprehensive methods are
			available to quantify the benefits of existing TMC
			deployments.  This ongoing research project is
			developing a TMC performance evaluation system that
			addresses this problem. The system allows TMC managers
			to evaluate the performance of various bundles of TMC
			technologies and operational policies by mapping their
			effects onto events in the system that can be measured
			using existing surveillance systems and daily activity
			logs. The resulting tool provides managers with the
			long needed capabilities to:
			</p>
			<ul>
			  <li>justify valuable technology, personnel allocations,
			  and maintenance costs,</li>
			  <li>identify technologies that aren’t meeting their
			  initial promise, and</li>
			  <li>identify gaps in current operational strategies that
			  might be filled with new technology deployments.</li>
			</ul>

		  </section>
		</div>
	  </div>
	</section>

	<section id="method">
	  <header class="page-header">
		<h2>Method</h2>
	  </header>
	  <div class="row-fluid">
		<div class="span1 columns">
		  &nbsp;
		</div>
		<div class="span10 columns">
		  <p>
			The evaluation method used primarily considers delay
			savings that are attributable to specific TMC actions.  All
			computations are based on direct measurement of the system
			using available sensors and do not rely on speculative
			simulation models requiring extensive assumptions.
		  </p>
		  <p>
			The system is implemented using a modular software
			architecture that can interface with a variety of
			existing or planned systems used by Caltrans. The
			initial deployment focuses on delivering a reporting
			system accessible from the Testbed Website. Possible
			future deployments could be integrated the core
			performance evaluation models with real-time TMC
			management systems to assist operators with
			prioritizing response.
		  </p>
		  
		  <section id="input-data">
			<header>
			  <h3>Input Data</h3>
			</header>

			<p>
			  The following datasets are
			  replicated in local Postgresql databases and used in
			  the analysis:
			</p>
			<ul>
			  <li>PeMS 5 minute data, obtained from the <a href="http://pems.eecs.berkeley.edu/">PeMS clearinghouse</a></li>
			  <li>District 12 TMC Activity Log Data, the log
			  database is replicated in
			  the <a href="http://atmstestbed.net">Caltrans ATMS
			  Testbed</a></li>
			  <li>CHP iCAD data, since mid-2009 replicated as part
			  of the District 12 TMC Activity Log</li>
			</ul>
		  </section>
		  
		  <section id="preprocessing">
			<header>
			  <h3>Preprocessing Steps</h3>
			</header>

			<p>The TMC Activity Log Data is preprocessed to identify
			the time and location of critical events in incident
			management as defined in
			the <a href="http://localhost/redmine/projects/tmcpe/wiki/Event_Management_Flowchart"
			class="wikilink">event management flow charts</a>
			including: first call, verification, TMC response
			actions ranging from dispatching traffic management
			team to displaying CMS messages, TMC monitoring, and
			the end of incident management.
			</p>
		  </section>
		  
		  <section id="measured-delay">
			<header>
			  <h3>Computing Measured Incident Delay.</h3>
			</header>
			<p>
			  The delay calculation estimates the
			  time-space region affected by the incident by using
			  sensor data evidence and assumptions regarding the
			  physical characteristics of traffic flow.  This
			  evidence is formulated into an Integer Program that
			  seeks to identify the time-space region "impacted" by
			  the event such that the degree to which the evidence
			  of congestion as shown in the following image
			</p>

			<div class="centered cleared">
			  <p:image src="doc/tsd-example.png" style="width:67%;border-style:solid;border-width:2px;" />
			</div>

			<p>
			  which shows how the speed during this incident
			  deviated from the average (green = close to mean or
			  faster, red=far below the mean speed).  The blue
			  border shows the affected region estimated by the
			  TMCPE delay algorithm.
			</p>
		  </section>
		  
		  <section id="tmc-benefits">
			<header>
			  <h3>Compute TMC Benefits.</h3>
			</header>
			<p>
			  The "impacted" time-space region identified in step 3
			  serves as the basis for determining the benefits
			  provided by the TMC.  Using this "control volume" as a
			  starting point, we model the lack of TMC
			  actions---such as incident verification via CCTV
			  cameras---as a change in the shape (typically an
			  increase) of the impacted region which defines
			  additional delay.  The difference between the observed
			  delays and those estimated in the absence of the TMC
			  is interpreted as delay savings attributable to TMC
			  actions.  <span class="emph">This feature is not yet
			  incorporated into the website.</span>
			  <!--
				  Refer
				  to <a href="http://localhost/redmine/issues/25">this
				  page</a> to track progress on this issue.
			  -->
			</p>
		  </section>
		</div>
	  </div>
	</section>

	<section id="web-application">
		<header class="page-header">
		  <h2>The Web Application</h2>
		</header>
	  <div class="row-fluid">
		<div class="span1 columns">
		  &nbsp;
		</div>
		<div class="span10 columns">

		  The web application is designed around three sets of core
		  functionality: 
		  <ul>
			<li>a broad, aggregate view of TMC Performance,</li>
			<li>a detailed, aggregate view of TMC Performance for particular
			groupings of incidents, and</li>
			<li>a detailed view of TMC Performance for specific incidents</li>
		  </ul>

		  <section id="home-pages">
			<header>
			  <h3>The Home Pages</h3>
			</header>

			<p>
			  In addition to providing this background information
			  about the site, the main home page (click the
			  "<a href="${createLink(controller:'home')}">Home</a>"
			  button shows summary statistics for all incidents in
			  the activity log database including the number that
			  have been analyzed and the computed delays and
			  attributable TMC delay savings.
			</p>

		  </section>

		  <section id="query-interface">
			<header>
			  <h3>The Query Interface</h3>
			</header>
			<p>
			  More generally, however, the site is designed as a
			  reporting tool whereby the analyst can define a set of
			  event criteria using logical and spatial queries to
			  identify a class of events to study.  Delay and TMC
			  impact for these events can be viewed and summary
			  statistics for the selected group are provided.

			  You can access the query reporting feature by clicking
			  on the
			  "<a href="${createLink(controller:'map')}">Query
			  Incidents</a>" button in the top right corner of the
			  page.
			</p>
		  </section>

		  <section id="detail-view">
			<header>
			  <h3>The Detail View</h3>
			</header>
			<p>
			  ...
			</p>
		  </section>
		</div>
	  </div>
	</section>

	<section id="further-info">
	  <header>
		<h2>Further Information</h2>
	  </header>
	  <div class="row-fluid">
		<div class="span1 columns">
		  &nbsp;
		</div>
		<div class="span10 columns">
		  <p>
			Detailed documentation about the site is available
			from
			the <a href="http://localhost/redmine/projects/tmcpe">Testbed
			issue tracking tool </a>.  You must be an
			authenticated user to use this site.  Useful links:
			<ul>
			  <li>Tooltips are provided where possible to guide
			  the user on how to use the interface</li>
			  <li>The <a href="http://localhost/redmine/projects/tmcpe/wiki">User Guide</a></li>
			</ul>
		  </p>
		</div>
	  </div>
	</section>

	<section id="current-stats">
	  <header>
		<h2>Current Statistics</h2>
	  </header>
	  <div class="row-fluid">
		<div class="span1 columns">
		  &nbsp;
		</div>
		<div class="span10 columns">

		  <p>Current statistics for period between ${stats["tot"].tot[1]} and ${stats["tot"].tot[2]}</p>
		  <table class="table table-striped table-condensed">
			
			<thead>
			  <tr><th id="eventTypeHeader">Event type</th><th id="analyzedHeader" class="number">Analyzed</th><th id="totalColumnHeader" class="number">Total</th><th id="delayColumnHeader" class="number">Analyzed Delay</th><th id="tmcSavingsColumnHeader" class="number">TMC Delay Savings</th></tr>
			</thead>
			<g:each in="${stats.findAll {it.key != 'tot'}}">
			  <tr>
				<td>${it.key}</td>
				<td class="number"><g:formatNumber number="${it.value.analyzed}" format="###,##0"/></td>
				<td class="number"><g:formatNumber number="${it.value.tot[0]}" format="###,##0"/></td>
				<td class="number"><g:formatNumber number="${it?.value?.delay?it?.value?.delay:0}" format="###,##0"/></td>
				<td class="number" id="unavailable"><!--<g:formatNumber number="0" format="###,##0"/>-->n/a</td>
			  </tr>	  
			</g:each>
			<tfoot>
			  <tr>
				<th>Total</th>
				<th class="number"><g:formatNumber number="${stats['tot'].analyzed[0]}" format="###,##0"/></th>
				<th class="number"><g:formatNumber number="${stats['tot'].tot[0]}" format="###,##0"/></th>
				<th class="number"><g:formatNumber number="${stats['tot']?.delay?stats['tot'].delay:0}" format="###,##0"/></th>
			  <th class="number" id="unavailable"><!--<g:formatNumber number="0" format="###,##0"/>-->n/a</th></tr>
			</tfoot>
		  </table>
		  <!-- Summary Table Tooltips -->
		  <!--
			  <span dojoType="dijit.Tooltip"
			  connectId="eventTypeHeader">
			  The event type classification
			  </span>
			  <span dojoType="dijit.Tooltip"
			  connectId="analyzedHeader"> The number of each event
			  type that have been analyzed for delay.  Only incidents
			  whose location is known are automatically analyzed.
			  </span>
			  <span dojoType="dijit.Tooltip"
			  connectId="totalColumnHeader">
			  The total number of each event type in the database
			  </span>
			  <span dojoType="dijit.Tooltip"
			  connectId="delayColumnHeader">
			  The computed delay for analyzed incidents in each category
			  </span>
			  <span dojoType="dijit.Tooltip"
			  connectId="tmcSavingsColumnHeader"> The computed TMC
			  delay savings for analyzed incidents in each
			  category.  <span class="alert">This computation is not
			  yet available on the website.</span>
			  </span>
			  <span dojoType="dijit.Tooltip"
			  connectId="unavailable"> This computation is not yet available on the website.
			  </span>
-->
		</div>
	  </div>
	</section>
  </body>
</html>
