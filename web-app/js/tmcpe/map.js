var doQueryMap = function( data, parent ) {

    var theight = 500;
    var tt; // the main incident table

    var po = org.polymaps;

    var svg = d3.select("#map")
	.append("svg:svg")
	.attr("id","mapsvg")
	.attr("height",theight)[0][0];

    var map = po.map()
	.container(svg)
	.center({lat: 33.739, lon: -117.830})
	.zoom(13)
	.zoomRange([1,/*6*/, 18])
	.add(po.interact());

    map.add(po.image()
	    .url(po.url("http://{S}tile.openstreetmap.org"
			+ "/{Z}/{X}/{Y}.png")
		 .hosts(["a.", "b.", "c.", ""])))
	.add(po.compass()
	     .pan("none"))
	.add(po.hash());


    var asInitVals = new Array();


    Array.max = function( array ){
	return Math.max.apply( Math, array );
    };
    Array.min = function( array ){
	return Math.min.apply( Math, array );
    };

    var incs;

    d3.json("/tmcpe/incident/list.geojson"
	    +"?startDate=2010-10-01"
	    +"&Analyzed=onlyAnalyzed"
	    +"&max=1000",
	    function(e) {
		var dd = $.map( e.features, function( f ) { return f.properties.tmcpe_delay; } );
		var fmin = Array.min(dd);
		var fmax = Array.max(dd);
		var color = pv.Scale.linear(fmin,(fmax-fmin)/2,fmax).range("green","yellow","red");

		incs = po.geoJson()
		    .tile(true)
		    .features(e.features)
		    .id("incidents")
		    .zoom( 13 )
		    .on("load",function(a,b,c) {
			$("#incidents circle").click( incidentClicked );
//			d3.selectAll("#incidents circle")
//			    .data(e.features)
//			    .on("click", incidentClicked )
		    })
		    .on("load", po.stylist()
			.attr("id", function( d ) { return d.id; } )
			.attr("cad", function( d ) { return d.cad; } )
			.attr("r", function( d ) { 
//			    var z = map.zoom();
//			    var r =  Math.pow(2, Math.max(18-z,0)) * 0.5;
			    return 25;
			})
			.attr("fill",function(d) { 
			    var cc = color(d.properties.tmcpe_delay).color;
			    return cc;
			})
			.attr("stroke",function(d) { 
			    var cc = color(d.properties.tmcpe_delay).color;
			    return cc;
			})
		       );
		map.add(incs);

		map.add(incs)
		    .on("move",function(d){
//			d3.selectAll("#incidents circle")
//			    .data(e.features)
//			    .on("click", incidentClicked )
			$("#incidents circle").click( function ( d ) { 
			    incidentClicked( d.currentTarget ); } );
		    });

		function RenderDecimalNumber(oObj,oCustomInfo) {	
		    var num = new NumberFormat();
		    num.setInputDecimal('.');
		    num.setNumber(oObj.aData[oObj.iDataColumn]); 
		    num.setPlaces(oCustomInfo.decimalPlaces, true);	
		    num.setCurrency(false);	
		    num.setNegativeFormat(num.LEFT_DASH);	
		    num.setSeparators(true, oCustomInfo.decimalSeparator, oCustomInfo.thousandSeparator);

		    return num.toFormatted();
		}

		function RenderIncidentTimestamp(obj) {
		    dd = new Date( obj.aData[2] );
		    return $.format.date(dd,'EEE yyyy-MM-dd kk:mm:ss');
		};

		


		// construct table of incident data using the given fields...
		var fields = [ "id", "cad", "timestamp", "locString", "memo", "d12_delay", "tmcpe_delay", "savings" ];
		var settings =  [ {sType:"numeric",sWidth:'20px'},
				  {sType:"string",bSortable:true}, 
				  {sClass:"datefield mono",sType:"date",bSortable:true,
				   fnRender: RenderIncidentTimestamp},
				  {sClass:"locstring", sType:"string"},
				  {sType:"string"},
				  {sClass:"numeric",sType:"numeric",bSortable:true, fnRender: function (oDt) { return RenderDecimalNumber( oDt, {"decimalPlaces":0,"thousandSeparator":",","decimalSeparator":"."} ); }},
				  {sClass:"numeric",sType:"numeric",bSortable:true, fnRender: function (oDt) { return RenderDecimalNumber( oDt, {"decimalPlaces":0,"thousandSeparator":",","decimalSeparator":"."} ); }},
				  {sClass:"numeric",sType:"numeric",bSortable:true, fnRender: function (oDt) { return RenderDecimalNumber( oDt, {"decimalPlaces":0,"thousandSeparator":",","decimalSeparator":"."} ); }}
				];
		var tab = d3.select("#incidentListTablebox")
		    .append("table")
		    .attr("id", "inctable" );

		// make the header
		var head = tab.append("thead")

		// now the body
		var body = tab.append("tbody");

		var foot = tab.append("tfoot");
		foot.append("tr").selectAll("th").data(fields).enter()
		    .append("th")
		    .attr("class","top-foot")
		    .text(function(d){return d;});

		// add a header row with search columns
		head.append("tr").selectAll("td").data(fields).enter()
		    .append("td")
		    .append("input")
		    .attr("type","text")
		    .attr("name",function(d,i){ return "search_"+d; })
		    .attr("value",function(d,i){ return "Search "+d; })
		    // append the classes from the settings object
		    .attr("class",function(d,i){ ["search_init",settings[i].sClass].join(" ") } );

		head.append("tr").selectAll("th").data(fields).enter()
		    .append("th")
		    .attr("class","bottom-head")
		    .text(function(d){return d;});
		

		$("thead input").keyup( function () {
		    /* Filter on the column (the index) of this element */
		    if ( tt ) 
			tt.fnFilter( this.value, $("thead input").index(this),true,false );
		} );

		/*
		 * Support functions to provide a little bit of 'user friendlyness' to the textboxes in 
		 * the footer
		 */
		$("thead input").each( function (i) {
		    asInitVals[i] = this.value;
		} );
		
		$("thead input").focus( function () {
		    if ( this.className == "search_init" )
		    {
			this.className = "";
			this.value = "";
		    }
		} );
		
		$("thead input").blur( function (i) {
		    if ( this.value == "" )
		    {
			this.className = "search_init";
			this.value = asInitVals[$("thead input").index(this)];
		    }
		} );


		// Use D3 magic to create rows for each incident
		var ii = incs.features();
		var rows = body.selectAll("tr")
		    .data(ii)
		    .enter().append("tr")
		    .attr("id", function( d ) { 
			return d.id 
		    } )
		    .on("click",function(d,e) { 
			if ( !featureVisible(d) ) centerOnIncident( d );
//			raiseIncident( d );
//			highlightIncident( d ); 
//			updateIncidentInfo( d );
			incidentClicked( d );
		    } );

		// Now populate each row with the relevant data
		rows.selectAll("td")
		    .data(function(d) {
			// extract properties
			var props = [];
			$.each( fields, function(i, val ) {
			    props.push( d.properties[val] );
			});
			return props;
		    } )
		    .enter().append("td")
		    .text( function (dd) { 
			return dd } );

		// datatables plugin function to allow callbacks to get filtered
		// data
		$.fn.dataTableExt.oApi.fnGetFilteredData = function ( oSettings ) {
		    var a = [];
		    for ( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ ) {
			a.push(oSettings.aoData[ oSettings.aiDisplay[i] ]._aData);
		    }
		    return a;
		}

		$.fn.dataTableExt.oApi.fnDisplayRow = function ( oSettings, nRow )
		{
		    var iPos = -1;
		    for( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ )
		    {
			if( oSettings.aoData[ oSettings.aiDisplay[i] ].nTr == nRow )
			{
			    iPos = i;
			    break;
			}
		    }
		    
		    if( iPos >= 0 )
		    {
			oSettings._iDisplayStart = ( Math.floor(i / oSettings._iDisplayLength) ) * oSettings._iDisplayLength;
			this.oApi._fnCalculateEnd( oSettings );
		    }
		    
		    this.oApi._fnDraw( oSettings );
		}

		tt = $("#inctable").dataTable(
		    {"aaSorting":[[1,"desc"]],  // selects date
		     "oSearch":{"sSearch":"","bRegex":true, "bSmart":false},
		     "aoColumns":settings,
		     "sDom":'<"top"lf><"info"pi"><"tabletable"rt><"clear">',
		     "fnInfoCallback": function( oSettings, iStart, iEnd, iMax, iTotal, sPre ) {
			 // filtering complete, hide filtered data on map
			 if ( tt ) {
			     var visible = tt.fnGetFilteredData();
			     d3.selectAll("#incidents circle").attr("class","hidden");
			     $.each( visible, function( i, d ) { 
				 // NOTE: d[1] corresponds to the "CAD" item
				 d3.selectAll('#incidents circle[cad="'+d[1]+'"]').attr("class","");
			     });
			 }
			 return " items "+iStart+" to "+iEnd+" of "+iTotal+" (with "+(iMax-iTotal)+ " filtered)";
		     }
		    }
		);


		// rows.append("td").text(function(d){return d.cad;});
		// rows.append("td").text(function(d){
		//     return d.timestamp;});
		// rows.append("td").text(function(d){
		//     return d.locString;});
		// rows.append("td").text(function(d){
		//     return d.memo;});

	    });

    function incidentClicked( d, e, f ) {
	//updateIncidentInfo( d );
//	if ( !d ) 
//	    d = ff[e];
//	var dd = d.currentTarget;
	raiseIncident( d );
	highlightIncident( d );
	highlightIncidentRow( d );
	scrollIncidentTableToItem( d );
	updateIncidentInfo( d )
    }

    function highlightIncidentRow( d ) {
//	d3.selectAll('#inctable tr.selected').attr("class",'selected');
	var data = tt.fnGetData();
	


//	d3.selectAll('#inctable tr[id="'+d.id+'"]').attr("class","selected");
    }

    function scrollIncidentTableToItem( d ) {
	var data = tt.fnGetData();
	var it;
	for ( it = 0; it < data.length && data[it][0] != d.id; ++it );
	var pos = it;

	/* Example use */
	/*
	  var oTable;
	  $(document).ready(function() {
	  oTable = $('#example').dataTable();
	  oTable.fnDisplayRow( oTable.fnGetNodes()[20] );
	  } );
	*/
	tt.fnDisplayRow( tt.fnGetNodes()[pos] );
    }

    function featureVisible( d ) {
	var c = d.geometry.coordinates;
	var ext = map.extent();
	var vis = ( c[0] >= Math.min( ext[0].lon, ext[1].lon )
		    && c[0] <= Math.max( ext[0].lon, ext[1].lon )
		    && c[1] >= Math.min( ext[0].lat, ext[1].lat )
		    && c[1] <= Math.max( ext[0].lat, ext[1].lat ) );
	return vis;
    }

    function centerOnIncident( d ) {
	map.center( {lon:d.geometry.coordinates[0],lat:d.geometry.coordinates[1]} );
    }

    function raiseIncident( d ) {
	// In SVG, the z-index is the element's index in the dom.  To raise an
	// element, just detach it from the dom and append it back to its parent
	var targets = $("circle[id="+d.id+"]");
	var target = targets[0];
	var parent = target.parentElement;
	targets.detach().appendTo( parent );
    }

    function highlightIncident( d, e ) {
	d3.selectAll('#incidents circle').attr( "class", "" );
	d3.selectAll("#incidents circle[id='"+d.id+"']").attr("class","selected");
    }

    function updateIncidentInfo( d, e ) {
	// Update the title
	if ( d.id ) {
	    $('#incidentTitle').html( 'Incident <a href="/tmcpe/incident/d3_tsd?id=' + d.id + '">' + d.id + '</a>' );
	} else {
	    $('#incidentTitle').html( 'Incident <a href="/tmcpe/incident/d3_tsd?id=' + d.cad + '">' + d.cad + '</a>' );
	}

	// Remove the existing table (if any)
	$('#incidentDetailTablebox table').remove();

	// create a new one
	var tab = d3.select("#incidentDetailTablebox")
	    .append("table")
	    .attr("id", "incdetail");

	var body = tab.append("tbody");
	var props = ["id","cad","timestamp","locString","memo","d12_delay","tmcpe_delay","savings","analysisCount"];
	var data = $.map( props, function(e,i) { return [ [ e,d.properties[e] ] ] } );
	var rows = body.selectAll("tr")
	    .data(data)
	    .enter().append("tr");
	
	rows.selectAll("td")
	    .data(function(dd) { 
		return dd; })
	    .enter().append("td")
	    .text( function(dd) { 
		return dd; } );

	
    }
}