/**
 * Contains logic for implementing the TMCPE incident list view
 * combining a scrollable table, a polymaps window, and a detail box
 */

// Creates a bounded scale...FIXME: crindt: clarify the implementation here...
function boundedScale( dom, ran ) {
    var dommin = dom[0];
    var dommax = dom[dom.length-1];
    return function( val ) {
	var vv = Math.max( Math.min( val, dommax ), dommin );
	var scale;
	if ( dom.length == 2 ) {
	    scale = pv.Scale.linear(dom[0], dom[1] ).range(ran[0], ran[1]);
	} else if ( dom.length == 3 ) {
	    scale = pv.Scale.linear(dom[0], dom[1], dom[2] ).range(ran[0], ran[1], ran[2]);
	} else {
	    scale = pv.Scale.linear(dom).range(ran);
	}
	return scale( val );
    }
}


// Red to green color range for delay
function delayColor( ff ) {
    var colorPV = boundedScale( [0, 400, 800], [ "#00ff00", "#ffff00", "#ff0000" ] );
    return function( v ) {
	var col = colorPV( v ).color;
	var rgb = pv.color(col).rgb();
	var rcol = pv.rgb( rgb.r < ff ? ff : rgb.r,
			   rgb.g < ff ? ff : rgb.g,
			   rgb.b < ff ? ff : rgb.b );
	return rcol.color;
    }
}


