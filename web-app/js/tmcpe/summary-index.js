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
	  $(window).trigger( "tmcpe.queryChanged", url );
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
      ,ww = 800
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
//	  var color = d3.interpolateRgb("#ff0000", "#00ff00");
	  
	  

	  function last_subgroup_data(sgidx,gidx) {
	      if ( sgidx <= 0 ) return 0;

	      return ( odata[sgidx-1][gidx] != null 
		       ? odata[sgidx-1][gidx].x : 0 )
		  + last_subgroup_data( sgidx-1, gidx );
	  }

	  // Here we make sure the data is organized properly
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
				     sgidx: sgidx,
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

	  var h = (m+1.5)*barheight;


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
	  y = function(d,bh) { return d != null ? d.y * (bh==null?barheight:bh) : 0; },
	  x0 = function(d) { return d.x0 * w / mx; },
	  x1 = function(d) { return (d.x + d.x0) * w / mx; }
	  ;


	  svg = container
	      .append("svg:svg")
	      .attr("id","aggchartsvg")
	      .attr("class","chart")
	      .attr("height",(m+(n+2))*barheight)
	      .attr("width",ww);


	  var layers = svg.selectAll("g.layer")
	      .data(odata)
	      .enter().append("svg:g")
	      .style("fill",function(d,i){return n<=1 ? color(0) : color((i)/(n-1));})
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
	      .attr("sgidx", function(d,i) { 
		  return d.sgidx; })
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

	  // create the legend
	  var legend = svg.append("svg:g")
	      .attr("class","legend")
	      .attr("transform","translate("+(margin+20)+","+(y({y:m})+50)+")")
	  ;

	  var items = legend.selectAll("g.legenditem")
	      .data(odata)
	      .enter().append("svg:g")
	      .attr("class","legenditem")
	      .attr("transform",function(d,i){
		  return "translate(0,"+y({y:i},barheight*.65)+")";})
/*
	      .on("mouseover",function(d,i){
		  // mousing over legend item should highlight blocks in chart
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "#aggchart .bar rect[sgidx='"+good_data[0].sgidx+"']";
		  var sel = $(selstr);
//		  sel.addClass("highlight");
	      })
	      .on("mouseout",function(d,i){
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "#aggchart .bar rect[sgidx='"+good_data[0].sgidx+"']";
		  var sel = $(selstr);
//		  sel.svg().removeClass("highlight");
	      })
*/
	  ;

	  items.append("svg:rect")
	      .attr("x",0)
	      .attr("y",0)
	      .attr("height",10)
	      .attr("width",10)
	      .style("fill",function(d,i){return n<=1 ? color(0) : color((i)/(n-1));})
	  ;
	  items.append("svg:rect")
	      .attr("x",0)
	      .attr("y",0)
	      .attr("height",10)
	      .attr("width",10)
	      .style("fill",function(d,i){return n<=1 ? color(0) : color((i)/(n-1));})
	  ;
	  items.append("svg:text")
	      .attr("class", "label")
	      .attr("text-anchor", "left")
	      .attr("x",15)
	      .attr("y",0)
	      .attr("dy","9px")
	      .text(function(d){
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var sg = $.parseJSON(good_data[0].subgroup);
		  return _.map(sg,function(val,key){return val;}).join(", ");
	      })
	  ;


	  
	  


	  // Add tooltips for each bar
	  //$('#aggchart rect[title]').tooltip();
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
	  var gvals = _.map(gkeys,function(d){return $.parseJSON(d)});

	  var labelblock = svg.append("svg:g");

	  var labels = labelblock.selectAll("text.label")
	      .data(odata[0])
	      .enter().append("svg:text")
	      .attr("class", "label")
	      .attr("x", margin - 5)
	      .attr("y", function (d) { 
		  return y(d); } )
	      //.attr("dx", x({x: .45}))
	      .attr("dy", "15px")
	      .attr("text-anchor", "end")
	      .text(function(d, i) { 
		  return _.values(gvals[i]).join(", ");
	      });

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
	      .text(function(d){
		  return d;})
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

      $(window).bind("tmcpe.queryChanged", function(caller, d) {
      });
      
      // create (default) query
      var aggquery = tmcpe
	  .aggquery()
	  .url("incident/listGroups.json?groups=year&stackgroups=eventType")
      ;


      /////////// QUERY FORM MANIP

      // jquerytools tabs
      $('ul.tabs').tabs('div.panes > div');

      function radioFromArray( sel, data ) {
	  var spans = sel.selectAll('span')
	      .data(data)
	      .enter()
	      .append('span')
	      .attr('class','radiospan')
	  ;
	  spans.append('input')
	      .attr('type','radio')
	      .attr('name','groups')
	      .attr('value',function(d){
		  return d.key;
	      })
	  ;
	  spans.append('span')
	      .text( function( d ) {
		  return d.text;
	      })
	  ;
	  spans.append('br');
      }

      function selectFromArray( sel, data ) {
	  var select = sel.append('select');
	  select.selectAll('option')
	      .data(data)
	      .enter()
	      .append('option')
	      .attr('value',function(d){return d.key;})
	      .text(function(d){ return d.text; })
	  ;
	  return select;
      }


      function updateQuery() {
	  // pull data from form
	  var q = ["groups="+$('select[name=groups]').val(),
		   "stackgroups="+$('select[name=stacks]').val()
		  ].join("&");
	  aggquery.url("incident/listGroups.json?"+q);
      }

      // create basic query form
      //$('groupby')
      $.get('incident/formData', function(data){
	  //radioFromArray(d3.select('#groupby'),data.groups);
	  selectFromArray( d3.select('#groupby'),data.groups)
	      .attr('name',"groups")
	      .on('change',function(d){
		  updateQuery();
	      });
	  selectFromArray( d3.select('#stackby'),data.groups)
	      .attr('name',"stacks")
	      .on('change',function(d){
		  updateQuery();
	      });

      });

      // update if the querybox changes
      $("#advancedqueryinput").keypress(function(e){
	  if(e.which == 13){
	      aggquery.url("incident/listGroups.json?"+this.value);
	  }

      });

      

  });
 })();

  