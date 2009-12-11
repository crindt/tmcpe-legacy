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

    buildRendering: function() {
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
	//            var gmap = new OpenLayers.Layer.Google("Google", {sphericalMercator:true});


	this._map.addLayers([mapnik, osma]);

	this._map.addControl(new OpenLayers.Control.LayerSwitcher());

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

	this._map.zoomToExtent(
            new OpenLayers.Bounds(
	            -117.9784, 33.594, -117.6832, 33.7768
            ).transform(this._map.displayProjection, this._map.projection)
	);

    },

    __dummyFunction: function() {}
});
