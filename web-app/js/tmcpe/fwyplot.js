// 

dojo.require("dojox.gfx");
dojo.require("dojox.json.ref");
dojo.require("dojox.lang.aspect");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");
 

var aop = dojox.lang.aspect;
var polys = [];


//var theme = "stdspd";
var theme = dojo.byId( "mapTheme" );

// convert a 24-hr time string to decimal hours
var timeInHours = function( timestr )
{
    var hms = timestr.split(":");
    var hr = parseInt(hms[ 0 ]);
    var min = parseInt(hms[ 1 ]);
    var sec = parseInt(hms[ 2 ]);
    return hr + min/60.0 + sec/3600.0;
}

var hoursAsString = function( timeInHours )
{
    var hr  = Math.floor( timeInHours );
    var minF = ( timeInHours - hr ) * 60;
    var min = Math.floor( minF );
    var secF = ( minF - min ) * 60;
    var sec = Math.floor( secF );
    return hr + ":" + ( min < 10 ? "0" : "" ) + min + ":" + ( sec < 10 ? "0" : "" ) + sec;
}

var polyClicked = function( evt ) {
    console.debug( "poly:" + evt.target );
    var i = evt.target.getAttribute( 'i' );
    var j = evt.target.getAttribute( 'j' )
    console.debug( "you clicked poly: " + i + ", " + j );
    console.debug( "   segment: " + data.segments[j].pmstart + "->" + data.segments[j].pmend );
    console.debug( "    incspd: "+ data.incspd[ i ][ j ] );

    var i = evt.target.getAttribute( 'station_idx' );
    var station = stations[ i ];
    showStation( station );
    
/*
    dojo.byId( "statusText" ).style.visibility = 'visible';
    dojo.byId( "statusText" ).textContent = 
	"seg " 
	+ data.segments[j].pmstart + "->" + data.segments[j].pmend 
	+ " @ " + hoursAsString( timeInHours( data.opts.mintimeofday ) + ( 5 * i ) / 60.0 )
	+ ": incspd=" + data.incspd[ i ][ j ];
*/
};


var polyMousedOver = function( evt ) {
//    console.debug( "poly:" + evt.target );
    var i = evt.target.getAttribute( 'i' );
    var j = evt.target.getAttribute( 'j' )

    var i = evt.target.getAttribute( 'station_idx' );
    var station = stations[ i ];
    hoverStation( station );

/*
    dojo.byId( "statusText" ).style.visibility = 'visible';
    dojo.byId( "statusText" ).textContent = 
	"seg " 
	+ data.segments[j].pmstart + "->" + data.segments[j].pmend 
	+ " @ " + hoursAsString( timeInHours( data.opts.mintimeofday ) + ( 5 * i ) / 60.0 )
	+ ": incspd=" + data.incspd[ i ][ j ];
*/
};

var showActivityLogEntry = function( evt ) {
    console.debug( "actlog:" + evt.target );
    var i = evt.target.getAttribute( 'logentry_idx' );
    var logentry = data.actlog[ i ];
/*
    dojo.byId( "statusText" ).style.visibility = 'visible';
    dojo.byId( "statusText" ).textContent = 
	"Log: " 
	+ logentry.stampdate + " " + logentry.stamptime + ": "
	+ logentry.status + ", " + logentry.activitysubject + ", " + logentry.memo;
*/
}

var showStation = function( station ) {
    console.debug( "station:" + station.vdsid );

    // HACK: highlight the corresponding station in the map
    var vsl = getVdsSegmentLines();
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
	// OK, found the feature.  Highlight it?  select it
	selectVds.unselectAll();
	selectVds.select( feature );
    }
}

var hoverStation = function( station ) {
    console.debug( "station:" + station.vdsid );

    // HACK: highlight the corresponding station in the map
    var vsl = getVdsSegmentLines();
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
	// OK, found the feature.  Highlight it?  select it
	getHoverVds().unselectAll();
	getHoverVds().select( feature );
    }
}


showEventTooltip = function( evt ) {
    console.debug( "obj:" + evt.target );
    console.debug( "TOOLTIP: " + evt.target.getAttribute( 'description' ) );
}



// the json object: { opts, segments, data }
var data;
var metadata;
var surface;
var stations;

// This function loads incident analysis data from a json object
var loadObjects = function(r){
    console.debug( "Loading objects" );
//    dojo.byId( "statusText" ).textContent = "Parsing objects...";

    if(!r){
	alert("Wrong JSON object. Did you type the file name correctly?");
	return;
    }

    // read the json data
    data = dojox.json.ref.fromJson( r );;
};

