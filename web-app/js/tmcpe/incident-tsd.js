if ( !tmcpe ) var tmcpe = {};

(function()
 {tmcpe.version = 0.1;
  
  Array.max = function( array ){
      return Math.max.apply( Math, array );
  };
  Array.min = function( array ){
      return Math.min.apply( Math, array );
  };
  
  tmcpe.util = {};

  tmcpe.util.getGRColor = function( val, min, max,  minval, midval, maxval ) {
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
      //var ret = "#"+[ tmcpe.util.toColorHex( r*255 ), tmcpe.util.toColorHex( g*255 ), tmcpe.util.toColorHex( b*255 ) ].join("");

      var color = pv.Scale.linear(0,0.5,1.0).range(minval,midval,maxval);
      
      return color( r ).color;
  };

  tmcpe.util.toColorHex = function( /* integer */ v ) {
      // summary:
      //		helper function to convert a decimal integer to a hexidecimal value
      var val = parseInt( v ).toString( 16 );
      if ( val.length < 2 ) val = '0' + val;
      return val;
  };

  tmcpe.util.color = function( d, trans, scale ) {
      // get colors from css
      var startColor = $('.dummy-tsd-speed-start-color').css('fill') || '#ff0000';
      var midColor   = $('.dummy-tsd-speed-mid-color').css('fill')   || '#ffff00';
      var endColor   = $('.dummy-tsd-speed-end-color').css('fill')   || '#00ff00';

      var col = "#ccc";
      trans = trans ? trans : function( dd ) { return (dd.spd-dd.spd_avg)/dd.spd_std };
      var themeScale=scale?scale:-1.0;
      if ( d != null && d.spd != null && d.spd_avg != null && d.spd_std != null 
	   && ( d.p_j_m == 0 || d.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	   //		 && d.days_in_avg < 30  // fixme: make this a parameter
	   //		 && d.pct_obs_avg < 30  // fixme: make this a parameter
	 ) {
	  col = tmcpe.util.getGRColor( trans( d ), 0, 1, startColor, midColor, endColor );
      }
      return col;
  };

  tmcpe.tsd = {};

  tmcpe.plottrajectory = function( d, i ) {
      
  }

  tmcpe.hh = function() { return $("#tsdbox").height()-2; };
  tmcpe.ww = function() { return $("#tsdbox").width()-2; };

  tmcpe.ns = {
      svg: "http://www.w3.org/2000/svg",
      xlink: "http://www.w3.org/1999/xlink"
  };


  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };

  tmcpe.tsdParams = function() {
      var tsdparams = {}
      ;      
      
      return tsdparams;
  };

  // Handle view elements for the TSD parameters
  tmcpe.tsdParamsView = function () {
      var tsdParamsView = {},
      container,
      tsdParams   // the tsdParams (model) this view is tied to
      ;

      function init() {

	  // handle some element styling
	  $('input[type=range]',container).rangeinput();

	  // connect form elements to change events
	  $('input[type=radio]',container)
	      .change(function(d){
		  $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	      });
	  $('input[type=text]',container)
	      .change(function(d){
		  $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	      });
	  $('select',container)
	      .change(function(d){
		  $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	      });
      }

      function formAsModel() {
	  var form = [];
	  $('input:radio:checked',container).each(function(i, e) {
	      var t = e.value;
	      form[e.name] = t;
	  });
	  $('input:text',container).each(function(i,e) {
	      form[e.name] = e.value;
	  });
	  $('select',container).each(function(i,e) {
	      form[e.name] = e.value;
	  });
	  return form;
      }

      tsdParamsView.container = function(x) {
	  if (!arguments.length) return container;
	  container = x;
	  container.attr("class", "tsdParams");
	  init();
	  return tsdParamsView;
      }

      tsdParamsView.params = function(x) {
	  if ( x == null ) return tsdParams;
	  tsdParams = x;
	  update();
      }

      /**
       * Make the form match the tsdParams (model)
       */
      function update() {
	  if ( tsdParams ) {
	  }
      }

      return tsdParamsView;
  };


  // view of the affected sections in time and space on one facility
  tmcpe.tsd = function() {
      var tsd = {},
      container,
      size,
      sizeActual,
      json,
      dw,      // total number of columns
      dh,      // total numbers of rows
      szs,     // size per section in px
      szt,     // size per timestep in px
      twidth,
      theight,
      svg,
      cellStyle,
      cellAugmentStyle,
      selectedTime,
      seclensum,
      startTime = 0,
      endTime,// = 20,
      
      p = 20  // padding, in px
      ;

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      tsd.container = function(x) {
	  if (!arguments.length) return container;
	  container = x;
	  container.setAttribute("class", "tsd");
//	  container.appendChild(rect);
//	  return tsd.resize(); // infer size
	  return tsd;
      }

      tsd.resize = function() {
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
	  return tsd;
      };

      tsd.data = function(x) {
	  if ( !arguments.length ) return json;
	  json = x;

/*
	  json.sections = json.sections.sort( function(a,b) {
	      var diff =  a.pm - b.pm;
	      if ( a.dir == 'S' || a.dir == 'W' )
		  return -diff;
	      else
		  return diff;
	  });
*/

	  tsd.redraw();
	  return tsd;
      }

      tsd.hh = function() { return $(container).height()-2; };
      tsd.ww = function() { return $(container).width()-2; };


      function translateY(d, i) { return "translate(0,"+(i*szs)+")"; };
      function translateX(d, i) { return "translate("+(i*szt)+",0)"; };

      function grid0(x,y) {
	  if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	  return json.data[y][x].inc==0;
      }
      function grid1(x,y) {
	  if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	  return json.data[y][x].inc==1;
      }



      function updateText( newText ) {
	  d3.select("#msgtxt").html( newText );
      }

      tsd.cellStyle = function(x) {
	  if (!arguments.length) return cellStyle;
	  cellStyle = x;
	  return tsd.updateCellStyle();
      }

      tsd.cellAugmentStyle = function(x) {
	  if (!arguments.length) return cellAugmentStyle;
	  cellAugmentStyle = x;
	  return tsd.updateCellAugmentation();
      }

      tsd.updateCellStyle = function( ) {
	  d3.select(container).selectAll("g")
	      .selectAll("rect")
	      .attr("style", cellStyle );
	  return tsd;
      }

      tsd.updateCellAugmentation = function() {
	  d3.select(container).selectAll("g").selectAll("circle")
	      .attr("style", cellAugmentStyle );
	  return tsd;
      }

      $(window).bind("tmcpe.tsd.paramsChanged", function( params ) {
	  tsd.updateCellStyle();
	  tsd.updateCellAugmentation();
      });

      function showSelectedTime() {
	  var data = json.data,
	  sections = json.sections

	  // assertions
	  if ( sections == null || sections.length == 0 ) throw "Missing section data to show selected time";
	  if ( selectedTime < 0 ) throw "Asked to throw undefined (<0) selected time in TSD";

	  // update cross line by translating it to the proper section
	  var cross = d3.select(container).selectAll("#tsdsec")
	      .data([1])
	      .attr("transform", function(dd, ii) { 
		  var dist = 0;
		  var j;
		  for ( j = 0; j<selectedTime; ++j ) { dist += sections[j].seglen; }
		  var val = theight*(dist+sections[selectedTime].seglen/2)
		      /seclensum;
		  return "translate(0,"+(val)+")"; 
	      });


	  // create cross line if it doesn't exist
	  cross.enter()
	      .append("svg:line")
	      .attr("id","tsdsec")
	      .attr("transform", function(dd, ii) { 
		  var dist = 0;
		  var j;
		  for ( j = 0; j<selectedTime; ++j ) { dist += sections[j].seglen; }
		  var val = theight*(dist+sections[selectedTime].seglen/2)
		      /seclensum;
		  return "translate(0,"+(val)+")"; 
	      })
	      .attr("x1",0)
	      .attr("y1",0)
	      .attr("x2",tsd.twidth)
	      .attr("y2",0)
	      .attr("style","stroke:purple;stroke-width:3");

	  // highlight edge
	  var seg = $('path[id^='+sections[selectedTime].vdsid+']');
	  seg.map( function (jj, s) { s.style.setProperty("stroke-width",6 ) } );
      }

      tsd.selectedTime = function(x) {
	  if (!arguments.length) return selectedTime;
	  selectedTime = x;

	  showSelectedTime();

	  return tsd;
      }

      tsd.redraw = function() {
	  // assertions
	  if ( json == null ) throw "Can't redraw cumflow diagram without data";
	  if ( json.analysis == null ) throw "Can't display data without a solution result";

	  // clear any existing
	  $(container).children().remove();


	  if ( json.analysis.badSolution ) {
	      // catch bad solution and display info
	      $(container).append('<p style="text-align:right">NO ANALYSIS PERFORMED'+(json.analysis.badSolution 
							      ? ' BECAUSE: '+json.analysis.badSolution 
							      : '' )+'</p>');
	      // nothing to see here.
	      return tsd;
	  }

	  if ( json.data == null || 
	       json.data.length == 0 || 
	       json.data[0].length == 0 ) throw "Bad solution data returned from server";

	  // Insert dummy elements to pull styling from css into tsd construction
	  $(container).append("<div class='dummy-tsd-speed-start-color'/>");
	  $(container).append("<div class='dummy-tsd-speed-mid-color'/>");
	  $(container).append("<div class='dummy-tsd-speed-end-color'/>");

	  var data = json.data,
	  sections = json.sections
	  fn       = [grid0, grid1],      // contouring functions
	  grid = grid1;

	  dh = data.length,        // how many time steps
	  dw = timeSlice(data[0]).length,     // how many sections

	  szs = (tsd.hh()-2*p)/dh;
	  szt = (tsd.ww()-7*p)/dw;

	  twidth = szt*dw;
	  tsd.twidth = twidth;
          theight = szs*dh;

	  seclensum = 0;
	  $.each(sections, function(i,s){ seclensum+=s.seglen; } );

	  function scale(p) { 
	      var dist = 0;
	      var j;
	      for ( j = 0; j<p[1]; ++j ) { 
		  dist += sections[j].seglen; 
	      }
	      var val = theight*dist/seclensum;
	      return [p[0]*szt, val]; 
	  }

	  function contour(svg, agrid, start) {
	      svg.selectAll("path")
		  .data([d3.geom.contour( agrid, start).map(scale)])
		  .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
		  .enter().append("svg:path")
		  .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
		  .attr("class","incidentBoundary");
	  }

	  function timeSlice( d ) {
	      return d.slice( startTime?startTime:0,endTime!=null?endTime:d.length );
	  }


	  function mouseover(d,i) {
	      updateText( "inc:" + d.inc + ", spd:" + d.spd + ", occ:" + Math.floor(d.occ*100+0.5) + "%, vol:" + d.vol + ", loc: " +sections[d.i].name + ", time: "+json.timesteps[d.j]+", lanes: " + sections[d.i].lanes );

	      // update cross hatch
 	      var cross = svg.selectAll("#tsdtime")
		  .data([1])
		  .attr("x1",(d.j+1)*szt)
		  .attr("y1",0)
		  .attr("x2",(d.j+1)*szt)
		  .attr("y2",theight-1)
		  .attr("style","stroke:purple;stroke-width:3");

	      // create cross hatch if it doesn't yet exist
	      cross.enter()
		  .append("svg:line")
		  .attr("id","tsdtime" )
		  .attr("x1",(d.j+1)*szt)
		  .attr("y1",0)
		  .attr("x2",(d.j+1)*szt)
		  .attr("y2",theight-1)
		  .attr("style","stroke:purple;stroke-width:3");


	      // Get all sections at time == j, these give use the colors
	      var el = $('rect[j^='+d.j+']');

	      // Next, foreach el, find the corresponding segment and update the stroke
	      el.map( function (ii, e) {
		  if ( e != null && !isNaN(e.__data__.i) ) {
		      // update segment colors
		      var seg = $('path[id^='+sections[e.__data__.i].vdsid+']');
		      seg.map( function (jj, s) { 
			  s.style.setProperty("stroke",e.style.getPropertyValue("fill"),"important") } );

		      // update node colors
		      var nod = $('#ends circle[id^="node:'+sections[e.__data__.i].vdsid+'"]');
		      nod.map( function (jj, s) { 
			  s.style.setProperty("fill",e.__data__.inc ? "blue" : e.style.getPropertyValue("fill"),"important" )
			  s.setAttribute("r", e.__data__.inc ? 4 : 2 );
		      } );

		      // update arrow colors
		      var nod = $('#ends path[id^="node:'+sections[e.__data__.i].vdsid+'"]');
		      nod.map( function (jj, s) { 
			  s.style.setProperty("fill",e.__data__.inc ? "blue" : e.style.getPropertyValue("fill"),"important" )
			  s.setAttribute("r", e.__data__.inc ? 4 : 2 );
		      } );

		  }
	      });

	      // finally, update the map text
	      d3.select("#maptext")
		  .text(json.timesteps[d.j]);
	  }


	  svg = d3.select(container)
              .append("svg:svg")
	      .attr("id", "tsdsvg" )
              .attr("width", twidth + 7*p/*theight/*twidth*/ )
              .attr("height", theight + 2*p/*twidth/*theight*/ )
	      .append("svg:g")
	      .attr("transform", "translate(" + 6*p + "," + p + ")")
	      .on("keydown",function( k ) {
		  console.log( k );
	      });
	  tsd.svg = svg;

	  // now, create the rows of data.
	  var gg = svg.selectAll("g.sectionrow")
              .data(data)
              .enter().append("svg:g")
	      .attr("class","sectionrow")
	      .attr("id",function(d,i) { return "row"+i; })
	      .attr("vdsid",function(d,i) { 
		  return json.sections[i].vdsid; })
              .attr("transform", function(d, i) { 
		  var dist = 0;
		  var j;
		  for ( j = 0; j<i; ++j ) { dist += sections[j].seglen; }
  		  var val = theight*dist/seclensum;
		  return "translate(0,"+(val)+")"; 
	      });

	  // next, in each row, create the time-space cells
	  gg.selectAll("rect")
              .data(function(d) { return timeSlice(d); })
              .enter().append("svg:rect")
	      .attr("i", function(d){return d.i;} )
	      .attr("j", function(d){return d.j;} )
              .attr("width", szt )
              .attr("transform", translateX )
              .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
	      .attr("style", cellStyle)
	      .on("click", function(d,i) {
		  // when clicked, create a tmcpe selection event
		  $(window).trigger("tmcpe.tsd.selectedSection", 
				    {sectionidx: d.i }
				   );
	      })
	      .text("test")
/*
	      .attr("tt", function(d){ 
		  this.tooltip({ bodyHandler: function() {
                      return $($(this).attr("href")).html();
		  }});
	      })
*/
              .on("mouseover", mouseover)
	  ;



	  // create ylabels
	  gg.append("svg:text")
	      .attr("x", -4 )  // shift 4 px left of axis
	      .attr("class", "ylabels" )
	      .attr("dy",function (d,i) { 
		  return theight*sections[d[0].i].seglen/seclensum/2+5; } ) // put midway down
	      .attr("text-anchor","end")
	      .text(function(d,i){ 
		  // only show avery other segment name
		  return i%2 ? "" : sections[i].name; 
	      })
	      .attr("class","ylabels");

      // now, create the rows of data to show evidence as black dots in the
	  // center of cells suspected of being impacted by an incident
	  var g = svg.selectAll("g.evidence")
              .data(data)
              .enter().append("svg:g")
	      .attr("class","evidence")
              .attr("transform", function(d, i) { 
		  var dist = 0;
		  var j;
		  for ( j = 0; j<i; ++j ) { dist += sections[j].seglen; }
  		  var val = theight*dist/seclensum;
		  return "translate(0,"+(val)+")"; 
	      });

	  // next, in each row, create the evidence
	  g.selectAll("circle")
              .data(function(d) { return timeSlice(d); })
              .enter().append("svg:circle")
	  //.attr("class", function(d) { return "d"+d.inc; })
	      .attr("style", cellAugmentStyle )
              .attr("cx", function (d, i ) { return ((i+0.5)*szt) } )
              .attr("cy", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum)/2; })
	      .attr("r", 1.5 );


	  // make sure there's at least one cell with the incident
	  // flag set to 1, d3.contour infinite loops if that's not
	  // the case.  Issue #680
	  var incsum = 0;
	  for ( y in json.data ) {
	      for ( x in json.data[y] ) {
		  incsum += (json.data[y][x].inc==1?1:0);
	      }
	  }

	  // Only contour if there's a solution
	  if ( incsum > 0 && json.analysis.badSolution == null ) { 
	      contour( svg, grid );
	  } else {
	      updateText( "NO DELAY SOLUTION AVAILBLE BECAUSE: " + json.analysis.badSolution );
	  }

	  return tsd;

      }

      // some events this view listens to
      $(window).bind("tmcpe.tsd.selectedSection", function( caller, data ) {
	  // new selection selected, update the time selection in the tsd
	  tsd.selectedTime( data.sectionidx );
      });

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	  // new analysis loaded, update the data
	  tsd.data( json );
      });


      return tsd;
  }

  // view of the cumulative flow past an affected section during the timeframe
  // of the incident
  tmcpe.cumflow = function() {
      var cumflow = {},
      container,
      size,
      sizeActual,
      json,
      dw,
      dh,
      szs,
      szt,
      twidth,
      theight,
      svg,
      section,
      tmcDivPct = 20,
      startTime = 0,
      endTime,// = 20,
      
      p = 20
      ;

      // recursive function to sum all of a given cell property from time 0 to time j
      function sfunc (i,j,ff,vol) {
	  if ( vol == null ) vol = 0;
	  if ( j < 0 ) 
	      return vol;
	  else 
	      return sfunc( i, j-1, ff, vol + ff(json.data[i][j]) ); 
      }

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      cumflow.tmcDivPct = function(x) {
	  if (!arguments.length) return container;
	  tmcDivPct = x;
	  return cumflow.updateStats();
      }

      cumflow.container = function(x) {
	  if (!arguments.length) return container;
	  container = x;
	  container.setAttribute("class", "tsd");
	  //container.appendChild(rect);
	  return cumflow.resize(); // infer size
	  //return cumflow;
      }

      cumflow.resize = function() {
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
	  return cumflow;
      };

      cumflow.data = function(x) {
	  if ( !arguments.length ) return json;
	  json = x;

/*
	  json.sections = json.sections.sort( function(a,b) {
	      var diff =  a.pm - b.pm;
	      if ( a.dir == 'S' || a.dir == 'W' )
		  return -diff;
	      else
		  return diff;
	  });
*/


	  return cumflow;
      }

      cumflow.section = function(x) {
	  if ( !arguments.length ) return section != null ? section : json.getSectionIndex( json.sec )-1;
	  section = x;

	  cumflow.redraw();

	  return cumflow;
      }

      var data;


      function zeroOrBetter( x ) {
	  return x < 0 ? 0 : x;
      }


      cumflow.updateStats = function() {
	  // compute delay from implied queuing
	  var delay2 = 0;
	  var delay3 = 0;
	  var delay4 = 0;
	  var tmcSavings = 0;

	  if ( !data ) return cumflow;

	  if ( json.analysis.badSolution != null ) {
	      $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
		  d3.select("#"+v).html( "n/a" );
	      });
	      return cumflow;
	  }


	  $.each( data, function(i, d) {
	      delay2 += (d.y3-d.y)*5/60;       // div adj avg - obs
	      delay3 += (d.y2-d.y)*5/60;       // avg - obs
	      delay4 += (d.y2-d.incflow)*5/60; // avg - inc projected
	  });

	  // scale to convert div adj avg to netdelay
	  var factor = json.analysis.netDelay/(delay2+(delay3-delay2)*(1-tmcDivPct/100.0));

	  delay4 *= factor;
	  delay4 = zeroOrBetter( delay4 );
	  tmcSavings = delay4-zeroOrBetter(json.analysis.netDelay);
	  tmcSavings = ( tmcSavings < 0 ? 0 : tmcSavings );

	  $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
	      if ( json.analysis[v] != null  && v != 'computedMaxqTime' ) {
		  d3.select("#"+v).html( zeroOrBetter(json.analysis[v].toFixed(0) ) );
	      }
	  });
	  d3.select("#chartDelay2").html( delay2.toFixed(0) );
	  d3.select("#chartDelay3").html( delay3.toFixed(0) );
	  d3.select("#whatIfDelay").html( delay4.toFixed(0) );
	  d3.select("#tmcSavings").html( tmcSavings.toFixed(0) );
      }

      function timeSlice( d ) {
	  return d.slice( startTime?startTime:0,endTime!=null?endTime:d.length );
      }


      cumflow.redraw = function() {
	  // assertions
	  if ( json == null ) throw "Can't redraw cumflow diagram without data";
	  if ( json.analysis == null ) throw "Can't display data without a solution result";

	  // clear any existing
	  $(container).children().remove();


	  if ( json.analysis.badSolution ) {
	      // catch bad solution and display info
	      $(container).append('<p style="text-align:right">NO ANALYSIS PERFORMED'+(json.analysis.badSolution 
							      ? ' BECAUSE: '+json.analysis.badSolution 
							      : '' )+'</p>');
	      // nothing to see here.
	      return tsd;
	  }

	  if ( json.data == null || 
	       json.data.length == 0 || 
	       json.data[0].length == 0 || 
	       section < 0 ) throw "Bad solution data returned from server";



	  var t0 = new Date( json.t0 ).getTime()/1000;
	  var t1 = new Date( json.t1 ).getTime()/1000;
	  var t1p = new Date( json.t1 ).getTime()/1000 + 15*60;
	  var t2 = new Date( json.t2 ).getTime()/1000;
	  var t2p = new Date( json.t2 ).getTime()/1000 + 15*60;
	  var t3 = new Date( json.t3 ).getTime()/1000;
	  var volscale = 1/1000;
	  var volscale = 1;

	  var incidentSectionIndex = json.getSectionIndex(json.sec)-1;

	  d3.select("#chart_location").html(json.sections[section].name);



	  var t0Cell = json.timesteps.filter( function (e) {
	      return !t0 || (e.getTime()/1000 < t0);
	  }).length-1;

	  var startCell = json.timesteps.filter( function (e) {
	      return !t1 || (e.getTime()/1000 < t1);
	  }).length-1;


	  var t2Cell = json.timesteps.filter( function (e) {
	      return !t2 || (e.getTime()/1000 < t2);
	  }).length-1;

	  var t2pCell = json.timesteps.filter( function (e) {
	      return !t2p || (e.getTime()/1000 < t2p);
	  }).length-1;

	  var finishCell = json.timesteps.filter( function (e) {
	      return !t3 || (e.getTime()/1000 < t3);
	  }).length;

	  if ( finishCell >= json.timesteps.length ) {
	      finishCell = json.timesteps.length-1;
	  }


	  if ( t0Cell < 0 ) {
	      // BAD DATA
	      $(container).append('<p>NO INCIDENT START FOUND, <a href="http://tracker.ctmlabs.net/projects/tmcpe/issues/new">REPORT AN ISSUE</a></p>');
	      // nothing to see here.
	      return tsd;
	  }


	  // fixme: crindt: we really want to use the incident section by default, not the downstream section.
	  var diversion = sfunc(incidentSectionIndex,finishCell,function(v){
	      return v == null || v.vol_avg == null ? 0 : v.vol_avg/volscale;
	  }) - sfunc(incidentSectionIndex,finishCell,function(v){
	      return v == null || v.vol == null ? 0 : v.vol/volscale;
	  });

	  data = d3.range( json.timesteps.length ).map(function(j) {
	      return {x:json.timesteps[j].getTime()/1000+300,
		      y: sfunc(section,j,function(v){return v.vol/volscale}), 
		      y2: sfunc(section,j,function(v){return v.vol_avg/volscale}),
		      y3: ( j < startCell
			    ?  sfunc(section,j,function(v){return v.vol_avg/volscale})
			    : ( j > finishCell
				? sfunc(section,j,function(v){return v.vol/volscale})
				: sfunc(section,j,function(v){return v.vol_avg/volscale}) - diversion*(j-startCell)/(finishCell-startCell) ) ),
		     }
	  });

	  var incflowrate = (data[t2Cell].y - data[t0Cell].y)/(5*60*(t2Cell-t0Cell)) ;
	  var clearflowrate = (data[finishCell].y - data[t2Cell].y)/(5*60*(finishCell-t2Cell)) ;

	  // compute what-if flow rate
	  $.each(data,function(j,d){
	      if ( j < t2Cell ) {
		  // before t2 (clearance), what-if flow is equivalent to measured
		  d.incflow = sfunc(section,j,function(v){return v.vol/volscale})
	      } else if ( j < t2pCell ) {
		  // between t2 and t2p, what-if flow is the base vvalue 
		  var base = sfunc(section,t2Cell,function(v){return v.vol/volscale});
		  d.incflow =  base + incflowrate*(j-t2Cell)*60*5;
	      } else {
		  var base = sfunc(section,t2Cell,function(v){return v.vol/volscale});
		  d.incflow = base + incflowrate*(t2pCell-t2Cell)*60*5 + clearflowrate*(j-t2pCell)*60*5;
	      }

	      // don't allow projection to be greater than avg.
//	      if ( d.incflow > d.y2 ) d.incflow = d.y2;

	  });


	  // add zeroed elements at the beginning
	  data.unshift( { x:json.timesteps[0].getTime()/1000,y:0,y2:0,y3:0,incflow:0} );
	  
	  // Compute the maximum cumulative flow across all sections (to set the max scale)
	  var maxflow = Array.max( json.data.map( function( r ) { 
	      return Array.max( [ sfunc( r[0].i,r.length-1, function(v){return v.vol/volscale}), 
				  sfunc( r[0].i,r.length-1, function(v){return v.vol_avg/volscale}) ] );
	  } ) );


	  var w = $(container).width()-2,
	  h = $(container).height()-2,
	  ww = w - 7*p,       // width available for plot
	  hh = h - 4*p,   // height available for plot
	  x = d3.scale.linear()
	      .domain([json.timesteps[startTime ? startTime : 0 /*0*/].getTime()/1000,
		       json.timesteps[endTime ? endTime-1: json.timesteps.length-1].getTime()/1000+300])
	      .range([0, ww]),
	  y = d3.scale.linear().domain(/*[0,20]*/[0, maxflow]).range([hh, 0]),
	  now = new Date();
	  
	  var vis = d3.select("#chartbox")
	      .append("svg:svg")
	      .attr("class", "flowchart" )
	      .data([timeSlice(data)])
	      .attr("width", w) // margin of 100
	      .attr("height", h)
	      .append("svg:g")
	      .attr("transform", "translate(" 
		    + 6*p      // shift left 5p (1p margin on right)
		    + "," + p  // shift down 1p (1p margin on top)
		    + ")");
	  
	  // create some data for the section rules
	  var rr = d3.range( json.timesteps[0].getTime()/1000,
			     json.timesteps[json.timesteps.length-1].getTime()/1000+300,
			     300 );
	  rr = timeSlice( rr );

	  // create some data for the time rules
	  var rr2 = x.ticks(json.timesteps.length);
	  rr2 = timeSlice( rr2 );

	  
	  // Now, for each section, create a group
	  var rules = vis.selectAll("g.rule")
	      .data( rr )
	      .enter().append("svg:g")
	      .attr("class", "rule");
	  
	  // within each section group, create a line (it's vertical here, 
	  // but will be horizontal on the rotated plot
	  rules.append("svg:line")
	      .attr("x1", x)
	      .attr("x2", x)
	      .attr("y1", 0)
	      .attr("y2", hh - 1);

	  // For each time, create a group
	  var rules2 = vis.selectAll("g.rule2")
	      .data(y.ticks(10))
	      .enter().append("svg:g")
	      .attr("class","rule2");
	  
	  // within each time group, create a line (it's horizontal here,
	  // but will be vertical on the rotated plot
	  rules2.append("svg:line")
	      .attr("class", function(d) { return d ? null : "axis"; })
	      .attr("y1", y)
	      .attr("y2", y)
	      .attr("x1", 0)
	      .attr("x2", ww );
	  
	  // a function to rotate the time axis labels
	  function xlabel_rotate (xx) {
	      return "rotate("+[90,x(xx),(hh+3)].join(",")+")"
	  }
	  
	  // now, add labels for each section
	  rules2.append("svg:text")
	      .attr("y", y)
	      .attr("x", -4)  // shift 4px to left of axis
	      .attr("dy", "8pt")
	      .attr("text-anchor", "end")
	      .text(y.tickFormat(10))
	      .attr("class","ylabels");

	  // finally, add labels for each time step
	  rules.append("svg:text")
	      .attr("x", x )
	      .attr("y", hh + 5 )
	      .attr("dy", ".25em")
	      .attr("text-anchor", "start")
	      .attr("transform",function(d) { return xlabel_rotate(d); } )
	      .text(/*x.tickFormat(10)*/ function (x) { 
		  return $.format.date(new Date( x*1000 ), "HH:mm");
//		  return new Date( x*1000 ).toLocaleTimeString();
	      } )
	      .attr("class","xlabels");
	  
	  

	  // averages
	  vis.append("svg:g")
	      .attr("class", "area2")
	      .append("svg:path")
	      .attr("d", d3.svg.area()
		    .x(function(d) { 
			return x(d.x); })
		    .y0(hh - 1)
		    .y1(function(d) { 
			return y(d.y2); }))
	      .on("mouseover", function( d,i ) { 
		  avgmouseover( ); 
		  /*
		    vis.selectAll( "g.area2 path" )
		    .transition()
		    .attr("fill-opacity", 1 );
		    */
	      } )
	      .on("mouseout", function (d,i) { 
		  updateText( "&nbsp;" );
		  /*
		    vis.selectAll( "g.area2 path" )
		    .filter( function (d,j) { 
		    return j == i;
		    } )
		    .transition()
		    .attr("fill-opacity", 0.5 );
		  */
	      } );
	  
	  vis.append("svg:path")
	      .attr("class", "line2")
	      .attr("d", d3.svg.line()
		    .x(function(d) { return x(d.x); })
		    .y(function(d) { return y(d.y2); }));
	  // divavg
	  if ( section == incidentSectionIndex ) {
	      vis.append("svg:g")
		  .attr("class", "area3")
		  .append("svg:path")
		  .attr("d", d3.svg.area()
			.x(function(d) { return x(d.x); })
			.y0(hh - 1)
			.y1(function(d) { return y(d.y3); }))
		  .on("mouseover", function( d,i ) { 
		      updateText( "Expected non-diverted Cumulative Flow (Observed delay)" );
		      /*
			vis.selectAll( "g.area3 path" )
			.transition()
			.attr("fill-opacity", 0.5 );
			*/
		  } )
		  .on("mouseout", function (d,i) { 
		      updateText( "&nbsp;" );
		      /*
			vis.selectAll( "g.area3 path" )
			.filter( function (d,j) { 
			return j == i;
			} )
			.transition()
			.attr("fill-opacity", 1 );
			*/
		  } );
	      
	      vis.append("svg:path")
		  .attr("class", "line3")
		  .attr("d", d3.svg.line()
			.x(function(d) { return x(d.x); })
			.y(function(d) { return y(d.y3); }));

	  }



	  // observed
	  vis.append("svg:path")
	      .attr("class", "area")
	      .attr("d", d3.svg.area()
		    .x(function(d) { return x(d.x); })
		    .y0(hh - 1)
		    .y1(function(d) { return y(d.y); }))
	      .on("mouseover", obsmouseover )
	      .on("mouseout", function () { updateText( "&nbsp;" ) } );

	  
	  vis.append("svg:path")
	      .attr("class", "line")
	      .attr("d", d3.svg.line()
		    .x(function(d) { return x(d.x); })
		    .y(function(d) { return y(d.y); }));

	  // what-if
	  vis.append("svg:path")
	      .attr("class", "whatif")
	      .attr("d", d3.svg.area()
		    .x(function(d) { return x(d.x); })
		    .y0(hh - 1)
		    .y1(function(d) { return y(d.incflow); }))
	      .on("mouseover", obsmouseover )
	      .on("mouseout", function () { updateText( "&nbsp;" ) } );


	  // draw start of incident

	  var tr = [ 
	      { t:t0, n: "t0", l:"Onset of incident" }, //"t<tspan baseline-shift='sub'>0</tspan>" },
	      { t:t1, n: "t1", l:"Verification" }, 
	      { t:t2, n: "t2", l:"Roadway clear" }, 
	      { t:t3, n: "t3", l:"Queue dissipated" }, 
	      { t:t1p, n: "t1p", l:"Verification without TMC (estimated)"},
	      { t:t2p, n: "t2p", l:"Clearance time without TMC (estimated)"},
	  ].filter( function( d ) { return d.t != null; } );

	  var times = vis.selectAll("g.timebar")
	      .data( tr )
	      .enter().append("svg:g")
	      .attr("class", "timebar")
	      .attr("critevent", function(d) { return d.n } )
	  ;

	  times.append("svg:line")
	      .attr("x1", function (d) { 
		  return x(d.t) } )
	      .attr("x2", function (d) { 
		  return x(d.t) } )
	      .attr("y1", 0 )
	      .attr("y2", hh - 1 )
	      .on("mouseover", function(d,i) {
		  this.style.stroke="red";
		  updateText( $.format.date( new Date(d.t*1000), "HH:mm" ) + ":: " + d.l );

		  // Add tooltips to lines
		  $(this).tipsy( "test" ) 

	      })
	      .on("mouseout", function(d,i) {
		  this.style.stroke="";
	      })
	  ;


	  d3.selectAll("g.timebar")
	      .append("svg:text")
	      .attr("class","critical-time")
	      .attr("x", function (d) { 
		  return x(d.t) } )
	      .attr("y", 0 )
	      .attr("text-anchor", "start")
	      .text( function(d) { 
		  return d.n; } )
	  ;

	  // Add activity log entries
	  var times2 = vis.selectAll("g.timebar")
	      .data( json.log, 
		     // use an ID function to allow for logtimebars in addition to timebars
		     // so we can highligh them onmouseover
		     function(d,i) { return "log_"+d.id; }  
		   )
	      .enter().append("svg:g")
	      .attr("class", "logtimebar activitylog hidden")
	      .attr("logid", function(d,i) { return d.id; } )
	  ;

	  times2.append("svg:line")
	      .attr("x1", function( d ) { 
		  var dd = new Date( d.stampDateTime ).getTime()/1000; 
		  return x( dd ); } )
	      .attr("x2", function( d ) { 
		  var dd = new Date( d.stampDateTime ).getTime()/1000; 
		  return x( dd ); } )
	      .attr("y1", 0 )
	      .attr("y2", hh - 1 )
	      .on("mouseover", function(d,i) { 
		  this.style.stroke="red";
		  updateText( "Log: " + new Date(d.stampDateTime).toLocaleTimeString() + ": " + d.memoOnly ); 
	      })
	      .on("mouseout", function(d,i) {
		  this.style.stroke="";
	      })
	  ;


	  cumflow.updateStats();

	  function avgmouseover(d,i) {
	      updateText( "Expected Cumulative Flow" );
	  }

	  function obsmouseover(d,i) {
	      updateText( "Observed Cumulative Flow" );
	  }

	  function updateText(msg) {
	      d3.select("#msgtxt").html(msg);
	  }


      }

      // some events this view listens to
      $(window).bind("tmcpe.tsd.selectedSection", function( caller, data ) {
	  cumflow.section( data.sectionidx );
      });

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	  // new analysis loaded, update the data
	  cumflow.data( json );
      });

      return cumflow;
  };

  // view of the traffic conditions during the incident displayed on a map using
  // vds line segments
  tmcpe.segmap = function() {
      var segmap = {},
      container,
      theight,// = $(container).height()-2,
      twidth,// = $(container).height()-2,
      data,
      map,
      usearrow = true,
      rotate = "cardinal",  // default = incident
      secjson,
      segments,
      ends,

      po = org.polymaps;

      tmcpe.svg = function(type) {
	  return document.createElementNS(tmcpe.ns.svg, type);
      };

      segmap.container = function(x) {
	  if (!arguments.length) return container;
	  container = x;
	  container.setAttribute("class", "map");
	  //container.appendChild(rect);
	  return cumflow.resize(); // infer size
      }

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      segmap.resize = function() {
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
	  return segmap;
      };

      segmap.data = function(x) {
	  if ( !arguments.length ) return json;
	  json = x;
	  segmap.redraw();
	  readSegments();
	  return segmap;
      }

      segmap.secjson = function(x) {
	  if ( !arguments.length ) return secjson;

	  secjson = x;

	  // 
	  addSegmentLayer();
	  // order is important here if we're drawing arrows
	  zoomExtents();
	  rotateLayer();
	  addEndsLayer();
	  
	  return segmap;
      }


      segmap.hh = function() { return $(container).height()-2; };
      segmap.ww = function() { return $(container).width()-2; };


      segmap.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  return segmap;
      }

      segmap.redraw = function() {
	  if ( container ) $(container).children().remove();
	  create();
	  addImageLayer();
	  return segmap;
      }

      segmap.rotate = function(x) {
	  if ( !arguments.length ) return rotate;
	  rotate = x;
	  rotateLayer()
	  return segmap;
      }

      function create() {

	  // create the map
	  var svg = d3.select(container)
	      .append("svg:svg")
	      .attr("id","segmapsvg")
	      .attr("height",segmap.hh())
	      .attr("width",segmap.ww())[0][0];

	  map = po.map()
	      .container(svg)
	      .zoom(13)
	      .zoomRange([1,/*6*/, 18])
	      .add(po.interact());

	  return segmap;
      }
      
      function addImageLayer() {

	  map.add(po.image()
		  .url(po.url("http://{S}tile.openstreetmap.org"
			      + "/{Z}/{X}/{Y}.png")
		       .hosts(["a.", "b.", "c.", ""])));
	  return segmap;
      }

      function rotateLayer() {
	  if ( rotate == "incident" ) {

	      var ff = secjson.features.slice(0,secjson.features.length-1).sort(function(a,b){
		  var diff =  a.pm - b.pm;
		  if ( a.dir == 'N' || a.dir == 'E' )
		      return -diff;
		  else
		      return diff;
	      });

	      var startll = ff[0].geometry.coordinates;
	      start = map.coordinatePoint(map.locationCoordinate(map.center()),
					  map.locationCoordinate( {lon:startll[0][0],lat:startll[0][1] } ) );
	      var endll = ff[ff.length-1].geometry.coordinates;
	      end = map.coordinatePoint(map.locationCoordinate(map.center()),
					map.locationCoordinate( {lon:endll[endll.length-1][0],lat:endll[endll.length-1][1] } ) );

	      // x,y screen coords are flipped on the x axis (y increases downward)
	      // we negate the y coords here for the angle calc
	      var dy = -((end.y)-(start.y));
	      var dx = (end.x-start.x);
	      var angle = Math.atan2( dy, dx );
	      var aa = angle * 180 / Math.PI;

	      rr = angle + Math.PI/2.0;

	      var rra = rr * 180 / Math.PI;

	      console.log( "Angle,rra:"+aa+","+rra );

	      map.angle( rr )
//	      map.angle( 90*Math.PI/180.0 );

	  } else {
	      // default is cardinal
	      map.angle( 0 );
	  }
      }

      function screenAngleBetweenGeoJsonPoints(a,b) {
	  var p1 = map.coordinatePoint(map.locationCoordinate(map.center()),map.locationCoordinate({lon:a[0],lat:a[1]}));
	  var p2 = map.coordinatePoint(map.locationCoordinate(map.center()),map.locationCoordinate({lon:b[0],lat:b[1]}));
	  return {a:Math.atan2( p2.y - p1.y, p2.x - p1.x ),p1:p1,p2:p2};
      }

      function addEndsLayer() {
	  // remove existing
	  $("#ends").remove();

	  var ends = po.geoJson().features(secjson.features.map( function (f) {

	      var p3 = f.geometry.coordinates[ f.geometry.coordinates.length-1 ]; // end of segment/arrow

	      if ( !usearrow ) {
		  // draw a circle
		  return {data: f.properties, 
			  geometry: { type:"Point", 
				      coordinates: p3
				    }};

	      } else {
		  // draw an arrow
		  var p1 = f.geometry.coordinates[ f.geometry.coordinates.length-2 ]; // base of shaft
		  
		  var aa = screenAngleBetweenGeoJsonPoints( p1, p3 );

		  var angle1 = aa.a;
		  var angle2 = angle1 +Math.PI/2;

		  var shaftlen = Math.pow(2, map.zoom() - 9);;
		  var shaftlen2 = Math.pow(2, map.zoom() - 9.5);;
		  var arrowwid = Math.pow(2, map.zoom() - 10);

		  var c1b = {x:aa.p2.x - Math.cos(angle1)*shaftlen,y:aa.p2.y - Math.sin(angle1)*shaftlen};  // convert pixels
		  var c1c = {x:aa.p2.x - Math.cos(angle1)*shaftlen2,y:aa.p2.y - Math.sin(angle1)*shaftlen2};  // convert pixels
		  var c2 = {x:c1b.x + Math.cos(angle2)*arrowwid,y:c1b.y + Math.sin(angle2)*arrowwid};  // convert pixels
		  var c4 = {x:c1b.x - Math.cos(angle2)*arrowwid,y:c1b.y - Math.sin(angle2)*arrowwid};  // convert pixels

		  p1 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c1c));
		  p2 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c2));
		  p3 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),aa.p2));
		  p4 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c4));


		  return {data: f.properties, 
			  geometry: { type:"Polygon",
				      coordinates: [[[p1.lon,p1.lat],
						     [p2.lon,p2.lat],
						     [p3.lon,p3.lat],
						     [p4.lon,p4.lat],
						     [p1.lon,p1.lat]]] }
			 }; 
	      }
	  } ) );

	  ends.id("ends")
	      .zoom( function(z) { return Math.max(4, Math.min(18, z)); } )
	      .tile(false)
	      .on("load", po.stylist()
		  .attr("id", function(d) { 
		      return "node:"+d.data.id } )
		  .attr("r", 2 )
		  /*
		    function(d) { 
		    var zz = map.zoom()
		    var lev = 2+Math.floor(((zz-1))/17*(8-2));
		    return Math.min( Math.max( 2, lev ), 8 ) } )
		  */
		  .attr("stroke", "yellow" )
		  .attr("fill", "blue" )
		  .title(function(d) { 
		      return [d.data.id,d.data.name].join(":"); }));
	  map.add(ends);
      }

      function zoomExtents() {


	  var x = Array();
	  var y = Array();
	  for (var i = 0; i < secjson.features.length; i++) {
	      var feature = secjson.features[i];
	      var coords = feature.geometry.coordinates;
	      var polygons = $.map(coords, function(a){
		  return [a];});
	      var points = $.map(polygons, function(a){
		  return [a];
		  // convert to screen coordinates to compute extent
		  //		       var p = map.coordinatePoint( map.locationCoordinate(map.center()),map.locationCoordinate({lon:a[0],lat:a[1]}) )
		  //		       return p;
	      });
	      $.map(points, function(a){
		  if(!isNaN(a[0])){
		      x.push(a[0])
		  }; 
		  if(!isNaN(a[1])){
		      y.push(a[1])
		  };
	      });
	  }
	  xMax = Array.max(x);
	  xMin = Array.min(x);
	  yMax = Array.max(y);
	  yMin = Array.min(y);

	  map.extent([{lon:xMin,lat:yMin},{lon:xMax,lat:yMax}])
//	      .zoomBy(segmap.ww()/segmap.hh())
	      .zoomBy((yMax-yMin)/(xMax-xMin)*(Math.abs(Math.sin(map.angle()))))
	      .zoomBy(-0.75)
	  ;

	  map.add(po.compass().pan("none"));

      }

      function readSegments() {
	  // assertions
	  if ( json == undefined || json.sections == undefined ) throw "Missing TSD analysis data";
	  
	  var url = g.createLink({controller:'vds', 
				  action:'list.geojson',
				  params: {freewayDir: json.sections[0].dir,
					   idIn: json.sections.map( function( sec ) {return sec.vdsid;}).join(",")}
				 });

	  d3.json(url, function(e){
	      // update the section layer json
	      segmap.secjson( e );
	  });
      }

      segmap.getSectionIndex = function( sec, e  ) {
	  for (var i = 0; i < e.features.length; i++) {
	      if ( e.features[i].data.id == sec ) {
		  return i;
	      }
	  }
	  return null;
      }

      function addSegmentLayer() {
	  // remove existing
	  $("#segments").remove();

	  var secs = po.geoJson().features(secjson.features)
	      .id("segments")
	      .zoom( function(z) { return Math.max(4, Math.min(18, z)); } )
	      .tile(false)
	      .on("load", 
		  function (e) {
		      for (var i = 0; i < e.features.length; i++) {
			  var f = e.features[i];
			  var c = $(f.element);
			  var g = c.parent().add("svg:g", c);
			  g.add(c);

/* Add text
			  var crdst  = f.data.geometry.coordinates[0];
			  var crdend = f.data.geometry.coordinates[f.data.geometry.coordinates.length-1];
			  var aa = screenAngleBetweenGeoJsonPoints( crdst, crdend );
			  var text = g[0].appendChild(po.svg("text"));
			  text.setAttribute("x",crdend.x);
			  text.setAttribute("y",crdst.y);
			  text.setAttribute("dy",".71em");
			  var rr = -aa.a;
			  var rra = rr * 180/Math.PI;
			  //text.setAttribute("transform","rotate("+(rr)+")");
			  text.appendChild(document.createTextNode("test"));
			  */
		      }
		      
		      // Find the incident section

		      var i;
		      var incsecIndex=segmap.getSectionIndex(json.sec, e);
		      var incsec=e.features[incsecIndex];

		      if ( incsec ) {
			  var c = $(incsec.element);
			  var g = c.parent().add("svg:g", c );
			  g.add(c);
			  
			  var point = g[0].appendChild(po.svg("circle"));
			  point.setAttribute("id", "location");
			  // mark at end of incsec
			  var crd = incsec.data.geometry.coordinates[incsec.data.geometry.coordinates.length-1];
//			  var lc = map.locationCoordinate({lon:crd[0],lat:crd[1]});
//			  var cc = map.coordinatePoint(map.locationCoordinate(map.center()),lc)
			  point.setAttribute("class", "incidentLocation" )
			  point.setAttribute("cx", crd.x);
			  point.setAttribute("cy", crd.y);
			  //point.setAttribute("r", Math.pow(2, tile.zoom - 11) * Math.sqrt(cluster.cluster.length));
			  point.setAttribute("r", Math.pow(2, map.zoom() - 7) );
		      }


		      po.stylist()
			  .attr("id", function( d ) { return d.id; } )
			  .attr("i", function( d ) { return d.i; } )
			  .attr("stroke", function( d ) {
			      var el = $('g[vdsid^="'+d.id+'"] rect[j^=11]')[0]; // fixme: j == 11?  this is a hanging hardcode
			      return el == null ? "black" : el.style.fill; 
			  } )
			  .attr("stroke-width", 4 )
			  .title(function(d) { 
			      return [d.id,d.name].join(":"); })(e);
		  });

	  map.add(secs);


	  /*
	  $.map(secs.features(), function(f) {
	      var c = f.geometry.coordinates;
	      var tt = $(
	      var text = tt.appendChild(po.svg("text"));
	      text.setAttribute("x",c[c.length-1][0]);
	      text.setAttribute("y",c[c.length-1][1]);
	      text.setAttribute("dy",".71em");
	      text.appendChild(document.createTextNode("test"));
	  });
	  */
	  

      }

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, adata) {
	  segmap.data( adata ).redraw();
      });

      return segmap;
  };



  var i = 0;
  var tsd;
  var cumflow;
  var map;

  var themeScale=1.0;

  function maxSpeed() {
      //var maxSpd = $("#maxspdslider").slider("option","value");
      var maxSpd = [];
      if ( maxSpd.length == 0 ) maxSpd = 60;
      return maxSpd;
  }

  function speedScale() {
      //var scale  = $("#scaleslider").slider("option","value");
      var scale = [];
      if ( scale.length == 0 ) scale = 1.0;
      return scale;
  }

  function cellStyle(d) {
     var themeWid = $("#theme")[0];
     var theme = themeWid.options[themeWid.selectedIndex].value;
     var scale  = speedScale();
     var maxSpd = maxSpeed();

     // return grey if evidence is uncertain (imputed data)
     if ( d.p_j_m > 0 && d.p_j_m < 1 ) {
        return "fill:#999;stroke:#eee;"
     } 

     if ( theme == "stdspd" ) {
        var color = pv.Scale.linear(-scale,
                  -(scale/2),0 ).range("#ff0000","#ffff00","#00ff00");
        var vv = Math.min(0,Math.max((d.spd-d.spd_avg)/d.spd_std,-4));
        var col = "fill:"+color(vv).color+";stroke:#eee;"
        return col;
     } else if ( theme == "spd" ) {
        var minspd = 15;
        var color = pv.Scale.linear(minspd,
                                    minspd+(maxSpd-minspd)/2,
                                    maxSpd)
                      .range("#ff0000","#ffff00","#00ff00");
        var col = "fill:"+color(d.spd).color+";stroke:#eee;"
        return col;
     }
  }

  function evidenceOfIncident( d, scale, maxIncidentSpeed ) {
      var stdlev = (d.spd - d.spd_avg)/d.spd_std;
      var tmppjm = 1; // no incident probability is default
      if ( d.p_j_m != 0 && d.p_j_m != 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	  tmppjm = 0.5;
      else if ( stdlev < 0 
		&& stdlev < -scale
		&& d.spd < maxIncidentSpeed
	      )
      {
	  tmppjm = 0.0;
      }
      return tmppjm == 0.0;
  }


  function cellAugmentStyle(d) {
     var v1 = speedScale();
     var v2 = maxSpeed();
     var ev = evidenceOfIncident( d, v1, v2 );
     return ev ? "fill:black;" : "fill:none;";
  }

  function syncchart(tsd,cumflow) {
      return function( d, i ) { 
	  tsd.selectedTime( d.i );

          // updates the chart's data
	  cumflow.section( d.i );
      };
  };


  function rotateMap( v ) {
     map.rotate( v.value );
  }

  function handleFailure( e ) {
      return "poof";
  }

  function updateStats( json ) {
      if ( json.analysis.badSolution != null ) {
          //$( '#generalStats td' ).text( "" );   // clear everything
	  $( '#generalStats_wrapper').remove();
	  $( '#generalStatsContainer').append("<p>ANALYSIS FOR THIS FACILITY FAILED: "+json.analysis.badSolution+"</p>");
      } else {
	  // FIXME: This dups a similar function in tsd.js
	  $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
              if ( json.analysis[v] != null  && v != 'computedMaxqTime' ) {
		  var val = json.analysis[v].toFixed(0);
		  d3.select("#"+v).html( val < 0 ? 0 : val  );
              }
	  });

	  // Update the download analysis link.  Currently tied to the currently displayed analysis...
	  $('#tmcpe_tsd_download_link').html( 'Download XLS for facility analysis ' + json.id );
	  $('#tmcpe_tsd_download_link').attr( 'href', "${resource(dir:'/',absolute:true)}"+'incidentFacilityImpactAnalysis/show.xls?id='+json.id );


	  // Update the report problem link
	  $('#tmcpe_report_analysis_problem_link').html( 'Report problem with this analysis' );
	  url = "http://tracker.ctmlabs.net/projects/tmcpe/issues/new?tracker_id=3&"
		+ encodeURIComponent( "issue[subject]=Problem with analysis of Incident "+json.cad+"["+json.id+"]" )
		+ "&" + encodeURIComponent( "issue[description]=Bad analysis for available for ["+json.cad+"["+json.id+"]"+"]("
					    +window.location.href
					    +")\n\n"
					    +"User Agent: " + navigator.userAgent
					  )
	  $('#tmcpe_report_analysis_problem_link').attr('href',url);
	  $('#tmcpe_report_analysis_problem_link').attr('target', "_blank" );
      }
  }

  function updateLog( json ) {
      // clear existing
      var container = d3.select( '#logtableContainer' );

      $('#logtableContainer').children().remove();

      // select table element (for d3)
      var tab = container
	  .append("table")
	  .attr("id","activityLog");

      function renderLogTimestamp(obj) {
	  dd = new Date( obj );
	  return $.format.date(dd,'yyyy-MM-dd kk:mm');
      };

      var fields = [ {key:"stampDateTime",title:"Time",render:renderLogTimestamp}, 
		     {key:"activitySubject",title:"Activity"}, 
		     {key:"memoOnly",title:"Description"}, 
		   ];

      var head = tab.append("thead");


      head.append("tr").selectAll("th").data(fields).enter()
	  .append("th")
	  .attr("class",function(d){return d.key ? d.key : d;})
	  .html(function(d){return d.title ? d.title : d});


      var body = tab.append("tbody");

      function raiseLogEntry( d ) {
	  // In SVG, the z-index is the element's index in the dom.  To raise an
	  // element, just detach it from the dom and append it back to its parent
	  var targets = $("g[logid="+d.id+"]");
	  var target = targets[0];
	  var parent = target.parentNode;
	  targets.detach().appendTo( parent );
	  return 
      }

      // create log rows
      var rows = body.selectAll("tr")
	  .data(json.log,function(d) {return d.id})
	  .enter().append("tr")
	  .attr("id", function( d ) { return ["log",d.id].join("-"); })
	  .attr("logid", function( d ) { return d.id; })
	  .attr("class", function( d, i ) { return ( i % 2 ? "even" : "odd" ) + " " + d.type } )
	  .on("mouseover",function(d,e) {
	      // placehold, should highlight on TSD
	      d3.selectAll('g.activitylog').attr("class","logtimebar activitylog hidden");
	      d3.selectAll('g.activitylog[logid="'+d.id+'"]')
		  .attr("class",function(dd,e){
		      raiseLogEntry(dd);
		      return "logtimebar activitylog";
		  });
	  } );
      
      // now populate rows
      rows.selectAll("td")
	  .data(function(d) {
	      var props = [];
	      $.each( fields, function( i, dd ) {
		  var item = d[dd.key];
		  props.push( dd.render ? dd.render( item ) : item );
	      });
	      return props;
	  })
	  .enter().append("td")
	  .attr("class", function(d,i) { return fields[i].key } )
	  .text( function(dd) { return dd; } );

      $("#activityLog").dataTable({ 
	  bPaginate: false, sScrollY:"200px","bAutoWidth":false,"bFilter": false,

	  "aoColumns": [
	      {"sWidth": "20%", "sType":"date" },
	      {"sWidth": "20%", "sType":"string" },
	      {"sWidth": "60%", "sType":"string" }
	  ]});
      
      
  }

  function updateTsd() {
     tsd.updateCellStyle( ); // update style
     tsd.updateCellAugmentation( ); // update style
  }

  function updateCumFlowStats() {
     cumflow.tmcDivPct( $("#tmcpct").text() );

      var unit = $('input[name=delayUnit]:checked').val();
      var vot = $("#valueOfTime")[0];

      if ( unit == 'usd' ) {
          $('#valueOfTime').attr("disabled","");

          if ( vot != "" ) {
	      $(".delayValue").each(function() { 
		  var val = this.innerText*vot.value;
		  this.innerHTML = val.toFixed();
	      });
              $(".delayUnit").each(function() { 
		  this.innerHTML = "USD";
	      });
          }
      } else {
          $('#valueOfTime').attr("disabled","disabled");
          $(".delayUnit").each(function() { 
	      this.innerHTML = "veh-hr";
	  });
      }
  }

  function changeUnit(v) {
      updateCumFlowStats();
  }

  function updateAnalysis( id ) {
      $(window).trigger( "tmcpe.tsd.analysisRequested", { id: id } );
      
      var url = g.createLink({controller:'incidentFacilityImpactAnalysis', 
			      action:'tsdData',
			      params: {id: id.value} 
			     });
      d3.json(url,function(e){
	  if ( e == null || e.timesteps == null ) {
	      // this is an error condition
	      $('#server_error').overlay({load:true});
	      return;
	  }

	  // convert date strings to date objects
	  e.timesteps = e.timesteps.map( function( d ) { return new Date(d); } ); 

	  // add the sectionindex conversion function
	  // get section index from vdsid
	  e.getSectionIndex = function( id ) {
	      if ( e.sections == null || e.sections.length == 0 ) {
		  return null;
	      }
	      var sec = e.sections.length-1; // default to the last
	      var ii;
	      for( ii = 0; ii < e.sections.length; ++ii ) {
		  if ( e.sections[ii].vdsid == id ) 
		      sec = (ii==e.sections.length-1?ii:ii+1);
	      }
	      return sec;
	  }
	  
	  // broadcast the new data
	  $(window).trigger( "tmcpe.tsd.analysisLoaded", e );
      });
      
      $('#generalStats #facility').html(id.children[0].innerHTML);
  }

  $(document).ready(function() {
      // create the various views to show the data
      var tsdView = tmcpe.tsd()
	  .container( $("#tsdbox")[0] )
      	  .cellStyle( cellStyle )
	  .cellAugmentStyle( cellAugmentStyle );

      var cumflowView = tmcpe.cumflow()
              .container( $("#chartbox")[0] )

      var mapView = tmcpe.segmap().container( $("#mapbox")[0] );

      var tsdParamsView = tmcpe.tsdParamsView()
	  .container($('#tsdParams'))
      ;

      // put the settings in the true header (from base.gsp)
      var settings = $("#settings").detach();
      settings.appendTo('.header');
      
      // bind events
      var loadingOverlay;
      $(window).bind("tmcpe.tsd.analysisRequested", function( caller, d ) {
	  loadingOverlay = $("#loading").overlay({load:true, closeOnClick:false, api:true});
      });

      // Event called when a new analysis has been processed from the server
      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {

	  updateViews( json );

	  if ( loadingOverlay ) loadingOverlay.close();
      });

      
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD

      $("#ifia").each(function() {
	  if ( this.value != "" ) {
  	      updateAnalysis( this ); 
 	  } else {
	      $("#msgtxt").text("NO ANALYSES AVAILABLE");
	  }
      });
      //d3.select('#ifia').on("change",function(d){this.options[this.selectedIndex]});
      //d3.select('#theme').on("change",function(d){updateTsd()});
      //d3.select('#valueOfTime').on("change",function(d){updateCumFlowStats()});
      

      $("#databox .tabs").tabs( 'div.panes > div' );

/*
      {
	  // hack to resize columns in a tab: http://datatables.net/examples/api/tabs_and_scrolling.html
	  "show": function(event, ui) {
	      var oTable = $('div.dataTables_scrollBody>table', ui.panel).dataTable();
	      if ( oTable.length > 0 ) {
		  oTable.fnAdjustColumnSizing();
	      }
	  }
      } );
*/
      var gs = $("#generalStats");
      gs.dataTable({
	  "bPaginate": false,
	  "sScrollY": gs.parent().height()*.5,
	  "bLengthChange": false,
	  "bFilter": false,
	  "bSort": false,
	  "bInfo": false,
	  "aoColumns": [
	      {"sWidth": "60%", "sType":"string", "sClass":"right" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" },
	      {"sWidth": "10%", "sType":"number", "sClass":"left" }
	  ]
      } );
      

      // Helper function to update views based upon (analysis) data received from the server
      function updateViews( data ) {

	  // Select a time to synchronize
	  $(window).trigger("tmcpe.tsd.selectedSection",{sectionidx:cumflowView.section()});

	  updateStats( data );

	  updateLog( data );

	  // update the $$ calc
	  cumflowView.tmcDivPct( $("#tmcpct").text() );

	  // update the band and max speed sliders
	  /*
	    $('#maxspdslider').slider('value',json.parameters.maxIncidentSpeed);
	    $('#maxspd').text(json.parameters.maxIncidentSpeed);
	  */

	  // create the map
	  //doMap( json );

	  // if the window is resized, recompute the bounds of all the components.
	  $(window).resize(function() { 
              tsdView.resize(); 
              tsdView.redraw(); 
	      cumflowView.resize( );
	      cumflowView.redraw( );
	      updateStats( data );
	      updateLog( data );
	      //	 doMap( data );
              mapView.data(data).redraw();
	  });

      }


  });

 })()