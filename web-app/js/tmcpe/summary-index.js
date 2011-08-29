/**
 * Contains logic for implementing the TMCPE group aggregate summary view
 */

if ( !tmcpe ) var tmcpe = {};
(function()
 {tmcpe.version = "0.1";
  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };
  tmcpe.aggquery = {};

  tmcpe.aggquery = function () {
      var query = {}
      ,data
      ,url
      ;

      function executeQuery() {
	  if ( url == null ) return; // fixme: more checks
	  
	  $(window).trigger( "tmcpe.aggregatesRequested", query );
	  
	  d3.json( url,
		   function(e) {
		       // hold the json response here
		       data = e;
		       
		       $(window).trigger( "tmcpe.aggregatesLoaded", data );
		   });
      }
      
      // Setting the url executes the query
      query.url = function(x) {
	  if ( !arguments.length ) return url;
	  url = x;
	  executeQuery()
	  return query;
      }
      
      
      query.data = function(x) {
	  if ( !arguments.length ) return data;
	  data = x;
	  return query;
      }
      return query;
  }

  tmcpe.aggchart = function () {
      var aggchart = {}
      ,container
      ,svg
      ,data
      ,barheight = 20
      ,w = 420
      ;

      // create the aggchart svg
      function init() {
	  if ( container == null ) return;

	  // empty container
	  container.selectAll('div').remove();
      }

      function stringifyMap(map) {
	  if ( map == null ) return "";
	  return JSON.stringify(map);
      }

      // update the map with new aggregate data
      function update() {
	  if ( data == null || data.length == 0 ) return


	  // Let's reorganize the data...
	  // Each item in the data array consists of statistics by group and stacked group
	  //
	  // For our purposes here, the list of groups will represent a single
	  // category
	  //
	  // The list of stacked groups will represent sub-categories we want to
	  // display as a stacked bar for the given category
	  //
	  // The stats contain the possible data to display...
	  //
	  // Following http://mbostock.github.com/d3/ex/stack.html
	  // We want the data organized as:
	  // odata = [ /*subgroup1*/ [ {group1}, {group2}, ..., {groupN} ],
	  //           /*subgroup2*/ [ {group1}, {group2}, ..., {groupN} ],
	  //           /*subgroupM*/ [ {group1}, {group2}, ..., {groupN} ]]
	  var odata = new Array();
	  var sg = new Array();
	  var g = new Array();
	  var color = d3.interpolateRgb("#aad", "#556");
	  
	  _.each(data,function(it){
	      var sgstr = stringifyMap(it.stackgroups);
	      var gstr  = stringifyMap(it.groups);
	      var sgidx;
	      var gidx;
	      if ( (sgidx = sg[sgstr]) == null ) {
		  sgidx = sg[sgstr] = _.keys(sg).length;
	      }
	      if ( (gidx = g[gstr]) == null ) {
		  gidx = g[gstr] = _.keys(g).length;
	      }
	      if ( odata[sgidx] == null ) odata[sgidx] = new Array();
	      odata[sgidx][gidx] = { y: gidx, 
				     x: it.stats["cnt"],  // FIXME: hardwire
				     x0: (sgidx > 0 ? odata[sgidx-1][gidx].x : 0 ) };
	  });


	  // n is the number of "layers", a.k.a. subgroups
	  var n = odata.length;
	  // m is the number of samples per layer, a.k.a. groups
	  var m = odata[0].length;


	  var my = m,
	  mx = d3.max(odata, function(d) {
	      return d3.max(d, function(d) {
		  return d.x0 + d.x;
	      });
	  }),
	  mz = d3.max(odata, function(d) {
	      return d3.max(d, function(d) {
		  return d.x;
	      });
	  }),
	  y = function(d) { return d.y * barheight; },
	  x0 = function(d) { return w - d.x0 * w / mx; },
	  x1 = function(d) { return w - (d.x + d.x0) * w / mx; },
	  x2 = function(d) { return d.x * w / mz; } // or `mx` to not rescale
	  ;


	  svg = container
	      .append("svg:svg")
	      .attr("id","aggchart")
	      .attr("class","chart")
	      .attr("height",(m+1)*barheight)
	      .attr("width",w);


	  var layers = svg.selectAll("g.layer")
	      .data(odata)
	      .enter().append("svg:g")
	      .style("fill",function(d,i){return color(i/(n-1));})
	      .attr("class","layer")
	  ;

	  var bars = layers.selectAll("g.bar")
	      .data(function(d){return d;})
	      .enter().append("svg:g")
	      .attr("class","bar")
	      .attr("transform",function(d){return "translate(0,"+y(d)+")";})
	      .attr("title",function(d){ 
		  $(this).tipsy(); 
		  return d.x;})
	  ;

	  bars.append("svg:rect")
	      .attr("height",20)
	      .attr("y",0)
	      .attr("x",0)
	      .attr("width",0)
	      .transition()
	      .delay(function(d, i) { return i * 10; })
	      .attr("x", x1)
	      .attr("width", function(d) { return x0(d) - x1(d); })
	  ;


/*
	  // scales
	  var xscale = d3.scale.linear()
	      .domain([0, d3.max(_.map(odata,function(d){
		  return d.stats.cnt;
	      }))])
	      .range([0, w]);

	  // sort and assign indices (FIXME: do server side?)
	  var idx = 0;
	  _.each(data,function(d){ d.idx = idx++; });

	  var yscale = d3.scale.ordinal()
	      .domain(_.range(data.length))
	      .rangeBands([0, data.length*barheight]);

	  svg.selectAll("rect")
	      .data(data)
	      .enter().append("svg:rect")
	      .attr("y", function(d) { 
		  return yscale(d.idx); })
	      .attr("width", function(d) { 
		  return xscale(d.stats.cnt); })
	      .attr("height", yscale.rangeBand());

	  svg.selectAll("text")
	      .data(data)
	      .enter().append("svg:text")
	      .attr("x", function(d) { return xscale(d.stats.cnt); })
	      .attr("y", function(d) { return yscale(d.idx) + yscale.rangeBand() / 2; })
	      .attr("dx", -3) // padding-right
	      .attr("dy", ".35em") // vertical-align: middle
	      .attr("text-anchor", "end") // text-align: right
	      .text(function(d) { return d.stats.cnt; } );
*/
      }

      aggchart.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return aggchart;
      }

      aggchart.data = function(x) {
	  if ( !arguments.length ) return data;
	  data = x;
	  update(data);      // push the new data onto the map
	  return aggchart;
      }

      // event handlers go here


      return aggchart;
  }

  

  $(document).ready(function() {

      // create view objects
      var aggchart = tmcpe
	  .aggchart()
	  .container(d3.select('#aggchart'))
      ;


      // create view event bindings
      $(window).bind("tmcpe.aggregatesRequested", function(caller, d) { 
	  $("#loading").css('visibility','visible');
      } );

      $(window).bind("tmcpe.aggregatesLoaded", function(caller, d) { 
	  $("#loading").css('visibility','hidden');

	  aggchart.data(d);

      } );
      

      // create (default) query
      var aggquery = tmcpe
	  .aggquery()
	  .url('incident/listGroups.json?groups=year&stackgroups=analyzed')
      ;

  });
 })();

  