var processStations = function( r ) {
    console.debug( "Processing stations" );
    if(!r){
	alert("Wrong JSON object. Did you type the file name correctly?");
	return;
    }
    // read the json data
    stations = dojox.json.ref.fromJson( r );
};


var processMetadata = function( r ) {
    console.debug( "Processing metadata" );
    if(!r){
	alert("Wrong JSON object. Did you type the file name correctly?");
	return;
    }

    // read the json data
    metadata = dojox.json.ref.fromJson( r );;

    // update the datastores
    incidentStore = new dojo.data.ItemFileWriteStore({data: metadata.incidents });
//    var incidentStore = dojo.byId( 'incidentStore' );
    //incidentStore.setData( metadata.incidents );
    setIncident( metadata.incidents.items[ 0 ].cad );
    dijit.byId( 'incidentCombo' ).store = incidentStore;

    changeFacilityList( 'facilityCombo', metadata.incidents.items[ 0 ].facilities );

    var newValue = incidentStore.fetch(
	{
	    query: {cad: "*"} ,
	    onComplete: function(items, request) {
		dijit.byId('incidentCombo').setValue(items[0].cad);
		dijit.byId('incidentCombo').setDisplayedValue(items[0].cad);
	    }
	});



    //dojo.byId( 'incidentCombo' ).setValue( metadata.incidents.items[ 0 ].cad );
    
//    facilityStore.newItem( metadata.incidents[ 0 ].facilities[ 0 ]
}

var startHr;
var startMin;


var init = function() {
//    dojo.byId('mapTheme').value = theme;
//    setIncident( dojo.byId( 'incidentCombo' ).value ); // this will load the data
//    setFacility( dojo.byId( 'incidentCombo' ).value ); // this will load the data
//    setTheme( 'stdspd' );
    loadMetadata();
}

// Draw all the polygons, etc.
var redraw = function()
{
//    dojo.byId( "statusText" ).textContent = "Drawing plot...";
    resizeSurface();
    getParameters();       // get critical parameters from the file
    makeShapes( );         // draw the polygons
    makePostmileLabels();  // draw the labels
    makeEvents();          // overlay events
    makeActivityLog();     // overlay activity log
    displayActivityLog( dojo.byId( 'activityCheck' ).checked ? 'visible' : 'hidden' ); // hack using the interface
    makeStations();        // overlay stations
    displayStations( dojo.byId( 'stationCheck' ).checked ? 'visible' : 'hidden' ); // hack using the interface

    updateView();          // update the polygon colors

    //dojo.connect( dojo.byId( "title" ), 'onclick', function() { console.debug( "Clicked the title" ); } );
}

var loadMetadata = function() {
//     console.debug( "Loading metadata" );
//     dojo.byId( "statusText" ).textContent = "Loading metadata...";
//     dojo.byId( "progressBar" ).indeterminate = 'true';
//     dojo.byId( "statusText" ).style.visibility= 'visible';
//     dojo.byId( "progressBar" ).style.visibility= 'visible';
//     jsProgress.update( {indeterminate: true} );    
//     var theUrl = "metadata.json";
//     dojo.xhrGet({
// 			url:			theUrl,
// 	preventCache:	true,
// 	handleAs:		"text",
// 	sync: true, //false,
// 	load: function( r ) {
// 	    processMetadata( r );
// 	    dojo.byId( "progressBar" ).style.visibility= 'hidden';
// 	    dojo.byId( "statusText" ).textContent = "";
// 	},
// 	error:			function(r){ alert("Error: " + r); }
//     });
};



var loadData = function( inc ){
    if ( !inc ) {
	console.debug( "Bad incfacdir " + inc );
	return;
    }
    var fwydir = inc.split( '-' );
    var theUrl = "/tmcpe/data/" + incidentData.id + "-" + fwydir[0] + "-" + fwydir[1] + ".json";

//    jsProgress.update( {indeterminate: true} );
    dojo.xhrGet({
//			url:			"83-113007-5=S.json",
	         //       url: "61-110207-5=S.json",
	      //          url: "t4.json",
///	                url: "t4b.json",
			url:			theUrl,
//	url:			"test.json",
	preventCache:	true,
	//		handleAs:		"json",
	handleAs:		"text",
	sync: true, //false,
	load: function( r ) {
	    loadObjects( r );
	},
	error:			function(r){ alert("Error: " + r); }
    });
    dojo.xhrGet({
	url: "/tmcpe/data/stations.json",
	preventCache: true,
	handleAs: "text",
	sync: true,
	load: function( r ) {
	    processStations( r );
	},
	error:			function(r){ alert("Error: " + r); }
    });
};

var syncMetaInterface = function() {
    
}

