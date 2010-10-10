// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.IncidentView");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dojox.json.ref");

// dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.IncidentView", [ dijit._Widget ], {

    // parameters
    incidentId: null,

    // private vars
    _incident: null,
    _tsd: null,
    _map: null,
    _vdsSegmentLines: null,
    _incidentsLayer: null,
    _selectVds: null,
    _hoverVds: null,
    _facilityImpactAnalysis: null, // the active impact analysis (the one in the plot)

    _facilityStore: null, // The dojo facility store
    _incidentSummary: null, // The dom node holding the incident summary
    _activityLogGrid: null, // The dom node holding the activity log grid dojo
							// widget
    
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
	console.log( "LOADING DATA FOR INCIDENT " + url );
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
	var caller = this;
	var url = base + 'incident/showAnalyses?id=' + this.incidentId;
	console.log( "LOADING ANALYSES FOR INCIDENT " + url );
	if ( this._incident && this._incident.id != null ) {
	    dojo.xhrGet({
		url: url,
		preventCache: true,
		handleAs: "text",
		sync: true, //false,
		load: function( r ) {
		    var inc = caller._incident;
		    inc.analyses = dojox.json.ref.fromJson( r );
		},
		error: function( r ) {
		    alert( 'Error loading analyses for ' + caller._incident.cad + ': ' + r)
		}
	    });
	} else {
	    alert( "Asked to load analyses for NULL incident" );
	}

	if ( this._incident.analyses.length > 0 ) {
	    // sets the displayed analysis to the default (0) and
	    // loads the facility analyses into the filteringselect
	    facilityStore.url = base + 'incidentImpactAnalysis/showAnalyses?id=' + this._incident.analyses[ 0 ].id;

	    // Here, we set the default displayed TSD to that
	    // corresponding to the primary disrupted facility
	    var ff = this._incident.section.freewayId + '-' + this._incident.section.freewayDir;
	    facilityCombo.set( 'displayedValue', ff );
	} else {
	    this.getTsd()._displayNoAnalysis();
	}
    },

    updateFacilityImpactAnalysis: function( fiaId ) {
	var base = document.getElementById("htmldom").href;
	this._facilityImpactAnalysis = fiaId;
	this.getTsd().updateUrl( base + 'incidentFacilityImpactAnalysis/show.json?id='+fiaId );

	var fia = this.getTsd()._data;

	var fiaSummary = "incident " + this._incident.cad + "["+this._incident.id+"] analysis "+fiaId+":"+fia.location.freewayDir+"-"+fia.location.freewayId

	// Update XLS link
	var base = document.getElementById("htmldom").href;
	dojo.byId('tmcpe_tsd_xls_link').innerHTML = 'Download XLS for facility analysis ' + this._facilityImpactAnalysis;
	dojo.byId('tmcpe_tsd_xls_link').href = base+'incidentFacilityImpactAnalysis/show.xls?id='+this._facilityImpactAnalysis;

	dojo.byId('tmcpe_report_problem_link').innerHTML = 'Report problem with this facility analysis';
	url = "http://localhost/redmine/projects/tmcpe/issues/new?tracker_id=3&issue[subject]=Problem%20with%20analysis%20of%20"+fiaSummary+"&issue[description]=Bad%20analysis%20for%20available%20for "+fiaSummary;
	dojo.byId('tmcpe_report_problem_link').href = url;
	dojo.byId('tmcpe_report_problem_link').onclick = "return popitup('"+url+"')";
	this.updateVdsSegmentsQuery();
    },

    _constructVdsSegmentsParams: function( theParams ) {

	var tsd = this.getTsd();
	if ( !theParams || theParams == undefined ) {
	    // some defaults to prevent runaways
	    theParams = {};
	    theParams[ 'district' ] = 12;
	}

	theParams[ 'type' ] = 'ML';
	theParams[ 'bbox' ] = [this.getMap().getExtent().toBBOX()];
	theParams[ 'proj' ] = "EPSG:900913";/* map.projection */

	var sectionParams = {idIn:[]};

	// Get the station indexes of all segments
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
	if ( ! this._vdsSegmentLines ) {
	    this.initVdsSegmentsLayer( {} );
	    return;
	}

	var base = document.getElementById("htmldom").href;

	var vdsSegmentLines = this._vdsSegmentLines;
	if ( vdsSegmentLines.protocol.url == "" ) {
	    // update the url
	    vdsSegmentLines.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: base + "vds/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	vdsSegmentLines.refresh({force: true, params:theParams});    
    },

    _linkFeaturesToCells: function() {
	// Now wire up the table data to highlight the
	var tsd = this._tsd;
	var sections = tsd._data.sections;
	var td = tsd._td;
	var itd = tsd._itd;
	for ( var i = 0; i < td.length; ++i ) {
	    var tr = tsd._tr[i];
	    var itr = tsd._itr[i];
	    dojo.connect( tr, "onmouseover", this, "_hoverTime" );
	    dojo.connect( itr, "onmouseover", this, "_hoverTime" );
	    for ( var j = 0; j < td[i].length; ++j ) {
		dojo.connect( td[i][j], "onmouseover", this, "_hoverStation" );
		dojo.connect( td[i][j], "onclick", this, "_clickTimeSpaceCell" );
		dojo.connect( itd[i][j], "onmouseover", this, "_hoverStation" );
		dojo.connect( itd[i][j], "onclick", this, "_clickTimeSpaceCell" );
	    }
	}

	// Loop over the stations to connect them to features
	var vsl = this._vdsSegmentLines;
	for ( var j = 0; j < tsd._data.sections.length; ++j ) {
	    var station = tsd._data.sections[ tsd._data.sections[ j ].stnidx ];
	    var feature = null;
	    // Loop over the lines until we find the correct station
	    for ( var k = 0; k < vsl.features.length && !feature; ++k )
	    {
		var ff = vsl.features[ k ];
		if ( station ) {
		    // console.log( [station.vdsid,' =?= ', ff.attributes[ 'id' ]
			// ].join( '') );
		    if ( station && station.vdsid == ff.attributes[ 'id' ] ) {
			feature = ff;
		    }
		}
	    }
	    if ( feature && feature.layer && station ) {
		station.feature = feature;
	    }
	}
    },

    _incidentsLayerInit: function() {
	// should validate
	var obj = this;

	// Create the incidents layer.  The URL is hardcoded here...
	var base = document.getElementById("htmldom").href;

	var theParams = {};

	theParams[ 'id' ] = this.incidentId;
	
	this._incidentsLayer = new OpenLayers.Layer.Vector("Incidents", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Protocol.HTTP({
            	url: base + "incident/list.geojson",//theurl,
            	params: theParams,
            	style: {strokeWidth: 2, strokeColor: "#ff0000", strokeOpacity: 0.25, fillColor: "#ff0000" },
            	format: new OpenLayers.Format.GeoJSON({})
            }),
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

    initVdsSegmentsLayer: function( theParams ) {

	var myParams = this._constructVdsSegmentsParams( theParams );

	var base = document.getElementById("htmldom").href;

	this._vdsSegmentLines = new OpenLayers.Layer.Vector("Vds Segments", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
	    style: {strokeWidth: 4, strokeColor: "#00ff00", strokeOpacity: 0.75 },
            protocol: new OpenLayers.Protocol.HTTP({
  		url: base + "vds/list.geojson",
		params: myParams,
		format: new OpenLayers.Format.GeoJSON({})
	    })
	});
	
	var obj = this;
	var first_vds_render = true;
	this._vdsSegmentLines.events.on({
	    "featuresadded": function() { 
		// OK, call linkfeaturestocells when features change on the layer
		obj._linkFeaturesToCells(); 
	    },
	    "featuresremoved": function() { obj._linkFeaturesToCells(); },
	    "moveend": function() { obj.updateVdsSegmentsQuery( {} ); }
	});


	this.getMap().addLayers([this._vdsSegmentLines]);


	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
// fillColor: "cyan",
// strokeColor: "cyan",
	    strokeWidth: 8,
	    strokeOpacity: 1
	}, OpenLayers.Feature.Vector.style["select"]);

	this._hoverVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLines,{ 
 	    hover: true,
 	    highlightOnly: true,
            renderIntent: "temporary",
	    selectStyle: hoverSelectStyle,
	    // eventListeners: {
	    // beforefeaturehighlighted: report,
	    // featurehighlighted: report,
	    // featureunhighlighted: report
	    // }
	});
	this.getMap().addControl(this._hoverVds);
	this._hoverVds.activate();


	var selectStyle = OpenLayers.Util.applyDefaults({
	// fillColor: "blue",
// strokeColor: "blue"
	}, OpenLayers.Feature.Vector.style["select"]);

	this._selectVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLines,{
	    highlightOnly: true,
	    renderIntent: "temporary",
	    selectStyle: selectStyle
	});
	
	this.getMap().addControl(this._selectVds);
	this._selectVds.activate();   


