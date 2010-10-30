// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.IncidentView");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dojox.json.ref");


/**
 * The application logic for the TMCPE Incident View
 */
dojo.declare("tmcpe.IncidentView", [ dijit._Widget ], {

    ////// parameters /////
    incidentId: null,       // The database id of the incident we're displaying
    _facilityImpactAnalysis: null, // the active impact analysis (the one in the plot)

    ////// private vars /////
    _incident: null,        // The JSON object holding the incident data

    // Widgets
    _tsd: null,             // The TimeSpaceDiagram widget
    _map: null,             // The map widget
    _facilityStore: null,   // The dojo facility store
    _incidentSummary: null, // The dom node holding the incident summary
    _activityLogGrid: null, // The dom node holding the activity log grid dojo

    // Openlayers
    _vdsSegmentLayer: null,
    _incidentsLayer: null,
    _selectVds: null,
    _hoverVds: null,
    
    constructor: function() {
    },

    postMixInProperties: function() {
	this.inherited( arguments );
    },

    postCreate: function( ) {
	this.inherited( arguments );

	// Pull in the Incident Data
	this._loadIncident();
	
    },

    startup: function() {
	// load analyses
	this.getTsd()._displayLoading();
	this._loadAnalyses();

	this.inherited( arguments );

	// A local reference to 'this' to be used in the callbacks below
	var obj = this;

	dojo.connect( logGrid, "onCellFocus", function( inCell, inRowIndex ) { 
	    obj.simpleSelectLogEntry( { cell: inCell, rowIndex: inRowIndex } );
	});

	// connect some styling features to the log grid
	dojo.connect( logGrid, "onStyleRow", function(row) { 
            //The row object has 4 parameters, and you can set two others to provide your own styling
            //These parameters are :
            // -- index : the row index
            // -- selected: wether the row is selected
            // -- over : wether the mouse is over this row
            // -- odd : wether this row index is odd.
	    //console.log( "STYLING " + row.index );

            var item = logGrid.getItem(row.index);
            if (item) {
               var type = logStoreJs.getValue(item, "type", null);

               if (type == "commLog") {
		  //row.customStyles += "background-color:rgba(255,0,"+selectBlue+",0.5);";
                   row.customClasses += " commLog";
               } else {
                  //row.customStyles += "background-color:rgba(0,255,"+selectBlue+",0.5);";
                   row.customClasses += " activityLog";
  	       }

            }
            logGrid.focus.styleRow(row);
            logGrid.edit.styleRow(row);
	});

	// This should draw the location of the incident on the map (if available)
	this._incidentsLayerInit( {} );
    },

    initApp: function() {
	this.initVdsSegmentsLayer( {} );
	this._incidentsLayerInit( {} );
    },

    getMap: function() {
	if ( this._map )
	    return this._map._map;
	else {
	    this._map = dijit.byId( 'map' );
	    return this._map._map;
	}
    },

    getTsd: function() {
	if ( ! this._tsd ) 
	    this._tsd = dijit.byId( 'tsd' );
	return this._tsd;
    },

    getFacilityStore: function() {
	if ( ! this._facilityStore ) {
	    this._facilityStore = dijit.byId('facilityStore');
	    if ( ! this._facilityStore ) {
		// create one!
		this._facilityStore = facilityStore;
	    }
	}
	return this._facilityStore;
    },

    getFacilityCombo: function() {
	if ( ! this._facilityCombo )
	    this._facilityCombo = dijit.byId('facilityCombo');
	return this._facilityCombo;
    },

    _loadIncident: function() {
	var base = document.getElementById("htmldom").href;
	var caller = this;
	var url = base + 'incident/show.json?id=' + this.incidentId;
	dojo.xhrGet({
	    url: url,
	    preventCache: true,
	    handleAs: "text",
	    sync: true, //false,
	    load: function( r ) {
		var inc = caller._incident = dojox.json.ref.fromJson( r );
	    },
	    error: function( r ) {
		alert( 'Error loading analyses for ' + caller.incidentId + ': ' + r)
	    }
	});
    },

    _loadAnalyses: function() {
	var base = document.getElementById("htmldom").href;
	if ( this._incident && this._incident.id != null ) {
	    var url = base + 'incident/showAnalyses?id=' + this._incident.id;
	    var caller = this;
	    dojo.xhrGet({
		url: url,
		preventCache: true,
		handleAs: "text",
		sync: true, //false,
		load: function( r ) {
		    var inc = caller._incident;
		    inc.analyses = dojox.json.ref.fromJson( r );

		    // Now update the facilityStore
		    if ( inc.analyses.length > 0 ) {
			// sets the displayed analysis to the default (0) and
			// loads the facility analyses into the filteringselect
			if ( inc.analyses[ 0 ].facilityAnalyses.length > 0 ) {
			    facilityStore.url = base + 'incidentImpactAnalysis/showAnalyses.json?id=' + inc.analyses[ 0 ].id;
			    
			    // Here, we set the default displayed TSD to that
			    // corresponding to the primary disrupted facility
			    var ff = inc.section.freewayId + '-' + inc.section.freewayDir;
			    facilityCombo.set( 'displayedValue', ff );
			} else {
			    alert( "No facility analyses for incident analysis: " + inc.analyses[ 0 ].id );
			}
		    } else {
			caller.getTsd()._displayNoAnalysis();
		    }
		},
		error: function( r ) {
		    alert( 'Error loading analyses for ' + caller._incident.cad + ': ' + r)
		}
	    });
	} else {
	    alert( "Asked to load analyses for NULL incident" );
	}
    },

    updateFacilityImpactAnalysis: function( fiaId ) {
	var base = document.getElementById("htmldom").href;

	if ( fiaId == null || fiaId == "" ) {
	    alert ( 'NO FIAID!!' );
	} else {
	    this._facilityImpactAnalysis = fiaId;
	    this.getTsd().updateUrl( base + 'incidentFacilityImpactAnalysis/show.json?id='+fiaId );

	    var fia = this.getTsd()._data;

	    var fiaSummary = "incident " + this._incident.cad + "["+this._incident.id+"] analysis "+fiaId+":"+fia.location.freewayDir+"-"+fia.location.freewayId

	    // Update XLS link
	    var base = document.getElementById("htmldom").href;
	    dojo.byId('tmcpe_tsd_xls_link').innerHTML = 'Download XLS for facility analysis ' + this._facilityImpactAnalysis;
	    dojo.byId('tmcpe_tsd_xls_link').href = base+'incidentFacilityImpactAnalysis/show.xls?id='+this._facilityImpactAnalysis;

	    dojo.byId('tmcpe_report_problem_link').innerHTML = 'Report problem with this facility analysis';
	    url = "http://localhost/redmine/projects/tmcpe/issues/new?tracker_id=3&"
		+ encodeURIComponent( "issue[subject]=Problem with analysis of "+fiaSummary )
		+ "&" + encodeURIComponent( "issue[description]=Bad analysis for available for ["+fiaSummary+"]("
					    +base+'incident/showCustom?id='+this._incident.id
					    +")" )
	    dojo.byId('tmcpe_report_problem_link').href = url;
	    dojo.byId('tmcpe_report_problem_link').onclick = "return popitup('"+url+"')";
	    this.updateVdsSegmentsQuery();
	}
    },

    _constructVdsSegmentsParams: function( theParams ) {

	var tsd = this.getTsd();
	if ( !theParams || theParams == undefined ) {
	    // some defaults to prevent runaways
	    theParams = {};
	    theParams[ 'district' ] = 12;
	}

	theParams[ 'type' ] = 'ML';

	// Don't apply a bounding box for this layer---load them all
	//theParams[ 'bbox' ] = [this.getMap().getExtent().toBBOX()];
	theParams[ 'proj' ] = "EPSG:900913";/* map.projection */

	var sectionParams = {idIn:[]};

	// Get the station indexes of all segments
	var i;
	for ( i = 0; i < tsd._data.sections.length; ++i )
	{
	    var station = tsd._data.sections[i];
	    if ( station ) 
		sectionParams[ 'idIn' ].push( station.vdsid );
	}
	theParams['idIn'] = sectionParams[ 'idIn' ];

	return theParams;

    },

    updateVdsSegmentsQuery: function( theParams ) {
	if ( this._selectVds )
	    this._selectVds.unselectAll();
	var myParams = this._constructVdsSegmentsParams( );
	
	this._updateVdsSegmentsLayer( myParams );
    },

    _updateVdsSegmentsLayer: function( theParams ) {
	if ( ! this._vdsSegmentLayer ) {
	    this.initVdsSegmentsLayer( {} );
	    return;
	}

	var base = document.getElementById("htmldom").href;

	var vdsSegmentLayer = this._vdsSegmentLayer;
	if ( vdsSegmentLayer.protocol.url == "" ) {
	    // update the url
	    vdsSegmentLayer.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: base + "vds/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	vdsSegmentLayer.refresh({force: true, params:theParams});

    },

    _linkFeaturesToCells: function() {
	// Now wire up the table data to highlight the
	var tsd = this._tsd;
	var sections = tsd._data.sections;
	var td = tsd._td;
	var i; 
	var j;
	for ( i = 0; i < td.length; i++ ) {
	    var tr = tsd._tr[i];

	    var row = [tr];
	    for ( var r in row ) {
		dojo.connect( row[r], "onmouseover", this, "_hoverTime" );
	    }

	    var tab = [td];
	    for ( var t in tab ) {
		for ( j = 0; j < td[i].length; j++ ) {
		    dojo.connect( tab[t][i][j], "onmouseover", this, "_hoverStation" );
		    dojo.connect( tab[t][i][j], "onclick", this, "_clickTimeSpaceCell" );
		}
	    }
	}

	// Loop over the stations to connect them to features
	var vsl = this._vdsSegmentLayer;
	for ( j = 0; j < tsd._data.sections.length; ++j ) {
	    var station = tsd._data.sections[ tsd._data.sections[ j ].stnidx ];

	    // this call builds the station->feature cache.  We do this now so
	    // that the UI isn't slow initially
	    var feature = this._getFeatureForStation( station )
	}
    },

    _incidentsLayerInit: function() {
	// should validate
	var obj = this;

	// Create the incidents layer.  The URL is hardcoded here...
	var base = document.getElementById("htmldom").href;

	var theParams = {};

	theParams[ 'id' ] = this.incidentId;

	var style = new OpenLayers.Style({
            pointRadius: 10,
            fillColor: "red",
            fillOpacity: 0.5,
            strokeColor: "blue",
            strokeWidth: 2,
            strokeOpacity: 0.8,
	    graphicZIndex: 500
        }, {
            context: {
                radius: function(feature) {
		    return Math.min(feature.attributes.count, 0)*2 + 5;
                },
            }
        });
	
	this._incidentsLayer = new OpenLayers.Layer.Vector("Incidents", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Protocol.HTTP({
            	url: base + "incident/list.geojson",//theurl,
            	params: theParams,
            	format: new OpenLayers.Format.GeoJSON({})
            }),
            styleMap: new OpenLayers.StyleMap({
		"default": style
	    }),
	    rendererOptions: {zIndexing: true},
            reportError: true
	});

	var obj = this;
	this._incidentsLayer.events.on({
//            "featureselected": obj.onFeatureSelectIncident,
//            "featureunselected": obj.onFeatureUnselectIncident,
	});

	//    map.events.register("moveend", null, function() { alert("updating query"); updateIncidentsQuery(); } )
	this.getMap().addLayers([this._incidentsLayer]);

	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "red",
	    strokeColor: "red"
	}, OpenLayers.Feature.Vector.style["select"]);


	this._hoverIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer,{ 
 	    hover: true,
 	    highlightOnly: true,
            renderIntent: "temporary",
	    selectStyle: hoverSelectStyle
	    //        eventListeners: {
	    //            beforefeaturehighlighted: report,
	    //            featurehighlighted: report,
	    //            featureunhighlighted: report
	    //        }
	});
	this.getMap().addControl(this._hoverIncident);
	this._hoverIncident.activate();

	this._selectIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer);
	this.getMap().addControl(this._selectIncident);
	this._selectIncident.activate();

    },

    _first_vds_render: true,

    recenterMap: function() {
	var bb = this.getIncidentExtent();
	this.getMap().zoomToExtent( bb );
//	var zoom = this.getMap().getZoomForExtent();
//	this.getMap().moveTo( bb.getCenterLonLat(), zoom-1 );
	
    },

    getIncidentExtent: function() {
	var maxExtent = this._vdsSegmentLayer.getDataExtent();
	if ( maxExtent == null ) maxExtent = new OpenLayers.Bounds();
	var unrendered = this._vdsSegmentLayer.unrenderedFeatures;
	var i;
	for ( i in unrendered ) {
	    var feat = unrendered[i];
	    var geom = feat.geometry;
	    if ( geom ) {
		maxExtent.extend( geom.getBounds() );
	    }
	}
	return maxExtent;
    },

    initVdsSegmentsLayer: function( theParams ) {

	var myParams = this._constructVdsSegmentsParams( theParams );

	var base = document.getElementById("htmldom").href;

	var obj = this;

	var cnt = 0;

	var style = new OpenLayers.Style({
	    strokeWidth: 6, 
	    strokeColor: "${getStrokeColor}", 
	    strokeOpacity: 0.75, 
	    graphicZIndex:300 
	}, {
	    context: { 
		getStrokeColor: function( feature ) {
		    // set the color to the associated tdc cell OR to green
		    var color = feature.tdc ? feature.tdc.style.backgroundColor : "#0000ff";
		    //console.log( feature.attributes.name + ":" + color );
		    return color;
		}
	    }
	});


	var hoverSelectStyle = style.clone();
	hoverSelectStyle.strokeWidth = 10;

	this._vdsSegmentLayer = new OpenLayers.Layer.Vector("Vds Segments", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
	    styleMap: new OpenLayers.StyleMap({
		"default": style,
		"hover": hoverSelectStyle
	    }),
            protocol: new OpenLayers.Protocol.HTTP({
  		url: base + "vds/list.geojson",
		params: myParams,
		format: new OpenLayers.Format.GeoJSON({})
	    }),
	    rendererOptions: {zIndexing: true},
            reportError: true
	});
	
	var obj = this;
	this._vdsSegmentLayer.events.on({
	    "loadend": function() { 
		obj._linkFeaturesToCells(); 
		if ( obj._first_vds_render ) {
		    obj.recenterMap();
		    obj._first_vds_render = false;
		}
	    },
	    "featuresremoved": function() { obj._linkFeaturesToCells(); },
	    "moveend": function() { obj.updateVdsSegmentsQuery( {} ); }
	});


	this.getMap().addLayers([this._vdsSegmentLayer]);

	this._hoverVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLayer,{ 
 	    hover: true,
 	    highlightOnly: true,
            renderIntent: "temporary",
	    selectStyle: hoverSelectStyle
	});
	this.getMap().addControl(this._hoverVds);
	this._hoverVds.activate();


	var selectStyle = OpenLayers.Util.applyDefaults({
	// fillColor: "blue",
// strokeColor: "blue"
	    strokeWidth: 8,
	    strokeOpacity: 1
	}, OpenLayers.Feature.Vector.style["select"]);

	this._selectVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLayer,{
	    highlightOnly: true,
	    renderIntent: "temporary",
	    selectStyle: selectStyle
	});
	
	this.getMap().addControl(this._selectVds);
	this._selectVds.activate();   


