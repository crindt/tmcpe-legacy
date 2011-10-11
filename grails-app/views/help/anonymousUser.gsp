<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="help" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1' />
    <p:javascript src="jquery.tools.min" />

    <!-- formatting -->

    <!-- visualization toolkits -->

    <!-- app code -->
    <p:javascript src='tmcpe/help' />

    <!-- supporting css -->

    <!-- less stylesheets -->
    <g:if env="development">
    </g:if>
    <g:if env="production">
    </g:if>
      

   <!-- note: less:scripts loaded by base.gsp -->

  </head>
  <body>
    <markdown:renderHtml>
# What is TMC Performance Evaulation (TMCPE)?

The TMCPE website is an analysis tool that allows users to estimate the
benefit provided by Caltrans Traffic Management Centers by estimating the
actual delay caused by managed events using Caltrans loop detector data
and modeling the delays that would have occured had TMC mitigation efforts
not occured.

## What benefits can be estimated?

The TMCPE method uses as its primary performance measure the delay
associated with events that either disrupt the capacity of the system
(e.g., accidents, construction, etc) or alter the demand placed on
particular facilities (e.g., a baseball game).  In order to estimate the
TMC benefits, we have to map the actions of TMC personnel onto the inputs
of the delay estimation model that defines the performance measures---in
this case, the extent and degree of congestion caused by the event under
consideration.

## Background?

Caltrans has a significant investment in TMCs throughout the state. These
operations centers are tasked with maintaining the safety and efficiency
of California's highways by actively managing disruptions to the system
caused by anticipated and unanticipated events that impact the available
capacity and/or the demand to use individual facilities.

To date, however, no comprehensive methods are available to quantify the
benefits of existing TMC deployments.  This ongoing research project is
developing a TMC performance evaluation system that addresses this
problem. The system allows TMC managers to evaluate the performance of
various bundles of TMC technologies and operational policies by mapping
their effects onto events in the system that can be measured using
existing surveillance systems and daily activity logs. The resulting tool
provides managers with the long needed capabilities to:

* justify valuable technology, personnel allocations, and maintenance
  costs,

* identify technologies that aren’t meeting their initial promise, and

* identify gaps in current operational strategies that might be filled
  with new technology deployments.
    </markdown:renderHtml>
  </body>
</html>
