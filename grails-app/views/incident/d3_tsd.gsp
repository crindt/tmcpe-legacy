<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Incident Detail</title>

<style type='text/css'> 
 svg {
  border: solid 1px #aaa;
}
path {
  stroke: blue;
  stroke-width: 4px;
  fill: none;
}
rect {
  fill: lightsteelblue;
  stroke: #eee;
  stroke-width: 2px;
}
rect.d1 {
  fill: steelblue;
}
rect.d2 {
  fill: darkblue;
}

 
.rule line {
  stroke: #eee;
  shape-rendering: crispEdges;
}
 
.rule line.axis {
  stroke: #000;
}
 
.area {
  fill: steelblue;
    fill-opacity: 0.75;
}
 
.line, circle.area {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}
 
.area2 {
  fill: red;
  fill-opacity: 0.5;
}

.timebar {
    stroke: purple;
    stroke-width: 4px;
}
 
.line2, circle.area2 {
  fill: none;
  stroke: yellow;
  stroke-width: 1.5px;
}
 
circle.area {
  fill: #fff;
}

</style> 

    <p:javascript src='d3/d3' />
    <p:javascript src='d3/d3.geom' />
    <g:javascript library="prototype" />
    
  </head>
  <body>

    <g:javascript>
      var themeScale=1.0;

      function getGRColor( /*float*/ val, /*float*/ min, /*float*/ max, /*float*/ minval, /*float*/ maxval ) {
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
	  var ret = "#"+[ toColorHex( r*255 ), toColorHex( g*255 ), toColorHex( b*255 ) ].join("");
	  return ret;
      }

      function toColorHex( /* integer */ v ) {
	  // summary:
	  //		helper function to convert a decimal integer to a hexidecimal value
	  var val = parseInt( v ).toString( 16 );
	  if ( val.length < 2 ) val = '0' + val;
	  return val;
      }


      function color( d ) {
	  var col = "#ccc";
	  if ( d != null && d.spd != null && d.spd_avg != null && d.spd_std != null 
	       && ( d.p_j_m == 0 || d.p_j_m == 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
	       //		 && d.days_in_avg < 30  // fixme: make this a parameter
	       //		 && d.pct_obs_avg < 30  // fixme: make this a parameter
	     ) {
	      col = getGRColor( (d.spd-d.spd_avg)/d.spd_std, -themeScale, 0, '#ff0000','#00ff00' );
	  }
	  return col;
      }

      function updateData( e ) {
	  var json = e.responseJSON;
	  json.timesteps = json.timesteps.map( function( d ) { return new Date(d); } ); // convert date strings to date objects
	  redraw(json);
      }

      function handleFailure( e ) {
	  return "poof";
      }

/* crindt: this tag doesn't do asynchronous or put the get method...
      <g:remoteFunction controller="incidentFacilityImpactAnalysis" action="tsdData" method="GET" asynchronous="false" id="${incidentInstance.analyses.first().incidentFacilityImpactAnalyses.first().id}" onSuccess="updateData(e)" onFailure="wtf(e)"></g:remoteFunction>
*/
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD
      new Ajax.Request('/tmcpe/incidentFacilityImpactAnalysis/tsdData/${incidentInstance.analyses.first().incidentFacilityImpactAnalyses.first().id}',{asynchronous:false,evalScripts:true,onSuccess:function(e){updateData(e)},onFailure:function(e){handleFailure(e)},method:'get'});
 
      function translateY(d, i) { return "translate(0,"+(i*szs)+")"; }
      function translateX(d, i) { return "translate("+(i*szt)+",0)"; }
      function computeWidth(d, i) {
	  var wid = twidth*sections[i].seglen/seclensum; 
	  return wid;
      }
	
      function redraw( json ) {
	  var data = json.data;
	  var sections = json.sections;
          var fn = [grid0, grid1],
             dw = data[0].length,
             dh = data.length;
             szs = 50,
   	     szt = 20,
             grid = grid1;
	  var twidth = szt*dw,
	     theight = szs*dh;
	  var seclensum = 0;
	  sections.each(function(s)
			{
			    seclensum+=s.seglen;
			}
		       );

	  function grid0(x,y) {
	      if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	      return data[y][x].inc==0;
	  }
	  function grid1(x,y) {
	      if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	      return data[y][x].inc==1;
	  }

	  // create the svg box
          var svg0 = d3.select("body")
                      .append("svg:svg")
                      .attr("width", theight/*twidth*/ )
              .attr("height", twidth/*theight*/ )
	  ;

	  // create a transform for the svg box that rotates it 90 degrees clockwise
	  var svg = svg0.append("svg:g").attr("transform","translate(0,"+(-theight)+")" + " rotate(90,0,"+theight+")" );

	  // create a message box for mouseover display
	  var text = d3.select("body")
	      .append("p")
	      .text("Nothing selected");
     
	  
	  // now, create the rows of data.
          var g = svg.selectAll("g")
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
          g.selectAll("rect")
              .data(function(d) { return d; })
              .enter().append("svg:rect")
              //.attr("class", function(d) { return "d"+d.inc; })
	      .attr("style", function(d) { return "fill:"+color(d)+";stroke:#eee;"; })
              .attr("width", szt )
              .attr("transform", translateX )
              .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
              .on("mouseover", mouseover);
     
	  // finally, draw a contour around the incident region.
          contour(grid);

	  function getSection( json, id ) {
	      var sec = json.sections.length-1; // default to the last
	      var ii;
	      for( ii = 0; ii < json.sections.length; ++ii ) {
		  if ( json.sections[ii].vdsid == id ) 
		      sec = (ii==json.sections.length-1?ii:ii+1);
	      }
	      return sec;
	  }

	  doChart( json, getSection( json, json.sec ) );
 
//var data = d3.range(20).map(function(i) {
//  return {x: i / 19, y: (Math.sin(i / 3) + 1) / 2};
//});

	  // next, append a chart showing flows
	  function doChart( json, loc ) {

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
	      h = 500,
	      p = 20,
	      x = d3.scale.linear().domain([json.timesteps[0].getTime()/1000,json.timesteps[json.timesteps.length-1].getTime()/1000]).range([0, w]),
	      y = d3.scale.linear().domain(/*[0,20]*/[dyn, [dyx,dyx2*1.05].max()]).range([h, 0]),
	      now = new Date();
	      
	      var vis = d3.select("body")
		  .append("svg:svg")
		  .data([data])
		  .attr("width", w + p * 2)
		  .attr("height", h + p * 2 + 100)
		  .append("svg:g")
		  .attr("transform", "translate(" + p + "," + p + ")");
	      
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
	      
	      rules.append("svg:line")
		  .attr("class", function(d) { return d ? null : "axis"; })
		  .attr("y1", y)
		  .attr("y2", y)
		  .attr("x1", 0)
		  .attr("x2", w + 1);
	      
	      function val (xx) {
		  return "rotate("+[90,x(xx),(h+3)].join(",")+")"
	      }
	      
	      rules.append("svg:text")
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
	      vis.append("svg:path")
		  .attr("class", "area2")
		  .attr("d", d3.svg.area()
			.x(function(d) { return x(d.x); })
			.y0(h - 1)
			.y1(function(d) { return y(d.y2); }))
	          .on("mouseover", avgmouseover )
	      	  .on("mouseout", function () { updateText( "&nbsp;" ) } );
		      
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
	      updateText( "inc:" + d.inc + ", spd:" + d.spd + ", occ:" + Math.floor(d.occ*100+0.5) + "%, vol:" + d.vol );
	      return;
	  }

	  function avgmouseover(d,i) {
	      updateText( "Delay due to incident" );
	  }

	  function obsmouseover(d,i) {
	      updateText( "Observed delay" );
	  }
 
	  function contour(grid, start) {
	      svg.selectAll("path")
		  .data([d3.geom.contour(grid, start).map(scale)])
		  .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
		  .enter().append("svg:path")
		  .attr("d", function(d) { return "M" + d.join("L") + "Z"; });
	  }
      }
    </g:javascript>     
  </body>

</html>
