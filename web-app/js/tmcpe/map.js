
if ( !tmcpe ) var tmcpe = {};

(function()
 {tmcpe.version = "0.1";
  tmcpe.query = {};
  

  function boundedScale( dom, ran ) {
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

  function color( ff ) {
      var colorPV = boundedScale( [0, 400, 800], [ "#00ff00", "#ffff00", "#ff0000" ] );
      return function( v ) {
	  var col = colorPV( v ).color;
	  var rgb = pv.color(col).rgb();
	  var rcol = pv.rgb( rgb.r < ff ? ff : rgb.r,
			     rgb.g < ff ? ff : rgb.g,
			     rgb.b < ff ? ff : rgb.b );
	  return rcol.color;
      }
  }

  tmcpe.query.qmap = function() {
      var qmap = {},
      container,
      theight,// = $(container).height()-2,
      twidth,// = $(container).height()-2,
      theData,
      allTheData,
      map,
      table,
      size,

      po = org.polymaps;

      tmcpe.svg = function(type) {
	  return document.createElementNS(tmcpe.ns.svg, type);
      };

      qmap.container = function(x) {
	  if (!arguments.length) return container;
	  container = x;
	  container.setAttribute("class", "map");
//	  container.appendChild(rect);
	  return qmap.resize(); // infer size
	  //return qmap;
      }

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      qmap.resize = function() {
	  if (!size) {
	      rect.setAttribute("width", "100%");
	      rect.setAttribute("height", "100%");
	      b = rect.getBBox();
	      sizeActual = {x: b.width, y: b.height};
	      //resizer.add(map);
	  } else {
	      sizeActual = size;
	      //resizer.remove(map);
	  }
	  rect.setAttribute("width", sizeActual.x);
	  rect.setAttribute("height", sizeActual.y);
	  return qmap;
      };

      qmap.data = function(x) {
	  if ( !arguments.length ) return theData;
	  theData = x;
	  qmap.redraw();
	  return qmap;
      }

      qmap.hh = function() { return $(container).height()-2; };
      qmap.ww = function() { return $(container).width()-2; };


/*
      qmap.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  return qmap;
      }
*/

      qmap.table = function(x) {
	  if ( !arguments.length ) return table;
	  table = x;
	  return qmap;
      }

      qmap.redraw = function() {
	  if ( container ) $(container).children().remove();
	  create();
	  addImageLayer();
	  qmap.render();
	  return qmap;
      }


      function create() {

	  // create the map
	  var svg = d3.select(container)
	      .append("svg:svg")
	      .attr("id","qmapsvg")
	      .attr("height",qmap.hh())
	      .attr("width",qmap.ww())[0][0];

	  map = po.map()
	      .container(svg)
	      .zoom(13)
	      .zoomRange([1,/*6*/, 18])
	      .add(po.interact())
	      .center({lat: 33.739, lon: -117.830})
//	      .add(po.hash())
	  ;

	  qmap.map = map;

	  return qmap;
      }
      
      function addImageLayer() {

	  map.add(po.image()
		  .url(po.url("http://{S}tile.openstreetmap.org"
			      + "/{Z}/{X}/{Y}.png")
		       .hosts(["a.", "b.", "c.", ""])));
	  map.add(po.compass()
		  .pan("none"));

	  return qmap;
      }

      qmap.render = function() {
	  allTheData = qmap.data();
	  var dd = $.map( allTheData, function( f ) { return f.properties.tmcpe_delay; } );
	  var fmin = Array.min(dd);
	  var fmax = Array.max(dd);
	  
	  incs = po.geoJson()
	      .tile(true)
	      .features(theData)
	      .id("incidents")
	      .zoom( 13 )
	      .on("load",function(a,b,c) {
		  $("#incidents circle").click( function(d) { 
		      return table.incidentClicked( d.currentTarget.cad ) } );
		  //			d3.selectAll("#incidents circle")
		  //			    .data(e.features)
		  //			    .on("click", incidentClicked )
	      })
	      .on("load", /*loadFeatures*/
		  po.stylist()
		  .attr("id", function( d ) { return d.id; } )
		  .attr("cad", function( d ) { return d.cad; } )
		  .attr("r", function( d ) { 
		      //			    var z = map.zoom();
		      //			    var r =  Math.pow(2, Math.max(18-z,0)) * 0.5;
		      return 25;
		  })
		  .attr("fill",function(d) { 
		      var cc = color(0)(d.properties.tmcpe_delay);
		      return cc;
		  })
		  .attr("stroke",function(d) { 
		      var cc = color(0)(d.properties.tmcpe_delay);
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
			table.incidentClicked( cad ); } );
		});

      }

      return qmap;
  }

  tmcpe.query.table = function() {
      var qtable = {},
      container,
      tab,
      thedata,
      map,
      fields = [ {key:"cad",title:"CAD"}, 
		 {key:"timestamp",title:"Time",render:renderIncidentTimestamp}, 
		 {key:"locString",title:"Location"}, 
		 {key:"memo",title:"Description"}, 
		 {key:"d12_delay",title:"D<sub>d12</sub>",render:renderDecimalNumber}, 
		 {key:"tmcpe_delay",title:"D<sub>tmcpe</sub>",render:renderDecimalNumber}, 
		 {key:"savings",title:"Savings",render:renderDecimalNumber} ];

      qtable.incidentClicked = function( d, e, f ) {
	  // restyle row
	  d3.selectAll("#inctable tr.selected").attr("class",function() { 
	      var ret =  this.className.replace(/\s*\bselected\b/i,""); // remove selected
	      return ret;
	  }).attr( "style", function(d,i) { 
	      return "background-color:"+color(160)(d.properties.tmcpe_delay); 
	  })

	  d3.selectAll("#inctable tr[cad='"+d+"']")
	      .attr("class",function (dd,e) { 
		  // ugh, highlight the incident in the map too
		  raiseIncident( dd );
		  highlightIncident( dd );
		  // ugh, and update the info
		  updateIncidentInfo( dd );
		  scrollIncidentTableToItem( dd,e,this );
		  
		  return this.className+" selected";
	      } )
	      .attr( "style", function(d,i) { 
		  return "background-color:"+color(0)(d.properties.tmcpe_delay); 
	      });

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

      function scrollIncidentTableToItem( d,e,t ) {
	  var p = $('#inctable').parent();
	  var st = p.scrollTop();
	  if ( st > t.offsetTop
	       || st+400 < t.offsetTop ) {
	      p.scrollTop(t.offsetTop);
	  }
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
	  var parent = target.parentNode;
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
	  if ( d.cad ) {
	      $('#incidentTitle').html( 'Incident <a href="incident/d3_tsd?id=' + d.id + '">' + d.cad + '</a>' );
	  } else {
	      $('#incidentTitle').html( 'Incident <a href="incident/d3_tsd?id=' + d.id + '">' + d.id + '</a>' );
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

	  // update the background color
	  d3.select("#infobox").attr("style","background-color:"+color(220)(d.properties.tmcpe_delay)); 
	  
      }


      qtable.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  return qtable;
      }

      qtable.map = function(x) {
	  if ( !arguments.length ) return map;
	  map = x;
	  return qtable;
      }

      qtable.data = function(x) {
	  if ( !arguments.length ) return thedata;
	  thedata = x;
	  qtable.redraw();
	  return qtable;
      }

      qtable.redraw = function() {
	  if ( container ) $(container).children().remove();

	  tab = d3.select(container)
	      .append("table")
	      .attr("id", "inctable" );

	  // make the header
	  var head = tab.append("thead")
	  
	  // now the body
	  var body = tab.append("tbody");
	  
	  var foot = tab.append("tfoot");
	  
	  // add a header row with search columns
	  head.append("tr").selectAll("td").data(fields).enter()
	      .append("td")
	      .append("input")
	      .attr("type","text")
	      .attr("name",function(d,i){ return "search_"+d.key; })
	      .attr("value",function(d,i){ return "Search "+d.key; })
	  // append the classes from the settings object
	      .attr("class",function(d,i){ return "search_init"; } );

	  /*
	    head.selectAll("tr th").append("p")
	    .attr("class",function(d){return d;})
	    .text(function(d){ return d;});
	  */
	  head.append("tr").selectAll("th").data(fields).enter()
	      .append("th")
	      .attr("class",function(d){return d.key;})
	      .html(function(d){return d.title ? d.title : d.key;});
	  
	  
	  

	  // Use D3 magic to create rows for each incident
	  var rows = body.selectAll("tr")
	      .data(thedata,function(d) { return d.cad })
	      .enter().append("tr")
	      .attr("id", function( d ) { 
		  return d.id 
	      } )
	      .attr("cad", function( d ) { 
		  return d.cad
	      } )
	      .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
	      .attr("style", function(d,i) { 
		  return "background-color:"+color(160)(d.properties.tmcpe_delay)/*+";opacity:0.5"*/; })
	      .on("click",function(d,e) { 
		  if ( !featureVisible(d) ) centerOnIncident( d );
		  qtable.incidentClicked( d.cad );
	      } );


	  // Now populate each row with the relevant data
	  rows.selectAll("td")
	      .data(function(d) {
		  // extract properties
		  var props = [];
		  $.each( fields, function(i, val ) {
		      var item = d.properties[val.key];
		      props.push( val.render ? val.render( item ) : item );
		  });
		  return props;
	      } )
	      .enter().append("td")
	      .attr("class", function(d,i) { return fields[ i ].key } )
	      .text( function (dd) { 
		  return dd;
	      } );


	  // sum and avg the data in the table
	  foot.append("tr").selectAll("td").data(fields)
	      .enter()
	      .append("td")
	      .attr( "class", function( d ) { return d.key + " summary_tot" } )
	      .html(function(d,i){
		  var tot = 0;
		  var cnt = 0;
		  $.each($("#inctable td."+d.key), function( index ) {
		      var val = parseFloat( this.innerText );
		      if ( !isNaN( val ) && this.innerText == ""+val+"" ) {
			  tot += val;
			  cnt ++;
		      }
		  });
		  var avg="n/a";
		  if  ( cnt > 0 ) { 
		      avg = (tot/cnt);
		      tot = d.render ? d.render( tot ) : tot;
		      avg = d.render ? d.render( avg ) : avg;
		      $(this).addClass("numeric");
		      return tot;
		  } else {
		      return "";
		  }
	      });
	  // sum and avg the data in the table
	  foot.append("tr").selectAll("td").data(fields)
	      .enter()
	      .append("td")
	      .attr( "class", function( d ) { return d.key + " summary_avg" } )
	      .html(function(d,i){
		  var tot = 0;
		  var cnt = 0;
		  $.each($("#inctable td."+d.key), function( index ) {
		      var val = parseFloat( this.innerText );
		      if ( !isNaN( val ) && this.innerText == ""+val+"" ) {
			  tot += val;
			  cnt ++;
		      }
		  });
		  var avg="n/a";
		  if  ( cnt > 0 ) { 
		      avg = (tot/cnt);
		      tot = d.render ? d.render( tot ) : tot;
		      avg = d.render ? d.render( avg ) : avg;
		      $(this).addClass("numeric");
		      return avg;
		  } else {
		      return "";
		  }
	      });



	  // Insert the sorting handler
	  $("thead input").keyup( function () {

	      // Now, apply all the active filters to the complete dataset
	      var newFeatures = thedata;
	      $("thead input").each(function(ee,ii) {
		  if (/search_init/.test(this.className) ) return;
		  var input = this;
		  var name = input.name.replace("search_","");
		  var patt = new RegExp(input.value,"i");
		  newFeatures = $.grep(newFeatures,function(eee,iii){
		      return patt.test(eee.properties[name]);
		  });
	      });

	      // At this point, newFeatures will contain only those
	      // features that match all filters.  Here, we update d3's
	      // data that are associated with the tr's for the table
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
		      return "background-color:"+color(160)(d.properties.tmcpe_delay); })
		  .on("click",function(d,e) { 
		      if ( !featureVisible(d) ) centerOnIncident( d );
		      qtable.incidentClicked( d.cad );
		  } )
		  .selectAll("td")
		  .data(function(d) {
		      // extract properties
		      var props = [];
		      $.each( fields, function(i, val ) {
			  var item = d.properties[val.key];
			  props.push( val.render ? val.render( item ) : item );
		      });
		      return props;
		  } )
		  .enter().append("td")
		  .attr("class",function(d,i) { 
		      var cc = this.className;
		      var key = fields[ i ].key;
		      return [cc,key].join(" "); 
		  })
		  .text( function (dd) { 
		      return dd } );

	      // update, reseting the odd/even columns
	      rr.attr("class", function(d,i) {
		  var cc = this.className;
		  cc = cc.replace(/\s*(even|odd)/ig,"");
		  cc += i % 2 ? " even" : " odd"; 
		  return cc;
	      } )
		  .selectAll("td")
		  .attr("class",function(d,i) { 
		      var cc = this.className;
		      var key = fields[ i ].key;
		      return [cc,key].join(" "); 
		  })
	      ;

	      // exit, removing items that have been filtered
	      rr.exit().remove();

	      // update totals
	      foot.selectAll("tr td.summary_tot")
		  .html(function(d,i){
		      var tot = 0;
		      var cnt = 0;
		      $.each($("#inctable td."+d.key), function( index ) {
			  var val = parseFloat( this.innerText );
			  if ( !isNaN( val ) && this.innerText == ""+val+"" ) {
			      tot += val;
			      cnt ++;
			  }
		      });
		      var avg="n/a";
		      if  ( cnt > 0 ) { 
			  avg = (tot/cnt);
			  tot = d.render ? d.render( tot ) : tot;
			  avg = d.render ? d.render( avg ) : avg;
			  $(this).addClass( "numeric" );
			  return tot;
		      } else {
			  return "";
		      }
		  });

	      foot.selectAll("tr td.summary_avg")
		  .html(function(d,i){
		      var tot = 0;
		      var cnt = 0;
		      $.each($("#inctable td."+d.key), function( index ) {
			  var val = parseFloat( this.innerText );
			  if ( !isNaN( val ) && this.innerText == ""+val+"" ) {
			      tot += val;
			      cnt ++;
			  }
		      });
		      var avg="n/a";
		      if  ( cnt > 0 ) { 
			  avg = (tot/cnt);
			  tot = d.render ? d.render( tot ) : tot;
			  avg = d.render ? d.render( avg ) : avg;
			  $(this).addClass( "numeric" );
			  return avg;
		      } else {
			  return "";
		      }
		  });

	      $("#inctable").trigger("update"); 

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
	  var asInitVals = new Array();

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

	  $("#inctable").dataTable({
	      bPaginate:false, sScrollY:"250px","bAutoWidth":false,
	      "aoColumns": [
		  { "sWidth": "15%", "sType": "string" }, // CAD
		  { "sWidth": "10%", "sType": "date" },   // timestamp
		  { "sWidth": "15%", "sType": "string" }, // location; implement custom type
		  { "sWidth": "30", "sType": "string" }, // description; implement custom type
		  { "sWidth": "10%", "sType": "numeric", "sClass":"numeric" }, // d12_delay; implement custom type
		  { "sWidth": "10%", "sType": "numeric", "sClass":"numeric" }, // tmcpe_delay; implement custom type
		  { "sWidth": "10%", "sType": "numeric", "sClass":"numeric" } // savings; implement custom type
	      ]});




	  return qtable;
      }

      function renderDecimalNumber(oObj,oCustomInfo) {	
/*
	  var num = new NumberFormat();
	  num.setInputDecimal('.');
	  num.setNumber(oObj); 
	  num.setPlaces(0, true);	
	  num.setCurrency(false);	
	  num.setNegativeFormat(num.LEFT_DASH);	
	  num.setSeparators(true, "", ".");

	  return num.toFormatted();
	  */
	  return (oObj != null ? oObj.toFixed(0) : oObj );
      }

      function renderIncidentTimestamp(obj) {
	  dd = new Date( obj );
	  return $.format.date(dd,'yyyy-MM-dd kk:mm');
      };

      

      return qtable;
  }
 })();
 
