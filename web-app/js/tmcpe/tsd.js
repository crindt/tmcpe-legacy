(function()
 {tmcpe = {version: "1.99.0"};

  Array.max = function( array ){
      return Math.max.apply( Math, array );
  };
  Array.min = function( array ){
      return Math.min.apply( Math, array );
  };

  tmcpe.util = {};

  tmcpe.util.getGRColor = function( val, min, max,  minval, maxval ) {
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
      var ret = "#"+[ tmcpe.util.toColorHex( r*255 ), tmcpe.util.toColorHex( g*255 ), tmcpe.util.toColorHex( b*255 ) ].join("");
      return ret;
  };

  tmcpe.util.toColorHex = function( /* integer */ v ) {
      // summary:
      //		helper function to convert a decimal integer to a hexidecimal value
      var val = parseInt( v ).toString( 16 );
      if ( val.length < 2 ) val = '0' + val;
      return val;
  };

  tmcpe.util.color = function( d, trans, scale ) {
      var col = "#ccc";
      trans = trans ? trans : function( dd ) { return (dd.spd-dd.spd_avg)/dd.spd_std };
      var themeScale=scale?scale:-1.0;
      if ( d != null && d.spd != null && d.spd_avg != null && d.spd_std != null 
	   && ( d.p_j_m == 0 || d.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	   //		 && d.days_in_avg < 30  // fixme: make this a parameter
	   //		 && d.pct_obs_avg < 30  // fixme: make this a parameter
	 ) {
	  col = tmcpe.util.getGRColor( trans( d ), -themeScale, 0, '#ff0000','#00ff00' );
      }
      return col;
  };

  tmcpe.util.evidenceOfIncident = function( d, scale, maxIncidentSpeed ) {
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

  tmcpe.tsd = {};

  tmcpe.plottrajectory = function( d, i ) {
      
  }

  tmcpe.hh = 500;
  tmcpe.ww = 600;

  tmcpe.tsd.redraw = function( json ) {
      var data = json.data;
      var sections = json.sections;
      var fn = [grid0, grid1],
      dw = data[0].length,
      dh = data.length;
      grid = grid1,
      p = 20,  // padding
      szs = (tmcpe.hh-2*p)/dh,
      szt = tmcpe.ww/dw;
      var twidth = szt*dw,
         theight = szs*dh;
      var seclensum = 0;
      $.each(sections, function(i,s)
		    {
			seclensum+=s.seglen;
		    }
		   );


      function translateY(d, i) { return "translate(0,"+(i*szs)+")"; };
      function translateX(d, i) { return "translate("+(i*szt)+",0)"; };

      function grid0(x,y) {
	  if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	  return data[y][x].inc==0;
      }
      function grid1(x,y) {
	  if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	  return data[y][x].inc==1;
      }

  
      function contour(grid, start) {
	  svg.selectAll("path")
	      .data([d3.geom.contour(grid, start).map(scale)])
	      .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
	      .enter().append("svg:path")
	      .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
	      .attr("class","incidentBoundary");
      }

      function scale(p) { 
	  var dist = 0;
	  var j;
	  for ( j = 0; j<p[1]; ++j ) { 
	      dist += sections[j].seglen; 
	  }
	  var val = theight*dist/seclensum;
	  return [p[0]*szt, val]; 
      }
      
      
      function updateText( newText ) {
	  text.html( newText );
      }

      function updateData( json ) {
//	  svg.select("#d12d").text( json.
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
		  var nod = $('circle[id^="node:'+sections[e.__data__.i].vdsid+'"]');
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


      function syncchart( json ) {
	  return function( d, i ) { 
	      d3.selectAll(".flowchart").remove();
	      tmcpe.cumflow.doChart( json, d.i ); 

	      // update cross hatch
	      var cross = svg.selectAll("#tsdsec")
		  .data([1])
		  .attr("transform", function(dd, ii) { 
		      var dist = 0;
		      var j;
		      for ( j = 0; j<d.i; ++j ) { dist += sections[j].seglen; }
  		      var val = theight*(dist+sections[d.i].seglen/2)
			  /seclensum;
		      return "translate(0,"+(val)+")"; 
		  })
		  .attr("x1",0)
		  .attr("y1",0)
		  .attr("x2",twidth)
		  .attr("y2",0)
		  .attr("style","stroke:purple;stroke-width:3");


	      // create cross hatch if it doesn't exist
	      cross.enter()
		  .append("svg:line")
		  .attr("id","tsdsec")
		  .attr("transform", function(dd, ii) { 
		      var dist = 0;
		      var j;
		      for ( j = 0; j<d.i; ++j ) { dist += sections[j].seglen; }
  		      var val = theight*(dist+sections[d.i].seglen/2)
			  /seclensum;
		      return "translate(0,"+(val)+")"; 
		  })
		  .attr("x1",0)
		  .attr("y1",0)
		  .attr("x2",twidth)
		  .attr("y2",0)
		  .attr("style","stroke:purple;stroke-width:3");

	      // highlight edge
	      var seg = $('path[id^='+sections[d.i].vdsid+']');
	      seg.map( function (jj, s) { 
		  s.style.setProperty("stroke-width",6 ) } );

	  };
      };



      // create a message box for mouseover display
      var text = d3.select("#msgtxt").text("Nothing selected");


      // create the svg box
      var svg0 = d3.select("#tsdbox")
          .append("svg:svg")
          .attr("width", twidth + 6*p/*theight/*twidth*/ )
          .attr("height", theight + 2*p/*twidth/*theight*/ )
	  .append("svg:g")
	  .attr("transform", "translate(" + 5*p + "," + p + ")");
      svg0.append("svg:defs")
	  .append("svg:pattern")
	  .attr("id","hatch00")
	  .attr("patternUnits","userSpaceOnUse")
	  .attr("x",0)
	  .attr("y",0)
	  .attr("width",5)
	  .attr("height",5)
	  .append("svg:g")
	  .attr("style","fill:none;stroke:black; stroke-width:1")
          .append("svg:line")
	  .attr("x1",0)
	  .attr("y1",0)
	  .attr("x2",5)
	  .attr("y2",5)
	  .on("keydown",function( k ) {
	      console.log( k );
	  });

      // create a transform for the svg box that rotates it 90 degrees clockwise
      //	  var svg = svg0.append("svg:g").attr("transform","translate(0,"+(-theight)+")" + " rotate(90,0,"+theight+")" );
      var svg = svg0;     
      
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
          .data(function(d) { return d; })
          .enter().append("svg:rect")
      //.attr("class", function(d) { return "d"+d.inc; })
	  .attr("style", function(d) { 
	      return "fill:"+tmcpe.util.color(d,function( dd ) { 
		  return (dd.spd-dd.spd_avg)/dd.spd_std;
	      }, -1 )+";fill-opacity:1;stroke:#eee;"; })
	  .attr("i", function(d){return d.i;} )
	  .attr("j", function(d){return d.j;} )
          .attr("width", szt )
          .attr("transform", translateX )
          .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
          .on("mouseover", mouseover)
          .on("click", syncchart( json ) );

      gg.append("svg:text")
//	  .attr("dx",twidth)
	  .attr("dy",function (d,i) { 
	      return theight*sections[d[0].i].seglen/seclensum/2+5; } ) // put midway down
	  .attr("text-anchor","end")
	  .text(function(d,i){ 
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
          .data(function(d) { return d; })
          .enter().append("svg:circle")
      //.attr("class", function(d) { return "d"+d.inc; })
	  .attr("style", function(d) { 
	      return tmcpe.util.evidenceOfIncident( d, $("#scaleslider").slider("option","value"), $("#maxspdslider").slider("option","value") ) ? "fill:black;" : "fill:none"; })
          .attr("cx", function (d, i ) { return ((i+0.5)*szt) } )
          .attr("cy", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum)/2; })
	  .attr("r", 2 );


      

      
      // finally, draw a contour around the incident region.
      contour(grid);

      return svg;

  }

  function getSection( json, id ) {
      var sec = json.sections.length-1; // default to the last
      var ii;
      for( ii = 0; ii < json.sections.length; ++ii ) {
	  if ( json.sections[ii].vdsid == id ) 
	      sec = (ii==json.sections.length-1?ii:ii+1);
      }
      return sec;
  }

  tmcpe.cumflow = {};

  tmcpe.cumflow.doChart = function( json, loc ) {

      var text = d3.select("#msgtxt");

      if ( loc == null ) {
	  loc = getSection( json, json.sec );
	  loc--;  // fixme: crindt: we really want to use the incident section by default, not the downstream section.
      }
      
      function sfunc (json,i,j,ff,vol) {
	  if ( vol == null ) vol = 0;
	  if ( j < 0 ) 
	      return vol;
	  else 
	      return sfunc( json, i, j-1, ff, vol + ff(json.data[i][j]) ); 
      }

      var t0 = new Date( json.t0 ).getTime()/1000;
      var t1 = new Date( json.t1 ).getTime()/1000;
      var t2 = new Date( json.t2 ).getTime()/1000;
      var t3 = new Date( json.t3 ).getTime()/1000;

      var startCell = json.timesteps.filter( function (e) {
	  return !t1 || (e.getTime()/1000 < t1);
      }).length-1;

      var finishCell = json.timesteps.filter( function (e) {
	  return !t3 || (e.getTime()/1000 < t3);
      }).length;

      // fixme: crindt: we really want to use the incident section by default, not the downstream section.
      var diversion = sfunc(json,getSection(json,json.sec)-1,finishCell,function(v){return v.vol_avg/1000.0})
	  - sfunc(json,getSection(json,json.sec)-1,finishCell,function(v){return v.vol/1000.0});

      var data = d3.range( json.timesteps.length ).map(function(j) {
	  return {x:json.timesteps[j].getTime()/1000+300,
		  y: sfunc(json,loc,j,function(v){return v.vol/1000.0}), 
		  y2: sfunc(json,loc,j,function(v){return v.vol_avg/1000.0}),
		  y3: ( j < startCell
			?  sfunc(json,loc,j,function(v){return v.vol_avg/1000.0})
			: ( j > finishCell
			    ? sfunc(json,loc,j,function(v){return v.vol_avg/1000.0}) - diversion
			    : sfunc(json,loc,j,function(v){return v.vol_avg/1000.0}) - diversion*(j-startCell)/(finishCell-startCell) ) )
		 }
      });

      // add zeroed elements at the beginning
      data.unshift( { x:json.timesteps[0].getTime()/1000,y:0,y2:0,y3:0} );
      
      // Compute the maximum cumulative flow across all sections (to set the max)
      var tt = Array.max( json.data.map( function( r ) { 
	  return Array.max( [ sfunc( json, r[0].i,r.length-1, function(v){return v.vol/1000.0}), 
			      sfunc( json, r[0].i,r.length-1, function(v){return v.vol_avg/1000.0}) ] );
      } ) );


      var w = tmcpe.ww,
      h = 400,
      x = d3.scale.linear().domain([json.timesteps[0].getTime()/1000,json.timesteps[json.timesteps.length-1].getTime()/1000+300]).range([0, w]),
      y = d3.scale.linear().domain(/*[0,20]*/[0, tt]).range([h, 0]),
      now = new Date();
      
      var vis = d3.select("#chartbox")
	  .append("svg:svg")
	  .attr("class", "flowchart" )
	  .data([data])
	  .attr("width", w + 6*p)
	  .attr("height", h + p + 100)
	  .append("svg:g")
	  .attr("transform", "translate(" + 5*p + "," + p + ")");
      
      var rr = d3.range( json.timesteps[0].getTime()/1000,
			 json.timesteps[json.timesteps.length-1].getTime()/1000+300,
			 300 );
      var rr2 = x.ticks(json.timesteps.length);
      var rules = vis.selectAll("g.rule")
	  .data( rr )
	  .enter().append("svg:g")
	  .attr("class", "rule");
      
      rules.append("svg:line")
	  .attr("x1", x)
	  .attr("x2", x)
	  .attr("y1", 0)
	  .attr("y2", h - 1);

      var rules2 = vis.selectAll("g.rule2")
	  .data(y.ticks(10))
	  .enter().append("svg:g")
	  .attr("class","rule2");
      
      rules2.append("svg:line")
	  .attr("class", function(d) { return d ? null : "axis"; })
	  .attr("y1", y)
	  .attr("y2", y)
	  .attr("x1", 0)
	  .attr("x2", w + 1);
      
      function xlabel_rotate (xx) {
	  return "rotate("+[90,x(xx),(h+3)].join(",")+")"
      }
      
      rules2.append("svg:text")
	  .attr("y", y)
	  .attr("x", -3)
	  .attr("dy", ".35em")
	  .attr("text-anchor", "end")
	  .text(y.tickFormat(10))
	  .attr("class","ylabels");

      rules.append("svg:text")
	  .attr("x", x )
	  .attr("y", h + 5 - szt )
	  .attr("dy", ".25em")
	  .attr("text-anchor", "start")
	  .attr("transform",function(d) { return xlabel_rotate(d); } )
	  .text(/*x.tickFormat(10)*/ function (x) { 
	      return new Date( x*1000 ).toLocaleTimeString()
	  } )
	  .attr("class","xlabels");
      
      

      // averages
      vis.append("svg:g")
	  .attr("class", "area2")
	  .append("svg:path")
	  .attr("d", d3.svg.area()
		.x(function(d) { return x(d.x); })
		.y0(h - 1)
		.y1(function(d) { return y(d.y2); }))
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

      // compute delay from implied queuing
      var delay2 = 0;
      $.each( data, function(i, d) {
	  delay2 += (d.y3-d.y)*1000*5/60;
      });

      d3.select("#chartDelay2").html( delay2.toFixed(0) );

      // divavg
      if ( loc == getSection( json, json.sec )-1 ) {
	  vis.append("svg:g")
	      .attr("class", "area3")
	      .append("svg:path")
	      .attr("d", d3.svg.area()
		    .x(function(d) { return x(d.x); })
		    .y0(h - 1)
		    .y1(function(d) { return y(d.y3); }))
	      .on("mouseover", function( d,i ) { 
		  updateText( "Delayed non-diverted traffic" );
/*
		  vis.selectAll( "g.area3 path" )
		      .transition()
		      .attr("fill-opacity", 1 );
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
		      .attr("fill-opacity", 0.5 );
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
		.y0(h - 1)
		.y1(function(d) { return y(d.y); }))
	  .on("mouseover", obsmouseover )
	  .on("mouseout", function () { updateText( "&nbsp;" ) } );

      
      vis.append("svg:path")
	  .attr("class", "line")
	  .attr("d", d3.svg.line()
		.x(function(d) { return x(d.x); })
		.y(function(d) { return y(d.y); }));


      // draw start of incident

      var tr = [ t0, t1, t2, t3 ].filter( function( x ) { return x != null; } );
      var times = vis.selectAll("g.timebar")
	  .data( tr )
	  .enter().append("svg:g")
	  .attr("class", "timebar");

      times.append("svg:line")
	  .attr("x1", x )
	  .attr("x2", x )
	  .attr("y1", 0 )
	  .attr("y2", h - 1 );


      function avgmouseover(d,i) {
	  updateText( "Delay due to incident" );
      }

      function obsmouseover(d,i) {
	  updateText( "Observed delay" );
      }

      function updateText(msg) {
	  d3.select("#msgtxt").html(msg);
      }


  };


 })()