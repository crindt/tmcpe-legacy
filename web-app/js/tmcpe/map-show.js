/**
 * Contains logic for implementing the TMCPE incident list view
 * combining a scrollable table, a polymaps window, and a detail box
 */


// Red to green color range for delay.  The ff factor defines the
// minimum value for any color channel (0,255).  Setting it above 0
// will fade the colors  (lighten, make the colors whiter)
function delayColor( ff ) {
    var scale = d3.scale.linear();
    var nodatacolor = "#eee";

    function dcx() {
		return dc;
    }

    function dc(x) {
		if ( x == null ) return nodatacolor;

		var v = scale(x);

		var rgb = d3.rgb(v);
        // cap the max channel
        $.each(["r","g","b"],function(d,k) { 
				   rgb[k] = rgb[k] < ff ? ff : rgb[k]; });

        return rgb.toString();
    }

    // We have to override these range, domain, and ticks classes to make this work
    // NOTE: other d3.scale methods are NOT currently exposed
    dc.range =  function(x) { 
		if ( !arguments.length == 1 ) return scale.range();
		scale.range(x);
		return dc;
    };
    dc.domain =  function(x) { 
		if ( !arguments.length == 1 ) return scale.domain();
		scale.domain(x);
		return dc;
    };
    dc.ticks =  scale.ticks;

    return dcx();
}


