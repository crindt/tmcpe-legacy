/* Copyright (c) 2006-2008 MetaCarta, Inc., published under the Clear BSD
 * license.  See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license. */

/**
 * @requires OpenLayers/Format/JSON.js
 * @requires OpenLayers/Feature/Vector.js
 * @requires OpenLayers/Geometry/Point.js
 * @requires OpenLayers/Geometry/MultiPoint.js
 * @requires OpenLayers/Geometry/LineString.js
 * @requires OpenLayers/Geometry/MultiLineString.js
 * @requires OpenLayers/Geometry/Polygon.js
 * @requires OpenLayers/Geometry/MultiPolygon.js
 * @requires OpenLayers/Console.js
 */

/**
 * Class: OpenLayers.Format.GeoJSON
 * Read and write GeoJSON. Create a new parser with the
 *     <OpenLayers.Format.GeoJSON> constructor.
 *
 * Inherits from:
 *  - <OpenLayers.Format.JSON>
 */
myGeoJSON = OpenLayers.Class(OpenLayers.Format.GeoJSON, {

    _progress: null,

    /**
     * Constructor: OpenLayers.Format.GeoJSON
     * Create a new parser for GeoJSON.
     *
     * Parameters:
     * options - {Object} An optional object whose properties will be set on
     *     this instance.
     */
    initialize: function(options) {

	if ( options.progress ) {
	    this._progress = options.progress;
	}

        OpenLayers.Format.JSON.prototype.initialize.apply(this, [options]);
    },
    
    /**
     * Method: parseFeature
     * Convert a feature object from GeoJSON into an
     *     <OpenLayers.Feature.Vector>.
     *
     * Parameters:
     * obj - {Object} An object created from a GeoJSON object
     *
     * Returns:
     * {<OpenLayers.Feature.Vector>} A feature.
     */
    parseFeature: function(obj) {
        var feature, geometry, attributes, bbox;
        attributes = (obj.properties) ? obj.properties : {};
        bbox = (obj.geometry && obj.geometry.bbox) || obj.bbox;
        try {
            geometry = this.parseGeometry(obj.geometry);
        } catch(err) {
            // deal with bad geometries
            throw err;
        }
        feature = new OpenLayers.Feature.Vector(geometry, attributes);
        if(bbox) {
            feature.bounds = OpenLayers.Bounds.fromArray(bbox);
        }
        if(obj.id) {
            feature.fid = obj.id;
        }

	if ( this._progress ) {
	    var val = this._progress.internalProgress;
	    this._progress.update( { 'progress': (val+1) } );
	}
	
        return feature;
    },

    CLASS_NAME: "myGeoJSON" 

});     