var syncInterface = function() {
    dojo.byId( 'bandSlider' ).value = data.opts.band;
    dojo.byId( 'scaleValue' ).value = data.opts.band;
/*
    dojo.byId('title').textContent = "TMC Incident Performance Evaluator --- Incident " 
	+ data.opts.incident + ": " + data.opts.mindate + " @ " + data.opts.mintimeofday;
*/

}

var getColor = function( val, min, max, minval, maxval ) {
    // plot rectangle w/appropriate color
    var spdfrac = (val-min)/(max-min);
    if ( spdfrac < 0 )
    {
	return minval;
    }
    else if ( spdfrac > 1 )
    {
	return maxval;
    }
    var r = 1;
    var g = 1;
    var b = 0;
    if ( spdfrac <= 0.5 )
    {
	r = 1;
	g = spdfrac/0.5;
    }
    else
    {
	r = ( 1 - (spdfrac-0.5)/0.5 );
	g = 1;
    }
    var ret = [ parseInt( r*255 ), parseInt( g*255 ), parseInt( b*255 ), 1.0 ];
    return ret;
};

var themeScale = 4;
var scalex = 1;
var scaley = 1;
var boundaryWidth = 3.0;

var updateView = function()
{
    for ( i = 0; i < polys.length; i = i + 1 )
    {
	for ( j = 0; j < polys[ 0 ].length; j = j + 1 )
	{
	    var poly = polys[i][j];
	    if ( theme == 'stdspd' )
	    {
		min = -themeScale;
		max = 0;
		poly.setFill( getColor( (data.incspd[i][j]-data.avgspd[i][j])/data.stdspd[i][j], min, max, [255,0,0,1.0], [0,255,0,1.0] ) );
		
	    }
	    else if ( theme == 'avgspd' )
	    {
		min = -themeScale;
		max = 0;
		poly.setFill( getColor( data.incspd[i][j]-data.avgspd[i][j], min, max, [255,0,0,1.0], [0,255,0,1.0] ) );
		
	    }
	    else if ( theme == "inc" )
	    {
		var color = [0,255,0,1.0];
		if ( data.inc[i][j] == 1 ) color = [255,0,0,1.0];
		poly.setFill( color );
	    }
	    else if ( theme == "pjm" )
	    {
		var color = [0,255,0,1.0];
		var stdlev = (data.incspd[i][j] - data.avgspd[i][j])/data.stdspd[i][j];
		var tmppjm = 1; // no incident probability is default
		if ( data.pjm[i][j] == 0.5 )
		    tmppjm = 0.5;
		else if ( stdlev < 0 && stdlev < -themeScale )
		{
		    tmppjm = 0.0;
		}
		
		if ( tmppjm == 0 ) 
		    color = [255,0,0,1.0];
		else if ( tmppjm == 0.5 )
		    color = [153,153,153,1.0];  // grey if no/bad data
		poly.setFill( color );
	    }
	    else // spd
	    {
		min = 10;
		max = 75;
		poly.setFill( getColor( data.incspd[i][j], min, max, [255,0,0,1.0], [0,255,0,1.0] ) );
	    }
	}
    }
}

var bpolys = Array();
var transform;
var texttransform;
var mmaxx;
var mmaxy;


