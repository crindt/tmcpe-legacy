// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.TimeSpaceDiagram");

// TimeSpaceDiagram is a dojo widget...
dojo.require("dijit._Widget");

// We assume the TSD data comes from a URI returning the json data to plot
dojo.require("dojox.json.ref");


dojo.declare("tmcpe.TimeSpaceDiagram", [ dijit._Widget ], {
    // summary: 
    //        A TimeSpaceDiagram widget rendered as a colored HTML table
    // description:
    //        This widget renders a TimeSpaceDiagram (in the traffic flow sense) 
    //        based upon json data obtained from a provided URI.  Currently, it
    //        can display data for each cell using a variety of themes mostly 
    //        trending from green to red as congestion gets worse.

    // _data: Object
    //        A variable for holding the JSON data read from the URI
    _data: null,

    // _stations: Object
    //        A variable for holding VDS station data (NOTE: this will soon be deprecated)
    _stations: null,

    // _colorDataAccessor: function(int i, int j)
    //        A variable holding the function to use to compute the color for time-space 
    //        cell (i,j).  This is a feature used to theme the TSD (e.g., display absolute 
    //        speeds instead of deviations from the mean)
    _colorDataAccessor: null,

    // _themeScale: Float
    //        A scaling parameter used by the colorDataAccessor.  This is generally controlled by the user interface
    _themeScale: 0.75,

    // colorDataAccessor: String
    //        The name of the standard accessor to use.  This should be set by the user interface.
    //        In the current implementation (which is a bit application specific), standard color 
    //        accessors are available to compute color as follows:
    //           "stdspd" --- Scale the color from green to red based upon the number of standard deviations below the mean speed
    //           "avgspd" --- Scale the color from green to red based upon how far below the average speed it is
    //           "spd"    --- Scale the color from green to red where pure green is 75mph or greater and red is 10mph or below
    //           "inc"    --- Set the color red if an incident is affecting the cell and green if not
    //           "pjm"    --- Set the color red if evidence suggests an incident affects the cell and green otherwise.
    colorDataAccessor: "stdspd",

    // _numTimeRows: Integer
    //        Internal variable holding the number of timesteps to display.  This determines the number of rows in the table
    _numTimeRows: null,


    // _tr: Array of tr elements
    //        internal variable to hold a reference to the table rows so we can update them as necessary
    _tr: null,

    // _td: Array of td elements
    //        internal variable to hold a reference to the table data (cells) so we can update them as necessary
    _td: null,

    // incident: String
    //        The incident number to display in the TSD.  Note that this is implementation specific 
    //        and is used in the interface.  A more general version of this widget would not know 
    //        anything about incidents and the like
    incident: null,

    // facility: String
    //        The facility for which the traffic data is being displayed.  Again, this
    //        is an application detail that needs to be taken out of this widget
    facility: null,

    // direction: String
    //        The direction of the facility for which the traffic data is being displayed.  Again, this
    //        is an application detail that needs to be taken out of this widget
    direction: null,


    buildRendering: function() {
	// summary:
	// 		method called to draw the widget, overridden from _Widget

	// Let the superclass do most of the work
	this.inherited( arguments );

	// Now do our thing...
	this.updateData();
    },
    
    changeIncident: function( /* String */ inc, /* String */ fac, /* String */ dir ) {
	// summary:
	// 		method to be called by the user interface to change the data source
	// description:
	//		This should really be in the application code, not the widget code
	this.incident = inc;
	this.facility = fac;
	this.direction = dir;
	this.updateData();
    },

    updateData: function() {
	// summary:
	// 		function to change (or create) the time space digram
	// description:
	//		

	// grabs data for the given incident
	var v = [this.incident, this.facility, this.direction].join( "-" );
	this._loadData( v ) ;      

	// Call our method to render the timespacedigram table
	this._redraw();
	
	//syncInterface(); // sets interface paramters to match
    },

    getTimeForIndex: function( i ) {
	var dd = dojo.date.locale.parse( this._data.opts.mintimestamp, {datePattern:"yyyy/MM/dd", timePattern:"HH:mm:ss"} );
	var dd2 = dojo.date.add( dd, 'minute', i*5 );
	return dd2;
    },

    _colorAccessors: {
	stdspd: function( i,j ) { return this._getColor( (this._data.incspd[i][j]-this._data.avgspd[i][j])/this._data.stdspd[i][j], -this._themeScale, 0, '#ff0000','#00ff00' ) },
	avgspd: function( i,j ) { return this._getColor( (this._data.incspd[i][j]-this._data.avgspd[i][j]), -this._themeScale, 0, '#ff0000','#00ff00' ) },
	inc: function( i,j ) { var color = '#00ff00'; if ( this._data.inc[i][j] == 1 ) color = '#ff0000'; return color; },
	pjm: function( i,j ) { 
	    var color = '#00ff00';
	    var stdlev = (this._data.incspd[i][j] - this._data.avgspd[i][j])/this._data.stdspd[i][j];
	    var tmppjm = 1; // no incident probability is default
	    if ( this._data.pjm[i][j] == 0.5 )
		tmppjm = 0.5;
	    else if ( stdlev < 0 && stdlev < -this._themeScale )
	    {
		tmppjm = 0.0;
	    }
	    
	    if ( tmppjm == 0 ) 
		color = '#ff0000';
	    else if ( tmppjm == 0.5 )
		// grey if no/bad data
		color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");
	    return color;
	},
	spd: function( i,j ) { return this._getColor( this._data.incspd[i][j], 10, 75, '#ff0000', '#00ff00' )	}
    },

    setTheme: function( th ) {
	this.colorDataAccessor = th;
	this.updateTheme();
    },

    setThemeScale: function( ths ) {
	this._themeScale = ths;
	this.updateTheme();
    },

    updateTheme: function() {
	console.log( "UPDATING THEME" );
	var numrows = Math.round(((this._data.opts.prewindow/1) + (this._data.opts.postwindow/1))/5);
	this._colorDataAccessor = this._colorAccessors[ this.colorDataAccessor ];
	
	for ( i = 0; i < numrows; ++i ) {
	    // iind is used to flip the diagram so time increases going up
	    var iind = numrows-1-i;
	    for ( j = 0; j < this._data.segments.length; ++j ) {
		this._td[i][j].style.backgroundColor = this._colorDataAccessor(iind,j);
	    }
	}
    },

    _redraw: function()
    {
	// summary:
	//		method to actually create the TimeSpaceDiagram table in the widget's div
	// description:
	//		
	
	// Get the accessor we'll use to theme the table
	this._colorDataAccessor = this._colorAccessors[ this.colorDataAccessor ];

	//    dojo.byId( "statusText" ).textContent = "Drawing plot...";

	// Remove any existing table in the widget's dom node
	this.domNode.removeChild( this.domNode.firstChild );

	// Now create the table element  
	// FIXME: Some of the styling is hardcoded here.  Really should move it into a css file
	this.domNode.appendChild( dojo.create( "table", { ref: [this.incident, this.facility, this.direction].join('-'), style: "border-width:1px;border-color:#000000;cellpadding:0px;cellspacing:0px;border-collapse:collapse;width:100%;height:100%;"
							}) );
	// tt is a local shorthand variable for working with the table node (makes the code cleaner)
	var tt = this.domNode.firstChild;

	// delete all rows (if they exist---I think this might not be necessary but it's inexpensive)
	if ( tt.rows != null ) {
	    for(var i = tt.rows.length; i > 0;i--)
	    {
		tt.deleteRow(i -1);
	    }
	}

	// d is a local shorthand variable for accessing the traffic data
	var d = this._data;


	// FIXME: This is hacky and hardcoded.  Basically, I'm
	// computing the number of rows (timesteps) from data passed
	// in the JSON object.  The JSON data format needs to be
	// standardized
	var numrows = Math.round(((d.opts.prewindow/1) + (d.opts.postwindow/1))/5);
	console.log( "NUMROWS IS" + numrows );
	this._numTimeRows = numrows;

	// FIXME: Similarly here, I'm getting the number of freeway
	// segments (columns) to plot and computing the total length
	// of the section.  Standardization required
	var totlen = 0;
	for ( j = 0; j < d.segments.length; ++j )
	{
	    totlen += ( d.segments[j].pmend - d.segments[j].pmstart );
	}
	if ( totlen < 0 ) totlen = -totlen;
	

	// I size the rows and columns using percentages in the CSS
	// styling.  Here we compute the height of the rows (all
	// assumed to be the same because we assume a single time
	// step) as a percentage of the total height of the TSD widget
	var height = 100.0/numrows;

	// Create the arrays for holding the row and cell data
	this._tr = new Array(numrows);
	this._td = new Array(numrows);

	for ( i = 0; i < numrows; ++i )
	{
	    // iind is used to flip the diagram so time increases going up
	    var iind = numrows-1-i;

	    // add the next row to the table
	    var tr = tt.appendChild( dojo.create( "tr", {timeidx: i, time: iind, style: "height:" + height + "%;" } ) );
	    this._tr[i] = tr;

	    // Now loop and create the table cells
	    this._td[i] = new Array( d.segments.length );
	    for ( j = 0; j < d.segments.length; ++j )
	    {
//		console.log( i + " < " + numrows + ", " + j + " < " + d.segments.length );

		// The width of the cell is proportional to its actual length in the real world
		var width = 100 * (d.segments[j].pmend - d.segments[j].pmstart)/totlen;
		if ( width < 0 ) width = -width;

		// compute borders---This is specific to display the extent of an incident
		var borders = "";
		if ( j > 0 && this._data.inc[iind][j] != this._data.inc[iind][j-1] )
		{
		    borders += "border-left-width:3px;border-left-style:solid;border-left-color:blue;";
		}
		// right
		if ( j < (d.segments.length-1) && this._data.inc[iind][j] != this._data.inc[iind][j+1] )
		{
		    borders += "border-right-width:3px;border-right-style:solid;border-right-color:blue;";
		}
		// top
		if ( iind > 0 && this._data.inc[iind][j] != this._data.inc[iind-1][j] )
		{
		    borders += "border-bottom-width:3px;border-bottom-style:solid;border-bottom-color:blue;";
		}
		// bottom
		if ( iind < (d.segments.length-1) && this._data.inc[iind][j] != this._data.inc[iind+1][j] )
		{
		    borders += "border-top-width:3px;border-top-style:solid;border-top-color:blue;";
		}

		// Actually create the cell in the appropriate table row
		this._td[i][j] = tr.appendChild( dojo.create( "td", { 
		    id:["tsd",iind,j].join("_"), 
		    time: iind,
		    segment: j,
		    station: d.segments[j].stnidx,
		    innerHTML: ""/*i + "," + j*/, style: "width:" + width + "%;border-width:1px;border-color:gray;border-style:dotted;background-color:"+this._colorDataAccessor(iind,j)+";"+borders,
		} ) );
	    }
	}
    },

    _loadData: function( inc ){
	// summary:
	//		Grab the data from the network using an ajax call
	// description:
	//		This is currently too implementation specific.  
	//              Probably best to obtain the JSON outside the widget and simply
	//              pass it as an argument...
	if ( !inc ) {
	    console.debug( "Bad incfacdir " + inc );
	    return;
	}
//	var fwydir = inc.split( '-' );
	var theUrl = "/tmcpe/data/" + inc + ".json";

	var caller = this;
	
	//    jsProgress.update( {indeterminate: true} );

	// Make a synchronous call to get the incident data (which
	// contains the speed/etc data that this widget will plot
	dojo.xhrGet({
	    url:			theUrl,
	    preventCache:	true,
	    handleAs:		"text",
	    sync: true, //false,
	    load: function( r ) {
		caller._loadObjects( r );
	    },
	    error:			function(r){ alert("Error: " + r); }
	});

	// Make a synchronous call to get the station data FIXME: I
	// plan to remove this call and consolidate things into a
	// single call
	dojo.xhrGet({
	    url: "/tmcpe/data/stations.json",
	    preventCache: true,
	    handleAs: "text",
	    sync: true,
	    load: function( r ) {
		caller._processStations( r );
	    },
	    error:			function(r){ alert("Error: " + r); }
	});


	// Do some processing on the data we obtained above.
	// Specifically: compute some information about the stretch of
	// freeway being plotted.  FIXME: the station data should
	// probably come in the same JSON call as the speed data.
	var data = this._data;
	var stations = this._stations;
	for ( j = 0; j < data.segments.length; ++j )
	{
	    var pmstart = data.segments[j].pmstart+0;
	    var pmend = data.segments[j].pmend+0;

	    var stnidx = null;
	    for ( k = 0; k < stations.length && stnidx == undefined; k = k + 1 )
	    {
		var station = stations[k];
		var pm = ( this.direction == "N" || this.direction == "W" ) ? -station.pm : station.pm;

		//	    console.debug( "checking " + station.fwy + "==" + thefwy +" && "+station.dir+"=="+thedir+" && "+pm+">="+pmstart+" && "+pm+"<="+pmend)
		if ( station.fwy == this.facility && station.dir == this.direction && pm >= pmstart && pm <= pmend )
		{
		    // store the station index for this segment
		    stnidx = k;
		    data.segments[j].stnidx = k;
		}
	    }
	}
    },

    _loadObjects: function(r){
	// summary:
	//		processes the JSON obtained from an AJAX call into a JS object
	// description:
	//		The object is the freeway data (should validate)
	console.debug( "Loading objects" );
	//    dojo.byId( "statusText" ).textContent = "Parsing objects...";
	
	if(!r){
	    alert("Wrong JSON object. Did you type the file name correctly?");
	    return;
	}
	
	// read the json data
	this._data = dojox.json.ref.fromJson( r );;
    },

    _processStations: function( r ) {
	// summary:
	//		processes the JSON obtained from an AJAX call into a JS object
	// description:
	//		The object is the station data (should validate)
	console.debug( "Processing stations" );
	if(!r){
	    alert("Wrong JSON object. Did you type the file name correctly?");
	    return;
	}
	// read the json data
	this._stations = dojox.json.ref.fromJson( r );
    },
    
    _getColor: function( /*float*/ val, /*float*/ min, /*float*/ max, /*float*/ minval, /*float*/ maxval ) {
	// summary:
	//		Computes a color between green and red based upon the given value and limits
	// description:
	//		If val >= max, the color is green.  If val <=
	//		min, the color is red.  If it's in between,
	//		the color is trends from green->yellow->orange->red
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
//	var ret = [ parseInt( r*255 ), parseInt( g*255 ), parseInt( b*255 ), 1.0 ];
	var ret = "#"+[ this._toColorHex( r*255 ), this._toColorHex( g*255 ), this._toColorHex( b*255 ) ].join("");
	return ret;
    },

    _toColorHex: function( /* integer */ v ) {
	// summary:
	//		helper function to convert a decimal integer to a hexidecimal value
	var val = parseInt( v ).toString( 16 );
	if ( val.length < 2 ) val = '0' + val;
	return val;
    },

    
    _dummyLastFunction: function() {
	// summary:
	// 		A dummy function
	// description:
	//		I stick this at the bottom of javascript
	//		objects so I can just put a comma after every
	//		function instead of worrying about whether the
	//		function I added is the last one or not (it
	//		never will be because *this* function is
	//		always the last one)
    }
});
