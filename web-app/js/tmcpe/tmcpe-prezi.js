

if ( !tmcpe ) var tmcpe = {};
(function()
 {tmcpe.version = "0.1";
  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };
  tmcpe.query = {};

  //po = org.polymaps;

  ////////////////////////////////////////////////////////////////////////////////
  // Instantiates and manages the map display of the incidents in the query
  tmcpe.prezi = function()    {  
      var prezi = {}
      ,container
      ,curSlide=0;
      ;

      // create the base map
      function init() {
	  if ( container == null ) return;
	  // empty container
	  $(container[0]).children().remove();

	  var vpt = d3.selectAll(container[0])
	      .append("svg:svg")
	      .attr("width",function(d){ 
		  return 800; })
	      .attr("height",600)
	      .attr("class","viewport")
	      .on("click",function(){nextSlide()})
	  ;

	  vis = vpt.selectAll("g.viewgroup")
	      .data([{"x":0,"y":0,"scale":2.0,"slide":0}])
	      .enter()
	      .append("svg:g")
	      .attr("class","viewgroup")
	      .attr("transform",function(d) { return "scale("+d.scale+")"; })
	  ;

	  var slide = vis.selectAll("g.slide")
	      .data([{x:20,y:20,id:"test",t:"Test",z:3.0,w:300,h:300,rotate:0},
		     {x:500,y:20,id:"test2",t:"Test 2",z:3.0,w:300,h:300,rotate:0}],
		    function(d){return d.id;})
	      .enter().append("svg:g")
	      .attr("class","slide")
	      .attr("id",function(d) { return "slide_"+d.id; })
	      .attr("transform",function(d) { return renewTransform(d); });

	  slide.selectAll("rect")
	      .attr("class","frame")
	      .attr("width",function(d){return d.w;})
	      .attr("height",function(d){return d.h;});

	  var boxgroup = slide.selectAll("g.boxgroup")/*.selectAll("#test")*/
	      .data([
		  {"id":"first","dx":50,"dy":20,"text":"Identification<ul><li><em>Notify CT/CHP Staff</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":120,"dy":90,"text":"Verification<ul><li><em>Confirm location</em></li><li><em>Determine type</em></li><li><em>Determine severity</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":190,"dy":160,"text":"Response<ul><li><em>Disseminate</em></li><li><em>Field response</em></li><li><em>Coordinate</em></li><li><em>Manage</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":260,"dy":230,"text":"Monitoring<ul><li><em>Condition changes</em></li><li><em>Multiple incidents</em></li><li><em>Performance reports</em></li></ul>","w":100,"h":50}
	      ])
	      .enter().append("svg:g")
	      .attr("class","boxgroup")
	      .attr("id",function(d) { return "boxgroup_"+d.id; })
	      .attr("transform",function(d) { return "translate("+d.dx+","+d.dy+")"; })

	  boxgroup.append("svg:rect")
	      .attr("class","box")
	      .attr("width",function(d){return d.w;})
	      .attr("height",function(d){return d.h;})
	      .attr("rx",3)
	      .attr("ry",3)
	  ;
	  ;	  
	  boxgroup.append("svg:foreignObject")
	      .attr("width",function(d){return d.w;})
	      .attr("height",function(d){return d.h;})
	      .append("div")
	      .attr("class","boxtext")
	      .html(function(d){return d.text;});
	  

	  d3.xml("images/tst.svg", "image/svg+xml", function(xml) {
	      var slide = vis.selectAll("g.slide")
		  .data([{x:350,y:350,id:"example",t:"Example",z:3.0,w:800,h:300,rotate:30}],function(d){return d.id;})
		  .enter().append("svg:g")
		  .attr("class","slide")
		  .attr("id",function(d) { return "slide_"+d.id; });
	      var inner = 
		  slide.append("svg:g")
		  .attr("transform",function(d){return "translate("+d.x+","+d.y+")";})
		  .append("svg:g")
		  .attr("transform",function(d){return "rotate("+d.rotate+")";})
	      ;

	      $(inner[0]).append(xml.documentElement)
;
	  });


	  function zoomAndPan(change,speed) {
	      d3.selectAll("g.viewgroup")
		  .transition()
		  .duration(speed)
		  .attr("transform",function(d) { 
		      if ( change.dscale != null ) d.scale *= change.dscale;
		      if ( change.dx != null ) {    
			  var dx = 0;
			  var dy = 0;
			  if ( d.rotate != null ) {
			      dx = change.dx*Math.cos(-d.rotate*Math.PI/180.0);
			      dy = change.dx*Math.sin(-d.rotate*Math.PI/180.0);
			  } else {
			      dx = change.dx;
			  }
			  d.x += dx;
			  d.y += dy;
		      }
		      if ( change.dy != null ) {
			  var dx = 0;
			  var dy = 0;
			  if ( d.rotate != null ) {
			      dx = change.dy*Math.sin(d.rotate*Math.PI/180.0);
			      dy = change.dy*Math.cos(d.rotate*Math.PI/180.0);
			  } else {
			      dy = change.dy;
			  }
			  d.x += dx;
			  d.y += dy;

		      }
		      if ( change.drorate != null ) d.rotate += change.drotate;
		      if ( change.scale != null )  d.scale  = change.scale;
		      if ( change.x  != null )     d.x      = change.x;
		      if ( change.y  != null )     d.y      = change.y;
		      if ( change.rotate != null ) d.rotate = change.rotate;
		      if ( d.rotate == null ) d.rotate = 0;
		      if ( d.scale == null ) d.scale = 1;
		      return renewTransform( d ); 
		  });
	  }

	  function showSlide( idx ) {
	      var slide = vis.selectAll("g.slide")[0][idx];

	      if ( slide == null ) {
		  alert( "Unknown slide " + idx );
	      } else {
		  curSlide = idx;
		  var d = slide.__data__;
		  var scalex = 800/d.w;
		  var scaley = 600/d.h;
		  if ( scalex == null && scaley == null ) 
		      scalex = scaley = 1.0;
		  var trans = { x: -d.x, y: -d.y, scale: Math.min(scalex,scaley), rotate:-d.rotate };
		  
		  zoomAndPan(trans,1000);
	      }
	      
	  }


	  function prevSlide() {
	      showSlide( --curSlide );
	  }

	  function nextSlide() {
	      showSlide( ++curSlide );
	  }

	  function renewTransform(d) {
	      var s = (d.scale == null ? 1.0 : d.scale );
	      return ["scale("+s+")",
		      "rotate("+d.rotate+")",
		      "translate("+d.x+","+d.y+")",
		     ].join("");
	  }

	  d3.select(window).on("keydown",function(){
	      if ( d3.event.keyCode == 16 ) return;
	      switch(d3.event.keyCode) {
	      case 187: 
	      case 61: // for firefox
		  zoomAndPan( {dscale:1.2}, 100 ); break;
	      case 189: 
	      case 109: // for firefox
		  zoomAndPan( {dscale:0.8}, 100 ); break;
	      case 37:  
		  if (d3.event.shiftKey ) { 
		      prevSlide(); 
		  } else { 
		      zoomAndPan( {dx:50}, 100 );
		  }; break;
	      case 39:  if (d3.event.shiftKey ) { nextSlide() } else { zoomAndPan( {dx:-50}, 100 ) }; break;
	      case 38:  zoomAndPan( {dy:50}, 100 );      break;
	      case 40:  zoomAndPan( {dy:-50}, 100 );     break;
	      }
	      var num = d3.event.keyCode-48;
	      if ( num >=0 && num <= 9 ) {
		  showSlide( num );
	      }
	  });

	  // start it
	  showSlide(0);

      }

      // this resets the map
      prezi.container = function(x) {
	  if ( !arguments.length ) return container;
	  container = x;
	  init();
	  return prezi;
      }

      prezi.data = function(x) {
	  if ( !arguments.length ) {
	      return d3.select(container).filter('circle').data();
	  }
	  update(x);      // push the new data onto the map
	  return prezi;
      }


      return prezi;
  }
  // Create query object and load the data.
  // When the data is loaded, it gets pushed to the views through the event bindings
  var prezi = tmcpe.prezi().container(d3.select('#ttttt'));
 })();
