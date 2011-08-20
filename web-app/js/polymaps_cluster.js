//     polymaps_cluster.js  0.0.1
//     (c) 2011 James Marca
//
//     polymaps_cluster is freely distributable under the MIT license.
//
//     Portions of polymaps_cluster are inspired or borrowed from the
//     Polymaps cluster example.  Indeed, this code is inspired by our
//     dissatisfaction applying k-means clustering to events that
//     occur on roads.
//
//     Some techniques in polymaps_cluster are borrowed from code in
//     underscore.js, jQuery.js and similar, as noted.  I'd rather
//     borrow idioms from code that is widely used than make up my
//     own!
//
//     For all details and documentation:
//     http://jmarca.github.com/polymaps_cluster

(function() {
    // this technique is borrowed from underscore
    // Establish the root object, `window` in the browser, or `global` on the server.
    // while I don't expect this to be used in a server environment, never say never
    var root = this;

    // hello world
    var polymaps_cluster = {};
    // again borrowing from underscore, allow for exporting this function as a module

    // Export for **CommonJS**, with backwards-compatibility
    // for the old `require()` API. If we're not in CommonJS, add it to the
    // global object.
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = polymaps_cluster;
    } else {
        // Exported to global namespace
        root['polymaps_cluster'] = polymaps_cluster;
    }

    // Current version.
    polymaps_cluster.VERSION = '0.0.1';


    // useless. Instead of determining precision based on zoom, I am
    // just truncating decimals to zero.  but keeping in case it is
    // needed in the future
    function precision(zoom){
        return Math.ceil(Math.log(zoom-0) / Math.LN2);
    }

    // the parameters are totally empirical and hard coded at the moment
    //
    var csize = 15;
    polymaps_cluster.clusterfactor = function(val){
        if(val){
            csize=val;
            return polymaps_cluster;
        }else{
            return csize;
        }
    }

    // function to compute the coordKey for each feature based upon the
    // coordinates, this effectively defines the clustering
    polymaps_cluster.coordKey = function( coord ) {
        var x = coord.x.toFixed(0);
        var y = coord.y.toFixed(0);

        // build the cluster key based on the rounded off point,
        // divided by an arbirary number that looks good on my screen
        var x2 = (x/csize).toFixed(0);
        var y2 = (y/csize).toFixed(0);

        // rather than some complicated maths, just make a hash key
        // based on the rounded off number.  This will force all
        // nearby points to join a cluster.  Quick and dirty, but the
        // operative word is quick

	// fixme: crindt: In effect, this approach creates an arbitrary grid
	// over the map.  All points that fall within this grid are assigned to
	// the same cluster.  The cluster is represented by the first point
	// identified with that grid square.
	//
	// There is a problem with this logic, however.  If the representative
	// points for two adjacent grids squares are both near the boundary
	// between them, then the clusters can be very nearly on top of each
	// other.

	// crindt: use underscore so key can be used as a css selector too.
        var key = x2+'_'+y2;
	if ( x2 < 0 || y2 < 0 ) {
	    key = key.replace(/-/,'m');  // selectors can't have '-' either, substitute m (for minus)
	}
	
	return key;
    }


    //
    // The main function that provides zoom-based clustering.
    //
    polymaps_cluster.cluster = function(){
        // since each tile should have its own clustering function and
        // clusters, this is a closure that returns a function that
        // does the clustering;

        // a points object to stash clusters
        var points = {};

	// a map to look up the cluster (point) for a given element
	var elementMap = {};


        // the clustering function that we will be returning that can
        // access and manipulate the points object.
        //
        // It expects to be used in a Polymap-like environment, such
        // that each passed element has a 'data' member element with x
        // and y coordinates, etc.
        var cluster_func = function(elem) {

            var coord = elem.data.geometry.coordinates

            // position the cluster based on the very first point,
            // truncated to an integer note that x and y are created
            // by Polymaps, based on the geographic coordinates of the
            // object.  They represent the position in the map in
            // pixels, and so rounding them off is roughly equivalent
            // to "real" clustering based on the current zoom level.
            // when you zoom way in, the points get further apart in x
            // and y pixels, and so the clusters will break up

	    var key = polymaps_cluster.coordKey( coord );

	    console.log( key );
            if(!points[key]){
                // create a new cluster, initializing with the current point
                newpoint = elem;
                // make an elements array in the cluster for all other
                // points to be pushed into
                newpoint.data.properties.elements = [elem];
                // position the cluster at the (rounded off) intial
                // point's position.  This will make sure that the cluster
                // is centered at a point that "makes sense" For example,
                // directly on a freeway.
                newpoint.x = coord.x;
                newpoint.y = coord.y;
                // add this new point to the global points object
                points[key] = newpoint

            }else{
                // already have a cluster started for this rounded off
                // point, so add this element to the elements array of
                // that cluster.
                points[key].data.properties.elements.push(elem);
            }
            // that's all folks
            return;
        }

        // clear the clustered points object for a new clustering run
        cluster_func.reset = function(){
            points = {};
        }

        // get the points for this cluster.
        cluster_func.points = function(){
            return points;
        }

	// get the cluster (point) for a given element
	cluster_func.pointForElement = function( elem ) {
	    return points[coordKey(elem.data.geometry.coordinates)];
	}

        return cluster_func;
    };

    //
    // Using and drawing the cluster
    //
    // in Polymaps, there is a load event that is run for json data.
    //
    // the next function is intended to be used as a callback for that
    // function, and it will run the clustering function on the json
    // data for a tile (as parsed and processed already by Polymaps.
    //
    // Set a fixed radius to use for drawing the cluster.  totally
    // arbitrary
    var baseR = 4;
    polymaps_cluster.base_radius = function(val){
        if(val){
            baseR=val;
            return polymaps_cluster;
        }else{
            return baseR;
        }
    }

    //
    // Cluster_load, the function returns a function that calls the
    // above clustering function for each tile in a map.  Complicated
    // I know, but it makes sense in practice.
    //
    // parameter : {}  (an object)
    //  fill: the svg fill color for the point.  default red

    //  stroke: the svg stroke color for the outline of the point.
    //    default black

    //  svgstyleclass: the class to assign to the point. Optional

    //  clear_cb : a function to call when clearing data, will be
    //    passed a feature object

    //  cluster_cb : a function to call when done creating clusters,
    //    will be passed a feature object representing the cluster of
    //    features

    // point_cb : a function to call when a new clustered point is
    //    created.  will be passed the new svg point and the related feature

    //
    // The idea is that multiple layers might have data that require
    // clustering.  Furthermore, each of these layers is loaded in
    // tiles, and each tile will want to process out its own clusters.
    // So this function should be called with some sort of layerstyle
    // object...Not the layer in the sense of Polymaps, but rather
    // just some simple object that defines the defaults for how to
    // paint the clusters for this layer.  What you get in return is a
    // function that you can use for the load events for Polymaps json
    // data.
    //
    // the options currently used are 'stroke', 'fill', and 'svgstyleclass'.
    // The first two do what you expect, the last sets the class for
    // the svg element.  It is named funny due to historical reasons.

    // to do, need to parameterize the other options for the element
    // style.  see below.

    // also also, as I hack on this, you can pass in a callback to run
    // when clearing out the default features array, and again when
    // done creating the new, clustered features array.  option names
    // are 'clear_cb' and 'cluster_cb'.  Both will be paseed each
    // element of the features array (e.features[i]).  One example of
    // a cluster_cb is to pass a reference to the show handler.  and
    // of course, a callback that gets passed the newly created point
    // so you can run any needed code to set up things like tool tips
    // and popups.



    polymaps_cluster.nodeForElement = function( elem ) {
	var res = $("#"+polymaps_cluster.coordKey(elem.geometry.coordinates));
	return res[0];
    };


    polymaps_cluster.Cluster_load=function(layerstyle){
        var style = {'stroke' : "#000"
                       ,'fill'  : "#f00"
                      };
        var options = {};
        // if(_){
        //     _.extend(styles,layerstyle);
        // }else
        if (layerstyle){
            style.stroke = layerstyle.stroke ? layerstyle.stroke : style.stroke;
            style.fill = layerstyle.fill ? layerstyle.fill : style.fill;
            style.svgstyleclass = layerstyle.svgstyleclass ? layerstyle.svgstyleclass : style.svgstyleclass;
            if(layerstyle.clear_cb  ) options.clear_cb   = layerstyle.clear_cb;
            if(layerstyle.point_cb  ) options.point_cb   = layerstyle.point_cb  ;
            if(layerstyle.cluster_cb) options.cluster_cb = layerstyle.cluster_cb;

        }
        // the loading callback function that is passed back, accepts
        // a Polymaps tile element e, or reasonable facsimile thereof.
        return function(e){
            var tile = e.tile;
            var g = tile.element;
            // should perhaps test for existence of e.tile?
            if(!tile.cluster){
                // create a clustering function if it doesn't yet
                // exist for this tile
                tile.cluster=polymaps_cluster.cluster();
            }

            // hmm.  to reset or not?  I think Polymaps is pretty
            // smart about recycling tiles, but in initial usage I was
            // resetting.  test this later, for now leave it on
            tile.cluster.reset();
            // again, this is a polymaps tile element, so it has a features array.
            for (var i = 0; i < e.features.length; i++){
	        var f = e.features[i];
                tile.cluster(f);
                if(options.clear_cb){
                    options.clear_cb(f);
                }
            }

            // empty the feature array
            e.features = [];

            // the map already has points for each feature.  but since
            // I am clustering features, get rid of all of the points now
            while (g.lastChild) g.removeChild(g.lastChild);

            // iterate over the blob points (clusters) to fill in the
            // feature array, and to create new, blobby points
            jQuery.each(tile.cluster.points(), function(key, value) {
	        // add to the feature array
	        e.features.push(value);

                // create a point for this blob
                var point = g.appendChild(po.svg("circle"));
                point.setAttribute("cx", value.x);
                point.setAttribute("cy", value.y);

                // style the point
                var more_wider = value.data.properties.elements.length / 3;
                var more_darker = value.data.properties.elements.length / 20;
                more_darker = more_darker < 0.25 ? more_darker : 0.25;

		point.setAttribute("id", polymaps_cluster.coordKey( value ) );
                point.setAttribute("r", baseR + more_wider );
                point.setAttribute("stroke", style.stroke || "#000");
                point.setAttribute('fill',style.fill || "#f00");
                point.setAttribute("stroke-width",0.3);
                point.setAttribute("opacity",0.65+more_darker);
                point.setAttribute("stroke-opacity",0.8);
	        if(style.svgstyleclass){point.setAttribute("class",style.svgstyleclass);}

                // trigger any point callback
	        if(options.point_cb){
                    options.point_cb(point,value);
                }

	        // trigger any show handler
	        if(options.cluster_cb){
                    options.cluster_cb(value);
                }
            });
        };

    };



})();  // declare and call to create a closure