// obj.getMap().zoomToExtent( obj._vdsSegmentLayer.getDataExtent() );

/*
 * dojo.connect( this._vdsSegmentLayer, "moveend", this.updateVdsSegmentsQuery );
 * dojo.connect( this._vdsSegmentLayer, "featuresadded",
 * this._linkFeaturesToCells ); dojo.connect( this._vdsSegmentLayer,
 * "featuresremoved", this._linkFeaturesToCells );
 */

    },

    _clickTimeSpaceCell: function( e ) {
    	var stationnm = e.target.getAttribute( 'station' );
    	var timeidx = e.currentTarget.getAttribute( 'timeidx' );
    	var timeind = e.currentTarget.getAttribute( 'time' );
    	var station = this._tsd._data.sections[ stationnm ];
    	
    	// CENTER THE MAP ON THE VDS SECTION WE CLICKED ON
    	if ( station ) {
    	    var feature = this._getFeatureForStation( station )
    	    if ( feature ) {
		if ( feature.geometry ) {
		    var bb = feature.geometry.getBounds();

		    var zz = this.getMap().getZoomForExtent( bb );
		    // center on section, but don't zoom in quite all the way.
		    this.getMap().setCenter( bb.getCenterLonLat(), zz-3 );
		}
    	    }
    	} else
    		alert( "Unable to find feature in layer" );
    	
    	// SCROLL THE ACTIVITY LOG TO THE NEAREST ENTRY
    	
    },
    
    _hoverStation: function( e ) {
    	var stationnm = e.target.getAttribute( 'station' );
	var timeidx   = e.target.getAttribute( 'timeidx' );
	var timeind   = e.target.getAttribute( 'time' );

    	var station = this._tsd._data.sections[ stationnm ];
    	
    	// HACK: highlight the corresponding station in the map
    	var vsl = this._vdsSegmentLayer;
    	if ( vsl && station ) {

	    feature = this._getFeatureForStation( station );
    	    
    	    // OK, found the feature. Highlight it? 
    	    if ( feature ) {
    		this._hoverVds.unselectAll();

		if ( timeidx != null ) {
		    var tdc = this._tsd._td[timeidx][stationnm];

		    feature.tdc = this._tsd._td[timeidx][stationnm];
		}

		// For some reason, district 8 vds features don't have a layer,
		// but they're drawn???
		if ( feature.layer != null ) {
    		    this._hoverVds.select( feature );
		}
		
    	    }
    	}
    },

    _getFeatureForStation: function( station ) {
	if ( station == null ) return null;
	var vdsid = station.vdsid;
	// use the existing feature if it's still valid (in which case it
	// will have a layer)
	var feature = ( 
	    station.feature && station.feature.layer 
		? station.feature
		: null );

	var vsl = this._vdsSegmentLayer;
	if ( feature == null && vsl ) {

	    // Loop over the lines until we find the correct station
	    var feature = null;
	    var k;
	    for ( k = 0; k < vsl.features.length && !feature; ++k )
	    {
		var ff = vsl.features[ k ];
		var f_vdsid = ff.attributes[ 'id' ];
		if ( vdsid == f_vdsid ) {
		    feature = ff;

		    if ( feature && feature.layer )
			// store the mapping for later use
			station.feature = feature; 
		}
	    }
	}
	    
	return feature;
    },

    flipTimeSpaceDiagram: function( toggle ) {
	this._tsd.toggleTsdFlipWindow( toggle );
    },
    
    _hoverTime: function( e ) {
	// HACK: alter the segment colors to match tsd
	var timeidx = e.target.getAttribute( 'timeidx' );
	var timeind = e.target.getAttribute( 'time' );
	var d = this._tsd._data;

	var vsl = this._vdsSegmentLayer;
	if ( vsl ) {

	    var tt = this._tsd._td[ timeidx ].length;
	    var j;
	    for ( j = 0; j < tt; ++j )
	    {
		var tdc = this._tsd._td[timeidx][j];
		var si = tdc.getAttribute('station');
		var station = this._tsd._data.sections[ si ];

		if ( station ) {

		    var feature = this._getFeatureForStation( station );

		    if ( feature ) {
			// OK, found the feature. Redraw it to update the style
			// from the stylemap
			feature.tdc = tdc;

			if ( this._vdsSegmentLayer ) {
			    // reset the style, which will force the layer to
			    // recompute
			    feature.style = null;
			    this._vdsSegmentLayer.drawFeature( feature );
			}
		    }
		}
	    }
	}
	this._hoverStation( e ); // highlight the station we're hovering over

	// Now, update the cell info
	var stationnm = e.target.getAttribute( 'station' );
	var station = this._tsd._data.sections[ stationnm ];
	if ( ! station ) return;

	var dd = station.analyzedTimesteps[timeind];
	if ( dd != null ) {
	    var el = document.getElementById('tmcpe_tsd_cellinfo');
	    var str = station.vdsid + ":" + station.fwy + "-" + station.dir + " @ " + station.pm + " [" + station.name + "], " + this._tsd._data.timesteps[timeind];
	    str += "<br/>O:" + (dd.spd!=null?dd.spd.toFixed(1):"<undef>") + "-mph, A:" + (dd.spd_avg!=null?dd.spd_avg.toFixed(1):"<undef>") + "-mph +/- " + (dd.spd_std!=null?dd.spd_std.toFixed(1):"<undef>") + "-mph | OCC: " + (dd.occ!=null?(100*dd.occ).toFixed(1):"<undef") + '%';
	    if ( Math.abs(station.analyzedTimesteps[timeidx].p_j_m-0.5) < 0.25 ) str += ' <span style="color:#ff0000;font-weight:bold">&lt;UNRELIABLE&gt;</span>';
	    el.innerHTML = str;
	}
    },
    
    // //////// TABLE FUNCTIONS
    getActivityLogGrid: function() {
    	if ( !this._activityLogGrid ) {
    		this._activityLogGrid = dijit.byId( 'logGridNode' );
    	}
    	return this._activityLogGrid;
    },
    
    scrollActivityLogToItem: function ( item ) {
    	var gn = getActivityLogGrid();
    	
    	var idx = gn.getItemIndex( item );
    	if ( idx = -1 ) {
    		// hmm, the grid hasn't materialized this item,
    		idx = item._0;
    		// load the missing page
    		// some hackiness from
			// http://neonstalwart.blogspot.com/2009/05/fetching-everything-selected-in.html
    		var pageIndex = gn._rowToPage( idx );
    		gn._requestPage( pageIndex );
    	}
    	if ( idx >= 0 ) {
    		gn.selection.clear();
    		gn.selection.addToSelection( idx );
    		gn.scrollToRow( idx );
    	} else {
    		alert( "Strangely, item " + cad + " wasn't found in the grid!" );
    	}
    	
    },

    simpleSelectLogEntry: function( event ) {
	var logEntry = null
	if ( event.grid != null )
	    logEntry = event.grid.getItem( event.rowIndex );
	else if ( event.cell != null )
	    logEntry = event.cell.grid.getItem( event.rowIndex );
	else {
	    console.log( "WARNING: simpleSelectLogEntry: NO EVENT OR CELL!" );
	    return;
	}

	// Hide existing
	dojo.query( ".log_tsd_bar" ).forEach(function(node,index,arr){
	    if ( index != 0 ) {  // Always show the first entry
		node.style.visibility = 'hidden';
	    }
	});
	dojo.query( ".log_tsd_label" ).forEach(function(node,index,arr){
	    node.style.visibility = 'hidden';
	});

	dojo.query( "#logit_"+logEntry.id[0] ).forEach(function(node,index,arr){
	    node.style.visibility = 'visible';
	});
	dojo.query( "#logit_"+logEntry.id[0]+"_label" ).forEach(function(node,index,arr){
	    node.style.visibility = 'visible';
	});
    },
    
    __dummyFunc: function () {}
});
