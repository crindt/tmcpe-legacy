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
      ,model  // the JSON representation of the query
      ,data   // the result of the query
      ,url    // the URL representation of the query
      ;

      function executeQuery() {
	  if ( url == null ) throw "undefined URL in tmcpe.aggquery.executeQuery()";
	  
	  $(window).trigger( "tmcpe.aggregatesRequested", query );
	  
	  try {
	      d3.json( url,
		       function(e) {
			   // Catch network errors
			   if ( e == null ) throw "Error retreiving query data from server.";
			   
			   // hold the json response here
			   data = e;
			   
			   // broadcast the newly loaded data
			   $(window).trigger( "tmcpe.aggregatesLoaded", data );
		       });
	  } catch( e ) {
	      alert( "Error!" );
	  }
      }

      function modelToUrl() {
	  // assert
	  if ( model == null ) throw "Undefined model in tmcpe.aggquery";
	  if ( model.groups == null ) throw "Undefined model.groups in tmcpe.aggquery";
	  if ( model.stackgroups == null ) throw "Undefined model.stackgroups in tmcpe.aggquery";

	  var url = g.createLink( { controller: 'incident',
					 action: 'listGroups.json',
					 params: {
					     groups: model.groups,
					     stackgroups: model.stackgroups,
					     filters: model.filters
					 }
				       });
	  return url;
      }

      query.model = function(x) {
	  if ( !arguments.length ) return model;
	  model = x;
	  return query.url( modelToUrl() );
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

  /**
   * A view for representing the aggregate query in a form
   */
  tmcpe.queryView = function () {

      // use mustache style templates
      _.templateSettings = {
	  interpolate : /\{\{(.+?)\}\}/g
      };

      var queryView = {}
      ,query     // the query model this view is tied to
      ,container
      ,groupSelect
      ,stackSelect
      ,selectTemplate = '<select name="{{name}}">{{#choices}}<option value="{{key}}">{{text}}</option>{{/choices}}</select>'
      ,radioTemplate = '{{#choices}}<input type="radio" name="{{name}}" value="{{key}}"><span type="label">{{text}}</span><br/>{{/choices}}'
      ;

      function init() {
	  if ( container == null ) return;

	  // set a trigger on form elements being changed
	  d3.selectAll('#basicQueryPane select')
	      .on('change',function(d){
		  $(window).trigger("tmcpe.queryFormChanged", formAsModel() );
	      });

      }

      queryView.query = function(x) {
	  if ( x == null ) return query;
	  query = x;
	  update();
      }


      queryView.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return queryView;
      }

      // This will insert radio buttons inside the given selector for the given
      // array of data
      function radioFromArray( sel, data ) {
	  return sel.html( Mustache.to_html( radioTemplate, {name:name, choices: data} ) )
      }

      // This will a select group inside the given selector for the given array
      // of data
      function selectFromArray( sel, name, data ) {
	  return sel.html( Mustache.to_html( selectTemplate, {name:name, choices: data } ) );

      }

      /**
       * Returns the form data as a JSON model
       */
      function formAsModel() {
	  return { groups:[$('select[name=groups]').val()],
		   stackgroups:[$('select[name=stackgroups]').val()],
		   filters:[$('select[name=filters]').val()]
		 };
      }

      /**
       * make the form match the query (model)
       */
      function update() {

	  if ( query ) {
	      if ( query.groups ) {
		  var s = $("select[name='groups']");
		  s.val(query.groups[0]);
	      }
	      if ( query.stackgroups ) {
		  $("select[name=stackgroups]").val(query.stackgroups[0]);
	      }
	      if ( query.filters ) {
		  $("select[name=filters]").val(query.filters[0]);
	      }
	  }

	  // create the groups box
	  $(window).trigger("tmcpe.queryFormChanged", formAsModel() );

      }

      return queryView;
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

	  // add dummy elements to determine chart coloring from css
	  container.append("div").attr("class","dummy-chart-start-color");
	  container.append("div").attr("class","dummy-chart-end-color");
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
	  var gr = new Array();

	  // Obtain the color range for the chart using the fill value from the
	  // css-classed dummy divs created in the init() function
	  var color = d3.interpolateRgb($(".dummy-chart-start-color").css("fill"), 
					$(".dummy-chart-end-color").css("fill"));
	  
	  

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
	      if ( (gidx = gr[gstr]) == null ) {
		  gidx = gr[gstr] = _.keys(gr).length;
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
	  gk = _.keys(gr);
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
		  url = g.createLink( { controller: 'map',
					     action: 'show' } ) + "?" + parstr.join("&");
		  window.open(url);
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
	      .on("mouseover",function(d,i){
		  // mousing over legend item should highlight blocks in chart
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "#aggchart .bar rect[sgidx='"+good_data[0].sgidx+"']";
		  var sel = $(selstr);
		  //sel.addClass("highlight");
                  // SVG doesn't work with jquery.addClass and jquery.svgdom is overridden by jquery.tools
                  // This is a hacky copy of the svgdom implementation of addClass
                  var ac = function(c){ return function(n) { n.className ? n.className.baseVal += " " + c : n.setAttribute('class', c);} };
                  _.each(sel,ac('highlight'));
                  /*_.each($(this).find('text'),ac('highlight'));*/
	      })
	      .on("mouseout",function(d,i){
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "#aggchart .bar rect[sgidx='"+good_data[0].sgidx+"']";
		  var sel = $(selstr);
                  // SVG doesn't work with jquery.removeClass and jquery.svgdom is overridden by jquery.tools
                  // This is a hacky copy of the svgdom implementation of removeClass
                  var className = 'highlight';
                  var rc = function(c){ return function(node){
                      var classes = (node.className ? node.className.baseVal : node.getAttribute('class'));
                      classes = $.grep(classes.split(/\s+/), function(n, i) { return n != c; }).
						join(' ');
		      (node.className ? node.className.baseVal = classes :
		       node.setAttribute('class', classes));
                  } };
                  _.each(sel,rc('highlight'));
                  /*_.each($(this).find('text'),rc('highlight'));*/
	      })
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


	  var gkeys = _.keys(gr);
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

      var queryView = tmcpe
	  .queryView()
	  .container( d3.select('#basicQueryPane') )
      ;

      // create (default) query
      var aggquery = tmcpe
	  .aggquery()
      ;


      // create view event bindings
      var loadingOverlay;
      $(window).bind("tmcpe.aggregatesRequested", function(caller, d) { 
	  loadingOverlay = $("#loading").overlay({load:true, closeOnClick:false, api:true});
      } );

      $(window).bind("tmcpe.aggregatesLoaded", function(caller, d) { 
	  aggchart.data(d);
	  if ( loadingOverlay ) loadingOverlay.close();
      } );
      

      $(window).bind("tmcpe.queryFormChanged", function(caller, d) {
	  // d contains the query form data as a JSON object
	  // Update the aggregate query
	  aggquery.model( d );
      });


      /////////// QUERY FORM MANIP

      // jquerytools tabs
      $('ul.tabs').tabs('div.panes > div');

      // create basic query form
      //$('groupby')

      // update if the querybox changes
      $("#advancedqueryinput").keypress(function(e){
	  if(e.which == 13){
	      var url = g.createLink( { controller: 'incident',
					action: 'listGroups.json'
				      } ) + "?"+this.value;
	      aggquery.url(url);
	  }

      });



      // Now, fire things up by setting a default query
      //aggquery.url("incident/listGroups.json?groups=year&stackgroups=eventType")
      queryView.query( { groups: [ "year" ], stackgroups: ["eventType"], filters: ["none"] } );


      // set up the overlays
      
      

  });
 })();

  