var updateBoundary = function()
{
    bpolys = [];

    for ( i = 0; i < polys.length; i = i + 1 )
    {
	for ( j = 0; j < polys[ i ].length; j = j + 1 )
	{
	    // left
	    if ( j > 0 && data.inc[i][j] != data.inc[i][j-1] )
	    {
		var poly = surface.createPolyline([{x: data.segments[j].pmstart+0, y: mintimemin + i * 5.0}, {x: data.segments[j].pmstart+0, y: mintimemin + (i+1)*5.0} ] ).setStroke( {color: "blue", width: boundaryWidth/scalex} ); 
		bpolys.push( poly )
		poly.applyTransform( transform );
	    }
	    // right
	    if ( j < (polys[i].length-1) && data.inc[i][j] != data.inc[i][j+1] )
	    {
		var poly = surface.createPolyline([{x: data.segments[j].pmend+0, y: mintimemin + i * 5.0}, {x: data.segments[j].pmend+0, y: mintimemin + (i+1)*5.0} ] ).setStroke( {color: "blue", width: boundaryWidth/scalex} ); 
		bpolys.push( poly )
		poly.applyTransform( transform );
	    }
	    // top
	    if ( i > 0 && data.inc[i][j] != data.inc[i-1][j] )
	    {
		var poly = surface.createPolyline([{x: data.segments[j].pmstart+0, y: mintimemin + i * 5.0}, {x: data.segments[j].pmend+0, y: mintimemin + i*5.0} ] ).setStroke( {color: "blue", width: boundaryWidth/scaley} ); 
		bpolys.push( poly )
		poly.applyTransform( transform );
	    }
	    // bottom
	    if ( i < (polys.length-1) && data.inc[i][j] != data.inc[i+1][j] )
	    {
		var poly = surface.createPolyline([{x: data.segments[j].pmstart+0, y: mintimemin + (i+1) * 5.0}, {x: data.segments[j].pmend+0, y: mintimemin + (i+1)*5.0} ] ).setStroke( {color: "blue", width: boundaryWidth/scaley} ); 
		bpolys.push( poly )
		poly.applyTransform( transform );
	    }
	    
	}
    }
    
    for ( i = 0 ; i < data.length; i = i + 1 )
    {
	var sd = data[ i ];
	if ( sd.left == 1 )
        {
	    var poly = surface.createPolyline([{x: sd.segment.pmstart, y: sd.startTime}, {x: sd.segment.pmstart, y: sd.endTime} ] ).setStroke( {color: "blue", width: boundaryWidth/scalex} ); 
	    bpolys.push( poly );
	    poly.applyTransform( transform );
        }
	if ( sd.right == 1 )
        {
	    var poly = surface.createPolyline([{x: sd.segment.pmend, y: sd.startTime}, {x: sd.segment.pmend, y: sd.endTime} ] ).setStroke( {color: "blue", width: boundaryWidth/scalex} ); 
	    bpolys.push( poly );
	    poly.applyTransform( transform );
        }
	if ( sd.top == 1 )
        {
	    var poly = surface.createPolyline([{x: sd.segment.pmstart, y: sd.startTime}, {x: sd.segment.pmend, y: sd.startTime} ] ).setStroke( {color: "blue", width: boundaryWidth/scaley} ); 
	    bpolys.push( poly );
	    poly.applyTransform( transform );
        }
	if ( sd.bottom == 1 )
        {
	    var poly = surface.createPolyline([{x: sd.segment.pmstart, y: sd.endTime}, {x: sd.segment.pmend, y: sd.endTime} ] ).setStroke( {color: "blue", width: boundaryWidth/scaley} ); 
	    bpolys.push( poly );
	    poly.applyTransform( transform );
        }
    }               
    
}

var setTheme = function( newTheme ) {
    //if ( theme == newTheme ) return;
    theme = newTheme;

    console.debug( "Updating theme:  " + newTheme );

    dojo.byId( 'mapTheme' ).value = newTheme;

    // scale slider should only show for spd, and stdspd
    if ( theme == 'spd' || theme == 'stdspd' || theme == 'avgspd' || theme == 'pjm' )
    {
	dojo.byId( 'scaleSlider' ).style.visibility='visible';
    }
    else
    {
	dojo.byId( 'scaleSlider' ).style.visibility='hidden';
    }
}

var updateIncident = function( newIncident ) {
    console.debug( "Updating incident: " + newIncident );

    changeFacilityList( 'facilityCombo', newIncident );
}

var setFacility = function( value ) {
    if ( value == null || value == "" || value == "Select a facility..." ) return;
    updateData();
}

var updateData = function() {
    var v = dojo.byId( 'facility' ).value;
    loadData( v ) ;      // grabs data for the given incident (incidentData must be json defined in the page)
    redraw();        // redraws polygons
    syncInterface(); // sets interface paramters to match
}

var changeThemeScale = function( ts ) {
    themeScale = ts;
    updateView();    // updates the colors for the new theme scale
}

var plotBorderX = 75; //pixels
var plotBorderY = 75; //pixels

var resizeSurface = function() {
    if ( surface ) {
	var nn = dojo.byId( "incidentplot" );
	var pn = nn;//nn.parentNode;
	mmaxx = pn.clientWidth-plotBorderX*2-20;
	mmaxy = pn.clientHeight-plotBorderY*2-60;
	surface.setDimensions(
	    mmaxx+plotBorderX*2, 
	    mmaxy+plotBorderY*2+plotBorderY/2
	);
	
    }
}

var mintimemin;
var basetime;
var minx;
var maxx;
var miny;
var maxy;
var thefwy;
var thedir;

var getParameters = function() {
    var tt = data.opts.fwy.split(":");
    thefwy = tt[0];
    thedir = tt[1];
};


