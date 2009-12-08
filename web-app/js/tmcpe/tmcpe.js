//////// HERE'S A BUNCH OF MAP CRAP
var lon = 5;
var lat = 40;
var zoom = 5;
var map, select;

var incidentFeatureMap = new Object();
var incidents;
var vdsSegmentLines;
var hoverVds;
var selectVds;
var selectIncident;

function initApp() {
    mapInit();
    segmentsLayerInit();
    incidentsLayerInit();

//    vdsSegmentLines.raiseLayer(-100);
}

function mapInit(){
    var options = {
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
	//	        minZoomLevel: 3,
	//	        numZoomLevels: 17
	minZoomLevel: 1,
	maxZoomLevel: 17,
	numZoomLevels: 17,
        maxResolution: 156543.0339,
        maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34,
                                         20037508.34, 20037508.34)
    };
    map = new OpenLayers.Map('map', options);
    var mapnik = new OpenLayers.Layer.TMS(
        "OpenStreetMap (Mapnik)",
        "http://tile.openstreetmap.org/",
        {
            type: 'png', getURL: osm_getTileURL,
            displayOutsideMaxExtent: true,
            attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>'
        }
    );
    var osma = new OpenLayers.Layer.TMS(
        "OpenStreetMap (Osmarender)",
        "http://tah.openstreetmap.org/",
        {
            type: 'png', getURL: osm_getOsmaTileURL,
            displayOutsideMaxExtent: true,
            attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>'
        }
    );
    //            var gmap = new OpenLayers.Layer.Google("Google", {sphericalMercator:true});


    map.addLayers([mapnik, osma]);

    map.addControl(new OpenLayers.Control.LayerSwitcher());

    map.zoomToExtent(
        new OpenLayers.Bounds(
	        -117.9784, 33.594, -117.6832, 33.7768
        ).transform(map.displayProjection, map.projection)
    );
}


function osm_getTileURL(bounds) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    var z = this.map.getZoom();
    var limit = Math.pow(2, z);

    if (y < 0 || y >= limit) {
        return OpenLayers.Util.getImagesLocation() + "404.png";
    } else {
        x = ((x % limit) + limit) % limit;
        return this.url + z + "/" + x + "/" + y + "." + this.type;
    }
}

function osm_getOsmaTileURL(bounds) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    var z = this.map.getZoom();
    var limit = Math.pow(2, z);

    if (y < 0 || y >= limit) {
        return OpenLayers.Util.getImagesLocation() + "404.png";
    } else {
        x = ((x % limit) + limit) % limit;
	//        return this.url + z + "/" + x + "/" + y + "." + this.type;
	return this.url + "Tiles/tile/" + z + "/" + x + "/" + y + "." + this.type;
    }
}



function updateIncidentDetails( feature ) {
    var cad = feature.attributes.id
    dojo.byId( "incdet" ).innerHTML = 
	"<h3>INCIDENT " + cad + "</h3><dl>" 
	+ "<dt>loc</dt><dd>" + feature.attributes.locString + "</dd>"
	+ "<dt>memo</dt><dd>" + feature.attributes.memo + "</dd>"
        + "</dl>"
    
	+ '<p><A href="/tmcpe/incident/show?id='+cad+'">Show Incident</a></p>';
}

function onFeatureSelectIncident(event) {
    var feature = event.feature;

    scrollIncidentsToItem( feature );
    updateIncidentDetails( feature );
}


function onFeatureUnselectIncident(event) {
    var feature = event.feature;
    if(feature.popup) {
        map.removePopup(feature.popup);
        feature.popup.destroy();
        delete feature.popup;
    }
}

function onPopupCloseVds(evt) {
    selectVds.unselectAll();
}
function onFeatureSelectVds(event) {
    var feature = event.feature;
    var selectedFeature = feature;
    var lonlats = feature.attributes.vdsLocation.split( ' ' );
    var lonlat = new OpenLayers.LonLat( lonlats[ 0 ], lonlats[ 1 ] ).transform(map.displayProjection, map.projection)
    var popup = new OpenLayers.Popup.FramedCloud("chicken", 
        lonlat,
        new OpenLayers.Size(100,100),
        "<h2>"+feature.attributes.name + "</h2>",// + feature.attributes.description,
        null, true, onPopupCloseVds
						);
    feature.popup = popup;
    map.addPopup(popup);
}
function onFeatureUnselectVds(event) {
    var feature = event.feature;
    if(feature.popup) {
        map.removePopup(feature.popup);
        feature.popup.destroy();
        delete feature.popup;
    }
}

