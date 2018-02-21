# TMC Performance Evaluation Application

Toolchain and webapp for analyzing the impact of incidents occuring on freeway
systems.  Requires 5-minute freeway speeds for each freeway segment along with
their historical averages as well as TMC incident log data to identify incidents
for analysis.

To analyze incidents, the system computes incident impacts by executing a MILP
to identify the time-space region experiencing congestion.  These results are
accessible by a web-based front end that allows the user to visualize the
impacts.
