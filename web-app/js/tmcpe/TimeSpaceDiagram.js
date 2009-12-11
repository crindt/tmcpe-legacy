// all packages need to dojo.provide() _something_, and only one thing
dojo.provide("tmcpe.TimeSpaceDiagram");

// 
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dojox.json.ref");

//dojo.require("dojox.gfx.Surface");

// our declared class
dojo.declare("tmcpe.TimeSpaceDiagram", [ dijit._Widget ], {

    // private vars
    _data: null,
    _stations: null,
    _minStation: null,
    _maxStation: null,
    incident: null,
    facility: null,
    direction: null,
    colorDataAccessor: "stdspd",
    _colorDataAccessor: null,
    _numTimeRows: null,
    _themeScale: 0.75,   // by default
    _td: null,        // for holding the td cells
    _tr: null,        // for holding the td cells

    // methods
    buildRendering: function() {
	this.inherited( arguments );
	// create the objects
	// create the DOM for this widget
	this.updateData();
	
    },
    
    changeIncident: function( inc, fac, dir ) {
	this.incident = inc;
	this.facility = fac;
	this.direction = dir;
	this.updateData();
    },

    updateData: function() {
	var v = [this.incident, this.facility, this.direction].join( "-" );

	this._loadData( v ) ;      // grabs data for the given incident (incidentData must be json defined in the page)
	this._redraw();        // redraws polygons
	
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
	var numrows = ((this._data.opts.prewindow/1) + (this._data.opts.postwindow/1))/5;
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
	this._colorDataAccessor = this._colorAccessors[ this.colorDataAccessor ];


	//    dojo.byId( "statusText" ).textContent = "Drawing plot...";
	this.domNode.removeChild( this.domNode.firstChild );
	this.domNode.appendChild( dojo.create( "table", { ref: [this.incident, this.facility, this.direction].join('-'), style: "border-width:1px;border-color:#000000;cellpadding:0px;cellspacing:0px;border-collapse:collapse;width:100%;height:100%;"
							}) );

	var tt = this.domNode.firstChild;
	

	// delete all rows (if they exist)
	if ( tt.rows != null ) {
	    for(var i = tt.rows.length; i > 0;i--)
	    {
		tt.deleteRow(i -1);
	    }
	}

	var d = this._data;


	var numrows = ((d.opts.prewindow/1) + (d.opts.postwindow/1))/5;
	this._numTimeRows = numrows;

	var totlen = 0;
	for ( j = 0; j < d.segments.length; ++j )
	{
	    totlen += ( d.segments[j].pmend - d.segments[j].pmstart );
	}
	if ( totlen < 0 ) totlen = -totlen;
	

	var height = 100.0/numrows;
	var width = 100.0/d.segments.length;

	this._tr = new Array(numrows);
	this._td = new Array(numrows);
	for ( i = 0; i < numrows; ++i )
	{
	    // iind is used to flip the diagram so time increases going up
	    var iind = numrows-1-i;

	    var tr = tt.appendChild( dojo.create( "tr", {timeidx: i, time: iind, style: "height:" + height + "%;" } ) );
	    this._tr[i] = tr;
	    this._td[i] = new Array( d.segments.length );
	    for ( j = 0; j < d.segments.length; ++j )
	    {
//		console.log( i + " < " + numrows + ", " + j + " < " + d.segments.length );
		// min/max for stdspd theme
		var width = 100 * (d.segments[j].pmend - d.segments[j].pmstart)/totlen;
		if ( width < 0 ) width = -width;

		// compute borders
		// left
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


		this._td[i][j] = tr.appendChild( dojo.create( "td", { 
		    id:["tsd",iind,j].join("_"), 
		    time: iind,
		    segment: j,
		    station: d.segments[j].stnidx,
		    innerHTML: ""/*i + "," + j*/, style: "width:" + width + "%;border-width:1px;border-color:gray;border-style:dotted;background-color:"+this._colorDataAccessor(iind,j)+";"+borders,
		} ) );
	    }
	}

/*
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
*/
	
	//dojo.connect( dojo.byId( "title" ), 'onclick', function() { console.debug( "Clicked the title" ); } );
    },

    _loadData: function( inc ){
	if ( !inc ) {
	    console.debug( "Bad incfacdir " + inc );
	    return;
	}
//	var fwydir = inc.split( '-' );
	var theUrl = "/tmcpe/data/" + inc + ".json";

	var caller = this;
	
	//    jsProgress.update( {indeterminate: true} );
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



	// Do some processing
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
	console.debug( "Processing stations" );
	if(!r){
	    alert("Wrong JSON object. Did you type the file name correctly?");
	    return;
	}
	// read the json data
	this._stations = dojox.json.ref.fromJson( r );
    },
    
    _getColor: function( val, min, max, minval, maxval ) {
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
//	var ret = [ parseInt( r*255 ), parseInt( g*255 ), parseInt( b*255 ), 1.0 ];
	var ret = "#"+[ this._toColorHex( r*255 ), this._toColorHex( g*255 ), this._toColorHex( b*255 ) ].join("");
	return ret;
    },

    _toColorHex: function( v ) {
	var val = parseInt( v ).toString( 16 );
	if ( val.length < 2 ) val = '0' + val;
	return val;
    },


    _dummyLastFunction: function() {}
});