function getVdsSegmentLines() {
    return vdsSegmentLines;
}

function getHoverVds() {
    return hoverVds;
}

function getIncidentFeature(inname) {
    var ret = null;
    for ( f in incidents.features )
    {
	if ( incidents.features[f].attributes.name == inname ) {
	    ret = incidents.features[f];
	    return incidents.features[f];
	    break;
	} else {
	    continue;
	}
    }
    return ret;
}

function simpleSelectIncident( event ) {
    var incident = event.grid.getItem( event.rowIndex );

    // raise it to the top
    incidents.removeFeatures( incident, { silent:true } );
    incidents.addFeatures( incident, { silent:true } );

    selectIncident.unselectAll();
    selectIncident.select( incident );
}


function updateIncidentsQuery( theParams ) {

    // clear any existing selections...
    if ( selectIncident )
	selectIncident.unselectAll();

    var myParams = constructIncidentsParams( theParams );

//    loadStart();

    updateIncidentsLayer( myParams );
//    updateIncidentsTable( myParams );

//    loadEnd();
}

function updateVdsSegmentsQuery( theParams ) {
    if ( selectVds )
	selectVds.unselectAll();
    var myParams = constructVdsSegmentsParams( theParams );

    updateVdsSegmentsLayer( myParams );
}

function updateIncidentsLayer( theParams ) {

    if ( incidents.protocol.url == "" ) {
	// update the url
	incidents.protocol = 
	    new OpenLayers.Protocol.HTTP({
  		url: "/tmcpe/incident/list.geojson",
		params: theParams,
		format: new OpenLayers.Format.GeoJSON({})
	    });
    }
    incidents.refresh({force: true, params:theParams});
}

function updateVdsSegmentsLayer( theParams ) {
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
}




////////// TABLE FUNCTIONS

function scrollIncidentsToItem( item ) {
    var cad = item.attributes.id;
    var gn = dijit.byId( "incidentGridNode" );
    //				 alert( "ITEM["+cad+"] IS " + item.id );
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
	var items = incidents.features;
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
}

function updateIncidentsTable( theParams ) {
    // Point the store to the incidents layer
    var store = new tmcpe.ItemVectorLayerReadStore( {vectorLayer: incidents} );
    incidentGrid.setStore( store );
}






function constructVdsSegmentsParams( theParams ) {
    if ( !theParams || theParams == undefined ) {
	// some defaults to prevent runaways
	theParams = {};

	theParams = {};
	theParams[ 'district' ] = 12;
    }
    theParams[ 'type' ] = 'ML';
    theParams[ 'bbox' ] = [map.getExtent().toBBOX()];
    theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/

    return theParams;
}

function constructIncidentsParams( theParams ) {
    var w = 0;
    if ( !theParams || theParams == undefined ) {
	theParams = {};
    }
    theParams[ 'bbox' ] = [map.getExtent().toBBOX()];
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
}


function incidentsLayerInit(theurl) {
    incidents = new OpenLayers.Layer.Vector("Incidents", {
        projection: map.displayProjection,
        strategies: [new OpenLayers.Strategy.Fixed()],
/*
        protocol: new OpenLayers.Protocol.HTTP({
	    url: "/tmcpe/incident/list.kml",//theurl,
	    params: constructIncidentsParams(),
            format: new OpenLayers.Format.KML({
                extractStyles: true,
                extractAttributes: true
            })
        })
*/
        protocol: new OpenLayers.Protocol.HTTP({
	    url: "/tmcpe/incident/list.geojson",//theurl,
	    params: constructIncidentsParams(),
	    format: new OpenLayers.Format.GeoJSON({})
        })
    });

    incidents.events.on({
        "featureselected": onFeatureSelectIncident,
        "featureunselected": onFeatureUnselectIncident,
	"featuresadded": function() { updateIncidentsTable() },
	"featuresremoved": function() { updateIncidentsTable() },
	"moveend": function() { updateIncidentsQuery(); }
    });

//    map.events.register("moveend", null, function() { alert("updating query"); updateIncidentsQuery(); } )
    map.addLayers([incidents]);

    var report = function(e) {
        OpenLayers.Console.log(e.type, e.feature.id);
    };

    var selectStyle = OpenLayers.Util.applyDefaults({
	fillColor: "yellow",
	strokeColor: "yellow"}, OpenLayers.Feature.Vector.style["select"]);


    var hoverIncident = new OpenLayers.Control.SelectFeature(incidents,{ 
 	hover: true,
 	highlightOnly: true,
        renderIntent: "temporary",
	selectStyle: selectStyle
	//        eventListeners: {
	//            beforefeaturehighlighted: report,
	//            featurehighlighted: report,
	//            featureunhighlighted: report
	//        }
    });
    map.addControl(hoverIncident);
    hoverIncident.activate();

    selectIncident = new OpenLayers.Control.SelectFeature(incidents);
    map.addControl(selectIncident);
    selectIncident.activate();
}

