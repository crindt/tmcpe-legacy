

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
      ,curSlide=0
      ,viewWidth = 800
      ,viewHeight = 600
      ,viewMargin = 50
      ,vis
      ;

      // create the base map
      function init() {
	  if ( container == null ) return;
	  // empty container
	  $(container[0]).children().remove();

	  var vpt = d3.selectAll(container[0])
	      .append("svg:svg")
	      .attr("width",viewWidth)
	      .attr("height",viewHeight)
	      .attr("class","viewport")
	      .on("click",function(){nextSlide()})
	  ;

	  // creates the visualization group that we'll rotate about
	  vis = vpt.selectAll("g.viewgroup")
	      .data([{"x":0,"y":0,"scale":2.0,"slide":0}])
	      .enter()
	      .append("svg:g")
	      .attr("class","viewgroup")
	  ;

	  // Create the "title" slide
	  var titleSlide = createSlide(
	      {
		  x:-300,y:-700,id:"titleSlide",
		  text:'<h1 style="text-align:center;">Traffic Management is filtered through assets managed by the TMC</h1>',
		  idx:0,
		  w:200,
		  h:150,
		  scale:10,
		  rotate:0
	      });
					

	  // Create the TMC activity slide
	  var tmcActivitySlide = createSlide({x:20,y:20,id:"tmcActivity",t:"TMC Activity",z:3.0,w:300,h:300,rotate:0,idx:1,frame:true});

/*
	  var mapSlide = createSlide({x:0,y:1000,id:"map",scale:.01,w:25600,h:25600,rotate:0,idx:4,frame:true});
	  var imagerows = mapSlide.selectAll("#map g.imagerow")
	      .data(_.range(450559,450659))
	      .enter().append("svg:g")
	      .attr("class","imagerow")
	      .attr("transform",function(d,i) {
		  return "translate(0,"+((d-450559)*256)+")";
	      });

	  imagerows.selectAll("image")
	      .data(function(d){ return _.map(_.range(181264,181364),function(x){return { "x":x, "y":d }}) })
	      .enter().append("svg:image")
	      .attr("id",function(d){ return "img_"+d; })
	      .attr("width",256)
	      .attr("height",256)
	      .attr("xlink:href",function(d){return "http://khmdb0.google.com/kh?v=41&x="+d.x+"&y="+d.y+"&z=20&s=G&deg=0"})
	      .attr("x",function(d){return (d.x-181264)*256})
	      .attr("y",0)
	  ;
*/

	  tmcActivitySlide.selectAll("rect")
	      .attr("class","frame")
	      .attr("width",function(d){return d.w;})
	      .attr("height",function(d){return d.h;});

	  var boxgroup = tmcActivitySlide.selectAll("g.boxgroup")/*.selectAll("#test")*/
	      .data([
		  {"id":"first","dx":0,"dy":0,"text":"Identification<ul><li><em>Notify CT/CHP Staff</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":70,"dy":70,"text":"Verification<ul><li><em>Confirm location</em></li><li><em>Determine type</em></li><li><em>Determine severity</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":140,"dy":140,"text":"Response<ul><li><em>Disseminate</em></li><li><em>Field response</em></li><li><em>Coordinate</em></li><li><em>Manage</em></li></ul>","w":100,"h":50},
		  {"id":"first","dx":210,"dy":210,"text":"Monitoring<ul><li><em>Condition changes</em></li><li><em>Multiple incidents</em></li><li><em>Performance reports</em></li></ul>","w":100,"h":50}
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

	  

	  embedExternalSvgAsSlide({src:"images/tst.svg",x:350,y:350,id:"example",t:"Example",z:3.0,w:800,h:300,rotate:60,idx:2,frame:true});
	  embedExternalSvgAsSlide({src:"images/loops.svg",x:0,y:1000,id:"loops",t:"Loops",z:3.0,w:400,h:100,rotate:0,idx:3,scale:1,frame:true});

	  function createSlide(da) {
	      var slide = vis.selectAll("g.slide")
		  .data([da],function(d){return d.id;})
		  .enter().append("svg:g")
		  .attr("class","slide")
		  .attr("idx",function(d) { return d.idx; })
		  .attr("id",function(d) { return "slide_"+d.id; })
		  .attr("width",da.w)
		  .attr("height",da.h)
/*	      
	      ;
	      var inner = 
		  slide.append("svg:g")
*/
		  .attr("transform",function(d){
		      return [
			  "translate("+[v(d.x),v(d.y)].join(",")+")",
			  "scale("+v(d.scale,1.0)+")",
			  "rotate("+[v(d.rotate,0),-v(d.x),-v(d.y)].join(",")+")",
		      ].join("");
		  });

	      if ( da.frame ) {
		  slide
		      .append("svg:rect")
		      .attr("width",da.w)
		      .attr("height",da.h)
		      .attr("style","stroke:black;stroke-width:2;fill:none;");
	      }

	      if ( da.text != null ) {
		  // create text
		  slide.append("svg:foreignObject")
		      .attr("width",da.w)
		      .attr("height",da.h)
		      .append("div")
		      .html(da.text);
	      }
	      return slide;
	  }

	  function v(d,vv) { return d == null ? (vv==null?0:vv) : d; };

	  function embedExternalSvgAsSlide(da) {
	      if ( da.src == null ) { 
		  alert("External slide must have specified src");
		  return null;
	      }
	      d3.xml(da.src, "image/svg+xml", function(xml) {
		  var slide = vis.selectAll("g.slide")
		      .data([da],function(d){
			  if ( d.id == null ) { 
			      alert("Slide must have specified id!"); 
			      return null;
			  } else {
			      return d.id;
			  }
		      })
		      .enter().append("svg:g")
		      .attr("class","slide")
		      .attr("idx",function(d) { return d.idx; })
		      .attr("id",function(d) { return "slide_"+d.id; })
/*
  ;
		  var inner = 
		      slide
		      .append("svg:g")
		      .attr("class","transform")
*/
		      .attr("transform",function(d){
			  return [
			      "translate("+[v(d.x),v(d.y)].join(",")+")",
			      "scale("+v(d.scale,1)+")",
			      "rotate("+[v(d.rotate),v(d.rox),v(d.roy)].join(",")+")",
			  ].join("")
		      });
		  ;

		  if ( da.frame ) {
		      slide
			  .append("svg:rect")
			  .attr("width",function(d){return d.w;})
			  .attr("height",function(d){return d.h;})
			  .attr("style","stroke:black;stroke-width:2;fill:none;");
		  }
		  
		  
		  //$(inner[0]).append(xml.documentElement);
		  $(slide[0]).append(xml.documentElement);

		  // move the embedded svg up
		  //$(inner[0]).find("svg").children().detach().appendTo(inner[0]);
	      });
	  }


	  function transformView(change,speed,absolute) {
	      d3.selectAll("g.viewgroup")
		  .transition()
		  .duration(speed)
		  .attr("transform",function(d) {
		      if ( change.drorate != null ) d.rotate += change.drotate;
		      if ( change.scale != null )  d.scale  = change.scale;
		      if ( change.x  != null )     d.x      = change.x;
		      if ( change.y  != null )     d.y      = change.y;
		      if ( change.rotate != null ) d.rotate = change.rotate;
		      if ( change.dscale != null ) d.scale *= change.dscale;
		      if ( d.rotate == null ) d.rotate = 0;
		      if ( d.scale == null ) d.scale = 1;
		      if ( change.rox != null ) d.rox = change.rox;
		      if ( change.roy != null ) d.roy = change.roy;

		      var ss = absolute ? d.scale : 1;

		      if ( change.dx != null ) {    
			  var dx = 0;
			  var dy = 0;
			  if ( d.rotate != null ) {
			      dx = change.dx/ss*Math.cos(-d.rotate*Math.PI/180.0);
			      dy = change.dx/ss*Math.sin(-d.rotate*Math.PI/180.0);
			  } else {
			      dx = change.dx/ss;
			  }
			  d.x += dx;
			  d.y += dy;
		      }
		      if ( change.dy != null ) {
			  var dx = 0;
			  var dy = 0;
			  if ( d.rotate != null ) {
			      dx = change.dy/ss*Math.sin(d.rotate*Math.PI/180.0);
			      dy = change.dy/ss*Math.cos(d.rotate*Math.PI/180.0);
			  } else {
			      dy = change.dy/ss;
			  }
			  d.x += dx;
			  d.y += dy;

		      }
		      return [
			  "scale("+v(d.scale,1.0)+")",
			  "translate("+[v(d.x,0),v(d.y,0)].join(",")+")",
			  "rotate("+[v(d.rotate,0),-v(d.rox),-v(d.roy)].join(",")+")",
		      ].join("");
			      
		  });
	  }

	  function showSlide( idx, centera ) {
	      // select by idx
	      var slides = vis.selectAll('g.slide[idx="'+idx+'"]');
	      var slide = slides[0][0];
	      var center = v(centera,true);

	      if ( slide == null ) {
		  alert( "Unknown slide " + idx );
	      } else {
		  curSlide = idx;
		  var d = slide.__data__;
		  var w = d.w*v(d.scale,1);
		  var h = d.h*v(d.scale,1);
		  

		  var bbox = slide.getBBox();
		  var ww = w;
		  var hh = h;
/*
		  var ww = bbox.width/v(d.scale,1);
		  var hh = bbox.height/v(d.scale,1);
*/

		  var scalex = (viewWidth-2*viewMargin)/ww;
		  var scaley = (viewHeight-2*viewMargin)/hh;
		  if ( scalex == null && scaley == null ) 
		      scalex = scaley = 1.0;
		  var scale = Math.min(scalex,scaley) 

		  margx = viewMargin/v(scale,1);
		  margy = viewMargin/v(scale,1);

		  if ( center ) {
		      // adjust margins to center slide content in view
		      var res;
		      if ( scalex != scale ) {
			  res = ((viewWidth-2*viewMargin)-ww*scale);
			  margx += res/2/v(scale,1);
		      }
		      if ( scaley != scale ) {
			  res = ((viewHeight-2*viewMargin)-hh*scale);
			  margy += res/2/v(scale,1);
		      }
		  }

		  var trans = { x: (-v(d.x)+margx), y: (-v(d.y)+margy), 
				scale: scale,
				rotate:-v(d.rotate),
				rox: -v(d.x),
				roy: -v(d.y),
			      };
		  transformView(trans,1000);

		  /* 
		  // debugging: places circle on slide origin/rotation point
		  slides.selectAll(".cor").remove();

		  slides
		      .append("svg:circle")
		      .attr("class","cor")
		      .attr("r",20)
		  ;
		  */
		  
	      }
	      
	  }


	  function prevSlide() {
	      showSlide( --curSlide );
	  }

	  function nextSlide() {
	      showSlide( ++curSlide );
	  }

	  d3.select(window).on("keydown",function(){
	      if ( d3.event.keyCode == 16 ) return;
	      switch(d3.event.keyCode) {
	      case 187: 
	      case 61: // for firefox
		  transformView( {dscale:1.2}, 100 ); break;
	      case 189: 
	      case 109: // for firefox
		  transformView( {dscale:0.8}, 100 ); break;
	      case 37:  
		  if (d3.event.shiftKey ) { 
		      prevSlide(); 
		  } else { 
		      transformView( {dx:50}, 100, true );
		  }; break;
	      case 39:
		  if (d3.event.shiftKey ) { 
		      nextSlide() 
		  } else { 
		      transformView( {dx:-50}, 100, true ) 
		  }; break;
	      case 38:  transformView( {dy:50}, 100, true );      break;
	      case 40:  transformView( {dy:-50}, 100, true );     break;
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