// obj.getMap().zoomToExtent( obj._vdsSegmentLines.getDataExtent() );

/*
 * dojo.connect( this._vdsSegmentLines, "moveend", this.updateVdsSegmentsQuery );
 * dojo.connect( this._vdsSegmentLines, "featuresadded",
 * this._linkFeaturesToCells ); dojo.connect( this._vdsSegmentLines,
 * "featuresremoved", this._linkFeaturesToCells );
 */

    },

    _clickTimeSpaceCell: function( e ) {
    	var stationnm = e.target.getAttribute( 'station' );
    	var timeidx = e.currentTarget.getAttribute( 'timeidx' );
    	var timeind = e.currentTarget.getAttribute( 'time' );
    	var station = this._tsd._data.sections[ stationnm ];
    	
    	// CENTER THE MAP ON THE VDS SECTION WE CLICKED ON
    	console.log( "Centering on feature" );
    	if ( station ) {
    		var feature = station.feature;
    		if ( feature ) {
    			this.getMap().zoomToExtent( feature.geometry.getBounds() );
    		}
    	} else
    		alert( "Unable to find feature in layer" );
    	
    	// SCROLL THE ACTIVITY LOG TO THE NEAREST ENTRY
    	
    },
    
    _hoverStation: function( e ) {
    	var stationnm = e.target.getAttribute( 'station' );
    	var station = this._tsd._data.sections[ stationnm ];
    	/* console.debug( "station:" + station.vdsid ); */
    	
    	// HACK: highlight the corresponding station in the map
    	var vsl = this._vdsSegmentLines;
    	if ( vsl && station ) {
    		var feature = station.feature;
    		/*
    		 * // Loop over the lines until we find the correct station var feature =
    		 * null; for ( var j = 0; j < vsl.features.length && !feature; ++j ) {
    		 * var ff = vsl.features[ j ]; if ( station.vdsid == ff.attributes[ 'id' ] ) {
    		 * feature = ff; } }
    		 */
    		/*
    		 * if ( feature ) { feature.style.strokeColor =
    		 * tdc.style.backgroundColor; feature.style.strokeWidth = 8;
    		 * feature.style.strokeOpacity = 1;
    		 * this._vdsSegmentLines.drawFeature( feature ); }
    		 */
    		
    		// OK, found the feature. Highlight it? select it
    		if ( feature ) {
    			this._hoverVds.unselectAll();
    			this._hoverVds.select( feature );
    		}
    	}
    },
    
    _hoverTime: function( e ) {
	// HACK: alter the segment colors to match tsd
	var timeidx = e.currentTarget.getAttribute( 'timeidx' );
	var timeind = e.currentTarget.getAttribute( 'time' );
	var d = this._tsd._data;

	var vsl = this._vdsSegmentLines;
	if ( vsl ) {

	    var tt = this._tsd._td[ timeidx ].length;
	    for ( var j = 0; j < tt; ++j )
	    {
		var tdc = this._tsd._td[timeidx][j];
		var si = tdc.getAttribute('station');
		var station = this._tsd._data.sections[ si ];
		
		// Loop over the lines until we find the correct station
		var feature = null;
		for ( var k = 0; k < vsl.features.length && !feature; ++k )
		{
		    var ff = vsl.features[ k ];
		    var vdsid = ff.attributes[ 'id' ];
		    if ( station.vdsid == vdsid ) {
			feature = ff;
		    }
		}

		if ( station ) {
		    var feature = station.feature;
		    // OK, found the feature. alter the style
		    if ( feature ) {
			feature.style.strokeColor = tdc.style.backgroundColor;
			this._vdsSegmentLines.drawFeature( feature );
		    }
		}
	    }
	}
// this._hoverStation( e ); // highlight the station we're hovering over
	var stationnm = e.target.getAttribute( 'station' );
	var station = this._tsd._data.sections[ stationnm ];
	if ( ! station ) {
	    station = {
		fwy: "?",
		dir: "?",
		pm: "?",
		name: "?stationnm?"
	    };
	}
	var el = document.getElementById('tmcpe_tsd_cellinfo');
	var str = station.vdsid + ":" + station.fwy + "-" + station.dir + " @ " + station.pm + " [" + station.name + "], " + this._tsd._data.timesteps[timeind];
	var dd = station.analyzedTimesteps[timeind];
	str += " | O:" + dd.spd.toFixed(1) + "-mph, A:" + dd.spd_avg.toFixed(1) + "-mph +/- " + dd.spd_std.toFixed(1) + "-mph | OCC: " + (100*dd.occ).toFixed(1) + '%';
	if ( station.analyzedTimesteps[timeidx].p_j_m == 0.5 ) str += ' <span style="color:#ff0000;font-weight:bold">&lt;UNRELIABLE&gt;</span>';
	el.innerHTML = str;
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
	var logEntry = event.grid.getItem( event.rowIndex );

	// Hide existing
	dojo.query( ".log_tsd_bar" ).forEach(function(node,index,arr){
	    node.style.visibility = 'hidden';
	});

	dojo.query( "#logit_"+logEntry.id[0] ).forEach(function(node,index,arr){
	    node.style.visibility = 'visible';
	});
    },
    
    __dummyFunc: function () {}
});
