<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident List</title>

<!--
    <p:css name="po" />
-->


    <p:css name="960-fluid" /> <!-- Load the 960 css -->
    <p:css name="jquery/themes/base/jquery-ui" /> <!-- Load the openlayers css -->

<style type='text/css'> 

#maptext {
   border: 1px;
   background-color: yellow;
}
  #databox table {
  margin-top:1em;
}
 svg {
  border: solid 1px #aaa;
}
path.incidentBoundary {
  stroke: blue;
  stroke-width: 4px;
  fill: none;
}
rect {
  fill: lightsteelblue;
  stroke: #eee;
  stroke-width: 2px;
}
rect.d1 {
  fill: steelblue;
}
rect.d2 {
  fill: darkblue;
}

 
.rule line {
  stroke: #eee;
  shape-rendering: crispEdges;
}
 
.rule2 line {
  stroke: #eee;
  shape-rendering: crispEdges;
}
 
.rule line.axis {
  stroke: #000;
}
 
.rule2 line.axis {
  stroke: #000;
}
 
.area {
  fill: steelblue;
//    fill-opacity: 0.75;
}
 
.line, circle.area {
  fill: none;
  stroke: cyan;
  stroke-width: 1.5px;
}
 
.area2 path {
  fill: green;
//  fill-opacity: 0.75;
}

.line3 {
  fill: none;
  stroke: orange;
  stroke-width: 1.5px;
}
 
.area3 path {
  fill: red;
//  fill-opacity: 0.5;
}

.timebar {
    stroke: purple;
    stroke-width: 4px;
}
 
.line2, circle.area2 {
  fill: none;
  stroke: yellow;
  stroke-width: 1.5px;
}
 
circle.area {
  fill: #fff;
}

.ylabels, .xlabels {
   font-size: 8pt;
}

#scaleslider {
  width: 300px;
}
#maxspdslider {
  width: 300px;
}

td.label {
    text-align: right;
}

td.value {
    text-align: right;
    width: 4em;
}

td.unit {
    text-align: left;
}

.compass .back {
  fill: #256574;
}

.compass .fore, .compass .chevron {
  stroke: #1AA398;
}

#segments path {
  fill: none;
  stroke-linecap: round;
//  stroke-width: 4px;
}

#ends circle {
  fill: yellow;
  stroke: black;
  r: 1px;
}

#copy, #copy a {
  color: #1AA398;
}

#incidents circle {
//  fill: #ff0000;
  fill-opacity: 0.5;
  stroke: #000000;
}

.paginate_disabled_next {
background-image: url('../images/datatables/forward_disabled.jpg');
}
.paginate_enabled_next {
background-image: url('../images/datatables/forward_enabled.jpg');
}

.paginate_disabled_previous, .paginate_enabled_previous, .paginate_disabled_next, .paginate_enabled_next {
height: 19px;
width: 19px;
margin-left: 3px;
float: left;
}

.paginate_disabled_previous {
background-image: url('../images/datatables/back_disabled.jpg');
}
.paginate_enabled_previous {
background-image: url('../images/datatables/back_enabled.jpg');
}

.dataTables_paginate {
text-align: right;
}

.sorting {
background: url('../images/datatables/sort_both.png') no-repeat center left;
}

.sorting_asc {
background: url('../images/datatables/sort_asc.png') no-repeat center left;
}

.sorting_desc {
background: url('../images/datatables/sort_desc.png') no-repeat center left;
}

.mono {
font-family:monospace;
}

.odd {
background-color: #eee;
}

.even {
background-color: #bbb;
}

.odd.selected {
background-color: cyan;
}

.even.selected {
background-color: cyan;
}

.bottom-head {
   border-bottom: solid 1px black;
}

.top-foot {
   border-top: solid 1px black;
}

.datefield {
   width: 20em;
}

.locstring {
   width: 15em;
}

#inctable th, #inctable td {
   text-align: left;
   padding-right: 1em;
}


#inctable th.numeric, #inctable td.numeric {
   text-align: right;
   padding-right: 1em;
}

#inctable {
   border-collapse: separate;
   border-spacing: 0px;
}

#inctable td {
   padding: 3px 10px;
}

#inctable th {
   padding: 3px 20px;
}

.hidden {
   visibility: hidden;
}

#incidents .selected {
   stroke-width: 10px;
   stroke: cyan;
   fill-opacity: 0.85;
}

.dataTables_length {
   float: left;
}

.dataTables_filter {
   float: right;
   text-align: right;
}

.dataTables_paginate {
   clear: both;
}

</style> 

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <p:javascript src='tmcpe/tsd' />
    <p:javascript src='jquery/dist/jquery' />
    <p:javascript src='jquery-ui/1.8/ui/minified/jquery-ui.min' />
    <p:javascript src='jquery-format/dist/jquery.format-1.2.min' />
    <p:javascript src='polymaps/polymaps' />
    <p:javascript src='protovis/protovis' />
    <p:javascript src='tmcpe/map' />
    <p:javascript src='datatables/jquery.dataTables' />
    <p:javascript src='numberformat/NumberFormat154' />
    
    <g:javascript>
      var i = 0;

      var tsd;

      $(document).ready(function(){

	  
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD
         doQueryMap();
      });
		
    </g:javascript>     

  </head>
  <body>

    <div id="header" class="container_16">

      <div id="" class="grid_1 ">
      </div>

      <div id="" class="grid_14 ">

      </div>

    </div>


    <div id="content" class="container_16">

      <div id="" class="grid_16 ">

	<div id="mapbox" style="height:500px;" class="grid_8 alpha">
	  <div id="map"></div>
	</div>

	<div id="infobox" class="grid_8 omega">
	  <h3 id="incidentTitle">No incident selected</h3>
	  <div id="incidentDetailTableBox"></div>
	</div>
      </div>

      <div id="" class="grid_16 ">
	<div id="incidentListTablebox" class="grid_16 alpha omega">
	</div>
      </div>
    </div>

    <div id="footer" class="container_16">
      
      <div id="" class="grid_1 ">
      </div>
      
      <div id="" class="grid_14 ">
      </div>
      
    </div>
    
  </body>

</html>