var makeShapes = function( ){
    var step = 50;
    var nn = dojo.byId( "incidentplot" );
    var pn = nn;//nn.parentNode;
    mmaxx = pn.clientWidth-plotBorderX*2-20;
    mmaxy = pn.clientHeight-plotBorderY*2-60;

//    dojo.byId( "progressBar" ).indeterminate = 'false';

    var mintime = Date.parse( data.opts.mintimestamp );
    basetime = Date.parse( "2007/01/01 00:00:00" );
//    var mintimemin = mintime/60.0 - 19900065000;
    mintimemin = (mintime-basetime)/60.0/1000.0;

    if ( surface ) 
    {
	surface.clear();
    }
    else
    {
	surface = dojox.gfx.createSurface(
	    "incidentplot", 
	    mmaxx+plotBorderX*2, 
	    mmaxy+plotBorderY*2+plotBorderY/2
	);
    }

    var i=0;

    // polys is 2d array: rows = time, colums = segment
    polys = new Array();
    //var len = (opts.prewindow + opts.postwindow)/5;  // this is the number of time slices considered
    var num_time_slices = data.incspd.length;
    var num_segments = data.incspd[ 0 ].length;
    for ( i = 0; i < num_time_slices; i = i + 1 )
    {
	polys[ i ] = new Array( num_segments );
    }

    minx = null;
    maxx = null;
    miny = null;
    maxy = null;

    for ( j = 0; j < num_segments; j = j + 1 )
    {
	var pmstart = data.segments[j].pmstart+0;
	var pmend = data.segments[j].pmend+0;

	// Find the station object for this poly
	var stnidx=undefined;
//	console.debug( "PROCESSING SEGMENT " + j );
	for ( k = 0; k < stations.length && stnidx == undefined; k = k + 1 )
	{
	    var station = stations[k];
	    pm = station.pm;
//	    console.debug( "checking " + station.fwy + "==" + thefwy +" && "+station.dir+"=="+thedir+" && "+pm+">="+pmstart+" && "+pm+"<="+pmend)
	    if ( station.fwy == thefwy && station.dir == thedir && pm >= pmstart && pm <= pmend )
	    {
		stnidx = k
//		console.debug( "YES!! " + stnidx );
	    }
	}

	for ( i = 0; i < num_time_slices; i = i + 1 )
	{
//	    var startTime = i * 5.0;
	    var startTime = mintimemin + i * 5.0;
//	    var endTime = (i+1) * 5.0;
	    var endTime = mintimemin + (i+1) * 5.0;
	    // NOTE: width is zero because we draw the grid separately to account for scaling
	    var poly = surface.createPolyline( [{x: pmstart, y: startTime}, {x: pmend, y: startTime}, 
		{x: pmend, y: endTime}, {x: pmstart, y: endTime}, {x: pmstart, y: startTime}])
	    .setStroke({color: "black", style: "Dot", width: 0.00}) 
//	    console.debug( "POLY (" + i + ", " + j + "): {" + startTime + ", " + endTime + " , " + pmstart + ", " + pmend + "}" );

	    poly.getNode().setAttribute( 'station_idx', stnidx );
	    

	    poly.connect( 'onclick', polyClicked );
	    poly.connect( 'onmouseover', polyMousedOver );
	    poly.getNode().setAttribute( 'i', i );
	    poly.getNode().setAttribute( 'j', j );
	    if ( minx == null || pmstart < minx ) minx = pmstart;
	    if ( maxx == null || pmend > maxx ) maxx = pmend;
	    if ( miny == null || startTime < miny ) miny = startTime;
	    if ( maxy == null || endTime > maxy ) maxy = endTime;
	    polys[i][j] = poly;
	}
    }

    scalex = mmaxx/( maxx - minx );
    scaley = mmaxy/( maxy - miny );

    // draw gridlines scaled properly
    gridlines = new Array();
    for ( i = 0; i < num_time_slices; i = i + 1 )
    {
	gridlines.push( surface.createPolyline( [{ x: minx, y: mintimemin + 5*i }, {x: maxx, y: mintimemin + 5*(i) } ] )
			.setStroke( {color: "black", style: "[1, 1]", width: 0.5/scaley } ) );
    }

    for ( j = 0; j < num_segments; j = j + 1 )
    {
	gridlines.push( surface.createPolyline
			( [{ x: data.segments[j].pmstart, y: miny }, 
			   {x: data.segments[j].pmstart, y: maxy } ] 
			).setStroke( {color: "black", style: "[1, 1]", 
												 width: 0.5/scalex } ) );
    }
    

    bpolys.push( surface.createPolyline(
	[ { x: minx-plotBorderX/scalex, y: miny-plotBorderY/scaley }, 
	  { x: minx-plotBorderX/scalex, y: maxy+plotBorderY/scaley }, 
	  { x: maxx+plotBorderX/scalex, y: maxy+plotBorderY/scaley }, 
	  { x: maxx+plotBorderX/scalex, y: miny-plotBorderY/scaley }, 
	  { x: minx-plotBorderX/scalex, y: miny-plotBorderY/scaley }]
    ).setStroke({color: "blue", width: 1/scalex}) );

    //	polys.push( surface.createEllipse({ cx: minx, cy: miny, rx: 100/scalex, ry: 100/scaley })
    //		.setStroke({color: "purple", width: .1/scalex} ).setFill( "purple" ) );

    //	polys.push( surface.createEllipse({ cx: minx, cy: miny, rx: 50/scalex, ry: 50/scaley })
    //		.setStroke({color: "yellow", width: .1/scalex} ).setFill( "yellow" ) );

    //	polys.push( surface.createEllipse({ cx: maxx, cy: maxy, rx: 100/scalex, ry: 100/scaley })
    //		.setStroke({color: "purple", width: .1/scalex} ).setFill( "purple" ) );

    //	polys.push( surface.createEllipse({ cx: maxx, cy: maxy, rx: 50/scalex, ry: 50/scaley })
    //		.setStroke({color: "yellow", width: .1/scalex} ).setFill( "yellow" ) );

    console.debug( "XY:" + minx + "," +miny + ":" + maxx + "," +maxy );
    // this transforms the plot to be oriented in a traditional manner
    transform = dojox.gfx.matrix.multiply( 
	dojox.gfx.matrix.flipY
	, dojox.gfx.matrix.scale( scalex, scaley )
	,dojox.gfx.matrix.translate( -(minx-plotBorderX/scalex), -(maxy+(plotBorderY)/scaley) ) // what's the +10?
	//	        ,dojox.gfx.matrix.translate( -minx, -miny )
    );
//    texttransform = dojox.gfx.matrix.multiply( 
//	dojox.gfx.matrix.flipY
//	,dojox.gfx.matrix.scale( mmaxx/(maxx-minx),mmaxy/(maxy-miny) )
//	,dojox.gfx.matrix.translate( -minx, -maxy )
//    );
    texttransform = transform;

    for ( i = 0; i < polys.length; i = i + 1 )
    {	
	for ( j = 0; j < polys[0].length; j = j + 1 )
	    polys[i][j].applyTransform( transform );
    }

    for ( i = 0; i < bpolys.length; i = i + 1 )
    {	
	    bpolys[ i ].applyTransform( transform );
    }

    for ( i = 0; i < gridlines.length; i = i + 1 )
    {	
	    gridlines[ i ].applyTransform( transform );
    }
    //	surface.applyTransform( transform );

    updateView();  // sets colors
    updateBoundary();  // draws incident region    
};