function segmentsLayerInit( theParams ) {

    var myParams = constructVdsSegmentsParams( theParams );

    vdsSegmentLines = new OpenLayers.Layer.Vector("Vds Segments", {
        projection: map.displayProjection,
        strategies: [new OpenLayers.Strategy.Fixed()],
	style: {strokeWidth: 8, strokeColor: "#00ff00", strokeOpacity: 0.25 },
        protocol: new OpenLayers.Protocol.HTTP({
  	    url: "/tmcpe/vds/list.geojson",
	    params: myParams,
            format: new OpenLayers.Format.GeoJSON({})
	})
    });
    
    vdsSegmentLines.events.on({
	"featureselected": onFeatureSelectVds,
	"featureunselected": onFeatureUnselectVds,
	"moveend": function() { updateVdsSegmentsQuery( {} ); }
    });

/*
    vdsSegmentLines.events.register("featureselected", null, onFeatureSelectVds )
    vdsSegmentLines.events.register("featureunselected", null, onFeatureUnselectVds )

    map.events.register("moveend", null, function() { updateVdsSegmentsQuery(); } )
*/

    map.addLayers([vdsSegmentLines]);


    var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	fillColor: "yellow",
	strokeColor: "yellow"}, OpenLayers.Feature.Vector.style["select"]);

    hoverVds = new OpenLayers.Control.SelectFeature(vdsSegmentLines,{ 
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
    map.addControl(hoverVds);
    hoverVds.activate();


    var selectStyle = OpenLayers.Util.applyDefaults({
	fillColor: "blue",
	strokeColor: "blue"}, OpenLayers.Feature.Vector.style["select"]);

    selectVds = new OpenLayers.Control.SelectFeature(vdsSegmentLines,{
	highlightOnly: true,
	renderIntent: "temporary",
	selectStyle: selectStyle
    });
    
    map.addControl(selectVds);
    selectVds.activate();   



}





















function centerOnIncident( event )
{
    alert( 'simple select' ); 

    //    var layers = map.getLayersByName( layer );
    //    assert( layers.length = 1 );
    //    var layer = layers[ 0 ];
    var item = event.grid.getItem( event.rowIndex );
    var cad = item.attributes.id;
    var incident = getIncidentFeature( "Incident " + cad );
    if ( incident == null ) return;

    //    bbox = null;
    //    for (var i = 0; i < wfsLayer.features.length; i++) {
    //	var geometry = wfsLayer.features[i].geometry;
    //	if (bbox == null) {
    //            bbox = geometry.getBounds().clone();
    //	} else {
    //            bbox.extend(geometry.getBounds());
    //	}
    //    }

    // raise it to the top
    incidents.removeFeatures( incident );
    incidents.addFeatures( incident );

    bbox = incident.geometry.getBounds().clone();

    map.zoomToExtent( bbox );
}

var layersLoading = 0;
function loadStart(event) {
    if (layersLoading == 0) {
	//showLoadingImage();
	//var animnode = dojo.query('animation');
	var animnodes = dojo.query( '#animation' );
	var animnode = null;
	if ( animnodes[0] == null ) {
	    var map = dojo.query( '.olMapViewport' );
	    animnode = map.addContent('<div id="animation" style="position:relative;top:50%;left:50%;visible:true;"/>');
	} else {
	    animnode = animnodes[ 0 ];
	}
//	var image = "<img id='loading_indicator' src='images/ajax-loader.gif' alt='Loading...' />";
	var image = '<p style="visible:true;>BOGGS</p>';
	
	animnode.addContent(image);
	animnode.display = '';
    }
    layersLoading++;
}

function loadEnd(event) {
    layersLoading--;
    if (layersLoading == 0) {
	var li = dojo.byId('#loading_indicator');
	li.parentNode.removeChild( li );
    }
}

