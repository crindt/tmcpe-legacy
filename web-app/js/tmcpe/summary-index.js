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

  function v(x,da) { var d = (da == null ? "" : da); return x == null ? da : x; }


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
      ,ww = 600
      ,margin = 100
      ,w=ww-margin
      ;

      // create the aggchart svg
      function init() {
	  if ( container == null ) return;

	  // empty container
	  $(container[0]).children().remove();
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
//	  var color = d3.interpolateRgb("#aad", "#556");
	  var color = d3.interpolateRgb("#ff0000", "#0000ff");
	  
	  

	  function last_subgroup_data(sgidx,gidx) {
	      if ( sgidx <= 0 ) return 0;

	      return ( odata[sgidx-1][gidx] != null 
		       ? odata[sgidx-1][gidx].x : 0 )
		  + last_subgroup_data( sgidx-1, gidx );
      }

	  _.each(data,function(it){
	      var sgstr = stringifyMap(it.stackgroups);
	      var gstr  = stringifyMap(it.groups);
	      var filtstr = stringifyMap(it.filters);
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
				     group: gstr,
				     subgroup: sgstr,
				     filters: filtstr,
				   };
	  });

	  // make sure everything is initialized (in case of missing data from the controller)
	  var sgk = _.keys(sg),
	  gk = _.keys(g);
	  for( i = 0; i < sgk.length; ++i )
	      for ( j = 0; j < gk.length; ++j )
		  if ( odata[i][j] == null ) odata[i][j] = {y: j, x:0 };

	  // now set the last subgroup data
	  _.each(odata,function(it,sgidx){
	      _.each(it,function(d,gidx){
		  d.x0 = last_subgroup_data(sgidx,gidx)
	      });
	  });

	  // n is the number of "layers", a.k.a. subgroups
	  var n = odata.length;
	  // m is the number of samples per layer, a.k.a. groups
	  var m = odata[0].length;

	  var h = m*barheight;


	  var my = m,
	  mx = d3.max(odata, function(d) {
	      return d3.max(d, function(d) {
		  return (d != null ? d.x0 + d.x : -Infinity )
	      });
	  }),
	  mz = d3.max(odata, function(d) {
	      return d3.max(d, function(d) {
		  return (d != null ? d.x : -Infinity );
	      });
	  }),
	  y = function(d) { return d != null ? d.y * barheight : 0; },
	  x0 = function(d) { return d.x0 * w / mx; },
	  x1 = function(d) { return (d.x + d.x0) * w / mx; }
	  ;


	  svg = container
	      .append("svg:svg")
	      .attr("id","aggchart")
	      .attr("class","chart")
	      .attr("height",(m+1)*barheight)
	      .attr("width",ww);


	  var layers = svg.selectAll("g.layer")
	      .data(odata)
	      .enter().append("svg:g")
	      .style("fill",function(d,i){return color(i/(n-1));})
	      .attr("class","layer")
	      .attr("transform","translate("+margin+",0)")
	  ;

	  var bars = layers.selectAll("g.bar")
	      .data(function(d){return d;})
	      .enter().append("svg:g")
	      .attr("class","bar")
	      .attr("transform",function(d){return "translate(0,"+y(d)+")";})
	  ;

	  bars.append("svg:rect")
	      .attr("height",20)
	      .attr("y",0)
	      //.attr("x",0)
	      //.attr("width",0)
	      //.transition()
	      //.delay(function(d, i) { return i * 10; })
	      .attr("x", x0)
	      .attr("width", function(d) { 
		  return x1(d) - x0(d); })
	      .attr("title",function(d){ return ( d == null ? "" : d.x) })
	      .on("mouseover",function(d){ 
		  d3.select('#aggchartdetail').text( d == null ? "" : d.subgroup +":"+d.x)
	      })
	      .on("click",function(d){ 
		  var gparams = $.parseJSON(d.group);
		  var sgparams = $.parseJSON(d.subgroup);
		  var filtparams = $.parseJSON(d.filters);
		  var parstr = new Array();
		  for ( k in gparams ) {
		      parstr.push(k+"="+gparams[k]);
		  }
		  for ( k in sgparams ) {
		      parstr.push(k+"="+sgparams[k]);
		  }
		  if ( filtparams instanceof Array ) {
		      for ( e in filtparams ) {
			  // filters my be a single item (not a key value pair), catch this here
			  parstr.push(e.value);
		      }
		  } else {
		      // not array, just push filtparams
		      for ( k in filtparams ) {
			  parstr.push( filtparams[k] );
		      }
		  }
		  window.open('map/show?'+parstr.join("&"));
	      })
					     
	  ;

	  // Add tooltips for each bar
	  $('#aggchart rect[title]').tooltip();

/*
	  bars.each(function(d){
	      var bb = this.getBBox();
	      // anchor = bottom
	      var x = bb.x;
	      var y = bb.y;

	      var m = this.getScreenCTM();
	      var mi = m.inverse();
	      var point = (this.ownerSVGElement || this).createSVGPoint();
	      point.x = x;
	      point.y = y;
	      
	      point = point.matrixTransform(m);

	      var tip = d3.select("#aggchart").append("div")
		  .attr("style",["position:absolute",
				 //"visibility:hidden",
				 "background-color:yellow",
				 "z-index:100000",
				 "left:"+point.x+"px",
				 "top:"+point.y+"px",
				 "width:"+bb.width+"px",
				 "height:"+bb.height+"px"].join(";"))
		  .attr("title",d3.select(this).attr("title"))
	      ;

	      $(tip[0]).tipsy(); 
	  });
*/
	  

	  var gkeys = _.keys(g);

	  var labels = svg.selectAll("text.label")
	      .data(odata[0])
	      .enter().append("svg:text")
	      .attr("class", "label")
	      .attr("x", margin - 5)
	      .attr("y", function (d) { 
		  return y(d); } )
	      //.attr("dx", x({x: .45}))
	      .attr("dy", "15px")
	      .attr("text-anchor", "end")
	      .text(function(d, i) { return gkeys[i] });

	  var xscale = d3.scale.linear().domain([0,mx]).range([0,w]);

	  var rules = svg.append("svg:g");

	  rules = rules.selectAll(".rule")
	      .data(xscale.ticks(10))
	      .enter().append("svg:g")
	      .attr("class","rule")
	      .attr("transform",function(d){ 
		  return "translate("+(margin+x0({x0:d}))+",0)"; })
	  ;

	  rules.append("svg:line")
	      .attr("y2",0)
	      .attr("y1",h)
	  ;

	  rules.append("svg:text")
	      .attr("class", "label")
	      .attr("text-anchor", "middle")
	      .attr("y",h+15)
	      .text(function(d){return d;})
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
	  init();
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
	  .url("incident/listGroups.json?groups=year&stackgroups=eventType")
      ;

      // update if the querybox changes
      $("#querybox").keypress(function(e){
	  if(e.which == 13){
	      aggquery.url("incident/listGroups.json?"+this.value);
	  }

      });

      

  });
 })();

  