var addScaledText = function( node, font, fill, angle )
{
//    node.y = -node.y; // hack y since we're not scaling the text with flipY
    var text = surface.createText( node );
    if ( font ) text.setFont( font );
    if ( fill ) text.setFill( fill );;

    var xx = text.shape.x;
    var yy = text.shape.y;

    var trans = dojox.gfx.matrix.multiply( 
	texttransform, 
	dojox.gfx.matrix.scaleAt( 1/(scalex),-1/(scaley), xx, yy )
    );

    if ( angle ) trans = dojox.gfx.matrix.multiply( 
	trans, 
	dojox.gfx.matrix.rotateAt( angle, xx, yy ) );

    text.applyTransform( trans );

    return text;
}

var makePostmileLabels = function()
{
    var minyy=10000000;
    var segments = data.segments;
    for ( var i = 0; i < segments.length; i++ )
    {
	var xx = segments[ i ].pmstart;
	var yy = miny-10/scaley; // -10/scaley is to offset the labels downward 10 pixels
	var text = addScaledText( 
	    { x: xx, y: yy, align: "start", text: "" + segments[ i ].pmstart },
	    { size: "8pt"},
	    "black",
		60*(3.14159/180)
	);
	if ( text.shape.y < minyy ) minyy = text.shape.y;
    }

    // X ticks
    var hms = data.opts.mintimeofday.split(":");
    var hr = parseInt(hms[ 0 ]);
    var min = parseInt(hms[ 1 ]);
    var sec = parseInt(hms[ 2 ]);
    var tt = addScaledText(
	{ x: minx-5/scalex, y: miny, align: "end", text: hr + ":" + min },
	{ size: "8pt" },
	"black"
    );

    var steps = parseInt(data.opts.prewindow) + parseInt(data.opts.postwindow);
    var close = hr * 60 + min + steps;
    var chr = Math.floor(close/60);
    var cmn = Math.floor((close/60-chr)*60+0.5);
    var tt = addScaledText(
	{ x: minx-5/scalex, y: maxy, align: "end", text: chr + ":" + cmn },
	{ size: "8pt" },
	"black"
    );


    // add X label
    var xx = minx-50/scalex;
    var yy = (maxy-miny)/2+miny;
    var labelx = addScaledText(
	{ x: xx, y: yy, align: "middle", text: "Time of day" },
	{ size: "10pt", weight: "bold" },
	"black",
	-90*(3.14159/180)
    );

    // add Y label
    var xx = (maxx-minx)/2.0 + minx;
    var yy = miny-70.0/scaley;
    var labely = addScaledText(
	{ x: xx, y: yy, align: "middle", text: "Postmile along " + data.opts.fwy + " (travel right to left)"  },
	{ size: "10pt", weight: "bold" },
	"black",
	0
    );

    // add title
/*
    var xx = (maxx-minx)/2.0 + minx;
    var yy = maxy+40.0/scaley;
    var labely = addScaledText(
	{ x: xx, y: yy, align: "middle", text: "Incident " + data.opts.cad  },
	{ size: "10pt", weight: "bold" },
	"black",
	0
    );
*/
    
}

