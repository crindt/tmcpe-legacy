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
    themeScale: 1.5,

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
    _itr: null,

    // _td: Array of td elements
    //        internal variable to hold a reference to the table data (cells) so we can update them as necessary
    _td: null,
    _itd: null,

    // incident: String
    //        The incident number to display in the TSD.  Note that this is implementation specific 
    //        and is used in the interface.  A more general version of this widget would not know 
    //        anything about incidents and the like
    incident: null,

    // analysisId: Integer
    analysisId: null,

    // facility: String
    //        The facility for which the traffic data is being displayed.  Again, this
    //        is an application detail that needs to be taken out of this widget
    facility: null,

    // direction: String
    //        The direction of the facility for which the traffic data is being displayed.  Again, this
    //        is an application detail that needs to be taken out of this widget
    direction: null,

    // logStore: Array
    //        An array of log entries for the incident in question.
    logStore: null,

    // _tableNodeContainer: DomNode
    //        The DOM node containing all TSD elements
    _tableNodeContainer: null,

    // _tableNode: DomNode
    //        The DOM node containing the TSD table
    _tableNode: null,
    _incidentTableNode: null,

    buildRendering: function() {
	// summary:
	// 		method called to draw the widget, overridden from _Widget

	// Let the superclass do most of the work
	this.inherited( arguments );
    },

    updateUrl: function( /* String */ url) {
	// summary:
	// 		function to change (or create) the time space digram
	// description:
	//		
	console.debug( "BOGS!" );
	console.debug( "UPDATING TO " + url );
	this._loadData( url ) ;      

	// Call our method to render the timespacedigram table
	this._redraw();
	
	//syncInterface(); // sets interface paramters to match
    },

    getTimeForIndex: function( i ) {
	var dd = dojo.date.locale.parse( this._data.opts.mintimestamp, {datePattern:"yyyy/MM/dd", timePattern:"HH:mm:ss"} );
	var dd2 = dojo.date.add( dd, 'minute', i*5 );
	return dd2;
    },

    _toColorHex: function( /* integer */ v ) {
	return this._colorAccessors._toColorHex( v );
    },

    _getColor: function( /*float*/ val, /*float*/ min, /*float*/ max, /*float*/ minval, /*float*/ maxval ) {
	return this._colorAccessors._getColor( val, min, max, minval, maxval );
    },
    
    _colorAccessors: {
	
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

	stdspd: function( i,j,secdata ) { 
	    var secdat;
	    if ( secdata == null ) {
		    secdat = this._data.sections[j].analyzedTimesteps[i];
	    } else {
		secdat = secdata;
	    }
	    var color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");
	    if ( secdat != null && secdat.spd != null && secdat.spd_avg != null && secdat.spd_std != null 
		 && ( secdat.p_j_m == 0 || secdat.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
//		 && secdat.days_in_avg < 30  // fixme: make this a parameter
//		 && secdat.pct_obs_avg < 30  // fixme: make this a parameter
	       ) {
		color = this._getColor( (secdat.spd-secdat.spd_avg)/secdat.spd_std, -this.themeScale, 0, '#ff0000','#00ff00' );
	    }
	    return color;
	},
	avgspd: function( i,j ) { 
	    var secdat = this._data.sections[j].analyzedTimesteps[i];
	    var color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");
	    if ( secdat != null && secdat.spd != null && secdat.spd_avg != null 
		 && ( secdat.p_j_m == 0 || secdat.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
//		 && secdat.days_in_avg < 30  // fixme: make this a parameter
//		 && secdat.pct_obs_avg < 30  // fixme: make this a parameter
	       ) {
		color = this._getColor( (secdat.spd-secdat.spd_avg), -this.themeScale*10, 0, '#ff0000','#00ff00' );
	    }
	    return color
	},
	inc: function( i,j ) { 
	    var secdat = this._data.sections[j].analyzedTimesteps[i];
	    var color = this._colorAccessors[ 'stdspd' ](i,j,secdat);
	    if ( secdat != null && secdat.inc ) color = '#0000ff'; 
	    return color; 
	},
	pjm: function( i,j ) { 
	    var secdat = this._data.sections[j].analyzedTimesteps[i];
	    var color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");
	    if ( secdat != null && secdat.spd != null && secdat.spd_avg != null && secdat.spd_std != null ) {
		color = this._getColor( (secdat.spd-secdat.spd_avg)/secdat.spd_std, -this.themeScale, 0, '#ff0000', '#00ff00' );
		
		var stdlev = (secdat.spd - secdat.spd_avg)/secdat.spd_std;
		var tmppjm = 1; // no incident probability is default
		if ( secdat.p_j_m != 0 && secdat.p_j_m != 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
		    tmppjm = 0.5;
		else if ( stdlev < 0 && stdlev < -this.themeScale )
		{
		    tmppjm = 0.0;
		}
		
		if ( tmppjm == 0 ) 
		    color = '#0000ff';
		else if ( tmppjm == 0.5 )
		    // grey if no/bad data
		    color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");
	    }
	    return color;
	},
	spd: function( i,j ) { 
	    var secdat = this._data.sections[j].analyzedTimesteps[i];
	    var color = "#"+[ this._toColorHex( 153 ), this._toColorHex( 153 ), this._toColorHex( 153 ) ].join("");

	    if ( secdat != null && secdat.spd != null ) {
		color = this._getColor( secdat.spd, 15, 50, '#ff0000', '#00ff00' );
	    }
	    return color;
	}
    },

    setTheme: function( th ) {
	this.colorDataAccessor = th;
	this.updateTheme();
    },

    setThemeScale: function( ths ) {
	this.themeScale = ths;
	this.updateTheme();
    },

    updateTheme: function() {
	console.debug( "UPDATING THEME" );
	var numrows = this._data.timesteps.length;
	this._colorDataAccessor = this._colorAccessors[ this.colorDataAccessor ];
	
	for ( i = 0; i < numrows; ++i ) {
	    // iind is used to flip the diagram so time increases going up
	    var iind = numrows-1-i;
	    for ( j = 0; j < this._data.sections.length; ++j ) {
		this._td[i][j].style.backgroundColor = this._colorDataAccessor(iind,j);
	    }
	}
    },

    _clear: function()
    {
	// Remove any existing table in the widget's dom node
	if ( this.domNode.hasChildNodes() )
	{
	    while ( this.domNode.childNodes.length >= 1 )
	    {
		this.domNode.removeChild( this.domNode.firstChild );       
	    } 
	}
    },

    _displayLoading: function()
    {
	this._clear();
	this.domNode.appendChild
	( dojo.create( "span", 
		       { id: "loadingAnalysisDiv",
			 class: "dijitContentPaneLoading",
			 innerHTML: "Loading..."
		       } ) );
    },

    _displayNoAnalysis: function()
    {
	this._clear();
	var url = 'http://localhost/redmine/projects/tmcpe/issues/new?tracker_id=3&issue[subject]=Perform%20analysis%20of%20Incident ' + this.incident + '&issue[description]=No%20analysis%20is%20available%20for%20incident ' + this.incident + '.  Need to explore why this is not in the database.';
	this.domNode.appendChild
	( dojo.create( "div",
		       { id: "noAnalysisDiv",
			 style: "padding-top: 3em; text-align:center; font-weight:bold; color:red; width:100%;",
			 innerHTML: 'No analyses of this incident has been performed.<p><a href="'+url+'" onclick="return popitup("'+url+'")">Click here to request support in finding out why.</a></p>'
		       } ) );
    },

    toggleIncidentWindow: function(toggle)
    {
	this._incidentTableNode.style.visibility = ( toggle ? 'visible' : 'hidden' );
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
	this._clear();

	// destroy existing
	if ( this._tableNodeContainer ) {
	    this._tableNodeContainer.parentNode.removeChild( this._tableNodeContainer );
	    delete this._tableNodeContainer;
	    if ( this._tableNode ) delete this._tableNode;
	}

	// Create the container
	this._tableNodeContainer = 
	    dojo.create( "div", { id: "tsdTableNodeContainer", 
				  style: "padding:0px;margin:0px;spacing:0px;width:100%;position:relative;" 
				} );
	this.domNode.appendChild( this._tableNodeContainer );


	// Now create the table element  
	// FIXME: Some of the styling is hardcoded here.  Really should move it into a css file
	
	this._tableNode = 
	    dojo.create( "table", 
			 { id: "tsdTableNode", 
			   ref: [this.incident, this.facility, this.direction].join('-'), 
			   style: "border-width:1px;border-color:#000000;cellpadding:0px;cellspacing:0px;border-collapse:collapse;width:100%;height:100%;z-index:1;"
			 }
		       );
	this._tableNodeContainer.appendChild( this._tableNode );

	this._incidentTableNode = 
	    dojo.create( "table", 
			 { id: "tsdTableNode", 
			   ref: [this.incident, this.facility, this.direction].join('-'), 
			   style: "position:absolute;top:0;left:0;border-width:1px;border-color:#000000;cellpadding:0px;cellspacing:0px;border-collapse:collapse;width:100%;height:100%;z-index:2;"
			 }
		       );
	this._tableNodeContainer.appendChild( this._incidentTableNode );

	// tt is a local shorthand variable for working with the table node (makes the code cleaner)
	var tt = this._tableNode;
	var itn = this._incidentTableNode;

	// delete all rows (if they exist---I think this might not be necessary but it's inexpensive)
	if ( tt.rows != null ) {
	    for(var i = tt.rows.length; i > 0;i--)
	    {
		tt.deleteRow(i -1);
		itn.deleteRow(i -1);
	    }
	}

	// d is a local shorthand variable for accessing the traffic data
	var d = this._data;

	if ( !d ) {
	    console.debug( "Can't redraw time-space diagram because there's no data!" );
	    return;
	}


	// The numrows is the number of timesteps.  Pull this from the d.timesteps array
	var numrows = d.timesteps.length;
	//console.debug( "NUMROWS IS " + numrows );
	this._numTimeRows = numrows;

	// FIXME: Similarly here, I'm getting the number of freeway
	// segments (columns) to plot and computing the total length
	// of the section.  Standardization required
	var totlen = 0;
	var incloc=0;
	for ( j = 0; j < d.sections.length; ++j )
	{
	    if ( this._data.location.id == d.sections[j].vdsid ) {
		incloc = totlen + d.sections[j].seglen/2;
	    }
	    totlen += ( d.sections[j].seglen );
	}
	if ( totlen < 0 ) totlen = -totlen;

	//console.debug( "TOTAL SECTIONS IS " + d.sections.length );
	//console.debug( "TOTAL SECTIONS LENGTH IS " + totlen );
	

	// I size the rows and columns using percentages in the CSS
	// styling.  Here we compute the height of the rows (all
	// assumed to be the same because we assume a single time
	// step) as a percentage of the total height of the TSD widget
	var height = 100.0/(numrows);

	// Create the arrays for holding the row and cell data
	this._tr = new Array(numrows);
	this._td = new Array(numrows);
	this._itr = new Array(numrows);
	this._itd = new Array(numrows);

	for ( i = 0; i < numrows; ++i )
	{
	    //console.debug( "ROW " + i );
	    // iind is used to flip the diagram so time increases going up
	    var iind = numrows-1-i;

	    // add the next row to the table
	    var tr = tt.appendChild( dojo.create( "tr", {timeidx: i, time: iind, style: "height:" + height + "%;" } ) );
	    var itr = itn.appendChild( dojo.create( "tr", {timeidx: i, time: iind, style: "height:" + height + "%;visibility:inherit;" } ) );
	    this._tr[i] = tr;
	    this._itr[i] = itr;

	    // Now loop and create the table cells
	    this._td[i] = new Array( d.sections.length );
	    this._itd[i] = new Array( d.sections.length );
	    //console.debug( "this._td[i].length = " + this._td[i].length );
	    for ( jind = 0; jind < d.sections.length; ++jind )
	    {
		var j = (d.sections.length-jind-1);
		//console.debug( i + " < " + numrows + ", " + j + " < " + d.sections.length + " ::: " + iind);

		// The width of the cell is proportional to its actual length in the real world
		var width = 100 * (d.sections[j].seglen)/totlen;
		if ( width < 0 ) width = -width;
		//console.debug( "width = " + width );
		//console.debug( "OBJ: " + d.sections[j].analyzedTimesteps[iind] );

		// compute borders---This is specific to display the extent of an incident
		var borders = "";
		var targ = d.sections[j].analyzedTimesteps[iind];

		// left = downstream
		if ( j < (d.sections.length-1) ) {
		    var ds = d.sections[j+1].analyzedTimesteps[iind];
		    if ( ds && targ.inc != ds.inc ) {
			borders += "border-left-width:3px;border-left-style:solid;border-left-color:cyan;";
		    }
		}
		// right = upstream
		if ( j >0 ) {
		    var us = d.sections[j-1].analyzedTimesteps[iind]
		    if ( us && targ.inc != us.inc )
		    {
			borders += "border-right-width:3px;border-right-style:solid;border-right-color:cyan;";
		    }
		}
		// top = later
		if ( iind > 0 ) {
		    var later = d.sections[j].analyzedTimesteps[iind-1]
		    if ( later && targ.inc != later.inc )
		    {
			borders += "border-bottom-width:3px;border-bottom-style:solid;border-bottom-color:cyan;";
		    }
		}
		// bottom = earlier
		if ( iind < (d.sections.length-1) ) {
		    var earlier = d.sections[j].analyzedTimesteps[iind+1]
		    if ( earlier && targ.inc != earlier.inc )
		    {
			borders += "border-top-width:3px;border-top-style:solid;border-top-color:cyan;";
		    }
		}

		//console.debug( "d.sections["+j+"].stnidx = " + d.sections[j].stnidx );
		// Actually create the cell in the appropriate table row
		this._td[i][j] = tr.appendChild( dojo.create( "td", { 
		    id:["tsd",iind,j].join("_"), 
		    time: iind,
		    segment: j,
		    station: d.sections[j].stnidx,
		    innerHTML: ""/*i + "(" + iind + ")," + j*/, 
		    style: "width:" + width + "%;border-width:1px;border-color:gray;border-style:dotted;background-color:"+this._colorDataAccessor(iind,j)+";visibility:inherit;",
		} ) );
		var opacity = 0.6;
		if ( targ.inc != 0 ) opacity=0.0;
		this._itd[i][j] = itr.appendChild( dojo.create( "td", {
		    id:["itsd",iind,j].join("_"), 
		    time:iind,
		    segment: j,
		    station: d.sections[j].stnidx,
		    style: "width:" + width + "%;border-width:1px;border-color:gray;border-style:dotted;background-color:white;"+borders+";opacity:"+opacity+";visibility:inherit;",
		} ) );
		//console.debug( "this._td["+i+"]["+j+"] = " + this._td[i][j] );
	    }
	}

	// Insert vertical line for incident location
	var locpct = 100-(100*incloc/totlen);
	this._tableNodeContainer.appendChild( dojo.create( "div", { id: "incloc", style: "border-width:2px;border-color:#0000ff;background-color:#0000ff;width:2px;height:100%;position:absolute;top:0;left:"+locpct+"%;z-index:10;"}));

	// Now insert data for the activity log
	if ( logStoreJs ) {
	    var obj = this;
	    logStoreJs.fetch({
		queryObj: {id:"*"},
		onComplete: function(items,request) { obj.updateLogGUI(items,request) }
	    });
	}
    },

    updateLogGUI: function(items,request) {
	if ( items.length > 0 ) {
	    var st = Number(new Date(this._data.timesteps[0]));
	    var et = Number(new Date(this._data.timesteps[this._data.timesteps.length-1]));
	    var dur = et-st;
	    var i;
	    for ( i=0; i < items.length; ++i ) {
		var item=items[i];
		var dto=new Date(item.stampDateTime[0]);
		var dt = Number(dto);
//		var localOffset = dto.getTimezoneOffset() * 60000;
//		var localOffset = dto.getTimezoneOffset() * 60000;
//		dt += localOffset;
		var cur = dt-st;
		var frac = 100-100*(cur/dur);
		if ( frac < 0 ) console.log( "FRAC < 0" );
		if ( frac > 100 ) console.log( "FRAC > 100" );
		console.log( this._data.timesteps[0] + ":" + st + ":" + et + ":" + dur + ":" + item.stampDateTime[0] + ":" + cur + ":" + frac );
		this._tableNodeContainer.appendChild(dojo.create( "div", { id: "logit_"+item.id, class: "log_tsd_bar", style: "border-width:2px;border-color:#0000ff;background-color:#0000ff;width:100%;height:2px;position:absolute;top:"+frac+"%;left:0;visibility:hidden;z-index:10;"}));
	    }
	}
    },

    _loadData: function( url ){
	// summary:
	//		Grab the data from the network using an ajax call
	// description:
	//		This is currently too implementation specific.  
	//              Probably best to obtain the JSON outside the widget and simply
	//              pass it as an argument...
	if ( !url ) {
	    console.debug( "Bad analysis url " + url );
	    return;
	}
	console.debug( "LOADING " + url );

	var caller = this;
	
	//    jsProgress.update( {indeterminate: true} );

	// Make a synchronous call to get the incident data (which
	// contains the speed/etc data that this widget will plot
	dojo.xhrGet({
	    url:			url,
	    preventCache:	true,
	    handleAs:		"text",
	    sync: true, //false,
	    load: function( r ) {
		caller._loadObjects( r );
	    },
	    error: function(r){ 
		console.debug( r );
		this._data = [];
	    }
	});


	// Do some processing on the data we obtained above.
	// Specifically: compute some information about the stretch of
	// freeway being plotted.  FIXME: the station data should
	// probably come in the same JSON call as the speed data.
	var data = this._data;

	var sections = data.sections;

	if ( !data || !sections ) { 
	    console.debug( "NO DATA AVAILABLE...SKIPPING TSD!" );
	    return; 
	}

	for ( j = 0; j < sections.length; ++j )
	{
	    data.sections[j].stnidx = j;
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
