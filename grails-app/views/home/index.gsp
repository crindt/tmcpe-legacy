<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>TMC Performance Evaulation</title>
    <meta name="layout" content="tmcpe" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->
    <!-- Load the map javascript and css -->

    <p:dependantJavascript> <!-- render javascript at the end -->
      <g:javascript>
	dojo.addOnLoad(function(){ 
	  dojo.require("dijit.layout.StackContainer");
	  dojo.require("dijit.Tooltip");
	});
      </g:javascript>
    </p:dependantJavascript>
  </head>

  <body onload="" 
	class="tundra">
    <!-- Application -->
         <!-- (none) -->

    <!-- Viewport -->
    <div dojoType="dijit.layout.BorderContainer" id="homeView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.BorderContainer" id="contentpane" design="headline" region="center">
	<div dojoType="dijit.layout.BorderContainer" id="cc" region="center">
	  <div dojoType="dijit.layout.ContentPane" region="top">
	    <button id="previous" onClick="dijit.byId('contentstack').back()" dojoType="dijit.form.Button">
	      &lt;
	    </button>
	    <span dojoType="dijit.layout.StackController" containerId="contentstack">
	    </span>
	    <button id="next" onClick="dijit.byId('contentstack').forward()" dojoType="dijit.form.Button">
	      &gt;
	    </button>
	  </div>
	  <div dojoType="dijit.layout.StackContainer" id="contentstack" region="center">
	    <div dojoType="dijit.layout.ContentPane" title="Overview" class="docpage">
	      <h2>What is TMC Performance Evaulation (TMCPE)?</h2>
	      <p>
		The TMCPE website is an analysis tool that allows
		users to estimate the benefit provided by Caltrans
		Traffic Management Centers by estimating the actual
		delay caused by managed events using Caltrans loop
		detector data and modeling the delays that would have
		occured had TMC mitigation efforts not occured.
	      </p>
	      <h2>What benefits can be estimated?</h2>
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
	      <h2>Background?</h2>
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
	    </div>
	    <div dojoType="dijit.layout.ContentPane" title="Method" class="docpage">
	      <h2>Summary</h2>
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
	      <h2>Input Data</h2>
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
	      <h2>Preprocessing Steps</h2>
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
	      <h2>Computing Measured Incident Delay.</h2>  
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
	      <h2>Compute TMC Benefits.</h2>
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
	    </div>
	    <div dojoType="dijit.layout.ContentPane" title="Using the Site" class="docpage">
	      <h2>The Home Pages</h2>
	      <p>
		In addition to providing this background information
		about the site, the main home page (click the
		"<a href="${createLink(controller:'home')}">Home</a>"
		button shows summary statistics for all incidents in
		the activity log database including the number that
		have been analyzed and the computed delays and
		attributable TMC delay savings.
	      </p>
	      <h2>The Query Interface</h2>
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
	      <h2>Further Information</h2>
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
	</div>
	<div dojoType="dijit.layout.ContentPane" id="contentright" region="right" style="width:30%;">
	  <p>Current statistics for period between ${stats["tot"].tot[1]} and ${stats["tot"].tot[2]}</p>
	  <table class="summarytable">
	    <tr><th id="eventTypeHeader">Event type</th><th id="analyzedHeader" class="number">Analyzed</th><th id="totalColumnHeader" class="number">Total</th><th id="delayColumnHeader" class="number">Analyzed Delay</th><th id="tmcSavingsColumnHeader" class="number">TMC Delay Savings</th></tr>
	    <g:each in="${stats.findAll {it.key != 'tot'}}">
	      <tr>
		<td>${it.key}</td>
		<td class="number"><g:formatNumber number="${it.value.analyzed}" format="###,##0"/></td>
		<td class="number"><g:formatNumber number="${it.value.tot[0]}" format="###,##0"/></td>
		<td class="number"><g:formatNumber number="${it?.value?.delay?it?.value?.delay:0}" format="###,##0"/></td>
		<td class="number" id="unavailable"><!--<g:formatNumber number="0" format="###,##0"/>-->n/a</td>
	      </tr>	  
	    </g:each>
	    <tr>
	      <td>Total</td>
	      <td class="number"><g:formatNumber number="${stats['tot'].analyzed[0]}" format="###,##0"/></td>
	      <td class="number"><g:formatNumber number="${stats['tot'].tot[0]}" format="###,##0"/></td>
	      <td class="number"><g:formatNumber number="${stats['tot']?.delay?stats['tot'].delay:0}" format="###,##0"/></td>
	      <td class="number" id="unavailable"><!--<g:formatNumber number="0" format="###,##0"/>-->n/a</td></tr>
	  </table>
	  <!-- Summary Table Tooltips -->
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
	</div>
      </div>
    </div>
  </body>
</html>
