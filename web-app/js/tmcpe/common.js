if ( !tmcpe ) var tmcpe = {};
(function() 
 {

     // A wrapper for loading data that integrates with the UI
     var loadingOverlay;
     var loadCount=0;
     var whats = [];
     var whatul;
     var whatlis;
     tmcpe.loadData = function( url, callback, what ) {
	 // show the loading overlay
         if ( loadCount++ == 0 ) {
	     $(window).trigger("tmcpe.loadingStart");
             // create the ul
             whatul = d3.select("#loading").append("ul");
         }
	 loadingOverlay = $("#loading").overlay({load:true, closeOnClick:false, api:true});

         if ( what == null ) what = "Item "+loadCount;

         whats.push( what );

         // update loads
         whatlis = whatul.selectAll("li")
             .data(whats)
             .text(function(d){return d});

         // create list items for new loads
         whatlis.enter()
             .append("li")
             .text(function(d){return d})
         ;

         try {
	     d3.json(url,function(e) {
	         if ( e == null ) {
		     // this is an error condition
                     throw "Invalid (or no) data returned from the server";
	         }
                 
	         // run the callback to manage the data
	         callback(e);

                 // remove list items for completed elements
                 var idx = whats.indexOf(what);
                 if ( idx == -1 ) 
                     throw "Didn't find item loading in what list";
                 else 
                     whats.splice(idx,1);  // remove the what

                 // update the data
                 whatlis = whatul.selectAll("li").data(whats);

                 // remove data
                 whatlis.exit().remove();

	         
	         if ( loadingOverlay && !(--loadCount) ) {
                     loadingOverlay.close();
	             $(window).trigger("tmcpe.loadingFinished");
                 }
                 
	     });
         } catch ( err ) {
             alert( err );
         }
     }

     /**
      * A general theme object 
      */
     tmcpe.legendForLinearScale = function() {
	 var legendForLinearScale = {},
	 vertical  = true,
	 barwidth  = 10,
	 barlength = 300,
	 title     = "Property",
	 legendtickspace = 30,     // amount of space per legend tick
	 scale
	 ;

	 legendForLinearScale.scale = function(x) {
	     if ( !arguments.length ) return scale;
	     scale = x;
	     return legendForLinearScale;
	 }
	 legendForLinearScale.title = function(x) {
	     if ( !arguments.length ) return title;
	     title = x;
	     return legendForLinearScale;
	 }
	 legendForLinearScale.barwidth = function(x) {
	     if ( !arguments.length ) return barwidth;
	     barwidth = x;
	     return legendForLinearScale;
	 }
	 legendForLinearScale.barlength = function(x) {
	     if ( !arguments.length ) return barlength;
	     barlength = x;
	     return legendForLinearScale;
	 }
	 legendForLinearScale.vertical = function(x) {
	     if ( !arguments.length ) return vertical;
	     vertical = x;
	     return legendForLinearScale;
	 }

	 legendForLinearScale.styleClass = function(targ,x) {
	     if ( x.p_j_m > 0 && x.p_j_m < 1 ) {
		 d3.select(targ).classed('datapoor',true);
		 return "";
	     } else {
		 d3.select(targ).classed('datapoor',false);
	     }
	 }

	 // assumes vertical
	 legendForLinearScale.render = function( container ) {
	     // assert
	     if ( container == null ) throw "Can't render legend inside null container";
	     if ( scale == null )     throw "Can't render legend for a null scale";

	     //// create the legend
	     var legend = container.append("svg:g");

	     // create the gradient
	     // from here: http://groups.google.com/group/d3-js/browse_thread/thread/2c96f73276cddef
	     // and here: http://www.w3schools.com/svg/svg_grad_linear.asp

	     var dom = scale.domain();

	     legend.append("svg:linearGradient")
		 .attr("id","speedGradient")
		 .attr("opacity", 1 )
	     // make it a vertical gradient, top (high speeds) to bottom (low speeds)
		 .attr("x1","0%")
		 .attr("y1","100%")
		 .attr("x2","0%")
		 .attr("y2","0%")
		 .selectAll("stop")
		 .data(dom)
		 .enter()
		 .append("svg:stop")
		 .attr("offset",function(d){ return (d-dom[0])/(dom[dom.length-1]-dom[0]); })
		 .attr("stop-color",function(d){ return scale(d); })
		 .attr("stop-opacity", 1 )
	     ;

	     var legendheight = barlength;

	     legend
		 .append("svg:rect")
		 .attr('x',0)
		 .attr('y',0)
		 .attr('width',barwidth)
		 .attr('height',legendheight)
		 .style('fill','url(#speedGradient)')
		 .style('stroke','#000')
	     ;

	     var t = scale.ticks(legendheight/legendtickspace+1);
	     // create a tickscale ranging from min to max
	     var tickscale = d3.scale.linear()
		 .domain([t[0],t[t.length-1]])
		 .range([legendheight,0]);
	     var ticks = legend.selectAll("g.tick")
		 .data(t)
		 .enter()
		 .append("svg:g")
		 .attr('class','tick')
		 .attr('transform',function(d){ return "translate(0,"+tickscale(d)+")"; });
	     ticks.append("svg:line")
		 .attr('x0',0)
		 .attr('x1',13)
	     ;
	     ticks
		 .append("svg:foreignObject")
		 .attr("xmlns","http://www.w3.org/1999/xhtml")
		 .attr('x', 0-20-3 )
		 .attr('y', 0-8 )
		 .attr('width','20px')
		 .attr('height','20px')
		 .append("p")
		 .text(function(d){
		     return d;
		 });
	     ;

	     /*
	       legend.append("svg:rect")
	       .attr('x',(20/2)-50/2)
	       .attr('y',legendheight+20)
	       .attr('width',50)
	       .attr('height',40)
	       ;
	     */
	     

	     legend.append("svg:foreignObject")
		 .attr("xmlns","http://www.w3.org/1999/xhtml")
		 .attr('x',(-20/2)-50/2)
		 .attr('y',legendheight+10)
		 .attr('width',50)
		 .attr('height',40)
		 .append('p')
		 .attr('class','text-center')
		 .text(title)
	     ;

	     return legend;
	 }

	 return legendForLinearScale;
     }
     
     // solve the format problem
     tmcpe.createFormattedLink = function(data) {
         actarr = data.action.split(/\./);
         if ( actarr.length > 1 )
             data.action = actarr.slice(0,actarr.length-1).join(".");
         var url = g.createLink( data );
         if ( actarr.length > 1 )
             url = url.replace('/'+data.action,'/'+data.action+"."+actarr[actarr.length-1]);
         return url;
     }

     $(document).ready(function() {
     
	 // Add loading overlay handling
	 $(window).bind("tmcpe.loadingStart", function( caller, what ) {
	 });
	 // Event called when a new analysis has been processed from the server
	 $(window).bind("tmcpe.loadingFinished", function(caller, what) {
	 });
	 
	 
	 // Add common error handling overlay
	 $(window).error(function(e){
	     var ee = e.originalEvent;
	     var msg = ee.message.replace(/Uncaught */,"");
	     $('#error_overlay > h1').text(msg);
	     $('#error_overlay td.errfile').text(ee.filename);
  	     $('#error_overlay td.errline').text(ee.lineno);
  	     $('#error_overlay td.errmsg').text(ee.message);
	     
	     /*
	     jQuery.each(jQuery.browser, function(i, val) {
		 $("<div>" + i + " : <span>" + val + "</span>")
                     .appendTo( $('#error_overlay') );
	     });
	     */
	     
	     var params = {
		 'issue[tracker_id]': 1,
		 'issue[subject]': "Logical error executing " + window.location,
		 'issue[description]': "An error occured @ " + ee.filename + ":" + ee.lineno + " with the message\n\n     " + ee.message + "\n\nPlease track down the problem.\n\nDetails:\n\n"+_.map($.browser,function(val,key){ return "* *"+key+"*: "+val }).join("\n")+"\n",
		 'issue[assigned_to_id]': 3  // Hardcode Craig Rindt
	     };
	     var keyPairs = [];
	     for (var key in params) {
		 keyPairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(params[key]));
	     }
	     
	     $('#error_overlay li.report a').attr("href","http://tracker.ctmlabs.net/projects/tmcpe/issues/new?"+keyPairs.join("&"));
	     $('#error_overlay').overlay({load:true});
	 });
     });
 })();
