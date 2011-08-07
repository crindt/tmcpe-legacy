// These are from here: http://www.softcomplex.com/docs/get_window_size_and_scrollbar_position.html
function f_clientWidth() {
	return f_filterResults (
		window.innerWidth ? window.innerWidth : 0,
		document.documentElement ? document.documentElement.clientWidth : 0,
		document.body ? document.body.clientWidth : 0
	);
}
function f_clientHeight() {
	return f_filterResults (
		window.innerHeight ? window.innerHeight : 0,
		document.documentElement ? document.documentElement.clientHeight : 0,
		document.body ? document.body.clientHeight : 0
	);
}
function f_scrollLeft() {
	return f_filterResults (
		window.pageXOffset ? window.pageXOffset : 0,
		document.documentElement ? document.documentElement.scrollLeft : 0,
		document.body ? document.body.scrollLeft : 0
	);
}
function f_scrollTop() {
	return f_filterResults (
		window.pageYOffset ? window.pageYOffset : 0,
		document.documentElement ? document.documentElement.scrollTop : 0,
		document.body ? document.body.scrollTop : 0
	);
}
function f_filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}

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


// Red to green color range
function color( ff ) {
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

  // We'll store the master list of data in the table
  var df = d3.time.format("%Y-%m-%d %H:%M");
  tmcpe.tableView = function() {
      var tableView = {}
      ,element
      ,thead
      ,tbody
      ,container
      ,renderDate = function( o ) { return df(new Date( o )); }
      ,renderNumber = function( o ) { return ( o != null ? o.toFixed(0) : o ); }
      ,fields = [ {key:"cad",title:"CAD"}, 
		  {key:"timestamp",title:"Time",render:renderDate}, 
		  {key:"locString",title:"Location"}, 
		  {key:"memo",title:"Description"}, 
		  {key:"d12_delay",title:"D<sub>d12</sub>",render:renderNumber}, 
		  {key:"tmcpe_delay",title:"D<sub>tmcpe</sub>",render:renderNumber}, 
		  {key:"savings",title:"Savings",render:renderNumber},
		];
      ;

      // constructors and private methods
      function init() {
	  if ( container == null ) return;

	  // empty container
	  var divs = container.selectAll('div');
	  divs.remove();

	  // create the table skeleton
	  element = container.append('table').attr('id','incident-list');
	  thead = element.append('thead');
	  hrow = thead.append('tr');
	  hrow.selectAll('th').data(fields).enter()
	      .append('th')
	      .attr('class',function(d){return d.key;})
	      .html(function(d){return d.title;});

	  tbody = element.append('tbody');
	  resetColumnWidths();
	  $('#incident-list')
	      .dataTable({bPaginate:false,"bAutoWidth":false})
	      .fnFilter(true,null,true,false) // Use regex filtering, not "smart"
	  ;
      }


      // Update the table view with the given data (change in the model)
      function update(x) {
	  var rows = tbody.selectAll("tr")
	      .data(x.features)
	      .enter().append("tr")
	      .attr("id", function( d ) { 
		  return "table_incident_id_"+d.properties.id;
	      } )
	      .attr("cad", function( d ) { 
		  return d.cad
	      } )
	      .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
	      .attr("style", function(d,i) { 
		  return "background-color:"+color(160)(d.properties.tmcpe_delay)/*+";opacity:0.5"*/; })
	      .on("click",function(d,e) { 
		  $(window).trigger( "tmcpe.incidentSelected", d );
	      } )
	  ;

	  //rows.exit().remove();

	  // Now (re)populate each row with the relevant data
	  rows.selectAll("td")
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

	  
	  // Use jquery.dataTable to make the table pretty and sortable
	  $('#incident-list')
	      .dataTable({bPaginate:false,"bAutoWidth":false,"bDestroy":true})
	      .fnFilter($('#incident-list_filter input').val(),null,true,false) // Use regex filtering, not "smart"
	  ;
	  resetColumnWidths();
	  
      }


      // public methods
      tableView.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return tableView;
      }

      tableView.data = function(x) {
	  if ( !arguments.length ) { 
	      // map out the data from the dom
	      return d3.select(container).filter('tbody tr').data();
	  }
	  update(x);
	  return tableView;
      }


      // event handlers
      tableView.incidentSelected = function( incident ) {
	  // scroll if not visible

	  highlightIncidentRow( incident );
      }

      // internal event handlers
      function highlightIncidentRow(incident) {
	  //d3.select(e.currentTarget.parent).each( function(d) { d.addClass
	  $('tr.selected').removeClass('selected')
	  $("tr[cad~='"+incident.cad+"']").addClass('selected');
	  //	    $(e.currentTarget.parentElement).addClass('selected');
      }

      // utility methods
      function resetColumnWidths() {
	  // On this, we pretty much want to resize the memo column and that's it...
	  var wid = f_clientWidth();
	  var cwid = $(container[0]).width();
	  var mwid = $('#incident-list .memo').width();
	  var widsum = 0;
	  var hold=[];
	  _.each(['cad','timestamp','locString','memo','d12_delay','tmcpe_delay','savings'],
		 function( d ) {
		     var twid = $('#incident-list td.'+d).width();
		     widsum += $('#incident-list td.'+d).width()
		     hold[d] = twid;
		 });
	  var table_fudge=100;
	  var avwid = wid-250-table_fudge-(widsum-mwid);

	  $('#incident-list .memo').css('max-width',avwid+'px');
	  $('#incident-list .memo').css('width',avwid+'px');
	  _.each(['cad','timestamp','locString','d12_delay','tmcpe_delay','savings'],
		 function( d ) {
		     $('#incident-list thead th.'+d).css('width',hold[d]+'px');
		     $('#incident-list thead th.'+d).css('max-width',hold[d]+'px');
		 });
      }

      return tableView;
  }

  // Instantiates and manages the map display of the incidents in the query
  tmcpe.query.mapView = function()    {  
      var mapView = {}
      ,container
      ,map   // the polymaps map 
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
	      .zoomRange([1,/*6*/,18])
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
	      .zoom( 13 )
	      .on("load",polymaps_cluster.Cluster_load( {
		  point_cb: function( point, value ) {
		      // This callback is used to customize the circle drawn
		      // by polymaps_cluster

		      var props = value.data.properties;

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
		      point.setAttribute('fill', color(0)(_.max(arr)));

		      // set the title, for tooltips?
		      point.setAttribute("title",props.elements.length+" incident" + (props.elements.length==1 ? "" : "s") );

		      // add reference to props
		      // crindt: fixme: change point.data to point.props
		      point.data = props;
		      value.node = point;
		      
		      // Add a click handler
		      $(point).click(function(e) {
			  // Call local function to handle this...
			  clusterClicked( value.data );
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
	  //alert( "Incident Selected " + d.cad );

	  // Get the cluster for this cad
	  sel = $('circle[cads~="'+d.cad+'"]');	  

	  if ( sel.length == 0 ) alert( "Cluster not found for " + d.cad );

	  // propogate
	  $(window).trigger( 'tmcpe.clusterSelected', sel[0].data );
      }

      mapView.clusterSelected = function(d) {

	  clusterSelected(sel[0].data);
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
	  $(window).trigger( 'tmcpe.clusterSelected', e );
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
	  
      };



      return mapView;
  }

  
  // Instantiates and manages the incident detail as a function of cluster
  tmcpe.query.detailView = function() {
      var detailView = {}
      ,container
      ,list
      ;

      function init() {
	  if ( container == null ) return;

	  // empty container
	  $(container[0]).children().remove();

	  // create the detail view skeleton
	  list = container.append("div")
	      .attr("id","cluster-list")
	      .append("ul");
      }

      function update(x) {
	  if ( list == null ) return;

	  var li = list.selectAll("li")
	      .data(x, function(d) { return d.data.cad; } );

	  li.enter()
	      .append("li")
	      .attr('cad',function(d){ return d.data.cad; })
	      .html(function(d){ return d.data.cad; });

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
	  detailView.data( d.elements );
      }

      detailView.incidentSelected = function(d) {
	  container.selectAll("li[cad~='"+d.cad+"']").style("color","yellow");
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


      /* gmail-like hack to fix specific elements once we've scrolled past a point */
      $(window).scroll(function(e) { 

	  var scrollTop =f_scrollTop();
	  if ( scrollTop > (21+60) ) {
	      // We've scrolled such that the banner should disappear
	      // fix the map and thead a the top of the page
	      $('#leftbox').css({'position':'fixed','top':21,'left':'0px'});
	      $('#incident-list thead').css({'position':'fixed','top':'21px',
					     'left':(250 // width of map
						     +5 // content margin
						     +10)  // content padding
					     +'px'});

	      // now we need to adjust the th widths because they tend to get out of sync
	      _.each(['cad','timestamp','locString','memo','d12_delay','tmcpe_delay','savings'],
		     function( d ) {
			 wid = $('#incident-list td.'+d).css('width');
			 hwid = $('#incident-list th.'+d).css('width');
			 maxwid = $('#incident-list td.'+d).css('max-width');
			 hmaxwid = $('#incident-list th.'+d).css('max-width');
			 $('#incident-list thead th.'+d).css('width',wid);
			 $('#incident-list thead th.'+d).css('max-width',maxwid);
		     });
	      
	  } else if ( scrollTop <= (21+60) ) {
	      // OK, the banner should be visible now, ditch the fixed positions

	      $('#leftbox').css({'position':'absolute','top':'101px','left':'0px'});
	      $('#content').css({'position':'absolute','left':'250px'});
	      $('#incident-list thead').css({'position':'static'});
	  }
      })

      
      // Create query object and load the data.
      // When the data is loaded, it gets pushed to the views through the event bindings
      var query = tmcpe
	  .query()
	  .url('/tmcpe/incident/list.geojson?startDate=2010-09-01&endDate=2011-01-01&Analyzed=onlyAnalyzed&max=1000');
  });



 })();