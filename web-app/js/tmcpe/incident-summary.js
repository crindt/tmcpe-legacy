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
	      
	      tmcpe.loadData( url, function(e) {
		      // Catch network errors
		      if ( e == null ) throw "Error retreiving query data from server.";
		      
		      // hold the json response here
		      data = e;
		      
		      // broadcast the newly loaded data
		      $(window).trigger( "tmcpe.aggregatesLoaded", data );
	      }, "Loading aggregate data" );
      }

      function modelToUrl() {
	  // assert
	  if ( model == null ) throw "Undefined model in tmcpe.aggquery";
	  if ( model.groups == null ) throw "Undefined model.groups in tmcpe.aggquery";
	  if ( model.stackgroups == null ) throw "Undefined model.stackgroups in tmcpe.aggquery";

	  var url = tmcpe.createFormattedLink( { controller: 'incident',
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
      ,selectTemplate = '<select name="{{name}}">{{#choices}}<option value="{{key}}">{{pretty}}</option>{{/choices}}</select>'
      ,radioTemplate = '{{#choices}}<input type="radio" name="{{name}}" value="{{key}}"><span type="label">{{text}}</span><br/>{{/choices}}'
      ;

      function init() {
	  if ( container == null ) return;

	  // set a trigger on form elements being changed
	  d3.selectAll('#basicQueryPane select')
	      .on('change',function(d){
		  $(window).trigger("tmcpe.queryFormChanged", formAsModel() );
	      });


	  // set up the tooltips
	  $(container[0]).find(':input').tooltip({position:"bottom center", tipClass:"tooltip bottom"});

      }

      queryView.query = function(x) {
	  if ( x == null ) return query;
	  query = x;
	  updateFormFromModel();
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
      function updateFormFromModel() {

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

	  // Let other elements know that the query form has changed
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
      ,legendspace = margin   // gap between chart and legend/detail boxes
      ,legendboxsize = 10
      ,legendlabelskip = 10
      ,detailheight = 250     // height of the detail box
      ,detailTemplate = '{{count}} Incident{{plural}} matching:<ul><li>{{groups}}</li><li>{{subgroups}}</li>{{#filters}}<li>{{filters}}</li>{{/filters}}</ul>'
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
		       ? odata[sgidx-1][gidx].x.cnt : 0 )
		  + last_subgroup_data( sgidx-1, gidx );
	  }

	  // Here we make sure the data is organized properly The data comes as
	  // statistical aggregates ordered first by group fields and second by
	  // stackgroup fields.
	  _.each(data, function(it){
	      // looping on the data array, we group the group, subgroup, and
	      // filters as passed with the data and create strings for them.
	      var sgstr = stringifyMap(it.stackgroups);
	      var gstr  = stringifyMap(it.groups);
	      var filtstr = stringifyMap(it.filters);
	      var sgidx;
	      var gidx;

	      // Now, see if we've already seen this subgroup, if so, grab its
	      // index 
	      if ( (sgidx = sg[sgstr]) == null ) {
		  // store the index for the given subgroup by incrementing the
		  // number of subgroups by one.
		  sgidx = sg[sgstr] = _.keys(sg).length;
	      }

	      // Similarly, see if we've already seen this subgroup, if so, grab
	      // the index
	      if ( (gidx = gr[gstr]) == null ) {
		  // store the index for the given group by incrementing the
		  // number of subgroups by one.
		  gidx = gr[gstr] = _.keys(gr).length;
	      }

	      // See if we have output data for this subgroup yet.  If not,
	      // create a new array to store it.
	      if ( odata[sgidx] == null ) odata[sgidx] = new Array();

	      // Finally, shove the data into the array so the stackgroup logic
	      // can plot it.
	      odata[sgidx][gidx] = { y: gidx, 
				     x: it.stats,  // FIXME: hardwire
				     group: it.groups,
				     subgroup: it.stackgroups,
				     sgidx: sgidx,
				     filters: it.filters
				   };
	  });

	  // make sure everything is initialized (in case of missing data from the controller)
	  var sgk = _.keys(sg),
	  gk = _.keys(gr);
	  for( i = 0; i < sgk.length; ++i )
	      for ( j = 0; j < gk.length; ++j )
		  if ( odata[i][j] == null ) odata[i][j] = {y: j, x:{cnt:0} };

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
		  return (d != null ? d.x0 + d.x.cnt : -Infinity )
	      });
	  }),
	  mz = d3.max(odata, function(d) {
	      return d3.max(d, function(d) {
		  return (d != null ? d.x.cnt : -Infinity );
	      });
	  }),
	  y = function(d,bh) { return d != null ? d.y * (bh==null?barheight:bh) : 0; },
	  x0 = function(d) { return d.x0 * w / mx; },
	  x1 = function(d) { return (d.x.cnt + d.x0) * w / mx; }
	  ;

	  var chartheight = m*barheight;
	  var legendtitleheight = 25;
	  var legendheight = (n*(legendboxsize+legendlabelskip)) + 50 + legendtitleheight;

	  var hh = chartheight + ( legendheight > detailheight ? legendheight : detailheight ) + legendspace;


	  svg = container
	      .append("svg:svg")
	      .attr("title","Click on chart bars to open a new window with the list of incidents that belong to that grouping")
	      .attr("id","aggchartsvg")
	      .attr("height",hh)
	      .attr("width",ww);

	  var chart = svg.append("svg:g")
	      .attr("class","chart");
	  

	  var layers = chart.selectAll("g.layer")
	      .data(odata)
	      .enter().append("svg:g")
	      .style("fill",function(d,i){return n<=1 ? color(0) : color((i)/(n-1));})
	      .attr("class","layer")
	      .attr("title","Click on chart bars to open a new window with the list of incidents that belong to that grouping")
	      .attr("transform","translate("+margin+",0)")
	  ;
	  $(layers).tooltip({position:"top left", 
			     tipClass: "tooltip left", 
			     tip:'#chartTip',
			     offset: [100, 0]
			    });

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
	      //.attr("title",function(d){ return ( d == null ? "" : d.x.cnt) })
	      .attr("title",function(d){ d == null ? "" : d.subgroup +":"+d.x.cnt })
	      .attr("class","highlightable")
	      .on("mouseover",function(d){ 
		  // Update the chart box
                  var dd = {
		      count: d.x.cnt,
		      plural: d.x.cnt == 1 ? "" : "s" ,
                      groups:_.map(d.group,function(v,i){return i+"=" + v }).join(","),
                      subgroups:_.map(d.subgroup,function(v,i){return i+"=" + v }).join(","),
                      filters:_.map(d.filters,function(v,i){return i }).join(",")
                  };
                  var tt = Mustache.to_html( detailTemplate, dd  );

		  d3.select('#aggchartdetail').html( tt );
	      })
	      .on("click",function(d){ 
		  var parstr = new Array();
		  for ( k in d.group ) {
		      parstr.push(k+"="+d.group[k]);
		  }
		  for ( k in d.subgroup ) {
		      parstr.push(k+"="+d.subgroup[k]);
		  }
		  if ( d.filters instanceof Array ) {
		      for ( e in d.filters ) {
			  // filters my be a single item (not a key value pair), catch this here
			  parstr.push(e.value);
		      }
		  } else {
		      // not array, just push filtparams
		      for ( k in d.filters ) {
			  parstr.push( d.filters[k] );
		      }
		  }
		  // create the query url and open map/show
		  url = g.createLink( { controller: 'map',
					action: 'show' } ) + "?" + parstr.join("&");
		  window.open(url);
	      })
	  ;
