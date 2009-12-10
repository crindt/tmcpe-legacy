// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.IncidentView");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dojox.json.ref");

//dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.IncidentView", [ dijit._Widget ], {

    // private vars
    _tsd: null,
    _map: null,
    _vdsSegmentLines: null,
    _selectVds: null,
    _hoverVds: null,
    
    constructor: function() {
    },

    initApp: function() {
	mapInit();
	this.initVdsSegmentsLayer( {} );
    },

    _constructVdsSegmentsParams: function( theParams ) {

	this._tsd = dijit.byId( 'tsd' );
	var tsd = this._tsd;

	if ( !theParams || theParams == undefined ) {
	    // some defaults to prevent runaways
	    theParams = {};
	    theParams[ 'district' ] = 12;
	}

	theParams[ 'type' ] = 'ML';
	theParams[ 'bbox' ] = [map.getExtent().toBBOX()];
	theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/

	var sectionParams = {idIn:[]};

	// Get the station indexes of all segments
	for ( i = 0; i < tsd._data.segments.length; ++i )
	{
	    var stnidx = tsd._data.segments[i].stnidx;
	    var station = tsd._stations[ stnidx ];
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
	var vdsSegmentLines = this._vdsSegmentLines;
	if ( vdsSegmentLines.protocol.url == "" ) {
	    // update the url
	    vdsSegmentLines.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: "/tmcpe/vds/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	vdsSegmentLines.refresh({force: true, params:theParams});    

	this._linkFeaturesToCells();
    },

    _linkFeaturesToCells: function() {
	// Now wire up the table data to highlight the 
	var tsd = this._tsd;
	var segments = tsd._data.segments;
	var td = tsd._td;
	for ( var i = 0; i < td.length; ++i ) {
	    dojo.connect( tsd._tr[ i ], "onmouseover", this, "_hoverTime" );
	    for ( var j = 0; j < td[i].length; ++j ) {
		dojo.connect( td[i][j], "onmouseover", this, "_hoverStation" );
	    }
	}
    },

    initVdsSegmentsLayer: function( theParams ) {

	var myParams = this._constructVdsSegmentsParams( theParams );
	this._map = dijit.byId( 'map' );
	//var map = this._map;


	this._vdsSegmentLines = new OpenLayers.Layer.Vector("Vds Segments", {
            projection: map.displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
	    style: {strokeWidth: 4, strokeColor: "#00ff00", strokeOpacity: 0.75 },
            protocol: new OpenLayers.Protocol.HTTP({
  		url: "/tmcpe/vds/list.geojson",
		params: myParams,
		format: new OpenLayers.Format.GeoJSON({})
	    })
	});
	
	var obj = this;
	this._vdsSegmentLines.events.on({
//	    "featureselected": onFeatureSelectVds,
//	    "featureunselected": onFeatureUnselectVds,
	    "moveend": function() { obj.updateVdsSegmentsQuery( {} ); }
	});


	map.addLayers([this._vdsSegmentLines]);


	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
//	    fillColor: "cyan",
//	    strokeColor: "cyan",
	    strokeWidth: 8,
	    strokeOpacity: 1
	}, OpenLayers.Feature.Vector.style["select"]);

	this._hoverVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLines,{ 
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
	map.addControl(this._hoverVds);
	this._hoverVds.activate();


	var selectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "blue",
	    strokeColor: "blue"}, OpenLayers.Feature.Vector.style["select"]);

	this._selectVds = new OpenLayers.Control.SelectFeature(this._vdsSegmentLines,{
	    highlightOnly: true,
	    renderIntent: "temporary",
	    selectStyle: selectStyle
	});
	
	map.addControl(this._selectVds);
	this._selectVds.activate();   


	this._linkFeaturesToCells();

	map.zoomToExtent( this._vdsSegmentLines.getExtent() );

    },


    _hoverStation: function( e ) {
	var stationnm = e.target.getAttribute( 'station' );
	var station = this._tsd._stations[ stationnm ];
	console.debug( "station:" + station.vdsid );

	// HACK: highlight the corresponding station in the map
	var vsl = this._vdsSegmentLines;
	if ( vsl ) {
	    // Loop over the lines until we find the correct station
	    var feature = null;
	    for ( var j = 0; j < vsl.features.length && !feature; ++j )
	    {
		var ff = vsl.features[ j ];
		if ( station.vdsid == ff.attributes[ 'id' ] ) {
		    feature = ff;
		}
	    }
/*
	    if ( feature ) {
		feature.style.strokeColor = tdc.style.backgroundColor;
		feature.style.strokeWidth = 8;
		feature.style.strokeOpacity = 1;
		this._vdsSegmentLines.drawFeature( feature );
	    }
*/

	    // OK, found the feature.  Highlight it?  select it
	    this._hoverVds.unselectAll();
	    this._hoverVds.select( feature );
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
		var station = this._tsd._stations[ tdc.getAttribute('station') ];
		
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
		// OK, found the feature.  alter the style
		if ( feature ) {
		    feature.style.strokeColor = tdc.style.backgroundColor;
		    this._vdsSegmentLines.drawFeature( feature );
		}
	    }
	}
	this._hoverStation( e ); // highlight the station we're hovering over
	console.log( 'TIME: ' + this._tsd.getTimeForIndex( timeind ) );
    },

    __dummyFunc: function () {}
});