var evtObjs;
var makeEvents = function()
{
    var st = data.events.incident_start;
    evtObjs = new Array();
    if ( st ) 
    {
	// Plot 
	//evtObjs.push( surface.createPolyline( [ { x: minx, y: st.tod }, { x: maxx, y: st.tod } ] )
		//      .setStroke( { color: [0, 256, 256], width: 3.0/scaley } ) );
	//evtObjs.push( surface.createPolyline( [ { x: st.pm, y: miny }, { x: st.pm, y: maxy } ] )
		//      .setStroke( { color: [0, 256, 256], width: 3.0/scalex } ) );
	var evt = surface.createEllipse( { cx: st.pm, cy: st.tod, rx: 10/scalex, ry: 10/scaley } )
	.setStroke( { color: [0, 256, 256 ], width: 0 } )
	.setFill( [0, 256, 256, 0.5 ] );
	evtObjs.push( evt );
	evt.getNode().setAttribute( 'description', 'Approximate time-space location of incident' );
	evt.connect( 'onmouseover', showEventTooltip );
    }
    for ( i = 0; i < evtObjs.length; i = i + 1 )
    {	
	    evtObjs[ i ].applyTransform( transform );
    }
}

var stationObjs;
var sectionParams;
var makeStations = function()
{
    stationObjs = new Array();
    sectionParams = {idIn:[]};
    for ( i = 0; i < stations.length; i = i + 1 )
    {
	var station = stations[i];
	var pm = ( thedir == "N" || thedir == "W" ) ? -station.pm : station.pm;
	if ( station.fwy == thefwy && station.dir == thedir && pm >= minx && pm <= maxx )
	{
	    var stn = surface.createPolyline( [ { x: pm, y:miny}, { x:pm, y:maxy } ] )
	        .setStroke( { color: [ 256, 0, 153, 0.5 ], width: 1.0/scalex } );
	    stationObjs.push( stn );
	    stn.getNode().setAttribute( 'station_idx', i );
	    stn.connect( 'onclick', showStation );
	    stn.connect( 'onmouseover', hoverStation );
	    stn.applyTransform( transform );

	    // create the parameters to grab the relevant vds for the segments layer
	    sectionParams['idIn'].push( station.vdsid );

	    var text = addScaledText( 
		{ x: pm, y: maxy+10/scaley, align: "start", text: "" + station.name },
		{ size: "8pt"},
		"black",
		-60*(3.14159/180)
	    );
	    stationObjs.push( text );
	}
    }
}

var myUpdateVdsSegmentsLayer = function( theParams ) {
    if ( sectionParams && sectionParams['idIn'] && sectionParams['idIn'].length > 0 )
	updateVdsSegmentsLayer( sectionParams );
    map.zoomToExtent( getVdsSegmentLines().getExtent().toBBOX() );
}

var mySegmentsLayerInit = function() {
    if ( sectionParams && sectionParams['idIn'] && sectionParams['idIn'].length > 0 )
	segmentsLayerInit( sectionParams );

    // zoom the map to envelop the segments 
    map.zoomToExtent( getVdsSegmentLines().getExtent().toBBOX() );
}


var displayStations = function( visibility )
{
    for ( i = 0; i < stationObjs.length; i = i + 1 )
    {
	stationObjs[ i ].getNode().style.visibility = visibility;
    }
}