//	  $("svg:rect",svg).tooltip();




	  // draw in the vertical rules

	  var xscale = d3.scale.linear().domain([0,mx]).range([0,w]);

	  var rulecont = svg.append("svg:g").attr("class","rules");
	  var rules = rulecont.selectAll(".rule")
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


	  // draw the labels
	  var gkeys = _.keys(gr);
	  var gvals = _.map(gkeys,function(d){
              // loop to find a valid label because some data is missing
              // see issue #904
              for ( var i = 0; i<n; ++i ) {
                  if( odata[i][gr[d]].group ) return odata[i][gr[d]].group;
              }
              throw "Can't find group label for group: "+gr[d];
          });

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




	  var legendtop = (y({y:m})+legendspace)

	  // create the legend
	  var legend = svg.append("svg:g")
	      .attr("class","legend")
	      .attr("transform","translate("+(margin+20)+","+legendtop+")")
	  ;

	  // create a box around the items we're going to create
	  // must create first to be *under* the items
	  var legendregion = legend.append("svg:rect")
	      .attr("class","chartregion")
	      .attr("x",-10)
	      .attr("y",-10)
	      .attr("width", 200 ) /* arbitrary width, will resize after labels are created */
	      .attr("height", legendheight )
	  ;

	  // Put the legend title in
	  var good_data = _.filter(odata[0],function(val){return val.subgroup != null});
	  var sg = good_data[0].subgroup;
	  for ( i in sg ) { sg = i; break; }  // get the first key 
	  legend.append("svg:text")
	      .attr("x", 0 )
	      .attr("y", 0 )
	      .attr("dy","9px")
	      .attr("class","title label")
	      .text(sg)
	  ;


	  var items = legend.selectAll("g.legenditem")
	      .data(odata)
	      .enter().append("svg:g")
	      .attr("class","legenditem")
	      .attr("sgidx", function(d,i) { 
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  return good_data[0].sgidx; })
	      .attr("transform",function(d,i){
		  return "translate(0,"+(legendtitleheight+y({y:i},(legendboxsize+legendlabelskip)))+")";})
	      .on("mouseover",function(d,i){
		  // mousing over legend item should highlight blocks in chart
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "[sgidx='"+good_data[0].sgidx+"']";
		  var sel = svg.selectAll(selstr)
		      .classed( 'highlight', true );
		  d3.select(this).classed( 'highlight', true );
	      })
	      .on("mouseout",function(d,i){
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var selstr = "[sgidx='"+good_data[0].sgidx+"']";
		  var sel = svg.selectAll(selstr)
		      .classed('highlight', false );
		  d3.select(this).classed( 'highlight', false );
	      })
	  ;

	  items.append("svg:rect")
	      .attr("x",0)
	      .attr("y",0)
	      .attr("height",legendboxsize)
	      .attr("width",legendboxsize)
	      .style("fill",function(d,i){return n<=1 ? color(0) : color((i)/(n-1));})
	  ;
	  var legendlabels = items.append("svg:text")
	      .attr("class", "label")
	      .attr("text-anchor", "left")
	      .attr("x",legendboxsize+legendlabelskip)
	      .attr("y",0)
	      .attr("dy","9px")
	      .text(function(d){
		  var good_data = _.filter(d,function(val){return val.subgroup != null});
		  var sg = good_data[0].subgroup;
		  return _.map(sg,function(val,key){return val;}).join(", ");
	      })
	  ;

	  var max = 0;
	  var lw = legendlabels.each(function(d,i){ 
	      max = $(this).width() > max ? $(this).width() : max; 
	  });

	  // resize the box around the legend
	  legendregion.attr("width",max+50);


	  // Add a chart title
	  var xtitle = rulecont.append("svg:text")
	      .attr("class","label title")
	      .attr("text-anchor", "middle")
	      .attr("x",margin+w/2)
	      .attr("y",h+40)
	      .text("Number of matching incidents")
	  ;



	  // draw the detail box
	  var detailw = (ww-2*margin)/2;
	  var detail = svg.append("svg:g")
	      .attr("class","detail")
	      .attr("transform","translate("+(ww-margin-detailw)+","+legendtop+")");
	  var detailbox  = detail
	      .append("svg:rect")
	      .attr("class","chartregion")
	      .attr("x",-10)
	      .attr("y",-10)
	      .attr("width",detailw)
	      .attr("height",detailheight)
	  ;
	  var detailblock = detail
	      .append("svg:foreignObject")
	      .attr("xmlns","http://www.w3.org/1999/xhtml")
	      .attr("x",0)
	      .attr("y",0)
	      .attr("width",detailw)
	      .attr("height",detailheight)
	      .append("p")
	      .attr("id","aggchartdetail")
	  ;
/*
	  var detailtext = detail
	      .append("svg:text")
	      .attr("class", "label")
	      .attr("text-anchor", "left")
	      .attr("x",0)
	      .attr("y",0)
	      .attr("dy","9px")
	      .text("Test")
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
	      var url = tmcpe.createFormattedLink( { controller: 'incident',
					             action: 'listGroups.json'
				                   } ) + "?"+this.value;
	      aggquery.url(url);
	  }

      });



      // Now, fire things up by setting a default query
      //aggquery.url("incident/listGroups.json?groups=year&stackgroups=eventType")
      queryView.query( { groups: [ "year" ], stackgroups: ["month"], filters: ["analyzed=onlyAnalyzed"] } );


      // set up the overlays

  });
 })();

  