var doQueryMap = function( data, parent ) {

    var theight = 500;

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

    var theData;
    var allTheData;

    var boundedScale = function( dom, ran ) {
	var dommin = dom[0];
	var dommax = dom[dom.length-1];
	return function( val ) {
	    var vv = Math.max( Math.min( val, dommax ), dommin );
	    var scale;
	    if ( dom.length == 2 ) {
		scale = pv.Scale.linear(dom[0], dom[1] ).range(ran[0], ran[1]);
	    } else if ( dom.length == 3 ) {
		scale = pv.Scale.linear(dom[0], dom[1], dom[2] ).range(ran[0], ran[1], ran[2]);
	    } else {
		scale = pv.Scale.linear(dom).range(ran);
	    }
	    return scale( val );
	}
    }

    d3.json("/tmcpe/incident/list.geojson"
//	    +"?startDate=2010-01-01"
	    +"?startDate=2010-09-01"
	    +"&Analyzed=onlyAnalyzed"
	    +"&max=1000",
	    function(e) {
		var dd = $.map( e.features, function( f ) { return f.properties.tmcpe_delay; } );
		var fmin = Array.min(dd);
		var fmax = Array.max(dd);
//		var color = pv.Scale.linear(fmin,(fmax-fmin)/2,fmax).range("green","yellow","red");
		var color = boundedScale( [100, 600, 1100], [ "#00ff00", "#ffff00", "#ff0000" ] );
//		var color = boundedScale( [100, 600, 1100], [ "rgba(0,255,0,128)", "rgba(255,255,0,128)", "rgba(255,0,0,128)" ] );

		theData = e.features;
		allTheData = e.features;

		incs = po.geoJson()
		    .tile(true)
		    .features(theData)
		    .id("incidents")
		    .zoom( 13 )
		    .on("load",function(a,b,c) {
			$("#incidents circle").click( function(d) { return incidentClicked( d.currentTarget.cad ) } );
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

		map.on("move",function(d){
//			d3.selectAll("#incidents circle")
//			.append("div")
//			.data(e.features)
//			.on("click", incidentClicked )
		    $("#incidents circle").click( function ( el ) { 
			var cad = el.currentTarget.getAttribute("cad");
			incidentClicked( cad ); } );
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
		var fields = [ "cad", "timestamp", "locString", "memo", "d12_delay", "tmcpe_delay", "savings" ];
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
		    .attr("class",function(d,i){ return "search_init"; } );

		head.append("tr").selectAll("th").data(fields).enter()
		    .append("th")
		    .attr("class","bottom-head")
		    .text(function(d){return d;});
		

		// Use D3 magic to create rows for each incident
		var rows = body.selectAll("tr")
		    .data(theData,function(d) { return d.cad })
		    .enter().append("tr")
		    .attr("id", function( d ) { 
			return d.id 
		    } )
		    .attr("cad", function( d ) { 
			return d.cad
		    } )
		    .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
		    .attr("style", function(d,i) { 
			return "background-color:"+color(d.properties.tmcpe_delay).color/*+";opacity:0.5"*/; })
		    .on("click",function(d,e) { 
			if ( !featureVisible(d) ) centerOnIncident( d );
			incidentClicked( d.cad );
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


		$("thead input").keyup( function () {

		    var newFeatures = theData;
		    $("thead input").each(function(ee,ii) {
			if (/search_init/.test(this.className) ) return;
			var input = this;
			var name = input.name.replace("search_","");
			var patt = new RegExp(input.value,"i");
			newFeatures = $.grep(newFeatures,function(eee,iii){
			    return patt.test(eee.properties[name]);
			});
		    });

		    // var input = this;
		    // var name = input.name.replace("search_","");
		    // var patt = new RegExp(input.value,"i");
		    // var currentData = body.selectAll("tr").filter(function(ee,ii){
		    // 	return patt.test(ee.properties[name]);
		    // });

		    var rr = body.selectAll("tr").data(newFeatures,function(d) { return d.cad } );

		    // enter, adding new tr elements for new data.
		    rr.enter().append("tr")
			.attr("id", function( d ) { 
			    return d.id 
			} )
			.attr("cad", function( d ) { 
			    return d.cad
			} )
			.attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
			.attr("style", function(d,i) { 
			    return "background-color:"+color(d.properties.tmcpe_delay).color; })
			.on("click",function(d,e) { 
			    if ( !featureVisible(d) ) centerOnIncident( d );
			    incidentClicked( d.cad );
			} )
			.selectAll("td")
			.data(function(d) {
			    // extract properties
			    var props = [];
			    $.each( fields, function(i, val ) {
				props.push( d.properties[val] );
			    });
			    return props;
			} )
			.enter().append("td")
			.attr("class",function(d) { return d; })
			.text( function (dd) { 
			    return dd } );

		    // update, reseting the odd/even columns
		    rr.attr("class", function(d,i) {
			    var cc = this.className;
			    cc = cc.replace(/\s*(even|odd)/ig,"");
			    cc += i % 2 ? " even" : " odd"; 
			    return cc;
			} );

		    // exit, removing items that have been filtered
		    rr.exit().remove();

		    // resort
		    $("#inctable").tablesorter( ).bind("sortEnd",function(){
			// reset odd/even colors
			var rr = body.selectAll("tr")
			    .attr("class", function(d,i) {
				var cc = this.className;
				cc = cc.replace(/\s*(even|odd)/ig,"");
				cc += i % 2 ? " even" : " odd"; 
				return cc;
			    } );
		    }); 
		    
//		    $("#inctable").tableScroll({height:400});

		    // Now had all the filtered cicles in the SVG
                    d3.selectAll("#incidents circle").attr("class","hidden");
                    $.each( newFeatures, function( i, d ) { 
                        d3.selectAll('#incidents circle[cad="'+d.cad+'"]').attr("class","");
                    });
		    
		});

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

		
		$("#inctable").tablesorter( ).bind("sortEnd",function(){
		    // reset odd/even colors
		    var rr = body.selectAll("tr")
			.attr("class", function(d,i) {
			    var cc = this.className;
			    cc = cc.replace(/\s*(even|odd)/ig,"");
			    cc += i % 2 ? " even" : " odd"; 
			    return cc;
			} );
		}); 

		$("#inctable").tableScroll({height:400});

	    });

    function incidentClicked( d, e, f ) {
	// restyle row
	d3.selectAll("#inctable tr.selected").attr("class",function() { 
	    var ret =  this.className.replace(/\s*\bselected\b/i,""); // remove selected
	    return ret;
	});
	d3.selectAll("#inctable tr[cad='"+d+"']").attr("class",function (dd,e) { 
	    // ugh, highlight the incident in the map too
	    raiseIncident( dd );
	    highlightIncident( dd );
	    // ugh, and update the info
	    updateIncidentInfo( dd );

	    return this.className+" selected";
	} );

	//scrollIncidentTableToItem( el );
    }

    function removeClass( d ) {
	var classes = d.attr("class");
	classes.replace("\b"+d+"\b","");
    }

    function highlightIncidentRow( d ) {
	d3.selectAll('#inctable tr.selected').attr("class",function() { 
	    return "";
	});
	d3.selectAll('#inctable tr[id="'+d.id+'"]').attr("class","selected");
    }

    function scrollIncidentTableToItem( d ) {
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
	d3.selectAll('#incidents circle.selected').attr( "class", function (d) { 
	    var ret = this.className.baseVal.replace(/\s*\bselected\b/i,""); // remove selected
	    return ret;
	});
	d3.selectAll("#incidents circle[cad='"+d.cad+"']").attr("class",function (dd,e) { 
	    return this.className.baseVal+" selected";
	});
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
	var props = ["cad","timestamp","locString","memo","d12_delay","tmcpe_delay","savings","analysisCount"];
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