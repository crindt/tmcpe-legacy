(function()
 {tmcpe = {version: "1.99.0"};

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

  tmcpe.util.color = function( d, scale ) {
      var col = "#ccc";
      var themeScale=scale?scale:1.0;
      if ( d != null && d.spd != null && d.spd_avg != null && d.spd_std != null 
	   && ( d.p_j_m == 0 || d.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	   //		 && d.days_in_avg < 30  // fixme: make this a parameter
	   //		 && d.pct_obs_avg < 30  // fixme: make this a parameter
	 ) {
	  col = tmcpe.util.getGRColor( (d.spd-d.spd_avg)/d.spd_std, -themeScale, 0, '#ff0000','#00ff00' );
      }
      return col;
  };

  tmcpe.tsd = {};

  tmcpe.tsd.redraw = function( json ) {
      var data = json.data;
      var sections = json.sections;
      var fn = [grid0, grid1],
      dw = data[0].length,
      dh = data.length;
      szs = 20,
      szt = 800/data[0].length,
      grid = grid1,
      p = 20;
      var twidth = szt*dw,
      theight = szs*dh;
      var seclensum = 0;
      sections.each(function(s)
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
	      .attr("d", function(d) { return "M" + d.join("L") + "Z"; });
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
      
      function mouseover(d,i) {
	  updateText( "inc:" + d.inc + ", spd:" + d.spd + ", occ:" + Math.floor(d.occ*100+0.5) + "%, vol:" + d.vol + ", loc: " +sections[d.i].name +", lanes: " + sections[d.i].lanes );
	  return;
      }

      function avgmouseover(d,i) {
	  updateText( "Delay due to incident" );
      }

      function obsmouseover(d,i) {
	  updateText( "Observed delay" );
      }



      // create a message box for mouseover display
      var text = d3.select("body")
	  .append("p")
	  .text("Nothing selected");


      // create the svg box
      var svg0 = d3.select("body")
          .append("svg:svg")
          .attr("width", twidth + 3*p/*theight/*twidth*/ )
          .attr("height", theight + 2*p/*twidth/*theight*/ )
	  .append("svg:g")
	  .attr("transform", "translate(" + 2*p + "," + p + ")");
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


      d3.select("body").append("br");

      // create a transform for the svg box that rotates it 90 degrees clockwise
      //	  var svg = svg0.append("svg:g").attr("transform","translate(0,"+(-theight)+")" + " rotate(90,0,"+theight+")" );
      var svg = svg0;     
      
      // now, create the rows of data.
/*
      var g = svg.selectAll("g.evidence")
          .data(data)
          .enter().append("svg:g")
          .attr("transform", function(d, i) { 
	      var dist = 0;
	      var j;
	      for ( j = 0; j<i; ++j ) { dist += sections[j].seglen; }
  	      var val = theight*dist/seclensum;
	      return "translate(0,"+(val)+")"; 
	  });
      
      // next, in each row, create the evidence
      g.selectAll("rect")
          .data(function(d) { return d; })
          .enter().append("svg:rect")
      //.attr("class", function(d) { return "d"+d.inc; })
	  .attr("style", function(d) { return d.p_j_m < 0.5 ? "fill:url(#hatch00)" : ""; })
          .attr("width", szt )
          .attr("transform", translateX )
          .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
*/
      
      // now, create the rows of data.
      var gg = svg.selectAll("g")
          .data(data)
          .enter().append("svg:g")
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
	      return "fill:"+tmcpe.util.color(d)+";fill-opacity:1;stroke:#eee;"; })
          .attr("width", szt )
          .attr("transform", translateX )
          .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
          .on("mouseover", mouseover)
          .on("click", function( d, i ) { 
	      d3.selectAll(".flowchart").remove();
	      tmcpe.cumflow.doChart( json, d.i/*sections[d.i].vdsid*/ ); 
	  } );
      
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

      if ( loc == null ) loc = getSection( json, json.sec );
      
      var cvol = 0;
      function sfunc (json,i) {
	  cvol+=json.data[loc][i].vol/1000.0; 
	  return cvol;
      }
      var cvol2 = 0;
      function sfunc2 (json,i) {
	  cvol2+=json.data[loc][i].vol_avg/1000.0; 
	  return cvol2;
      }
      var data = d3.range( json.timesteps.length ).map(function(i) {
	  return {x:json.timesteps[i].getTime()/1000,y: sfunc(json,i), y2: sfunc2(json,i) }
      });
      
      var dyn = data.map(function(d) { return d.y }).min();
      var dyx = data.map(function(d) { return d.y }).max();
      var dyx2 = data.map(function(d) { return d.y2 }).max();

      var w = 800,
      h = 300,
      x = d3.scale.linear().domain([json.timesteps[0].getTime()/1000,json.timesteps[json.timesteps.length-1].getTime()/1000]).range([0, w]),
      y = d3.scale.linear().domain(/*[0,20]*/[dyn, [dyx,dyx2*1.05].max()]).range([h, 0]),
      now = new Date();
      
      var vis = d3.select("body")
	  .append("svg:svg")
	  .attr("class", "flowchart" )
	  .data([data])
	  .attr("width", w + p * 3)
	  .attr("height", h + p + 100)
	  .append("svg:g")
	  .attr("transform", "translate(" + 2*p + "," + p + ")");
      
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
      
      function val (xx) {
	  return "rotate("+[90,x(xx),(h+3)].join(",")+")"
      }
      
      rules2.append("svg:text")
	  .attr("y", y)
	  .attr("x", -3)
	  .attr("dy", ".35em")
	  .attr("text-anchor", "end")
	  .text(y.tickFormat(10));

      rules.append("svg:text")
	  .attr("x", x)
	  .attr("y", h + 3)
	  .attr("dy", ".25em")
	  .attr("text-anchor", "start")
	  .attr("transform",function(d) { return val(d); } )
	  .text(/*x.tickFormat(10)*/ function (x) { 
	      return new Date( x*1000 ).toLocaleTimeString()
	  } );
      
      

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
	      vis.selectAll( "g.area2 path" )
		  .transition()
		  .attr("fill-opacity", 1 );
	  } )
	  .on("mouseout", function (d,i) { 
	      updateText( "&nbsp;" );
	      vis.selectAll( "g.area2 path" )
		  .filter( function (d,j) { 
		      return j == i;
		  } )
		  .transition()
		  .attr("fill-opacity", 0.5 );
	  } );
      
      vis.append("svg:path")
	  .attr("class", "line2")
	  .attr("d", d3.svg.line()
		.x(function(d) { return x(d.x); })
		.y(function(d) { return y(d.y2); }));



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
      var t0 = new Date( json.t0 ).getTime()/1000;
      var t1 = new Date( json.t1 ).getTime()/1000;
      var t2 = new Date( json.t2 ).getTime()/1000;
      var t3 = new Date( json.t3 ).getTime()/1000;

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
  };


 })()