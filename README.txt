DOMAIN MODEL

We want to be able to model the delay assocated with given incidents,
keyed on certain parameters gleaned from the activity logs

Initially, we'll focus on incidents only...

The processing looks like this:

1 Receive activity log data via replication

2 Append the postgres activity log tables with the new data---Create a perl script to do this, possibly?

3 Run a perl script to identify, for each incident/event, the critical
  management events that correspond to the flowcharts.  The perl
  script should populate the Incident table and push these critical
  events into an IncidentEvent table.

4 The incident event table should be used to generate a default
  analysis that gets pushed to GAMS to compute facility impacts.



SECURITY

We're looking to integrate the TMCPE app with some sort of single sign-on system..

