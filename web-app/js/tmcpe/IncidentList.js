// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.IncidentList");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dijit.Dialog");
dojo.require("dijit.ProgressBar");
dojo.require("dijit.layout.StackContainer");
dojo.require("dijit.layout.ContentPane");
dojo.require("dojox.json.ref");
dojo.require("dojo.cookie");

dojo.require("tmcpe.TestbedMap");
dojo.require("tmcpe.ItemVectorLayerReadStore");

const queryCookie = 'TmcpeQueryParams';   // The query cookie name
const maxIncidents = 2500;                // The absolute max number of incidents to query

/**
 * The application logic for the TMCPE Incident List
 */
dojo.declare("tmcpe.IncidentList", [ dijit._Widget ], {
    
    ////// parameters //////
    _showProgress: null,    // show progress bar if true

    // widgets 
    _map: null,             // the TestbedMap widget

    // Openlayers
    _incidentsLayer: null,  // The layer of incident markers
    _selectIncident: null,  // The select controller for incident markers
    _hoverIncident: null,   // The hover controller for incident markers 

    _incidentGrid: null,
    _incidentStackContainer: null,
    _previousIncident: null,
    _nextIncident: null,

    _incidentDetails: null,

    _progressCount: null,
    _progressTot: null,
    _progressDialog: null,
    _progressBar: null,

    _incidentDetailButtonTooltip: null,

    _jobs: 0,

    postCreate: function() {
    },

    initApp: function() {
	this._incidentsLayerInit();

	var igrid = this.getIncidentGrid();
	// connect some styling features to the log grid
	dojo.connect( igrid, "onStyleRow", function(row) { 
            //The row object has 4 parameters, and you can set two others to provide your own styling
            //These parameters are :
            // -- index : the row index
            // -- selected: wether the row is selected
            // -- over : wether the mouse is over this row
            // -- odd : wether this row index is odd.

	    row.customClasses += " noHighlight";
	});

	var iGrid = this.getIncidentGrid();
	var obj = this; // for closure
	dojo.connect( iGrid, "onCellFocus", function( inCell, inRowIndex ) { 
            var item = iGrid.getItem(inRowIndex);
	    iGrid.selection.clear();
	    if ( item ) {
		iGrid.selection.setSelected( inRowIndex, true );
	    }
	    obj.simpleSelectIncident( { cell: inCell, grid: iGrid, rowIndex: inRowIndex } );
	});

    },

    /**
     * Accessor for the openlayers map object 
     * 
     * @returns OpenLayers map object contained in the TestbedMap
     */
    getMap: function() {
	if ( !this._map ) {
	    this._map = dijit.byId( 'map' );
	}

	// We return the openlayers map object contained in the TestbedMap
	return this._map._map;
    },

    /**
     * Accessor for the incident grid 
     *
     * @returns The incident grid dijit
     */
    getIncidentGrid: function() {
	if ( !this._incidentGrid ) {
	    this._incidentGrid = dijit.byId( 'incidentGrid' );
	}
	return this._incidentGrid;
    },

    /**
     * Accessor for the incident details 
     *
     * @returns The incident details DOM Node
     */
    getIncidentDetails: function() {
	if ( !this._incidentDetails ) {
	    this._incidentDetails = dojo.byId( 'incidentDetails' );
	}
	return this._incidentDetails;
    },

    /**
     * Store query params in the query cookie
     *
     * @arg theParams A hash of query parameters to store along with the form
     *                data
     */
    _storeIncidentsParams: function( theParams ) {
	if ( !theParams || theParams == undefined ) {
	    theParams = {};
	}

	// Loop over all the form inputs
	var inputs = dojo.query( '#queryForm input' );
	for ( var i = 0; i < inputs.length; ++i ) {
	    var input = inputs[ i ];
	    if (  input.id != null && input.id != "" ) {
		var djt = dijit.byId( input.id );
		theParams[ input.id ] = { 
		    value: djt.get( 'value' ), 
		    checked: djt.get( 'checked' ) 
		};
	    }
	}
	theParams[ 'extents' ] = this.getMap().getExtent().toArray();
	dojo.cookie( queryCookie, JSON.stringify( theParams ) );
    },

    /**
     * Get query params from the query cookie
     *
     * @returns A hash of query parameters
     */
    _restoreIncidentsParams: function () {
	var cookstr = dojo.cookie( queryCookie );
	if ( cookstr ) {
	    theParams = JSON.parse( cookstr );
	} else {
	    theParams = new Array();
	}

	return theParams;
    },

    /**
     * Create a set of query parameters from the form data
     *
     * @arg theParams An initial set of parameters to override
     *
     * @returns       A final set of query parameters
     */
    _constructIncidentsParams: function( theParams ) {
	if ( !theParams || theParams == undefined ) {
	    theParams = {};
	}
	var geo = dijit.byId( 'geographic' );
	if ( geo && geo.checked ) {
	    theParams[ 'bbox' ] = [this.getMap().getExtent().toBBOX()];
	    theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/
	}

	// get params from the search form...
	if ( dijit.byId( 'startDate' ).get( 'value' ) ) {
	    var value = dijit.byId( 'startDate' ).get( 'value' );
	    theParams[ 'startDate' ] = dijit.byId( 'startDate' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'endDate' ).get( 'value' ) ) {
	    var value = dijit.byId( 'endDate' ).get( 'value' );
	    theParams['endDate'] = dijit.byId( 'endDate' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'earliestTime' ).get( 'value' ) ) {
	    var value = dijit.byId( 'earliestTime' ).get( 'value' );
	    theParams['earliestTime'] = dijit.byId( 'earliestTime' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'latestTime' ).get( 'value' ) ) {
	    var value = dijit.byId( 'latestTime' ).get( 'value' );
	    theParams['latestTime'] = dijit.byId( 'latestTime' ).serialize( value );//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'fwydir' ).get( 'value' ) && dijit.byId( 'fwydir' ).get( 'value' ) != '<Show All>' ) {
	    var store = facilityStore;//dijit.byId( 'facilityStore' );
	    var val = dijit.byId( 'fwydir' ).item;
	    var vv = facilityStore.getValue( val, "facdir" );
	    var vals = vv.split("-");
	    theParams['freeway'] = vals[0];//myFormatDateOnly( value );
	    theParams['direction'] = vals[1];//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'eventType' ).get( 'value' ) && dijit.byId( 'eventType' ).get( 'value' ) != '<Show All>' ) {
	    var store = eventTypeStore;//dijit.byId( 'eventTypeStore' );
	    var val = dijit.byId( 'eventType' ).item;
	    var vv = eventTypeStore.getValue( val, "evtype" );
	    theParams['eventType'] = vv;
	}	
	if ( dijit.byId( 'queryForm' ).get('value').Analyzed ) {
	    var value = dijit.byId( 'queryForm' ).get('value').Analyzed
	    theParams['Analyzed'] = value;
	}
	var days = [ "mon", "tue", "wed", "thu", "fri", "sat", "sun" ];
	for ( dow in days ) {
	    var dowWid = dijit.byId( days[dow] );
	    if ( dowWid && dowWid.checked ) {
		//	    alert( "DOW " + days[dow] + " CHECKED" );
		if ( theParams['dow'] == undefined ) {
		    theParams['dow'] = dowWid.get('value');
		} else {
		    theParams['dow'] += "," + dowWid.get('value');
		}
	    }	
	}

	if ( theParams['max'] == undefined ) 
	{
	    theParams['max'] = maxIncidents;
	}

	// Push these query parameters to the cookie so they're persistent
	this._storeIncidentsParams( );

	return theParams;

    },

    /**
     * Push the given parameters out to the query form
     *
     * @arg theParams  The parameters to update the form with
     */
    _updateQueryFormFromParams: function( theParams ) {
	// Loop over all the inputs in the query form
	var inputs = dojo.query( '#queryForm input' );
	for ( var i = 0; i < inputs.length; ++i ) {
	    var input = inputs[ i ];
	    if (  input.id != null && input.id != "" ) {

		// Get the corresponding value for the input from the parameters
		var tp = theParams[ input.id ];;
		if ( tp != null && tp.value != null && tp.value != "" ) {
		    // It is a dijit with a value, update it
		    var djt = dijit.byId( input.id );  // get the dijit

		    if ( djt instanceof tmcpe.MyDateTextBox ) {
			// The date box requires a type conversion
			djt.attr( 'value', new Date( tp.value ) );

		    } else {
			djt.attr( 'value', tp.value );
		    }
		}
		if ( tp != null && tp.checked != null ) {
		    // It is a checkbox; set the checked value
		    var djt = dijit.byId( input.id );
		    djt.attr( 'checked', tp.checked );
		}
	    }
	}

	// Finally, update the map bounds
	if ( theParams[ 'extents' ] != null )
	    this.getMap().zoomToExtent( new OpenLayers.Bounds.fromArray( theParams[ 'extents' ] ) );

	return;
    },

    /**
     * Convenience function to restore the query view to the one last stored
     */
    setLastQuery: function() {
	this._updateQueryFormFromParams( this._restoreIncidentsParams() );
    },

    /**
     * Computes a color between green and red based upon the given value and
     * limits
     *
     * @arg val    The value to determine the color for
     * @arg min    The low end of the value range
     * @arg max    The high end of the value range
     * @arg minval The color to use if val < min
     * @arg maxval The color to use if val > max
     *
     * @returns    An rgba color string
     */
    _getColor: function( /*float*/ val, /*float*/ min, /*float*/ max, /*float*/ minval, /*float*/ maxval ) {
	// summary:
	//		Computes a color between green and red based upon the given value and limits
	// description:
	//		If val >= max, the color is green.  If val <=
	//		min, the color is red.  If it's in between,
	//		the color is trends from green->yellow->orange->red
	var frac = (val-min)/(max-min);
	if ( frac < 0 )      return minval;
	else if ( frac > 1 ) return maxval;
	var r = 1;
	var g = 1;
	var b = 0;
	if ( frac <= 0.5 ) {
	    r = frac/0.5;
	    g = 1;
	} else {
	    r = 1;
	    g = ( 1 - (frac-0.5)/0.5 );
	}
	var ret = "rgba("+[Math.round(r*255),Math.round(g*255),Math.round(b*255),1.0].join(",")+")"
	return ret;
    },

    /**
     * Initializes the incidents layer
     */
    _incidentsLayerInit: function() {

	// Set query parameters from cookie
	this.setLastQuery();

	if ( !this._progressDialog && this._showProgress ) {
	    // Show the progress
	    this._progressDialog = new dijit.Dialog({//dojox.widget.Dialog({
		//		title: "Loading",
		id: "progressDialog",
		showTitle: false,
		style: "width: 300px",
		modal: true
            });

	    // this hides the title bar of the dialog...
	    dojo.query( '#progressDialog > .dijitDialogTitleBar' ).style( { "display": "none" } ) ;


	    this._progressBar = new dijit.ProgressBar( { id:"downloadProgress", 
							 jsId:"jsProgress", 
							 style: "width:250px",
							 indeterminate: false
						       } );
	    this._progressDialog.set( 'content', this._progressBar ); 
	}

	// A local copy of 'this' for use in closures
	var obj = this;

	// The basic styling for incidents.
	var style = new OpenLayers.Style({
            pointRadius: "${getPointRadius}",
            fillColor: "${getFillColor}",
            fillOpacity: 0.5,
            strokeColor: "blue",
            strokeWidth: 2,
            strokeOpacity: 0.8,
	    graphicZIndex:1,
        }, {
            context: {
		// Return a radius based upon the number of features in the
		// cluster The minimum size is 5px, the maximum is 15, which is
		// the size when there are 5 or more features in a cluster
                getPointRadius: function(feature) {
		    var len = feature.cluster ? feature.cluster.length : 1;
		    return Math.min(len*2,10) + 5;
                },

		// Set the fill color based upon the average delay of incidents
		// in the feature cluster
		getFillColor: function(feature) {
		    var features;
		    if ( feature.cluster )
			features = feature.cluster;
		    else
			features = [ feature ];
		    var sum = 0;
		    var cnt = 0;
		    for ( var i = 0; i < features.length; i++) {
			var feat = features[ i ];
			var del = feat.attributes.tmcpe_delay;
			if ( del != undefined ) {
			    cnt++;
			    sum += del;
			}
		    }
		    if ( cnt == 0 ) {
			return "gray";
		    } else {
			// return a color between green and red as the delay
			// increases from 50 veh-hr to 800 veh-hr
			return obj._getColor( sum / cnt, 50, 800, "green", "red" );
		    }
		}
	    }
        });

	// The hover style: when you hover over an incident its stroke turns
	// magenta and the whole circle raises up
	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	    strokeColor: "rgba(255,0,208,1)",
	    strokeOpacity: 0.9,
	    fillOpacity: 0.65,
	    graphicZIndex: 5,
	}, style);

	// The select style: when you select an incident its stroke is a thick
	// magenta, it is more pronounced by being 5px bigger (in minRadius) and
	// bolder.  It is also raised even higher
	var selectStyle = OpenLayers.Util.applyDefaults({
	    strokeWidth: 6,
	    strokeOpacity: 0.9,
	    fillOpacity: 0.85,
	    graphicZIndex: 10
	}, hoverSelectStyle);

	// This should make the selected circle bigger too, but it doesn't --
	// FIXME
	selectStyle.context.getPointRadius = function(feature) {
	    var len = feature.cluster ? feature.cluster.length : 1;
	    return Math.min(len*2,10) + 10;
        };


	// OK, now create the incidents layer
	var base = document.getElementById("htmldom").href;
	this._incidentsLayer = new OpenLayers.Layer.Vector("Incidents", {
            projection: obj.getMap().displayProjection,
	    strategies: [new OpenLayers.Strategy.BBOX({resFactor: 1.1}),new OpenLayers.Strategy.Cluster()],
            protocol: new OpenLayers.Protocol.HTTP({
            	url: base + "incident/list.geojson",
            	params: obj._constructIncidentsParams(),
            	format: new OpenLayers.Format.GeoJSON({})
            }),
            styleMap: new OpenLayers.StyleMap({
		"default": style,
		"select": selectStyle,
		"temporary": hoverSelectStyle
	    }),
	    rendererOptions: {zIndexing: true},
            reportError: true
	});


	// Now, attach some event handlers to the incident layer & its features
	var loaded;  // closure vars
	var toadd;
	this._incidentsLayer.events.on({
            "featureselected": obj.onFeatureSelectIncident,
            "featureunselected": obj.onFeatureUnselectIncident,

	    "loadstart": function() {
		// notify IncidentList "app" that we're starting to load
		obj._loadStart();
		if ( obj._showProgress && obj._progressBar ) {
		    loaded = 0;
		    obj._progressBar.update( { 'maximum': 100, 'progress': loaded } );
		}
	    },
	    "loadend": function() {
		// notify IncidentList "app" that we've finished loading
		obj._loadEnd();
	    },

	    "loadcancel": function() {
		// force IncidentList "app" to recognize that we've finished loading
		obj._loadCancel();
	    },

	    "beforefeaturesadded": function (feat) { 
		console.log( "before features added" );
		console.log( "ADDING " + feat.features.length + " FEATURES" );
		toadd = feat.features.length;

		if ( obj._showProgress && obj._progressBar ) 
		    obj._progressBar.update( { 'maximum': toadd, 'progress': 0 } );
	    },

	    "featureadded": function( feat ) { 
		console.log( "feature added" );
		loaded++;

		if ( obj._showProgress && obj._progressBar ) {
		    // Update every 10%
		    if ( ( Math.floor( 100 * ( loaded / toadd ) ) % 20 ) == 0 ) {
			obj._progressBar.update( { progress: loaded } );
		    }
		}
	    },

	    "featuresadded": function( feat ) { 
		console.log( feat.features.length + " features added" );
	    },

	    "featuresremoved": function( feat ) { 
		console.log( feat.features.length + " features removed" );
	    },

	    "move": function() {
		obj._map.hideTooltip();    // Hide any tooltips that linger
	    },

	    "zoomend": function() {
		obj._map.hideTooltip();    // Hide any tooltips that linger
	    },

	    "moveend": function() { 
		/*
		  var geo = dijit.byId( 'geographic' );
		  if ( geo && geo.checked ) {
		  // Only update the query if we're doing geographic queries
		  console.log( "updating because of movement" );
		  obj.updateIncidentsQuery(); 
		  }
		*/
		obj._storeIncidentsParams( );  // the viewport will have changed
		obj.updateIncidentsTable();
	    },
	});

	this.getMap().addLayers([this._incidentsLayer]);

	this._hoverIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer,{ 
 	    hover: true,
	    highlightOnly: true,
	    renderIntent: "temporary"	});
	this.getMap().addControl(this._hoverIncident);
	this._hoverIncident.activate();
	

	var obj = this;
	this._selectIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer, {
	    renderIntent: "select",
	    eventListeners: {
		"featurehighlighted": function( evt ) {
		    var feature = evt.feature
		    if ( feature && feature.cluster ) {
			obj._showTooltipForFeature( feature );
		    }
		    obj.scrollIncidentsToItem( feature );
		},
		"featureunhighlighted": function( feature ) {
		    // hide tooltip when we unhighlight
		    obj._map.hideTooltip();
		}
	    }

	});
	this.getMap().addControl(this._selectIncident);
	this._selectIncident.activate();

	this.updateIncidentsQuery();
    },

    _showTooltipForFeature: function( feature ) {
	// create tooltip when we hover
	var pp = new OpenLayers.LonLat( feature.geometry.x, feature.geometry.y );
	var xy = this.getMap().getPixelFromLonLat( pp );

	// if the cluster feature has a 'last' property, use that value for the tooltip text
	
	var tmpCluster = feature.cluster.slice(0).sort( 
	    function( a, b ) {
		var a1 = a.attributes.tmcpe_delay ? a.attributes.tmcpe_delay : 0;
		var b1 = b.attributes.tmcpe_delay ? b.attributes.tmcpe_delay : 0;
		return b1 - a1;
	    }
	);

	var loc = "<unknown location>";
	var cad = "<unknown cad>";
	var i, targ = null;
	if ( feature.last != null ) {

	    for ( i = 0; i < tmpCluster.length && targ==null; ++i ) {
		var feat = tmpCluster[ i ];
		if ( feat == feature.last ) {
		    targ = feat;
		}
	    }
	    loc = targ.attributes.locString;
	    cad = targ.attributes.cad;
	} else {
	    loc = tmpCluster[0].attributes.locString;
	    cad = tmpCluster[0].attributes.cad;
	    i = 1;
	}
	var txt = cad + ": " + loc + ': <span style="font-weight:bold;">' + 
	    i + " of " + feature.cluster.length;
	this._map.showTooltip( txt, xy.x, xy.y );
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
	    gn.scrollToRow( idx );
	    gn.selection.addToSelection( idx );
	    //				     alert( "item " + cad + "found @ idx:" + idx );	
	} else {
	    alert( "Strangely, item " + cad + " wasn't found in the grid!" );
	}
	
	//    alert( "Selected " + cad )
    },


    updateIncidentsTable: function( theParams ) {
	console.log( "UPDATING INCIDENTS TABLE" );
	// Point the store to the incidents layer
	var store = new tmcpe.ItemVectorLayerReadStore( {vectorLayer: this._incidentsLayer} );
	this.getIncidentGrid().setStore( store );

	// we only want features that are on screen
	var geo = dijit.byId( 'geographic' );
	if ( geo ) this.getIncidentGrid().setQuery( { onScreen: 'true' } );

	var updateIncidentsSummary = function( items, request ) {
	    // Update the summary statistics:
	    console.debug( "Updating the incidents Summary" );
	    var totAnalyzed = 0;
	    var tot = 0;
	    var d12Delay = 0;
	    var totDelay = 0;
	    var totSavings = 0;
	    
	    for (var i = 0; i<items.length; ++i )
	    {
		tot++;
		var item = items[ i ];
		if ( item.attributes.analysesCount ) {
		    totAnalyzed++;
		}
		if ( item.attributes.d12_delay ) {
		    d12Delay += item.attributes.d12_delay;
		    //console.log( totDelay + ' += ' + item.attributes.d12_delay );
		}
		if ( item.attributes.tmcpe_delay ) {
		    totDelay += item.attributes.tmcpe_delay;
		    //console.log( totDelay + ' += ' + item.attributes.tmcpe_delay );
		}
		if ( item.attributes.savings ) {
		    totDelay += item.attributes.savings;
		}

	    }

	    var newStore = new dojo.data.ItemFileReadStore({
		data: { items: [
		    {cad: '',
		     timestamp: '',
		     locString: '',
		     memo:'Totals for Analyzed:',
		     d12_delay: d12Delay,
		     tmcpe_delay: totDelay,
		     savings: totSavings,
		     analysesCount: '',
		     dummy: ''}
		]}});
	    incidentSummaryGrid.setStore(newStore);
	}
	
	store.fetch( {onComplete: updateIncidentsSummary} );
    },



    updateIncidentCluster: function() {
	var scw = this._incidentStackContainer.selectedChildWidget;

	if ( scw.incident != null ) {
	    // select the new feature and update the tooltip
	    var feat = this._getFeatureForIncident( scw.incident );
	    feat.last = scw.incident;
	    this._showTooltipForFeature( feat );
	    this.scrollIncidentsToItem( scw.incident );
	}

	var scwi = this._incidentStackContainer.getIndexOfChild( scw ) + 1;

	var tot = this._incidentStackContainer.getChildren().length;
	
	if ( tot > 1 ){
	    // More than 1! update (and show) cluster controls
	    dojo.byId('incidentDetailsController').style.visibility = 'visible';

	    dojo.byId( 'incidentIndex' ).innerHTML = scwi + " of " + tot;
	    // set status of "previous" button
	    if ( scwi == 1 ) {
		dojo.byId( 'previousIncident' ).disabled = true;
	    } else {
		dojo.byId( 'previousIncident' ).disabled = false;
	    }
	    
	    // set status of "next" button
	    if ( scwi == tot ) {
		dojo.byId( 'nextIncident' ).disabled = true;
	    } else {
		dojo.byId( 'nextIncident' ).disabled = false;
	    }
	} else {
	    // only 1! hide cluster controls
	    dojo.byId('incidentDetailsController').style.visibility = 'hidden';
	}
    },

    updateIncidentDetails: function( feature ) {
	var base = document.getElementById("htmldom").href;

	if ( !this._incidentStackContainer ) {
	    // create the stack container!
	    dojo.byId( 'incidentDetails' ).innerHTML="";
	    dojo.byId( 'incidentDetails' ).marginTop = 0;
	    this._incidentStackContainer = new dijit.layout.StackContainer({
		id: "incidentStackContainer"
	    }, "incidentDetails" );
	    this._incidentStackContainer.startup();
	} else {
	    // Delete existing panes.
	    var cc = this._incidentStackContainer.getChildren();
	    for ( var i = 0; i < cc.length; ++i ) {
		var c = cc[i];
		this._incidentStackContainer.removeChild( c );
		c.destroy();
	    }
	}

	if ( feature.cluster ) {
	    var buttons = new Array();

	    // clone the cluster features and sort them on the basis of delay (desc)
	    var tmpCluster = feature.cluster.slice(0).sort( 
		function( a, b ) {
		    var a1 = a.attributes.tmcpe_delay ? a.attributes.tmcpe_delay : 0;
		    var b1 = b.attributes.tmcpe_delay ? b.attributes.tmcpe_delay : 0;
		    return b1 - a1;
		}
	    );
	    var selectedPane = null;
	    for ( var i = 0; i < tmpCluster.length; ++i ) 
	    {
//		var f = feature.cluster[ i ];
		var f = tmpCluster[ i ]
		var id = f.attributes.id;
		var cad = f.attributes.cad;
		
		var buttonId = 'showIncidentButton-'+f.attributes.id;
		var button;

		// Grab the portion of the memo up to the first :DOSEP:
		var ii = f.attributes.memo.indexOf(":DOSEP:");
		var memo = f.attributes.memo.substring(ii);

		// Create and add the content pane for this incident
		var cp = new dijit.layout.ContentPane(
		    { title: "INCIDENT " + cad,
		      content: '<table class="incidentSummary">' 
		      + "<tr><th>CAD</th><td>" + f.attributes.cad + "</td></tr>"
		      + '<tr><th style="width:8em;">Start Time</th><td>' + f.attributes.timestamp + "</td></tr>"
		      + "<tr><th>Location</th><td>" + f.attributes.locString + "</td></tr>"
		      + "<tr><th>Memo</th><td>" + memo + "</td></tr>"
		      + "<tr><th>D<sub>35</sub></th><td>" + f.attributes.d12_delay + " veh-hr</td></tr>"
		      + "<tr><th>D<sub>tmcpe</sub></th><td>" + f.attributes.tmcpe_delay + " veh-hr</td></tr>"
		      + "<tr><th>Savings</th><td>" + f.attributes.savings + " veh-hr</td></tr>"
		      + '<tr><td colspan=2 style="text-align:center;"><button id="'+buttonId+'"></button></td></tr>'
		      + "</table>"
		      //+ '<p><A href="'+base+'incident/showCustom?id='+id+'">Show Incident</a></p>'
		    });
		// store a reference to the feature so we can use it to update the map
		cp.incident = f;
		this._incidentStackContainer.addChild(cp);
		if ( f == feature.last ) {
		    // caller wants this to be highlighted (active)
		    selectedPane = cp;
		}

		// Create "show details button"
		var base = document.getElementById("htmldom").href;

		var button;
		if ( button = dijit.byId( buttonId ) ) {
		    button.destroyRecursive();
		}

		button =new dijit.form.Button({
		    ifaId: id,
		    label: "Show Incident Detail",
		    onClick: function() { 
			window.open( base+'incident/showCustom?id='+this.ifaId ); 
		    }
		},buttonId);


		// append button list for tooltips
		buttons[i] = buttonId;
	    }
	    // Add the tooltip for the buttons
	    if ( this._incidentDetailButtonTooltip ) {
		this._incidentDetailButtonTooltip.destroy();
	    }
	    this._incidentDetailButtonTooltip = new dijit.Tooltip({
		connectId: buttons,
		label: "The incident detail will open in a new window"
	    });
	    

	    if ( selectedPane != null ) {
		// Select the appropriate pane to show
		this._incidentStackContainer.selectChild( selectedPane );
	    }

	    if ( feature.cluster.length <= 1 ) {
		dojo.byId( 'previousIncident' ).disable = true;
		dojo.byId( 'nextIncident' ).disable = true;
		dojo.byId( 'incidentIndex' ).innerHTML = "0 of 0";
		this.updateIncidentCluster();
	    } else {
		this.updateIncidentCluster();
	    }

	} else {

	    var f = feature;
	    var id = f.attributes.id;
	    var cad = f.attributes.cad;

	    var il = dijit.byId( 'incidentList' );
	    il.scrollIncidentsToItem( feature );

	    var buttonId = 'showIncidentButton-'+f.attributes.id;
	    var button;
	    var ii = f.attributes.memo.indexOf(":DOSEP:");
	    var memo = f.attributes.memo.substring(ii);
	    var cp = new dijit.layout.ContentPane(
		{ title: "INCIDENT " + cad,
		  content: '<table class="incidentSummary">' 
		  + "<tr><th>CAD</th><td>" + f.attributes.cad + "</td></tr>"
		  + '<tr><th style="width:8em;">Start Time</th><td>' + myFormatDate( f.attributes.timestamp ) + "</td></tr>"
		  + "<tr><th>Location</th><td>" + f.attributes.locString + "</td></tr>"
		  + "<tr><th>Memo</th><td>" + memo + "</td></tr>"
		  + "<tr><th>D<sub>35</sub></th><td>" + myFormatNumber( f.attributes.d12_delay ) + " veh-hr</td></tr>"
		  + "<tr><th>D<sub>tmcpe</sub></th><td>" + myFormatNumber( f.attributes.tmcpe_delay ) + " veh-hr</td></tr>"
		  + '<tr><td colspan=2 style="text-align:center;"><button id="'+buttonId+'"></button></td></tr>'
		  + "</table>"
		  //+ '<p><A href="'+base+'incident/showCustom?id='+id+'">Show Incident</a></p>'
		});
	    this._incidentStackContainer.addChild(cp);
	    
	    // Create "show details button"
	    var base = document.getElementById("htmldom").href;
	    
	    var button;
	    if ( button = dijit.byId( buttonId ) ) {
		button.destroyRecursive();
	    }
	    
	    button =new dijit.form.Button({
		label: "Show Incident Detail",
		onClick: function() { window.open(base+'incident/showCustom?id='+id); }
	    },buttonId);


	    // Add the tooltip for the buttons
	    if ( this._incidentDetailButtonTooltip ) {
		this._incidentDetailButtonTooltip.destroy();
	    }
	    this._incidentDetailButtonTooltip = new dijit.Tooltip({
		connectId: buttonId,
		label: "The incident detail will open in a new window"
	    });
	    this.updateIncidentCluster();
	}
    },


    // EVENT HANDLERS: FIXME: This technically aren't members of this class; js quirks...
    onFeatureSelectIncident: function(event) {
	var il = dijit.byId( 'incidentList' );
	var feature = event.feature;

	il.updateIncidentDetails( feature );
	il._showTooltipForFeature( feature );
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

    
    // This is necessary when using the Cluster strategy because the incident
    // feature
    _getFeatureForIncident: function( incident ) {
	var layer = this._incidentsLayer;

	if ( layer.features ) {
	    for ( var i = 0; i < layer.features.length; ++i ) {
		var ff = layer.features[ i ];
		if ( ff.cluster && ff.cluster.length > 0 ) { 
		    for ( var j = 0; j < ff.cluster.length; ++ j ) {
			var fff = ff.cluster[ j ];
			if ( fff == incident ) return ff;
		    }
		} else {
		    if ( incident == ff ) return ff;
		}
	    }
	}
	return null;
		
    },

	    
    simpleSelectIncident: function( event ) {
	var il = dijit.byId( 'incidentList' );
	var incident = event.grid.getItem( event.rowIndex );

	// Find the feature cluster this belongs to and activate that one
	var incidentFeature = this._getFeatureForIncident( incident );

	if ( incidentFeature == null ) return;

	incidentFeature.last = incident;
	
	il._selectIncident.unselectAll();
	il._selectIncident.select( incidentFeature );
	il.updateIncidentDetails( incidentFeature );
	il._showTooltipForFeature( incidentFeature );
    },


    updateIncidentsQuery: function( theParams ) {

	// clear any existing selections...
	if ( this._selectIncident )
	    this._selectIncident.unselectAll();
	
	var myParams = this._constructIncidentsParams( theParams );

	this._updateIncidentsLayer( myParams );
	//    updateIncidentsTable( myParams );

    },

    filter: function() {
	console.log("OK, YEAH, IN THE FILTER: " + dijit.byId( 'onlyAnalyzed' ).checked);
	if ( dijit.byId( 'onlyAnalyzed' ).checked ) 
	{
	    this.getIncidentGrid().filter( { analysisCount: "6" } );
	    console.log("CHECKED");
	}
	else
	{
	    this.getIncidentGrid().filter( { } );
	    console.log("UNCHECKED");
	}
    },

    _loadStart: function() {
	this._jobs++;
	console.log( "LOAD START: " + this._jobs );

	if ( this._showProgress && this._progressBar ) {
	    this._progressBar.update( { progress: 0 } );
	    
	    if ( !this._progressDialog.open ) {
		this._progressDialog.show();
	    }
	}
    },

    _loadEnd: function() {
	this._jobs--;
	console.log( "LOAD END: " + this._jobs );

	if ( this._jobs <= 0 ) { 

	    // All reads from the server are done so we can update the table
	    this.updateIncidentsTable();

	    if ( this._showProgress && this._progressDialog ) { 
		this._progressDialog.set( "content", "finished" ); 
		this._progressDialog.hide(); 
	    }
	}
    },

    _loadCancel: function() {
	// repeatedly end until the number of open jobs is 0
	while ( obj._jobs > 0 ) { obj._loadEnd(); };
    },

    _updateIncidentsLayer: function( theParams ) {

	//	if ( this._incidentsLayer.protocol.url == "" ) {

	var base = document.getElementById("htmldom").href;

	// update the url
	this._incidentsLayer.protocol = 
	    new OpenLayers.Protocol.HTTP({
  		url: base + "incident/list.geojson",
		params: theParams,
		format: new OpenLayers.Format.GeoJSON({}),
		callback: function() { console.log( "GOT CALLBACK!" ); }
	    });
	//	}
	this._incidentsLayer.refresh({force: true, params:theParams});
    },


    sleep: function (naptime){
	naptime = naptime * 1000;
	var sleeping = true;
	var now = new Date();
	var alarm;
	var startingMSeconds = now.getTime();
	//alert("starting nap at timestamp: " + startingMSeconds + "\nWill sleep for: " + naptime + " ms");
	while(sleeping){
	    alarm = new Date();
	    alarmMSeconds = alarm.getTime();
	    if(alarmMSeconds - startingMSeconds > naptime){ sleeping = false; }
	}        
	//alert("Wakeup!");
    },
    
    __dummyFunction: function() {}
});