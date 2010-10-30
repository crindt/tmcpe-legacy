// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.TestbedMap");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dojox.json.ref");

//dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.TestbedMap", [ dijit._Widget ], {

    _map: null,

    _mapTooltip: null,

    buildRendering: function() {
	var options = {
            projection: new OpenLayers.Projection("EPSG:900913"),
            displayProjection: new OpenLayers.Projection("EPSG:4326"),
            units: "m",
	    //	        minZoomLevel: 3,
	    //	        numZoomLevels: 17
	    minZoomLevel: 1,
	    maxZoomLevel: 20,
	    numZoomLevels: 20,
            maxResolution: 156543.0339,
            maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34,
                                             20037508.34, 20037508.34),
	    featureEvents: true
	};
	this._map = new OpenLayers.Map('map', options);

	var obj = this;
	var mapnik = new OpenLayers.Layer.TMS(
            "OpenStreetMap (Mapnik)",
            "http://tile.openstreetmap.org/",
            {
		type: 'png', getURL: obj._osm_getTileURL,
		displayOutsideMaxExtent: true,
		attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>'
            }
	);
	var osma = new OpenLayers.Layer.TMS(
            "OpenStreetMap (Osmarender)",
            "http://tah.openstreetmap.org/",
            {
		type: 'png', getURL: obj._osm_getOsmaTileURL,
		displayOutsideMaxExtent: true,
		attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>'
            }
	);

	//var gmap = new OpenLayers.Layer.Google("Google", {sphericalMercator:true, numZoomLevels:20});


	this._map.addLayers([ mapnik, osma/*, gmap*/]);

	this._map.addControl(new OpenLayers.Control.LayerSwitcher());

	// for callback closure...
	var obj = this;
	
	// Add mouse position controls (per: http://www.peterrobins.co.uk/it/olchangingprojection.html)
	this._map.addControl(new OpenLayers.Control.MousePosition( {id: "ll_mouse", formatOutput: obj._formatLonlats} ));
//	this._map.addControl(new OpenLayers.Control.MousePosition( {id: "utm_mouse", prefix: "UTM ", displayProjection: obj._map.baseLayer.projection, numDigits: 0} ));
	
	
	// Create tooltip div
	this._mapTooltip = dojo.byId('map').appendChild( document.createElement( 'div', { 
	    id: "mapTooltip",
	    className: "popup",
	    style: "visibility: hidden;position:absolute;z-index:800;padding:5px;border-width:1px;border-color:#000000;border-style:solid;"
	}));
    },
    
    _formatLonlats: function(lonLat) {
        var lat = lonLat.lat;
        var lon = lonLat.lon;
        var ns = lat; OpenLayers.Util.getFormattedLonLat(lat);
        var ew = lon; OpenLayers.Util.getFormattedLonLat(lon,'lon');
        return ns + ', ' + ew + ' (' + (Math.round(lat * 10000) / 10000) + ', ' + (Math.round(lon * 10000) / 10000) + ')';
    },
    
    _osm_getTileURL: function(bounds) {
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
    },

    _osm_getOsmaTileURL: function(bounds) {
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
    },


    postCreate: function() {

	// This is hardcoded to OC right now
	this._map.zoomToExtent(
            new OpenLayers.Bounds(
	            -117.9784, 33.594, -117.6832, 33.7768
            ).transform(this._map.displayProjection, this._map.projection)
	);

    },




    // Tooltip code lifted from: http://www.peterrobins.co.uk/it/olvectors.html
    featureOver: function(feature) {
	// 'this' is selectFeature control
	var fname = feature.attributes.name || feature.attributes.title || feature.attributes.id || feature.fid;
	if (feature.geometry.CLASS_NAME == "OpenLayers.Geometry.LineString") {
	    fname += ' '+ Math.round(feature.geometry.getGeodesicLength(feature.layer.map.baseLayer.projection) * 0.1) / 100 + 'km';
	}
	var xy = this.map.getControl('ll_mouse').lastXy || new OpenLayers.Pixel(0,0);
	this.showTooltip(fname, xy.x, xy.y);
    },

    getViewport: function () {
	var e = window, a = 'inner';
	if ( !( 'innerWidth' in window ) ) {
	    a = 'client';
	    e = document.documentElement || document.body;
	}
	return { width : e[ a+'Width' ], height : e[ a+'Height' ] }
    },

    showTooltip: function(ttText, x, y) {
//	alert( "Showing tooltip " + ttText + " @ " + x + ", " + y );
	//var windowWidth = this.getViewport().width;
	var windowWidth = this._map.size.w;
	var o = this._mapTooltip;  //this._mapTooltip;
	o.innerHTML = ttText;
	if(o.offsetWidth) {
	    var ew = o.offsetWidth;
	    var eh = o.offsetHeight;
	} else if(o.clip.width) {
	    var ew = o.clip.width;
	    var eh = o.clip.height;
	}
	//y = y + 16;
	var oldy = y;
	y = y - 20;
	//x = x - (ew / 4);
	var oldx = x;
	x = x + 20;
	if (x < 2) {
	    x = 2;
	} else if(x + ew > windowWidth) {
	    x = oldx - ew - 20;
	}
	if ( y - 20 - eh < 0 ) {
	    y = oldy + 20;
	}


	o.style.zIndex = 800;
	o.style.backgroundColor = '#ffffff';
	o.style.borderColor = '#000000';
	o.style.borderLeft = '1px';
	o.style.borderRight = '1px';
	o.style.borderTop = '1px';
	o.style.borderBottom = '1px';
	o.style.borderStyle = 'solid';
	o.style.padding = '5px';
	o.style.position = 'absolute';
	o.style.left = x + 'px';
	o.style.top = y + 'px';
	o.style.visibility = 'visible';
    },

    hideTooltip: function () {
	this._mapTooltip.style.visibility = 'hidden';
    },


    __dummyFunction: function() {}
});
