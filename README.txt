DOMAIN MODEL

We want to be able to model the delay assocated with given incidents,
keyed on certain parameters gleaned from the activity logs

Initially, we'll focus on incidents only...

The processing looks like this:

1 Receive activity log data via replication

2 Append the postgres activity log tables with the new data---Create a
  perl script to do this, possibly?
2a Also load in the iCAD data
2b Identify distinct CAD entries

3 Run a perl script to identify, for each incident/event, the critical
  management events that correspond to the flowcharts.  The perl
  script should populate the Incident table and push these critical
  events into an IncidentEvent table.

4 The incident event table should be used to generate a default
  analysis that gets pushed to GAMS to compute facility impacts.  The
  results of this analysis should be pushed into the db for easier
  access by the webapp.  It may be useful to have grails/gorm handle
  this part so that the ORM stuff gets handled properly.  The pipeline
  to run GAMS can either be handled similarly to how we're doing it in
  perl, or we can dust off the old MULE stuff and actually get that
  working nicely.



SECURITY

We're looking to integrate the TMCPE app with some sort of single sign-on system..

