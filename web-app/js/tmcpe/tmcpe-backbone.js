// Attempt to use Backbone.js to manage query page.
jQuery.fn.addEvent = jQuery.fn.bind; 

var map;

function renderDecimalNumber(oObj,oCustomInfo) {	
    /*
      var num = new NumberFormat();
      num.setInputDecimal('.');
      num.setNumber(oObj); 
      num.setPlaces(0, true);	
      num.setCurrency(false);	
      num.setNegativeFormat(num.LEFT_DASH);	
      num.setSeparators(true, "", ".");

      return num.toFormatted();
    */
    return (oObj != null ? oObj.toFixed(0) : oObj );
}

function renderIncidentTimestamp(obj) {
    dd = new Date( obj );
    return $.format.date(dd,'yyyy-MM-dd kk:mm');
};


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


$(function(){
    po = org.polymaps;

    // A top-level event aggregator to propogate events between views
    // see http://lostechies.com/derickbailey/2011/07/19/references-routing-and-the-event-aggregator-coordinating-views-in-backbone-js/
    window.eventAggregator = _.extend({}, Backbone.Events);
    
    // A model for incident data
    window.Incident = Backbone.Model.extend({
	
	formattedTimestamp: function() {
	    return $.format.date( new Date( properties.timestamp ), 'yyyy-MM-dd kk:mm' );
	}
    });

    // Define the model for a list of incidents as a backbone collection...
    window.IncidentList = Backbone.Collection.extend({
	model: Incident,

	url: function() { 
	    return "/tmcpe/incident/list.geojson?startDate=2010-09-01&endDate=2011-01-01&Analyzed=onlyAnalyzed&max=1000"; 
	},

	// Override parse because the controller returns geojson
	parse : function(resp, xhr) {
	    return resp.features;
	},

	// These (done, nextOrder, comparator) are commented because they don't
	// apply here (yet).  Left in to lift some of the functionality later.
/*
	done: function() {
	    return this.filter(function(incident){
		return incident.get('done');
	    });
	},

	nextOrder: function() {
	    if (!this.length) return 1;
	    return this.last().get('order') + 1;
	},

	comparator: function(incident) {
	    return incident.get('order');
	},
*/

	pluralize: function(count) {
	    return count == 1 ? 'item' : 'items';
	}
	
    });

    // Instantiate an incident list 
    window.Incidents = new IncidentList;

    // Create a view for a single incident.  In this case, we define an incident
    // as a list item (li)
    window.IncidentListItemView = Backbone.View.extend({
	
	tagName: "tr",         // each incident is rendered as a list item
	className: "incident", // with class incident
	
	template: _.template("<td class='col cad-col'><%= cad %></td>"
			     +"<td class='col time-col'><%= properties.timestamp %></td>"
			     +"<td class='col loc-col'><%= properties.locString %></td>"
			     +"<td class='col loc-col'><%= properties.memo %></td>"
			    ),
	
	// FIXME: some legacy things here need to be revised
	events: {
	    "click #incident-list td" : "selectedIncidentRow",
	    "click .incident-check"      : "toggleDone",
	    "dblclick .incident-content" : "edit",
	    "click .incident-destroy"    : "clear",
	    "keypress .incident-input"   : "updateOnEnter"
	},

	selectedIncidentRow: function( e ) {
	    alert( e );
	},
	
	initialize: function() {
	    _.bindAll(this, 'render', 'close');
	    this.model.bind('change', this.render);
	    this.model.view = this;
	},
	
	render: function() {
	    $(this.el).html( this.template(this.model.toJSON()));
	    $(this.el).attr("id", "incident-"+this.model.id);
	    //this.setContent();
	    //Incidents.append(this.el);
	    return this;
	},
	
	setContent: function() {      
	    var content = this.model.get('content');
	    this.$('.incident-content').html( content );
	    this.$('.incident-input').attr("value", content);
	    
	    this.input = this.$(".incident-input");
	    this.input.addEvent('blur', this.close);
	},
	
	toggleDone: function() {
	    this.model.toggle();
	},
	
	edit: function() {
	    $(this.el).addClass("editing");
	    //this.input.fireEvent("focus");
	    this.input.focus();
	},
	
	close: function() {
	    this.model.save({content: this.input.getProperty("value")});
	    $(this.el).removeClass("editing");
	},
	
	updateOnEnter: function(e) {
	    if (e.code == 13) this.close();
	},
	
	clear: function() {
	    this.model.clear();
	}
	
    });


    // A view for displaying 
    window.IncidentTableRowView = Backbone.View.extend({
	tagName: "li",
	className: "incident"
    });



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



    function clusterClicked(e,c) {
	var c = e.currentTarget;
	
	alert( 'Selected cluster ' + c.data );
    }

    // This view is designed to manage the polymaps map window.
    // Generally, this is handled through events pushing changes to the incident
    // list to polymaps
    window.MapView = Backbone.View.extend({
	el: $("#map"),
	map: null,

	events: {
	    // Because we've used d3 to construct the map, we won't use backbone
	    // events to handle interactions
	},


	initialize: function(options) {
	    _.bindAll(this, 'render', 'incidentSelected', 'clusterSelected' );

	    this.vent = (options ? (options.vent ?options.vent : window.eventAggregator) : window.eventAggregator);

	    // bind on incident selected event
	    this.vent.bind('incidentSelected', this.incidentSelected);
	    this.vent.bind('clusterSelected', this.clusterSelected);

	    // bind on the change and reset events to Incidents so the MapView
	    // can update the map accordingly
	    Incidents.bind('reset',  this.render);  // req'd for initial rendering after fetch
	    Incidents.bind('change', this.render);
	    // FIXME: need events for filter changes?
//	    Incidents.bind('all',    this.render);

	    this.model.view = this;

	    // create the SVG container to hold the polymap
	    var svg = d3.select(this.el[0])
		.append("svg:svg")
		.attr("id","mapsvg")
		.attr("height",250)
		.attr("width",250)[0][0];

	    // create the map
	    this.map = po.map()
		.container(svg)
		.zoom(13)
		.zoomRange([1,/*6*/,18])
		.add(po.interact())
		.center({lat: 33.739, lon: -117.830})
	    ;

	    this.addMapTileLayer();
	},

	addMapTileLayer: function() {
	    this.map.add(po.image()
		    .url(po.url("http://{S}tile.openstreetmap.org"
				+ "/{Z}/{X}/{Y}.png")
			 .hosts(["a.", "b.", "c.", ""])));
	    this.map.add(po.compass()
		    .pan("none"));

	    return this.map;
	},

	// Draw the incidents from the IncidentList model on the map
	render: function() {
	    polymaps_cluster.base_radius( 12 );
	    polymaps_cluster.clusterfactor( 30 );

	    var view = this;  // for closure reference

	    var incs = po.geoJson()
		.tile(true)
		.features(
		    // Here, we map the Backbone Collection to a proper
		    // collection of GeoJson features so polymaps can understand
		    // it.  We may want to implement a custom layer for handling
		    // Backbone.js collections instead, but this works for now
		    _.map(this.model.models, function( item ) { var geoj = item.attributes; geoj.model = item; return geoj; } )
		)
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
			    view.clusterClicked( props );
			});
			
		    }
		} ))
	    ;
	    this.map.add(incs);
	    return this.el[0];
	},


	featureVisible: function( d ) {
	    if ( this.map == null ) return false;
	    var c = d.attributes.geometry.coordinates;
	    var ext = this.map.extent();
	    var vis = ( c[0] >= Math.min( ext[0].lon, ext[1].lon )
			&& c[0] <= Math.max( ext[0].lon, ext[1].lon )
			&& c[1] >= Math.min( ext[0].lat, ext[1].lat )
			&& c[1] <= Math.max( ext[0].lat, ext[1].lat ) );
	    return vis;
	},



	raiseIncident: function( elem ) {
	    
	    // In SVG, the z-index is the element's index in the dom.  To raise an
	    // element, just detach it from the dom and append it back to its parent
	    sel = $('circle[cads~="'+elem.attributes.cad+'"]').each( 
		function(i,node) { 
		    var parent = node.parentNode;
		    $(node).detach().appendTo( parent );
		});
	},

	centerOnIncident: function( elem ) {
	    this.map.center( {lon:elem.attributes.geometry.coordinates[0],lat:elem.attributes.geometry.coordinates[1]} );
	},

	clusterClicked: function( e ) {
	    // Here we trigger an event using the event
	    // aggregator so that other views can listen for
	    // this event.  Note the closure: the properties of
	    // the clicked cluster are in the props var
	    this.vent.trigger("clusterSelected", e);
	},

	clusterSelected: function( e ) {
	    //alert( 'Cluster selected' + e )

	    // if not visible, center on cluster
	    // raise cluster
	    // highlight cluster
	},

	incidentSelected: function( cad_elem ) {
	    // determine cluster, then do the call clusterSelected, which should do the following:
	    if ( !this.featureVisible(cad_elem) ) this.centerOnIncident( cad_elem );
	    this.raiseIncident( cad_elem );
	    this.highlightIncident( cad_elem );

	    // here we should update the views...?
	},

