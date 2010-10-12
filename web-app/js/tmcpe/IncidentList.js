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

dojo.require("tmcpe.TestbedMap");
dojo.require("tmcpe.ItemVectorLayerReadStore");

//dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.IncidentList", [ dijit._Widget ], {/* */
    
    _map: null,
    _incidentsLayer: null,
    _selectIncident: null,
    _hoverIncident: null,
    
    _vdsLayer: null,
    _selectVds: null,
    _hoverVds: null,
    
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
	var geo = dijit.byId( 'geographic' );
	if ( geo && geo.checked ) {
	    theParams[ 'bbox' ] = [this.getMap().getExtent().toBBOX()];
	    theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/
	}

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
	if ( dijit.byId( 'fwydir' ).getValue() && dijit.byId( 'fwydir' ).getValue() != '<Show All>' ) {
	    var store = facilityStore;//dijit.byId( 'facilityStore' );
	    var val = dijit.byId( 'fwydir' ).item;
	    var vv = facilityStore.getValue( val, "facdir" );
	    var vals = vv.split("-");
	    theParams['freeway'] = vals[0];//myFormatDateOnly( value );
	    theParams['direction'] = vals[1];//myFormatDateOnly( value );
	};
	if ( dijit.byId( 'eventType' ).getValue() && dijit.byId( 'eventType' ).getValue() != '<Show All>' ) {
	    var store = eventTypeStore;//dijit.byId( 'eventTypeStore' );
	    var val = dijit.byId( 'eventType' ).item;
	    var vv = eventTypeStore.getValue( val, "evtype" );
	    theParams['eventType'] = vv;
	}	
	if ( dijit.byId( 'queryForm' ).attr('value').Analyzed ) {
	    var value = dijit.byId( 'queryForm' ).attr('value').Analyzed
	    theParams['Analyzed'] = value;
	}
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

    // called to indicate that the layer update is complete...
    _demoCallback: function() {
	console.log( "GOT DEMO CALLBACK!" );
	//	this._loadEnd(); 
    },

    _incidentsLayerInit: function() {
	// should validate

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


	    this._progressBar = new dijit.ProgressBar( { id:"downloadProgress", 
							 jsId:"jsProgress", 
							 style: "width:250px",
							 indeterminate: false
						       } );
	    this._progressDialog.attr( 'content', this._progressBar ); 
	}

	var obj = this;

	// Create the incidents layer.  The URL is hardcoded here...
	var base = document.getElementById("htmldom").href;
	
	this._incidentsLayer = new OpenLayers.Layer.Vector("Incidents", {
            projection: this.getMap().displayProjection,
	    //            strategies: [new OpenLayers.Strategy.Fixed()],
	    strategies: [new OpenLayers.Strategy.BBOX({resFactor: 1.1}),new OpenLayers.Strategy.Cluster()],
            protocol: new OpenLayers.Protocol.HTTP({
            	url: base + "incident/list.geojson",//theurl,
            	params: this._constructIncidentsParams(),
            	style: {strokeWidth: 2, strokeColor: "#0000ff", strokeOpacity: 0.25 },
            	format: new OpenLayers.Format.GeoJSON({})
            }),
            reportError: true
	});

	var obj = this;
	this._incidentsLayer.events.on({
            "featureselected": obj.onFeatureSelectIncident,
            "featureunselected": obj.onFeatureUnselectIncident,

	    "loadstart": function() {
		// notify IncidentList "app" that we're starting to load
		obj._loadStart();
		obj._progressBar.update( { 'maximum': 100, 'progress': 0 } );
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
	    },
	    "featureadded": function( feat ) { 
	    },
	    "featuresadded": function() { 
		console.log( "features added" );
		obj.updateIncidentsTable(); 
	    },
	    "featuresremoved": function() { 
		console.log( "features removed" );
		obj.updateIncidentsTable();
	    },
	    "moveend": function() { 
		var geo = dijit.byId( 'geographic' );
		if ( geo && geo.checked ) {
		    // Only update the query if we're doing geographic queries
		    console.log( "updating because of movement" );
		    obj.updateIncidentsQuery(); 
		}
	    }
	});

	//    map.events.register("moveend", null, function() { alert("updating query"); updateIncidentsQuery(); } )
	this.getMap().addLayers([this._incidentsLayer]);

	var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	    fillColor: "yellow",
	    strokeColor: "yellow"
	}, OpenLayers.Feature.Vector.style["select"]);


	// for event closure
	var obj = this;

	this._hoverIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer,{ 
 	    hover: true,
 	    highlightOnly: true,
            renderIntent: "temporary",
	    selectStyle: hoverSelectStyle,
	    eventListeners: {
		//    beforefeaturehighlighted: report,
	        featurehighlighted: function( evt ) {
		    var feature = evt.feature
		    if ( feature && feature.cluster ) {
			var xy = obj.getMap().getControl('ll_mouse').lastXy || new OpenLayers.Pixel(0,0);
			var loc = feature.cluster[0].attributes.locString;
			var txt = loc + ': <span style="font-weight:bold;">' + feature.cluster.length + " event" + ( feature.cluster.length == 1 ? "" : "s" ) + "</span>";
			obj._map.showTooltip( txt, xy.x, xy.y );
		    }
		},
		featureunhighlighted: function( feature ) {
//		    alert( "unhighlighted" );
		    obj._map.hideTooltip();
		}
	    }
	});
	this.getMap().addControl(this._hoverIncident);
	this._hoverIncident.activate();
	
	this._selectIncident = new OpenLayers.Control.SelectFeature(this._incidentsLayer);
	this.getMap().addControl(this._selectIncident);
	this._selectIncident.activate();

	this.updateIncidentsQuery();
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

	var obj = this;

	var base = document.getElementById("htmldom").href;

	this._vdsLayer = new OpenLayers.Layer.Vector("Vds Segments", {
	    projection: this.getMap().displayProjection,
	    strategies: [new OpenLayers.Strategy.Fixed()],
	    style: {strokeWidth: 8, strokeColor: "#00ff00", strokeOpacity: 0.25 },
	    protocol: new OpenLayers.Protocol.HTTP({
  		url: base + "vds/list.geojson",
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
	    //	    fillColor: "blue",
	    //	    strokeColor: "blue"
	}, OpenLayers.Feature.Vector.style["select"]);

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
		    console.log( totDelay + ' += ' + item.attributes.d12_delay );
		}
		if ( item.attributes.tmcpe_delay ) {
		    totDelay += item.attributes.tmcpe_delay;
		    console.log( totDelay + ' += ' + item.attributes.tmcpe_delay );
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
	    for ( var i = 0; i < feature.cluster.length; ++i )
	    {
		var f = feature.cluster[ i ];
		var id = f.attributes.id;
		var cad = f.attributes.cad;
		
		var buttonId = 'showIncidentButton-'+f.attributes.id;
		var button;
		var ii = f.attributes.memo.indexOf(":DOSEP:");
		var memo = f.attributes.memo.substring(ii);
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
	    
	    if ( feature.cluster.length == 0 ) {
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

	this._progressBar.update( { progress: 0 } );

	if ( !this._progressDialog.open ) {
	    this._progressDialog.show();
	}
    },

    _loadEnd: function() {
	this._jobs--;
	//	this._progressDialog.attr( "content", "finished" ); 
	console.log( "LOAD END: " + this._jobs );
	if ( this._jobs <= 0 && this._progressDialog != null ) { this._progressDialog.hide(); }
    },

    _loadCancel: function() {
	// repeatedly end until the number of open jobs is 0
	while ( obj._jobs > 0 ) { obj._loadEnd(); };
    },

    updateVdsSegmentsQuery: function( theParams ) {
	if ( this._selectVds )
	    this._selectVds.unselectAll();
	var myParams = this._constructVdsSegmentsParams( theParams );

	this._updateVdsSegmentsLayer( myParams );
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

    _updateVdsSegmentsLayer: function( theParams ) {
	if ( this._vdsLayer.protocol.url == "" ) {
	    // update the url
	    var base = document.getElementById("htmldom").href;

	    this._vdsLayer.protocol = 
		new OpenLayers.Protocol.HTTP({
  		    url: base + "vds/list.geojson",
		    params: theParams,
		    format: new OpenLayers.Format.GeoJSON({})
		});
	}
	this._vdsLayer.refresh({force: true, params:theParams});    
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