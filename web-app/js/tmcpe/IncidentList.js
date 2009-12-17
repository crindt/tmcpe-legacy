// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.IncidentList");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dijit.Dialog");
dojo.require("dojox.widget.Dialog");
dojo.require("dojox.json.ref");

dojo.require("tmcpe.TestbedMap");
dojo.require("tmcpe.ItemVectorLayerReadStore");

//dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.IncidentList", [ dijit._Widget ], {
    
    _map: null,
    _incidentsLayer: null,
    _selectIncident: null,
    _hoverIncident: null,

    _vdsLayer: null,
    _selectVds: null,
    _hoverVds: null,

    _incidentGrid: null,

    _incidentDetails: null,

    _progressCount: null,
    _progressTot: null,
    _progressDialog: null,

    _jobs: 0,

    postCreate: function() {
    },

    getMap: function() {
	if ( !this._map ) {
	    this._map = dijit.byId( 'map' );
	}
	return this._map._map;
    },

    getIncidentGrid: function() {
	if ( !this._incidentGrid ) {
	    this._incidentGrid = dijit.byId( 'incidentGrid' );
	}
	return this._incidentGrid;
    },

    getIncidentDetails: function() {
	if ( !this._incidentDetails ) {
	    this._incidentDetails = dojo.byId( 'incidentDetails' );
	}
	return this._incidentDetails;
    },

    _constructIncidentsParams: function( theParams ) {
	var w = 0;
	if ( !theParams || theParams == undefined ) {
	    theParams = {};
	}
	theParams[ 'bbox' ] = [this.getMap().getExtent().toBBOX()];
	theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/

	// get params from the search form...
	if ( dijit.byId( 'startDate' ).getValue() ) {
	    var value = dijit.byId( 'startDate' ).getValue();
	    theParams[ 'fromDate' ] = dijit.byId( 'startDate' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'endDate' ).getValue() ) {
	    var value = dijit.byId( 'endDate' ).getValue();
	    theParams['toDate'] = dijit.byId( 'endDate' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'earliestTime' ).getValue() ) {
	    var value = dijit.byId( 'earliestTime' ).getValue();
	    theParams['earliestTime'] = dijit.byId( 'earliestTime' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'latestTime' ).getValue() ) {
	    var value = dijit.byId( 'latestTime' ).getValue();
	    theParams['latestTime'] = dijit.byId( 'latestTime' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'fwy' ).getValue() ) {
	    var value = dijit.byId( 'fwy' ).getValue();
	    theParams['freeway'] = value;//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'dir' ).getValue() ) {
	    var value = dijit.byId( 'dir' ).getValue();
	    theParams['direction'] = value;//myFormatDateOnly( value );
	};
	var days = [ "mon", "tue", "wed", "thu", "fri", "sat", "sun" ];
	for ( dow in days ) {
	    var dowWid = dijit.byId( days[dow] );
	    //	alert( "DOW " + days[dow] + ": " + dowWid );
	    if ( dowWid && dowWid.checked ) {
		//	    alert( "DOW " + days[dow] + " CHECKED" );
		if ( theParams['dow'] == undefined ) {
		    theParams['dow'] = dowWid.attr('value');
		} else {
		    theParams['dow'] += "," + dowWid.attr('value');
		}
	    }
	}
	//    alert( "PARAMS: " + theParams['dow'] );

	//    alert( "THE PARAMS MAX" + theParams['max'] );
	if ( theParams['max'] == undefined ) 
	{
	    theParams['max'] = 1000;
	}
	//    alert( "THE PARAMS MAX" + theParams[ 'max' ] );

	return theParams;

    },

    initApp: function() {
	this._incidentsLayerInit();
    },

    _incidentsLayerInit: function() {
	// should validate

	// Create the incidents layer.  The URL is hardcoded here...
	this._incidentsLayer = new OpenLayers.Layer.Vector("Incidents", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Protocol.HTTP({
		url: "/tmcpe/incident/list.geojson",//theurl,
		params: this._constructIncidentsParams(),
		format: new OpenLayers.Format.GeoJSON({})
            })
	});

	var obj = this;
	this._incidentsLayer.events.on({
            "featureselected": obj.onFeatureSelectIncident,
            "featureunselected": obj.onFeatureUnselectIncident,
	    "beforefeaturesadded": function (feat) { 
//		obj._loadStart();
		obj._progressTot = feat.features.length; 
		if ( obj._progressTot == 0 ) 
		    obj._loadEnd();
		else
		{
		    console.log( feat.features.length );
		    obj._progressCount = 0; 
		    obj._progressDialog.attr( 'content', "Downloaded " +obj._progressCount + " of " + obj._progressTot ); 
		    console.log( "Downloaded " +obj._progressCount + " of " + obj._progressTot );
		}
	    },
	    "featureadded": function( feat ) { 
		obj._progressCount++ 
		obj._progressDialog.attr( 'content', "Downloaded " +obj._progressCount + " of " + obj._progressTot ); 
		console.log( "Downloaded " +obj._progressCount + " of " + obj._progressTot );
	    },
	    "featuresadded": function() { obj.updateIncidentsTable(); obj._loadEnd(); },
	    "featuresremoved": function() { obj.updateIncidentsTable() },
	    "moveend": function() { obj.updateIncidentsQuery(); }
	});

	//    map.events.register("moveend", null, function() { alert("updating query"); updateIncidentsQuery(); } )
	this.getMap().addLayers([this._incidentsLayer]);

	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "yellow",
	    strokeColor: "yellow"
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

    _constructVdsSegmentsParams: function( theParams ) {
	if ( !theParams || theParams == undefined ) {
	    // some defaults to prevent runaways
	    theParams = {};
	    
	    theParams = {};
	    theParams[ 'district' ] = 12;
	}
	theParams[ 'type' ] = 'ML';
	theParams[ 'bbox' ] = [getMap().getExtent().toBBOX()];
	theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/
	
	return theParams;
    },
    
    
    _vdsLayerInit: function( theParams ) {

	var myParams = this._constructVdsSegmentsParams( theParams );

	this._vdsLayer = new OpenLayers.Layer.Vector("Vds Segments", {
            projection: this.getMap().displayProjection,
            strategies: [new OpenLayers.Strategy.Fixed()],
	    style: {strokeWidth: 8, strokeColor: "#00ff00", strokeOpacity: 0.25 },
            protocol: new OpenLayers.Protocol.HTTP({
  		url: "/tmcpe/vds/list.geojson",
		params: myParams,
		format: new OpenLayers.Format.GeoJSON({})
	    })
	});
	
	var obj = this;
	vdsSegmentLines.events.on({
	    "featureselected": obj._onFeatureSelectVds,
	    "featureunselected": obj._onFeatureUnselectVds,
	    "moveend": function() { obj.updateVdsSegmentsQuery( {} ); }
	});

	/*
           vdsSegmentLines.events.register("featureselected", null, onFeatureSelectVds )
           vdsSegmentLines.events.register("featureunselected", null, onFeatureUnselectVds )
           map._map.events.register("moveend", null, function() { updateVdsSegmentsQuery(); } )
         */

	this.getMap().addLayers([vdsSegmentLines]);


	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "yellow",
	    strokeColor: "yellow"}, OpenLayers.Feature.Vector.style["select"]);

	this._hoverVds = new OpenLayers.Control.SelectFeature(
	    this._vdsLayer,{ 
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
	this.getMap().addControl(this._hoverVds);
	this._hoverVds.activate();


	var selectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "blue",
	    strokeColor: "blue"}, OpenLayers.Feature.Vector.style["select"]);

	this._selectVds = new OpenLayers.Control.SelectFeature(
	    this._vdsLayer,{
		highlightOnly: true,
		renderIntent: "temporary",
		selectStyle: selectStyle
	    });
	
	this.getMap().addControl(selectVds);
	this._selectVds.activate();   
	
    },
    


    ////////// TABLE FUNCTIONS

    scrollIncidentsToItem: function ( item ) {
	var cad = item.attributes.id;
	var gn = this.getIncidentGrid();

	if ( !gn.store.isItemLoaded( item ) )
	{
	    gn.store.loadItem( item );
	}
	var idx = gn.getItemIndex( item );
	if ( idx == -1 ) {
	    // hmm, the grid hasn't materialized this item, 
	    /*
	idx = item._0;
	// load the missing page
	// some hackiness from http://neonstalwart.blogspot.com/2009/05/fetching-everything-selected-in.html
	var pageIndex = gn._rowToPage( idx );
	gn._requestPage( pageIndex );
*/
	    // the above hack only works for itemfilereadstore.  Here,
	    // we'll scan the features until we find the correct item.
	    // This will be slow, but should work
	    var i = 0;
	    var items = this._incidentsLayer.features;
	    for ( i = 0; i < items.length && items[ i ] != item; ++ i )
	    {}
	    // If found, set idx
	    if ( i <= items.length ) idx = i;
	}
	if ( idx >= 0 ) {
	    gn.selection.clear();
	    gn.selection.addToSelection( idx );
	    gn.scrollToRow( idx );
	    //				     alert( "item " + cad + "found @ idx:" + idx );	
	} else {
	    alert( "Strangely, item " + cad + " wasn't found in the grid!" );
	}
	
	//    alert( "Selected " + cad )
    },

    updateIncidentsTable: function( theParams ) {
	// Point the store to the incidents layer
	var store = new tmcpe.ItemVectorLayerReadStore( {vectorLayer: this._incidentsLayer} );
	this.getIncidentGrid().setStore( store );

    },



    updateIncidentDetails: function( feature ) {
	var cad = feature.attributes.id
	this.getIncidentDetails().innerHTML = 
	    "<h3>INCIDENT " + cad + "</h3><dl>" 
	    + "<dt>loc</dt><dd>" + feature.attributes.locString + "</dd>"
	    + "<dt>memo</dt><dd>" + feature.attributes.memo + "</dd>"
            + "</dl>"
	
	    + '<p><A href="/tmcpe/incident/show?id='+cad+'">Show Incident</a></p>';
    },





    // EVENT HANDLERS: FIXME: This technically aren't members of this class; js quirks...
    onFeatureSelectIncident: function(event) {
	var il = dijit.byId( 'incidentList' );
	var feature = event.feature;

	il.scrollIncidentsToItem( feature );
	il.updateIncidentDetails( feature );
    },


    onFeatureUnselectIncident: function(event) {
	var il = dijit.byId( 'incidentList' );
	var feature = event.feature;
	if(feature.popup) {
            il.getMap().removePopup(feature.popup);
            feature.popup.destroy();
            delete feature.popup;
	}
    },


    onFeatureSelectVds: function(event) {
	var il = dijit.byId( 'incidentList' );

	var feature = event.feature;
	var lonlats = feature.attributes.vdsLocation.split( ' ' );
	var lonlat = new OpenLayers.LonLat( lonlats[ 0 ], lonlats[ 1 ] ).transform(map._map.displayProjection, map._map.projection)
	var popup = new OpenLayers.Popup.FramedCloud("chicken", 
            lonlat,
            new OpenLayers.Size(100,100),
            "<h2>"+feature.attributes.name + "</h2>",// + feature.attributes.description,
            null, true, onPopupCloseVds
						    );
	feature.popup = popup;
	il.getMap().addPopup(popup);
    },

    onFeatureUnselectVds: function(event) {
	var il = dijit.byId( 'incidentList' );
	var feature = event.feature;
	if(feature.popup) {
            il.getMap().removePopup(feature.popup);
            feature.popup.destroy();
            delete feature.popup;
	}
    },

    
    simpleSelectIncident: function( event ) {
	var il = dijit.byId( 'incidentList' );
	var incident = event.grid.getItem( event.rowIndex );

	// raise it to the top
	il._incidentsLayer.removeFeatures( incident, { silent:true } );
	il._incidentsLayer.addFeatures( incident, { silent:true } );

	il._selectIncident.unselectAll();
	il._selectIncident.select( incident );
    },


    updateIncidentsQuery: function( theParams ) {

	// clear any existing selections...
	if ( this._selectIncident )
	    this._selectIncident.unselectAll();
	
	var myParams = this._constructIncidentsParams( theParams );

	this._loadStart();

	this._updateIncidentsLayer( myParams );
	//    updateIncidentsTable( myParams );

	// Sleep so we don't destroy the dialog too soon.
	var obj = this;
	setTimeout( function() { obj._loadEnd();} , 1000 );
    },

    _loadStart: function() {
	this._jobs++;
	if ( !this._progressDialog ) {
	    this._progressDialog = new dijit.Dialog({//dojox.widget.Dialog({
//		title: "Loading",
		id: "progressDialog",
		showTitle: false,
		style: "width: 300px",
		modal: true
            });
	    // this hides the title bar of the dialog...
	    dojo.query( '#progressDialog > .dijitDialogTitleBar' ).style( { "display": "none" } ) ;
	    //.style( { display: none } ); 
//	    dojo.byId('mapPane').appendChild( this._progressDialog );
	}
	this._progressDialog.attr( 'content', "Querying for incidents..." ); 
	if ( !this._progressDialog.open ) {
	    this._progressDialog.show();
	}
    },

    _loadEnd: function() {
	this._jobs--;
//	this._progressDialog.attr( "content", "finished" ); 
	if ( this._jobs <= 0 ) { this._progressDialog.hide(); }
    },

    updateVdsSegmentsQuery: function( theParams ) {
	if ( this._selectVds )
	    this._selectVds.unselectAll();
	var myParams = this._constructVdsSegmentsParams( theParams );

	this._updateVdsSegmentsLayer( myParams );
    },

    _updateIncidentsLayer: function( theParams ) {

	if ( this._incidentsLayer.protocol.url == "" ) {
	// update the url
	    this._incidentsLayer.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: "/tmcpe/incident/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	this._incidentsLayer.refresh({force: true, params:theParams});
    },

    _updateVdsSegmentsLayer: function( theParams ) {
	if ( this._vdsLayer.protocol.url == "" ) {
	    // update the url
	    this._vdsLayer.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: "/tmcpe/vds/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	this._vdsLayer.refresh({force: true, params:theParams});    
    },




    __dummyFunction: function() {}
});