/*
	    var cluster = qmap.clusterForCad( cad );

	    if ( cluster != detail.cluster() ) { 
		detail.cluster( cluster );
	    }
	    detail.cad( cad );
*/

	highlightIncident: function( elem ) {
	    // remove all currently selected
	    $('circle.selected').removeClass("selected");

	    sel = $('circle[cads~="'+elem.attributes.cad+'"]');
	    sel.addClass("selected");
	},
    });

    
    var clusterList = new IncidentList();
    
    window.ClusterView = Backbone.View.extend({
	el: $("#cluster-detail"),
	statsTemplate: _.template('<% if (total) { %><span class="incident-count"><span class="number"><%= total %></span><span class="word"> <%= total == 1 ? "incident" : "incidents" %></span> in cluster.</span><% } %>'),
	listTemplate: _.template('<li><%= cad %></li>'),

	
	initialize: function( options ) {
	    _.bindAll(this, 'render', 'clusterSelected');
	    
	    this.vent = (options ? (options.vent ?options.vent : window.eventAggregator) : window.eventAggregator);

	    this.vent.bind('clusterSelected', this.clusterSelected);

	    // listen to the clusterList
	    clusterList.bind('add',     this.addOne);
	    clusterList.bind('refresh', this.addAll);
	    clusterList.bind('all',     this.render);
	},

	// Here, the cluster view updates the cluster with new data
	clusterSelected: function( e ) {

	    clusterList.reset(  _.map(e.elements,function(el){ return el.data.model } ) );

	    // select the first
	    this.vent.trigger('incidentSelected', e.elements[0].data.model );
	},

	render: function() {
	    var cv = this;
	    this.$("#cluster-list").html(
		_.map(clusterList.models,function(d){
		    return cv.listTemplate({
			cad: d.attributes.cad
		    })}).join("<!-- -->"));
	    this.$("#cluster-stats").html(this.statsTemplate({
		total: clusterList.length
	    }));
	}

    });

    window.AppView = Backbone.View.extend({

	el: $("#tmcpeapp"),
	statsTemplate: _.template('<% if (total) { %><span class="incident-count"><span class="number"><%= total %></span><span class="word"> <%= total == 1 ? "item" : "items" %></span> in list.</span><% } %>'),
	mapView: null,
	clusterView: null,

	defaults: {
	},
	
	events: {
	    "click #incident-list td" : "incidentRowSelected",
	    "keypress #new-incident" : "searchOnEnter",
	    "keyup #new-incident"    : "showTooltip",
	    "click .incident-clear"  : "clearCompleted"
	},
	
	initialize: function(options) {
	    _.bindAll(this, 'addOne', 'addAll', 'render', 'incidentSelected');

	    this.vent = (options ? (options.vent ?options.vent : window.eventAggregator) : window.eventAggregator);

	    this.vent.bind('incidentSelected', this.incidentSelected);
	    
	    this.input = this.$("#new-incident");
	    
	    Incidents.bind('add',     this.addOne);
	    Incidents.bind('refresh', this.addAll);
	    Incidents.bind('all',     this.render);
	    
	    // Here, we add the (empty) map element.  This will get updated when
	    // the Incidents collection fetches
	    this.addMap(Incidents);

	    this.addClusterView(clusterList);

	    // Tell the Incidents model to grab incidents from the server
	    Incidents.fetch( );

	},
	
	render: function() {
//	    var done = Incidents.done().length;
	    this.addAll();
	    var stats = this.$("#incident-stats").html(this.statsTemplate({
		total:      Incidents.length,
	    }));
	},

	// what to do user selects the incident row
	incidentRowSelected: function(e) {
	    // propogate
	    this.vent.trigger( 'incidentSelected', e.currentTarget.parentElement.__data__ ); // fixme: crindt: using d3 internals here
 	},

	incidentSelected: function(e) {
	    //this.highlightIncidentRow(e);
	    this.highlightIncidentRow( e )
	    // scroll to row if it's not visible
	},

	highlightIncidentRow: function(e) {
	    //d3.select(e.currentTarget.parent).each( function(d) { d.addClass
	    $('tr.selected').removeClass('selected')
	    $("tr[cad~='"+e.attributes.cad+"']").addClass('selected');
//	    $(e.currentTarget.parentElement).addClass('selected');
	},

	addMap: function(incidents) {
	    // we don't render this because it should get updated with Incidents
	    // does
	    mapView = new MapView({model: incidents});
	},

	addClusterView: function(incidents) {
	    clusterView = new ClusterView({model:incidents})
	},
	
	addOne: function(incident) {
	    // Create an IncidentListItemView for this incident model
	    //var view = new IncidentListItemView({model: incident}).render().el;
	    //this.$("#incident-list").grab(view);

	    // Now, append the view to the incident-list
	    //this.$("#incident-list").append(view);

	    //Incidents.append(view);
	},
	
	addAll: function() {
//	    Incidents.each(this.addOne);
	    var tab = d3.select('#incident-list');
	    var tbody = d3.select('#incident-list tbody');
	    var rows = tbody.selectAll("tr").data(_.filter(Incidents.models,function(d) { 
		return d != null; } )
						,function(d,i) { 
						    return d == null ? null : d.attributes.cad } )
		.enter().append("tr")
		.attr("id", function( d ) { 
		    return "table_incident_id_"+d.attributes.id;
		} )
		.attr("cad", function( d ) { 
		    return d.attributes.cad
		} )
		.attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
		.attr("style", function(d,i) { 
		    return "background-color:"+color(160)(d.attributes.properties.tmcpe_delay)/*+";opacity:0.5"*/; })
/*
		.on("click",function(d,e) { 
		    if ( !featureVisible(d) ) centerOnIncident( d );
		    //qtable.incidentClicked( d.attributes.cad );
		    //theQuery.selectIncident( d.attributes.cad );
		} )
*/
	    ;

	    fields = [ {key:"cad",title:"CAD"}, 
		       {key:"timestamp",title:"Time",render:renderIncidentTimestamp}, 
		       {key:"locString",title:"Location"}, 
		       {key:"memo",title:"Description"}, 
		       {key:"d12_delay",title:"D<sub>d12</sub>",render:renderDecimalNumber}, 
		       {key:"tmcpe_delay",title:"D<sub>tmcpe</sub>",render:renderDecimalNumber}, 
		       {key:"savings",title:"Savings",render:renderDecimalNumber},
		     ];

	    // Now populate each row with the relevant data
	    rows.selectAll("td")
		.data(function(d) {
		    // extract properties
		    var props = [];
		    $.each( fields, function(i, val ) {
			var item = d.attributes.properties[val.key];
			props.push( val.render ? val.render( item ) : item );
		    });
		    return props;
		} )
		.enter().append("td")
		.attr("class", function(d,i) { return "col "+fields[ i ].key } )
		.text( function (dd) { 
		    return dd;
		} );

	    

	    $('#incident-list').dataTable({bPaginate:false,"bAutoWidth":false});
	    resetColumnWidths();


	},

	searchStringToUrl: function(str) {
	    // Here, we want to convert a general query string to a specific substring
	    // Right now, we just do CAD
	    var trimmed = str.replace(/^\s+|\s+$/g, '') ;
	    var qual = (trimmed==''?'':'?cad='+trimmed);
	    return "/tmcpe/incident/list.geojson"+qual; 
	},
	
	searchOnEnter: function(e) {
	    if (e.code != 13 && e.keyCode != 13 ) return;
	    
	    // remove all li's
	    this.$("#incident-list li").remove();

	    var searchString = this.input.attr('value');
	    Incidents.url= this.searchStringToUrl( searchString );
	    Incidents.fetch();
	},
	
	showTooltip: function(e) {      
	    var tooltip = this.$(".ui-tooltip-top");
	    //tooltip.fade("out");
	    
	    if (this.tooltipTimeout) clearTimeout(this.tooltipTimeout);
	    
	    if (this.input.getProperty("value") !== "" && this.input.getProperty("value") !== this.input.getProperty("placeholder")) {
		this.tooltipTimeout = setTimeout(function(){
		    tooltip.fade("in");
		}, 1000);
	    }
	},
	
	clearCompleted: function() {
	    _.each(Incidents.done(), function(incident){ incident.clear(); });
	    return false;
	}
	
    });

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

    function resetColumnWidths() {
	// On this, we pretty much want to resize the memo column and that's it...
	var wid = f_clientWidth();
	var cwid = $('#content').width();
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

	//$('#incident-list .memo').css('min-width',avwid+'px');
	$('#incident-list .memo').css('max-width',avwid+'px');
	$('#incident-list .memo').css('width',avwid+'px');
	    _.each(['cad','timestamp','locString','d12_delay','tmcpe_delay','savings'],
		   function( d ) {
		       $('#incident-list thead th.'+d).css('width',hold[d]+'px');
		       $('#incident-list thead th.'+d).css('max-width',hold[d]+'px');
		   });
	
    }

    $(document).load(function(e) {
	
    });

    $(window).resize(function(e) {
	resetColumnWidths();
    });

    window.App = new AppView;  
});