if ( !tmcpe ) var tmcpe = {};
(function()
 {tmcpe.version = "0.1";
  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };
  tmcpe.query = {};

  // set the scales
  tmcpe.delayColorScale = delayColor(0).domain([0,400,800]).range(["#0f0","#ff0","#f00"]);
  tmcpe.fadedDelayColorScale = delayColor(160).domain([0,400,800]).range(["#0f0","#ff0","#f00"]);

  po = org.polymaps;

  ////////////////////////////////////////////////////////////////////////////////
  // Top level query object.  This loads the data from the remote server.  It's
  // basically the model for this page
  tmcpe.query = function() {
      var query = {}
      ,data
      ,url
      ;

      function executeQuery() {
		  if ( url == null ) return; // more checks

		  // loading event
		  $(window).trigger( "tmcpe.incidentsRequested", query );

		  tmcpe.loadData(
			  url,
			  function(e) {
				  if ( e == null ) throw "Error retreiving query data from server.";
				  
				  data = e; // hold the json response here
				  
				  // done loading event
				  $(window).trigger( "tmcpe.incidentsLoaded", data );
			  },
			  "Loading incident list..."
		  );
      }

      // Setting the url executes the query
      query.url = function(x) {
		  if ( !arguments.length ) return url;
		  url = x;
		  executeQuery();
		  return query;
      };

      query.data = function(x) {
		  if ( !arguments.length ) return data;
		  data = x;
		  return query;
      };
      return query;
  };

  ////////////////////////////////////////////////////////////////////////////////
  // We'll store the master list of data in the table
  tmcpe.tableView = function() {
      var tableView = {}
      ,element
      ,thead
      ,tbody
      ,tfoot
      ,container
      ,dateFormat = d3.time.format("%Y-%m-%d %H:%M")
      ,renderDate = function( o ) { return dateFormat(new Date( o )); }
      ,renderNumber = function( o ) { return ( o != null ? o.toFixed(0) : o ); }
      ,fields = [ {key:"cad",title:"CAD"}, 
				  {key:"timestamp",title:"Time",render:renderDate}, 
				  {key:"locString",title:"Location"}, 
				  {key:"memo",title:"Description"}, 
				  {key:"d12_delay",title:"Delay<35",render:renderNumber}, 
				  {key:"tmcpe_delay",title:"Delay",render:renderNumber}, 
				  {key:"savings",title:"Savings",render:renderNumber}
				];
      ;

      // constructors and private methods
      function init() {
		  // If the container doesn't fit, you must aquit
		  if ( container == null ) throw "Container missing for tableView.";

		  // Clear container
		  var divs = container.selectAll('div');
		  divs.remove();

		  // create the table skeleton
		  element = container.append('table')
			  .attr('id','incident-list');
		  // twitter styling
		  //$(element[0]).addClass('table table-bordered table-condensed');
		  thead = element.append('thead');
		  hrow = thead.append('tr');
		  hrow.selectAll('th').data(fields).enter()
			  .append('th')
			  .attr('class',function(d){return d.key;})
			  .html(function(d){return d.title;})
			  .attr('title',function(d) { return "Click to toggle sort by "+d.title; })
		  ;

		  tbody = element.append('tbody');
		  $('#incident-list')
			  .width('100%')
			  .dataTable({
							 bPaginate:false
							 ,"bAutoWidth":false
							 ,"bFilter": false
							 /*,"sDom":"<t>"*/});

		  tfoot = element.append('tfoot');
		  hrow = tfoot.append('tr');
		  hrow.selectAll('th').data(fields).enter()
			  .append('th')
			  .attr('class',function(d){return d.key==null?"":d.key;})
			  .html(function(d){return d.key=="memo" ? "Totals:" : ""; })
		  ;
		  
		  resetColumnWidths();

		  $('#incident-list th[title]').tooltip({placement:"bottom"});
      }


      var first = true;


      function v(x,da) { var d = (da == null ? 0 : da ); return x != null ? x : da; }

      // Update the table view with the given data (change in the model)
      function update(x) {
		  var rows = tbody.selectAll("tr").data(
			  _.filter(x.features,
					   function(d){
						   return d!=null 
							   && d.properties.savings < 3500 
							   && d.properties.savings/d.properties.tmcpe_delay <= 5
						   ;
					   }),
			  function(d,i) { 
				  if ( d ) return d.cad;
				  else return null;
			  } );
		  
		  rows.enter().append("tr")
			  .attr("id", function( d ) { 
						return "table_incident_id_"+d.properties.id;
					} )
			  .attr("cad", function( d ) { 
						return d.cad
					} )
			  .attr("title", "Click row to view details in the left pane")
			  .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
			  .style("background-color",function(d){
						 return ( d.properties.tmcpe_delay != null 
								  ? tmcpe.fadedDelayColorScale(d.properties.tmcpe_delay)
								  : tmcpe.nodatacolor );
					 } )
		  
			  .on("click",function(d,e) { 
					  $(window).trigger( "tmcpe.incidentSelected", d );
				  } )
			  .selectAll("td")
			  .data(function(d) {
						// extract properties
						var props = [];
						$.each( fields, function(i, val ) {
									var item = d.properties[val.key];
									props.push( val.render ? val.render( item ) : item );
								});
						return props;
					} )
			  .enter().append("td")
			  .attr("class", function(d,i) { return "col "+fields[ i ].key; } )
			  .text( function (dd) { 
						 return dd;
					 } );
		  $("#incident-list tr").tooltip({placement:"left"});

		  rows.exit().remove();
		  resetColumnWidths();
		  
      }


      // public methods
      tableView.container = function(x) {
		  if ( !arguments.length ) return container;
		  container = x;
		  // If we change the container, we need to reinit everything?
		  // Could we just detach nodes and move them to the new?
		  init();  
		  return tableView;
      };

      tableView.data = function(x) {
		  if ( !arguments.length ) { 
			  // map out the data from the dom
			  // fixme: confirm this works
			  return d3.select(container).filter('tbody tr').data();
		  }
		  update(x); // new data means we must update
		  return tableView;
      };


      // event handlers
      tableView.incidentSelected = function( incident ) {
		  highlightIncidentRow( incident );
      };

      // internal event handlers
      function highlightIncidentRow(incident) {
		  //d3.select(e.currentTarget.parent).each( function(d) { d.addClass
		  $('tr.selected').removeClass('selected');
		  var newRow = $("tr[cad~='"+incident.cad+"']");
		  newRow.addClass('selected');

		  // get the top of the row and scroll it if it isn't visible
		  var rowOffset = newRow.offset();
		  var scrollTop = $(window).scrollTop();
		  var winheight = $(window).height();
		  var rowheight = newRow.height();
		  var loc = rowOffset.top - scrollTop;
		  var calc = (winheight-(21)-rowheight);
		  if ( loc < 0 || loc > calc ) {
			  var newTop = rowOffset.top-(21+40-3);
			  $(window).scrollTop( newTop );
		  }
		  

		  //	    $(e.currentTarget.parentElement).addClass('selected');
      }

      tableView.resetColumnWidths = function() {
		  resetColumnWidths();
      };

      // utility methods
      function resetColumnWidths() {
		  var otab = $('#incident-list')
			  .dataTable({
							 bPaginate:false,
							 "bAutoWidth":false,
							 "bDestroy":true,
							 'aaSorting':[[1,"asc"]],
							 "bFilter": false
						 });
		  return;
      }

      return tableView;
  };



  ////////////////////////////////////////////////////////////////////////////////
  // Instantiates and manages the map display of the incidents in the query
  tmcpe.query.mapView = function()    {  
      var mapView = {}
      ,container
      ,map   // the polymaps map 
      ,selectedCluster
      ,svg
      ,mycolor = tmcpe.delayColorScale
      ;

      // create the base map
      function init() {
		  if ( container == null ) return;
		  // empty container
		  var divs = container.selectAll('div');
		  divs.remove();

		  // create the tiled map
		  // create the SVG container to hold the polymap
		  svg = container
			  .append("svg:svg")
			  .attr("id","mapsvg")
			  .attr("class","map")
			  .attr("height",250)
			  .attr("width",'100%')[0][0];
		  
		  // create the map
		  map = po.map()
			  .container(svg)
			  .zoom(13)
			  .zoomRange([1,/*6*/,80])
			  .add(po.interact())
			  .center({lat: 33.739, lon: -117.830})
		  ;
		  addMapTileLayer();
		  
		  renderLegend();
      }

      // update the map with incident data
      function update( x ) {
		  polymaps_cluster.base_radius( 12 );
		  polymaps_cluster.clusterfactor( 30 );

		  var incs = po.geoJson()
			  .tile(true)
			  .features( x.features )
			  .id("incidents")
			  .zoom(  function(z) { return Math.max(4, Math.min(18, z)); } )
			  .on("load",polymaps_cluster.Cluster_load( {
															point_cb: function( point, value ) {
																// This callback is used to customize the circle drawn
																// by polymaps_cluster

																var props = value.data.properties;

																// sort the elements
																props.elements = props.elements.sort(function(a,b){ 
																										 return b.data.properties.tmcpe_delay - a.data.properties.tmcpe_delay;
																									 });

																// Here, we want to tweak the point styling for tmcpe
																point.setAttribute("cads",
																				   $.map(props.elements, function(d,i) { 
																							 return d.data.cad;
																						 }).join(" "));

																// get array of tmcpe_delays and set color based upon
																// the worst incident in the cluster
																var arr = $.map(props.elements,function(d){
																					return d.data.properties.tmcpe_delay;
																				});
																var mm = _.max(arr);
																point.setAttribute('fill', mm == -Infinity ? tmcpe.nodatacolor : mycolor(mm));

																
																var more_wider = value.data.properties.elements.length / 3;
																point.setAttribute("r", polymaps_cluster.base_radius() + more_wider );


																// set the title, for tooltips?
																point.setAttribute("title",props.elements.length+" incident" + (props.elements.length==1 ? "" : "s") );

																// add reference to props
																// crindt: fixme: change point.data to point.props
																point.data = props;
																value.node = point;
																
																// Add a click handler
																$(point).click(function(e) {
																				   // Call local function to handle this...
																				   clusterClicked( value.data.properties );
																			   });
															}
														} ))
		  ;
		  map.add(incs);
		  renderLegend();
      }



      function addMapTileLayer() {
		  map.add(po.image()
				  .url(po.url("http://{S}tile.openstreetmap.org"
							  + "/{Z}/{X}/{Y}.png")
					   .hosts(["a.", "b.", "c.", ""])));
		  map.add(po.compass()
				  .pan("none"));

		  return map;
      };

      function renderLegend() {
		  if ( svg == null || svg.length == 0 ) throw "Can't create legend without SVG element";

		  // remove existing
		  var mysvg = d3.select(svg);
		  mysvg.select("g.legend").remove();

		  var h = mysvg.attr('height');

		  legend = tmcpe.legendForLinearScale()
			  .title("Delay (veh-hr)")
			  .barlength(h-100-50)  // 100's are margins for top and bottom
			  .scale(mycolor)
			  .render(mysvg)
			  .attr('transform',"translate(30,100)") // place just below compass
			  .attr('class',"legend")
		  ;

      }


      // this resets the map
      mapView.container = function(x) {
		  if ( !arguments.length ) return container;
		  container = x;
		  init();
		  return mapView;
      };

      mapView.data = function(x) {
		  if ( !arguments.length ) {
			  return d3.select(container).filter('circle').data();
		  }
		  update(x);      // push the new data onto the map
		  return mapView;
      };


      // external event handlers
      mapView.incidentSelected = function( d ) {
		  // If an incident has been selected, we want to select the associated cluster...

		  // Get the cluster for this cad
		  sel = $('circle[cads~="'+d.cad+'"]');	  

		  if ( sel.length == 0 ) alert( "Cluster not found for " + d.cad );

		  if ( sel[0] ) {
			  $(window).trigger( 'tmcpe.clusterSelected', sel[0].data );
		  }
      };

      mapView.clusterSelected = function(d) {
		  // don't propagate if we've already selected this cluster
		  if ( d == selectedCluster ) return;

		  clusterSelected(d);
      };

      function raiseIncident( elem ) {
	      
		  // In SVG, the z-index is the element's index in the dom.  To raise an
		  // element, just detach it from the dom and append it back to its parent
		  sel = $('circle[cads~="'+elem.properties.cad+'"]').each( 
			  function(i,node) { 
				  var parent = node.parentNode;
				  $(node).detach().appendTo( parent );
			  });
      }

      function highlightIncident( elem ) {
		  // remove all currently selected
		  d3.select('circle.selected').classed('selected', false);
		  
		  d3.select('circle[cads~="'+elem.properties.cad+'"]')
			  .classed('selected',true);
      }


      function centerOnIncident( elem ) {
		  map.center( {lon:elem.geometry.coordinates[0],
					   lat:elem.geometry.coordinates[1]} );
      }
      
      function clusterClicked( e ) {
		  // Here we trigger an event using the event
		  // aggregator so that other views can listen for
		  // this event.  Note the closure: the properties of
		  // the clicked cluster are in the props var
		  
		  // raise the cluster
		  //clusterSelected( e.properties );
		  
		  // Select the first element in the list
		  
		  if ( e != selectedCluster ) {
			  // only update if we've clicked on a new cluster
			  $(window).trigger( 'tmcpe.clusterSelected', e );
			  $(window).trigger( 'tmcpe.incidentSelected', e.elements[0].data );
		  }
      }
	  
      function featureVisible( d ) {
		  var c = d.geometry.coordinates;
		  var ext = map.extent();
		  var vis = ( c[0] >= Math.min( ext[0].lon, ext[1].lon )
					  && c[0] <= Math.max( ext[0].lon, ext[1].lon )
					  && c[1] >= Math.min( ext[0].lat, ext[1].lat )
					  && c[1] <= Math.max( ext[0].lat, ext[1].lat ) );
		  return vis;
      }

      function clusterSelected( e ) {

		  // this will update the cluster view
		  //clusterList.reset(  _.map(e.elements,function(el){ return el.data.model } ) );
		  
		  // Use the first element to do the svg work
		  var cad_elem = e.elements[0].data;
		  
		  // if not visible, center on cluster
		  if ( !featureVisible(cad_elem) ) centerOnIncident( cad_elem );
		  
		  // raise cluster
		  raiseIncident( cad_elem );
		  
		  // highlight cluster
		  highlightIncident( cad_elem );

		  // record the current selection...
		  selectedCluster = e;
		  
      };

      return mapView;
  };

  
  ////////////////////////////////////////////////////////////////////////////////
  // Instantiates and manages the incident detail as a function of cluster
  tmcpe.query.detailView = function() {
      // use mustache style templates
      _.templateSettings = {
		  interpolate : /\{\{(.+?)\}\}/g
      };

      var tsdurl = tmcpe.createFormattedLink({controller:'incident',
											  action:'tsd'
											  //params: {cad:'{{cad}}'}  // a param for the template
											 });
      tsdurl += "?cad={{cad}}";  // can't use createLink because it encodes {{}}

      var detailView = {}
      ,container
      ,list
      ,nav
      ,selectedCluster
      ,selectedIncident
      ,detailTemplate = _.template(
		  ''
			  +'<h1 style="background:{{color}}">{{cad}}</h1>'
			  +'<table class="table table-condensed table-bordered">'
			  +'<tr><th>Type:</th><td>{{eventType}}</td></tr>'
			  +'<tr title="Facility, direction, postmile and vdsid of nearest station to incident"><th>Location:</th><td>{{properties.locString}}</td></tr>'
			  +'<tr title="The delay associated with this event following the Caltrans method of using 35mph as the baseline"><th>Delay<35:</th><td>{{(properties.d12_delay||0).toFixed(0)}} veh-hr</td></tr>'
			  +'<tr title="The delay associated with this event following the TMCPE method of using a average time-space speed as the baseline"><th>Delay:</th><td>{{(properties.tmcpe_delay||0).toFixed(0)}} veh-hr</td></tr>'
			  +'<tr title="The fraction of savings attributable to TMC actions"><th>Savings:</th><td>{{(properties.savings||0).toFixed(0)}} veh-hr</td></tr>'
			  +'<tr title="The approximate percent of time-space cells sampled for the incident"><th>Sample%:</th><td>{{((properties.samplePercent*100)||0).toFixed(1)}}%</td></tr>'
			  +'</table>'
			  +'<div style="width=100%;text-align:center;"><a class="btn btn-primary" target="_blank" href="'+tsdurl+'" title="Open a new window showing a time-space diagram of this incident and details of the delay analysis">Show detailed analysis</a></div>'
      )
      ;

      function init() {
		  if ( container == null ) return;

		  // empty container
		  $(container[0]).children().remove();

		  var countbox = container
			  .append("div")
			  .attr('style','width:100%;text-align:center');
		  var count = countbox.append("span")
			  .attr('class','nav-count')
			  .attr('title',"Click on an incident above or from the table to see its details below")
			  .html("No incident cluster selected");
		  $(count[0]).tooltip({placement:'right'});

		  

		  nav = container
			  .append("div")
			  .attr("class","pagination pagination-centered")
			  .append("ul")
			  .attr("id","cluster-nav")
		  ;
		  nav.append("li")
			  .attr("class","previous")
			  .append("a")
			  .html("&larr; Previous")
			  .attr("title","There are more incidents at this location, click for the previous" )
			  .on("click",function(d){ 
					  // get the previous li child
					  var prev = $(container[0]).find('li.selected').prev();
					  
					  if ( prev.length > 0 ) {
						  // move to the previous li child
						  $(window).trigger('tmcpe.incidentSelected',prev[0].__data__);
						  checkDetailButtons();
					  }
				  });
		  nav.append("li")
			  .attr("class","next")
			  .append("a")
			  .html("Next &rarr;")
			  .attr("title","There are more incidents at this location, click for the next" )
			  .on("click",function(d){ 
					  // get the previous li child
					  var next = $(container[0]).find('li.selected').next();

					  if ( next.length > 0 ) {
						  // move to the previous li child
						  $(window).trigger('tmcpe.incidentSelected',next[0].__data__);
						  checkDetailButtons();
					  }
				  });
		  checkDetailButtons();


		  // create the detail view skeleton
		  list = container.append("div")
			  .attr("id","cluster-list")
			  .append("ul");
      }


      var oldshow;

      function checkDetailButtons() {
		  var checknext = $(container[0]).find('li.selected').next();
		  if ( checknext.length == 0 ) {
			  // we're at the end, disable the button
			  $("#cluster-nav li.next").addClass("disabled")
				  .attr('data-original-title', null)
				  .tooltip('hide');
		  } else {
			  //$(".navnext").removeClass("disabled");
			  $("#cluster-nav li.next").removeClass("disabled");
			  $("#cluster-nav li.next a")
				  .tooltip({placement:"bottom"});
		  }
		  var checkprev = $(container[0]).find('li.selected').prev();
		  if ( checkprev.length == 0 ) {
			  // we're at the end, disable the button
			  $("#cluster-nav li.previous").addClass("disabled")
				  .attr('data-original-title', null)
				  .tooltip('hide');
			  
		  } else {
			  $("#cluster-nav li.previous").removeClass("disabled");
			  $("#cluster-nav li.previous a")
				  .tooltip({placement: "bottom"});
		  }

      }


      function update(x) {
		  if ( list == null ) return;

		  var li = list.selectAll("li")
			  .data($.map(x,function(t){return t.data;}), function(d) { return d.cad; } );

		  li.enter()
			  .append("li")
			  .on('click',function(d){ $(window).trigger('tmcpe.incidentSelected',d); })
			  .attr('cad',function(d){ return d.cad; })
			  .html(function(d){ 
						// Set the h1 color
						var tt = _.clone( d ); 
						if ( tt.eventType == null ) tt.eventType = "<unknown>";
						tt.color = tmcpe.fadedDelayColorScale(tt.properties.tmcpe_delay); 
						return detailTemplate( tt ); 
					});

		  // reset tooltips
		  $('#cluster-list [title]').tooltip({placement: 'right'});

		  li.exit().remove();
      }

      // this resets the map
      detailView.container = function(x) {
		  if ( !arguments.length ) return container;
		  container = x;
		  init();
		  return detailView;
      };

      detailView.data = function(x) {
		  if ( !arguments.length ) {
			  return d3.select(container).filter('li').data();
		  }
		  update(x);      // push the new data onto the map
		  return detailView;
      };

      // event handlers
      detailView.clusterSelected = function(d) {
		  if ( d == selectedCluster ) return;

		  selectedCluster = d;

		  detailView.data( d.elements );
		  
		  //$(window).trigger( 'tmcpe.incidentSelected', d.elements[0].data );
      };

      detailView.incidentSelected = function( d ) {
		  var all = $(list[0]).find('li');
		  var idx = 0;
		  if ( selectedCluster && selectedCluster.elements && selectedCluster.elements.length ) {
			  for ( idx = 0; 
					selectedCluster.elements[idx] && selectedCluster.elements[idx].data.cad != d.cad && idx < selectedCluster.elements.length; 
					++idx );
				  if ( idx > selectedCluster.elements.length )
					  alert( "Can't find selected incident in detail cluster" );
			  var nc = container.selectAll('.nav-count')
				  .html("Incident " + (idx+1) + " of " + selectedCluster.elements.length )
				  .attr('title','There are '+selectedCluster.elements.length+' incidents at this approximate location')
				  .attr('data-original-title','There are '+selectedCluster.elements.length+' incidents at this approximate location');
			  $(nc[0]).tooltip({placement:'right'});
			  
			  $(container[0]).find("li.selected").removeClass('selected');
			  $(container[0]).find("li[cad~='"+d.cad+"']").addClass('selected');//style("color","yellow");
		  } else {
			  alert( "Can't find incident in dataset" );
		  }

		  checkDetailButtons();
      };

      return detailView;
  };

  $(document).ready(
	  function() {
		  // create view objects
		  var tableView = tmcpe.tableView().container(d3.select('#incident-table'));
		  var mapView = tmcpe.query.mapView().container(d3.select('#mapview'));
		  var detailView = tmcpe.query.detailView().container(d3.select('#cluster-detail'));
		  
		  var loadingOverlay;

		  // create view event bindings
		  $(window).bind("tmcpe.incidentsRequested", 
						 function(caller, d) { 
							 loadingOverlay = $("#loading").modal();
						 } );
		  
		  $(window).bind("tmcpe.incidentsLoaded", 
						 function(caller, d) { 
							 if ( loadingOverlay ) loadingOverlay.modal('hide');
							 
							 // this hack to handle requery needs to be fixed
							 var it = d3.select('#incident-table');
							 tableView.container(it);
							 tableView.data(d);

							 mapView.data(d);
						 } );

		  $(window).bind("tmcpe.incidentSelected", 
						 function(caller, d) { 
							 tableView.incidentSelected(d);
							 mapView.incidentSelected(d);
							 detailView.incidentSelected(d);
						 } );

		  $(window).bind("tmcpe.clusterSelected", 
						 function(caller, d) { 
							 mapView.clusterSelected(d);
							 detailView.clusterSelected( d );
						 } );



		  $(window).resize(function(e) {
							   tableView.resetColumnWidths();
						   });


		  /* gmail-like hack to fix specific elements once we've scrolled past a point */
		  $(window).scroll(
			  function(e) { 
				  return;
				  
				  var scrollLeft = $(window).scrollLeft();
				  
				  if ( $(window).scrollTop() > (21+60) ) {
					  // We've scrolled such that the banner should disappear
					  // fix the map and thead a the top of the page
					  
					  
					  $('#leftbox').css({'position':'fixed','top':21,'left':'0px'});
					  $('#incident-list thead').css({'position':'fixed','top':'21px',
													 'left':(250         // width of map
															 +5          // content margin
															 +10         // content padding
															 -scrollLeft /* move it left
																		  * if we've
																		  * scrolled */
															)+'px'
													 
													});
					  
					  
					  // now we need to adjust the th widths because they tend to get out of sync
					  /*
					   _.each(['cad','timestamp','locString','memo','d12_delay','tmcpe_delay','savings'],
					   function( d ) {
					   wid = $('#incident-list tr:first-child td.'+d).css('width');
					   hwid = $('#incident-list th.'+d).css('width');
					   maxwid = $('#incident-list tr:first-child td.'+d).css('min-width');
					   hmaxwid = $('#incident-list th.'+d).css('min-width');
					   $('#incident-list thead th.'+d).css('width',wid).css('min-width',maxwid);
					   $('#incident-list tfoot th.'+d).css('width',wid).css('min-width',maxwid);
					   });
					   */
					  tableView.resetColumnWidths();
					  
				  }
				  if ( $(window).scrollTop() <= (21+60) ) {
					  // OK, the banner should be visible now, ditch the fixed positions
					  
					  $('#leftbox').css({'position':'absolute','top':'101px','left':'0px'});
					  $('#content').css({'position':'absolute','left':'250px'});
					  $('#incident-list thead').css({'position':'static'});
					  
				  }
				  if ( $(window).scrollTop() >= ( $(document).height() - $(window).height() - $('#incident-stats').height() ) ) {
					  $('#incident-list tfoot').css({'position':'static'});
				  } else {
					  $('#incident-list tfoot').css(
						  {'position':'fixed','bottom':'0px',
						   'left':(250         // width of map
								   +5          // content margin
								   +10         // content padding
								   -scrollLeft /* move it left
												* if we've
												* scrolled */
								  )        
						   +'px'});
				  }
			  });

		  
		  // Create query object and load the data.
		  // When the data is loaded, it gets pushed to the views through the event bindings
		  map_show_params['max'] = 1000;
		  var qparm = [];
		  _.map(_.filter(_.keys(map_show_params),function(x){
							 return x != 'action' && x!= 'controller';
						 }), function (key) { 
							 qparm[key] = map_show_params[key]; 
						 });
		  var url = tmcpe.createFormattedLink({controller: 'incident',
											   action: 'list.geojson',
											   params: qparm 
											  });
		  var query = tmcpe
			  .query()
			  .url(url);
		  

		  // read query box
		  $('#new-incident').keypress(
			  function(e){
				  url = tmcpe.createFormattedLink({controller: 'incident',
												   action: 'list.geojson',
												   param: {
													   max:1000,
													   Analyzed: 'onlyAnalyzed',
													   solution: 'good'
												   }
												  });
				  url = url + "&" + this.value;
				  
				  if(e.which == 13){
					  query.url(url);
				  }
			  });
		  
		  $('#year').change(
			  function(){
				  var year = this.value;
				  var url = g.createFormattedLink({controller: 'incident',
												   action: 'list.geojson',
												   param: {
													   max:1000,
													   Analyzed: 'onlyAnalyzed',
													   solution: 'good',
													   startDate: year+"-01-01",
													   endDate: year+"-01-01"
												   }
												  });
				  query.url(url);
			  });

		  // Add tooltips to any titled elements at this point
		  $("#mapview").tooltip({placement: "right"});
	  });
 })();