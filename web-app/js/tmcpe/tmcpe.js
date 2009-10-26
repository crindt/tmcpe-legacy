//////// HERE'S A BUNCH OF MAP CRAP
var lon = 5;
var lat = 40;
var zoom = 5;
var map, select;

var incidentFeatureMap = new Object();
var incidents;

function initApp() {
}

function mapInit(){
    var options = {
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
	//	        minZoomLevel: 3,
	//	        numZoomLevels: 17
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

function onPopupCloseIncident(evt) {
    selectIncident.unselectAll();
}
function onFeatureSelectIncident(event) {
    var feature = event.feature;
    var selectedFeature = feature;
    var popup = new OpenLayers.Popup.FramedCloud("chicken", 
        feature.geometry.getBounds().getCenterLonLat(),
        new OpenLayers.Size(100,100),
        "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
        null, true, onPopupCloseIncident
						);
    feature.popup = popup;
    map.addPopup(popup);
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
        "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
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

//function highlightFeatureByName( layer, name ) {
function centerOnIncident( event )
{
//    var layers = map.getLayersByName( layer );
//    assert( layers.length = 1 );
//    var layer = layers[ 0 ];
    var item = event.grid.getItem( event.rowIndex );
    var cad = item.id;
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
	   var map = dojo.query( '#map' );
	   animnode = map.addContent('<div id="animation" style="position:absolute;top:50%;left:50%"/>');
       } else {
	   animnode = animnodes[ 0 ];
       }
       var image = "<img id='loading_indicator' src='images/ajax-loader.gif' alt='Loading...' />";
       animnode.addContent(image);
       animnode.display = '';
   }
   layersLoading++;
}

function loadEnd(event) {
   layersLoading--;
   if (layersLoading == 0) {
       var li = dojo.query('#loading_indicator');
       li.parentNode.removeChild( li );
   }
}

function incidentsLayerInit(theurl) {
    incidents = new OpenLayers.Layer.Vector("Incidents", {
        projection: map.displayProjection,
        strategies: [new OpenLayers.Strategy.Fixed()],
        protocol: new OpenLayers.Protocol.HTTP({
	    url: theurl,
            format: new OpenLayers.Format.KML({
                extractStyles: true,
                extractAttributes: true
            })
        })
    });

    incidents.events.on({
        "featureselected": onFeatureSelectIncident,
        "featureunselected": onFeatureUnselectIncident
    });

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


    selectIncident = new OpenLayers.Control.SelectFeature(incidents)
    map.addControl(selectIncident);
    selectIncident.activate();
}

function segmentsLayerInit() {

    var vdsSegmentLines = new OpenLayers.Layer.Vector("Vds Segments", {
        projection: map.displayProjection,
        strategies: [new OpenLayers.Strategy.Fixed()],
        protocol: new OpenLayers.Protocol.HTTP({
  	    url: "vds/list.kml?district=12",
            format: new OpenLayers.Format.KML({
                extractStyles: true,
                extractAttributes: true
  	    })
	})
    });
    
    vdsSegmentLines.events.on({
        "featureselected": onFeatureSelectVds,
        "featureunselected": onFeatureUnselectVds
    });

    map.addLayers([vdsSegmentLines]);

    selectVds = new OpenLayers.Control.SelectFeature(vdsSegmentLines);
    
    map.addControl(selectVds);
    selectVds.activate();   



}