if ( !tmcpe ) var tmcpe = {};
(function()
 {tmcpe.version = "0.1";
  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };
  tmcpe.query = {};

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

	  // loading hook should go here

	  $(window).trigger( "tmcpe.incidentsRequested", query );

	  d3.json( url,
		   function(e) {
		       // hold the json response here
		       data = e;

		       $(window).trigger( "tmcpe.incidentsLoaded", data );
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
		  {key:"savings",title:"Savings",render:renderNumber},
		];
      ;

      // constructors and private methods
      function init() {
	  // If the container doesn't fit, you must aquit
	  if ( container == null ) return; 

	  // Clear container
	  var divs = container.selectAll('div');
	  divs.remove();

	  // create the table skeleton
	  element = container.append('table').attr('id','incident-list');
	  thead = element.append('thead');
	  hrow = thead.append('tr');
	  hrow.selectAll('th').data(fields).enter()
	      .append('th')
	      .attr('class',function(d){return d.key;})
	      .html(function(d){return d.title;})
	      .attr('title',function(d) { $(this).tipsy(); return "Click to toggle sort"; })
	  ;

	  tbody = element.append('tbody');
	  $('#incident-list')
	      .dataTable({bPaginate:false,"bAutoWidth":false/*,"sDom":"<t>"*/})
	      //.fnFilter(true,null,true,false) // Use regex filtering, not "smart"
	  ;

	  tfoot = element.append('tfoot');
	  hrow = tfoot.append('tr');
	  hrow.selectAll('th').data(fields).enter()
	      .append('th')
	      .attr('class',function(d){return d.key==null?"":d.key;})
	      .html(function(d){return d.key=="memo" ? "Totals:" : ""; })
	  ;
	  
	  resetColumnWidths();
      }



      var nodatacolor = "#eeeeee";

      var first = true;


      function v(x,da) { var d = (da == null ? 0 : da ); return x != null ? x : da; }

      // Update the table view with the given data (change in the model)
      function update(x) {
	  var rows = tbody.selectAll("tr").data(_.filter(x.features,function(d){return d!=null;}) ,function(d,i) { 
	      if ( d ) return d.cad;
	  } );
	  
	  rows.enter().append("tr")
	      .attr("id", function( d ) { 
		  return "table_incident_id_"+d.properties.id;
	      } )
	      .attr("cad", function( d ) { 
		  return d.cad
	      } )
	      .attr("title", function( d ) { $(this).tipsy(); return "Click row to view details in the left pane"; })
	      .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
	      .style("background-color",function(d){
		  return ( d.properties.tmcpe_delay != null 
			   ? delayColor(160)(d.properties.tmcpe_delay)
			   : nodatacolor )
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
	      .attr("class", function(d,i) { return "col "+fields[ i ].key } )
	      .text( function (dd) { 
		  return dd;
	      } );

	  rows.exit().remove();
	  
	  // Use jquery.dataTable to make the table pretty and sortable
	  $('#incident-list')
	      .dataTable({
		  bPaginate:false,
		  "bAutoWidth":false,
		  "bDestroy":true,
		  'aaSorting':[[1,"asc"]],
		  "bFilter": false,
			 })
	  //.fnFilter($('#incident-list_filter input').val(),null,true,false) // Use regex filtering, not "smart"
	  ;

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
      }

      tableView.data = function(x) {
	  if ( !arguments.length ) { 
	      // map out the data from the dom
	      // fixme: confirm this works
	      return d3.select(container).filter('tbody tr').data();
	  }
	  update(x); // new data means we must update
	  return tableView;
      }


      // event handlers
      tableView.incidentSelected = function( incident ) {
	  highlightIncidentRow( incident );
      }

      // internal event handlers
      function highlightIncidentRow(incident) {
	  //d3.select(e.currentTarget.parent).each( function(d) { d.addClass
	  $('tr.selected').removeClass('selected')
	  var newRow = $("tr[cad~='"+incident.cad+"']");
	  newRow.addClass('selected');

	  // get the top of the row and scroll it if it isn't visible
	  var rowOffset = newRow.offset();
	  var scrollTop = $(window).scrollTop()
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
      }


      // utility methods
      function resetColumnWidths() {
	  var wid = $(window).width();
	  var table_fudge=100;

	  $('#incident-list').width(wid-250-table_fudge);

	  // On this, we pretty much want to resize the memo column and that's it...
	  var cwid = $(container[0]).width();
	  var mwid = $('#incident-list .memo').width();
	  var mwid_min = $('#incident-list td .memo').css('min-width');
	  var widsum = 0;
	  var hold=[];
	  _.each(['cad','timestamp','locString','memo','d12_delay','tmcpe_delay','savings'],
		 function( d ) {
		     var twid = $('#incident-list tbody td.'+d).width();
		     widsum += twid;
		     hold[d] = twid;
		 });
//	  var avwid = cwid-(widsum);
	  var avwid = wid-table_fudge-250-(widsum-mwid);

	  if ( avwid < mwid_min || avwid < 200 ) avwid = 200;
	  var sel = $('#incident-list .memo').css('width',avwid+'px').css('max-width',avwid+'px');
	  _.each(['cad','timestamp','locString','d12_delay','tmcpe_delay','savings'],
		 function( d ) {
		     $('#incident-list thead th.'+d)
			 .css('width',hold[d]+'px')
			 .css('min-width',hold[d]+'px')
			 .css('max-width',hold[d]+'px')
		     ;
		     $('#incident-list tfoot th.'+d)
			 .css('width',hold[d]+'px')
			 .css('min-width',hold[d]+'px')
			 .css('max-width',hold[d]+'px')
		     ;
		 });
      }

      return tableView;
  }



  ////////////////////////////////////////////////////////////////////////////////
  // Instantiates and manages the map display of the incidents in the query
  tmcpe.query.mapView = function()    {  
      var mapView = {}
      ,container
      ,map   // the polymaps map 
      ,selectedCluster
      ;

      // create the base map
      function init() {
	  if ( container == null ) return;
	  // empty container
	  var divs = container.selectAll('div');
	  divs.remove();

	  // create the tiled map
	  // create the SVG container to hold the polymap
	  var svg = container
	      .append("svg:svg")
	      .attr("id","mapsvg")
	      .attr("height",250)
	      .attr("width",250)[0][0];

	  // create the map
	  map = po.map()
	      .container(svg)
	      .zoom(13)
	      .zoomRange([1,/*6*/,80])
	      .add(po.interact())
	      .center({lat: 33.739, lon: -117.830})
	  ;

	  addMapTileLayer();

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
			  return b.data.properties.tmcpe_delay - a.data.properties.tmcpe_delay 
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
		      var mm = _.max(arr)
		      point.setAttribute('fill', mm == -Infinity ? nodatacolor : delayColor(0)(mm));

		      
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


      // this resets the map
      mapView.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return mapView;
      }

      mapView.data = function(x) {
	  if ( !arguments.length ) {
	      return d3.select(container).filter('circle').data();
	  }
	  update(x);      // push the new data onto the map
	  return mapView;
      }


      // external event handlers
      mapView.incidentSelected = function( d ) {
	  // If an incident has been selected, we want to select the associated cluster...

	  // Get the cluster for this cad
	  sel = $('circle[cads~="'+d.cad+'"]');	  

	  if ( sel.length == 0 ) alert( "Cluster not found for " + d.cad );

	  /*
	  // find the index of the selected incident in the cluster
	  var elIndex;
	  for ( elIndex = 0; sel[0].data.elements[elIndex].cad != d.cad && elIndex < sel[0].data.elements[elIndex].length; ++elIndex );

	  if ( elIndex == sel[0].data.elements.length ) { 
	      alert( "Element " + d.cad + " Not found in cluster!" ); 
	      return;
	  } 

	  // propogate as a global tmcpe event
	  var cldata = {cluster:sel[0].data,elementIndex:elIndex};
	  */
	  if ( sel[0] ) {
	      $(window).trigger( 'tmcpe.clusterSelected', sel[0].data );
	  }
      }

      mapView.clusterSelected = function(d) {
	  // don't propagate if we've already selected this cluster
	  if ( d == selectedCluster ) return;

	  clusterSelected(d);
      }

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
	  $('circle.selected').removeClass("selected");
	  
	  sel = $('circle[cads~="'+elem.properties.cad+'"]');
	  sel.addClass("selected");
      }


      function centerOnIncident( elem ) {
	  map.center( {lon:elem.geometry.coordinates[0],lat:elem.geometry.coordinates[1]} );
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
  }

  
  ////////////////////////////////////////////////////////////////////////////////
  // Instantiates and manages the incident detail as a function of cluster
  tmcpe.query.detailView = function() {
      // use mustache style templates
      _.templateSettings = {
	  interpolate : /\{\{(.+?)\}\}/g
      };

      var detailView = {}
      ,container
      ,list
      ,nav
      ,selectedCluster
      ,selectedIncident
      ,detailTemplate = _.template(
	  ''
	      +'<h1 style="background:{{color}}">{{cad}}</h1>'
	      +'<hr/>'
	      +'<table>'
	      +'<tr><th>Type:</th><td>{{eventType}}</td></tr>'
	      +'<tr><th>Location:</th><td>{{properties.locString}}</td></tr>'
	      +'<tr title="The delay associated with this event using the D12 < 35-mph method"><th>Delay<35:</th><td>{{properties.d12_delay.toFixed(0)}} veh-hr</td></tr>'
	      +'<tr title="The delay associated with this event using the TMCPE method"><th>Delay:</th><td>{{properties.tmcpe_delay.toFixed(0)}} veh-hr</td></tr>'
	      +'<tr title="The fraction of savings attributable to TMC actions"><th>Savings:</th><td>{{properties.savings.toFixed(0)}} veh-hr</td></tr>'
	      +'<tr title="The approximate percent of time-space cells sampled for the incident"><th>Sample%:</th><td>{{(properties.samplePercent*100).toFixed(1)}}%</td></tr>'
	      +'</table>'
	      +'<hr/>'
	      +'<div style="width=100%;text-align:center;"><a target="_blank" href="incident/tsd?cad={{cad}}">Show detailed analysis</a></div>'
      )
      ;

      function init() {
	  if ( container == null ) return;

	  // empty container
	  $(container[0]).children().remove();

	  nav = container.append("div")
	      .attr("id","cluster-nav")
	      .style("width","100%")
	      .style("text-align","center")
	  ;
	  nav.append("a")
	      .html("Prev")
	      .attr("class","navbutton navprev")
	      .attr("title",function(d){$(this).tipsy({"gravity":"nw"});})
	      .style("float","left")
	      .on("click",function(d){ 
		  // get the previous li child
		  var prev = $(container[0]).find('li.selected').prev();

		  if ( prev.length > 0 ) {
		      // move to the previous li child
		      $(window).trigger('tmcpe.incidentSelected',prev[0].__data__);
		      checkDetailButtons();
		  }
	      });
	  nav.append("span")
	      .attr('class','nav-count')
	      .html("");
	  nav.append("a")
	      .html("Next")
	      .attr("class","navbutton navnext")
	      .attr("title",function(d){$(this).tipsy();})
	      .style("float","right")
	      .on("click",function(d){ 
		  // get the previous li child
		  var next = $(container[0]).find('li.selected').next();

		  if ( next.length > 0 ) {
		      // move to the previous li child
		      $(window).trigger('tmcpe.incidentSelected',next[0].__data__);
		      checkDetailButtons()
		  }
	      });
	  checkDetailButtons();


	  // create the detail view skeleton
	  list = container.append("div")
	      .attr("id","cluster-list")
	      .append("ul");
      }


      function checkDetailButtons() {
	  var checknext = $(container[0]).find('li.selected').next();
	  if ( checknext.length == 0 ) {
	      // we're at the end, disable the button
	      $(".navnext").addClass("disabled");
	      $(".navnext").attr("title",null );
	  } else {
	      $(".navnext").removeClass("disabled");
	      $(".navnext").attr("title","There are more incidents here, click for the next" );
	  }
	  var checkprev = $(container[0]).find('li.selected').prev();
	  if ( checkprev.length == 0 ) {
	      // we're at the end, disable the button
	      $(".navprev").addClass("disabled");
	      $(".navprev").attr("title",null );
	  } else {
	      $(".navprev").removeClass("disabled");
	      $(".navprev").attr("title","There are more incidents here, click for the previous" );
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
		  tt.color = delayColor(160)(tt.properties.tmcpe_delay); 
		  return detailTemplate( tt ); 
	      });

	  // add tool tips to the rows
	  $(list[0]).find('tr').tipsy();

	  li.exit().remove();
      }

      // this resets the map
      detailView.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return detailView;
      }

      detailView.data = function(x) {
	  if ( !arguments.length ) {
	      return d3.select(container).filter('li').data();
	  }
	  update(x);      // push the new data onto the map
	  return detailView;
      }

      // event handlers
      detailView.clusterSelected = function(d) {
	  if ( d == selectedCluster ) return;

	  selectedCluster = d;

	  detailView.data( d.elements );
	  
	  //$(window).trigger( 'tmcpe.incidentSelected', d.elements[0].data );
      }

      detailView.incidentSelected = function( d ) {
	  var all = $(list[0]).find('li');
	  var idx = 0;
	  if ( selectedCluster && selectedCluster.elements && selectedCluster.elements.length ) {
	      for ( idx = 0; 
		    selectedCluster.elements[idx] && selectedCluster.elements[idx].data.cad != d.cad && idx < selectedCluster.elements.length; 
		    ++idx );
	      if ( idx > selectedCluster.elements.length )
		  alert( "Can't find selected incident in detail cluster" );
	      nav.selectAll('.nav-count').html("Incident " + (idx+1) + " of " + selectedCluster.elements.length );
	      $(container[0]).find("li.selected").removeClass('selected');
	      $(container[0]).find("li[cad~='"+d.cad+"']").addClass('selected');//style("color","yellow");
	  } else {
	      alert( "Can't find incident in dataset" );
	  }

	  checkDetailButtons();
      }

      return detailView;
  }

  $(document).ready(function() {

      // create view objects
      var it = d3.select('#incident-table');
      var tableView = tmcpe.tableView().container(it);
      var mapView = tmcpe.query.mapView().container(d3.select('#mapview'));
      var detailView = tmcpe.query.detailView().container(d3.select('#cluster-detail'));
      
      // create view event bindings
      $(window).bind("tmcpe.incidentsRequested", function(caller, d) { 
	  $("#loading").css('visibility','visible');
      } );

      $(window).bind("tmcpe.incidentsLoaded", function(caller, d) { 
	  $("#loading").css('visibility','hidden');

	  // this hack to handle requery needs to be fixed
	  var it = d3.select('#incident-table');
	  tableView.container(it);
	  tableView.data(d) 

	  mapView.data(d) 
      } );

      $(window).bind("tmcpe.incidentSelected", function(caller, d) { 
	  tableView.incidentSelected(d);
	  mapView.incidentSelected(d);
	  detailView.incidentSelected(d);
      } );

      $(window).bind("tmcpe.clusterSelected", function(caller, d) { 
	  mapView.clusterSelected(d);
	  detailView.clusterSelected( d );
      } );



      $(window).resize(function(e) {
	  tableView.resetColumnWidths();
      });


      /* gmail-like hack to fix specific elements once we've scrolled past a point */
      $(window).scroll(function(e) { 


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
						    )+'px',
					     
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
	      $('#incident-list tfoot').css({'position':'fixed','bottom':'0px',
					     'left':(250         // width of map
						     +5          // content margin
						     +10         // content padding
						     -scrollLeft /* move it left
								  * if we've
								  * scrolled */
						    )        
					     +'px'});

	  }
      })

      
      // Create query object and load the data.
      // When the data is loaded, it gets pushed to the views through the event bindings
      var query = tmcpe
	  .query()
	  .url('incident/list.geojson?startDate=2011-01-01&endDate=2012-01-01&Analyzed=onlyAnalyzed&solution=good&notBounded&samplePercent=0.5&max=1000');
	  //.url('incident/list.geojson?startDate=2011-06-01&endDate=2012-01-01&max=1000');


      // read query box
      $('#new-incident').keypress(function(e){
      if(e.which == 13){
	  query.url("incident/list.geojson?max=1000&Analyzed=onlyAnalyzed&solution=good&"+this.value);
       }
      });
  });

 })();