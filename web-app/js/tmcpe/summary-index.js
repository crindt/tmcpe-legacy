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

      // update the map with new aggregate data
      function update() {
	  if ( data == null || data.length == 0 ) return

	  // change titling?


	  svg = container
	      .append("svg:svg")
	      .attr("id","aggchart")
	      .attr("class","chart")
	      .attr("height",data.length*barheight)
	      .attr("width",w);


	  // scales
	  var xscale = d3.scale.linear()
	      .domain([0, d3.max(_.map(data,function(d){return d.stats.cnt;}))])
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

  