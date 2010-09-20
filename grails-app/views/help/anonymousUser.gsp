<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>TMC Performance Evaulation</title>
    <meta name="layout" content="main" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->
    <!-- Load the map javascript and css -->
    <!-- <tmcpe:openlayers_latest /> --> <!--  brings in the openlayers stuff -->
    <tmcpe:tmcpe />              <!-- This loads the tmcpe (dojo-based) interface framework -->

    <g:javascript>
      dojo.require("dijit.Tooltip");
    </g:javascript>
    
  </head>

  <body onload="" 
	class="tundra">
    <!-- Application -->
         <!-- (none) -->

    <!-- Viewport -->
    <div dojoType="dijit.layout.BorderContainer" id="homeView" design="headline" region="center" gutters="true" liveSplitters="false">
      <div dojoType="dijit.layout.BorderContainer" id="contentpane" design="headline" region="center">
	<div dojoType="dijit.layout.BorderContainer" id="cc" region="center">
	    <div dojoType="dijit.layout.ContentPane" title="Overview" class="docpage" region="center">
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
	</div>
    </div>
  </body>
</html>