var actlogObjs;
var makeActivityLog = function()
{
    actlogObjs = new Array();
    
    for ( i = 0; i < data.actlog.length; i = i + 1 )
    {
//	var timeInMins = timeInHours( data.actlog[ i ].stamptime )*60 - timeInHours( data.opts.mintimeofday )*60;
	var alogdatestr = data.actlog[i].stampdate + " " + data.actlog[i].stamptime;
	alogdatestr = alogdatestr.replace( /-/g, "/" );
	var time = Date.parse( alogdatestr );
	var timeInMins = (time-basetime)/60.0/1000.0;
	var evt = surface.createPolyline( [ { x: minx-10/scalex, y: timeInMins }, { x:maxx, y: timeInMins } ] )
//	.setStroke( { color: [ 256, 0, 153, 0.5 ], width: 1.0/scaley } );
	.setStroke( { color: [ 0, 255, 255, 0.5 ], width: 1.0/scaley } );
//	console.debug( "ACTIVITY LOG @ " + alogdatestr + " = " + timeInMins);
	actlogObjs.push( evt );
	evt.getNode().setAttribute( 'logentry_idx', i );
	evt.connect( 'onclick', showActivityLogEntry );
	evt.applyTransform( transform );
    }
}

var displayActivityLog = function( visibility )
{
    for ( i = 0; i < actlogObjs.length; i = i + 1 )
    {
	actlogObjs[ i ].getNode().style.visibility = visibility;
    }
};



/*
* Function to change dataStore from filtering
*
* Param:
* myObj - ID of the filtering
* myURL - Your JSON return URL (U might use GET to recive for exemplo php....
*/

var vvstore;

function changeFacilityList(myObj, incident) {
    //
    //Disable the menu and put a wait message
//    dijit.byId(myObj).setDisplayedValue("Loading...");
//    dijit.byId(myObj).setDisabled(true);
    
    //
    // Create new dataStore with the gived URL
//     vvstore = new dojo.data.ItemFileReadStore( { "data": { identifier: 'id', items: [
//         { 'id': 1, 'cad': '61-110207', 'facility': '5-N' },
//         { 'id': 2, 'cad': '61-110207', 'facility': '5-S' },
//         { 'id': 3, 'cad': '83-113007', 'facility': '5-N' },
//         { 'id': 4, 'cad': '83-113007', 'facility': '5-S' },
//         { 'id': 5, 'cad': '83-113007', 'facility': '55-N' },
//         { 'id': 6, 'cad': '83-113007', 'facility': '55-S' }
//      ] } } );
//     var vvstore = new dojo.data.ItemFileReadStore( { "data": { identifier: 'id', items: [
//          { 'id': 1, 'cad': '61-110207', 'facility': '5-N' },
//          { 'id': 2, 'cad': '61-110207', 'facility': '5-S' },
//          { 'id': 3, 'cad': '83-113007', 'facility': '5-N' },
//          { 'id': 4, 'cad': '83-113007', 'facility': '5-S' },
//          { 'id': 5, 'cad': '83-113007', 'facility': '55-N' },
//          { 'id': 6, 'cad': '83-113007', 'facility': '55-S' }
// 	    ] } } );

    var vvstore = new dojo.data.ItemFileReadStore( { url: 'metadata2.json' } );
//    var t = dojo.toJson( store );
//    var vstore = new dojo.data.ItemFileWriteStore( { "data": t } );    


    //
    // Set the new store in the dijit "SELECT"
    dijit.byId( myObj ).store = vvstore;
    dijit.byId( myObj ).labelAttr = 'facility';
    dijit.byId( myObj ).query = {cad: incident};

    //
    // Fetch the values
    // Remember query{ name: "*" }.... where "name" refer to one of the fields...
    var newValue = vvstore.fetch(
	{
//	    query: {id: '*'},
	    query: {cad: incident},
	    labelAttr: "cad",
	    onComplete: function(items, request) {
//		dijit.byId(myObj).setDisplayedValue(items[0].facility);
//		dijit.byId(myObj).setValue( items[0].facility );
		dijit.byId(myObj).setValue( "Select a facility..." );
	    }
	});



    //
    // Enable the dijit "SELECT"
//    dijit.byId(myObj).setDisabled(false);

} // END




// SOME AOP STUFF

var displayProgress = {
    before: function() {
//	dojo.byId( "progressBar" ).style.visibility = 'visible';
    },

    after: function() {
//	dojo.byId( "progressBar" ).style.visibility = 'hidden';
    }
};

var displayStatus = {
    before: function() {
//	dojo.byId( "statusText" ).style.visibility = 'visible';
    },

    after: function() {
//	dojo.byId( "statusText" ).style.visibility = 'hidden';
    }
}




aop.advise( this, [ "loadObjects" ], [ displayStatus, displayProgress ] );

dojo.addOnLoad(init);

