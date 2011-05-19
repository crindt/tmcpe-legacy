// Function to get the Max value in Array
Array.max = function( array ){
    return Math.max.apply( Math, array );
};

// Function to get the Min value in Array
Array.min = function( array ){
    return Math.min.apply( Math, array );
};


// zoom-based clustering
// expects a global variable called map that is a polymap object
// Adapted from jmarca@translab.its.uci.edu
function cluster() {
    //useless just set to zero
    function precision(zoom){
        return Math.ceil(Math.log(zoom-0) / Math.LN2);
    }
    var cnt=0;
    var points = {};
    var incidentMap = {};
    var clusterf = function(elem) {
        coord = elem.data.geometry.coordinates
        var x = coord.x.toFixed(0);
        var y = coord.y.toFixed(0);

        var x2 = (coord.x/50).toFixed(0);
        var y2 = (coord.y/50).toFixed(0);
	
        var key = x2+','+y2;

        if(!points[key]){
            // create a new cluster
	    //            newpoint = elem;
	    //            newpoint.data.properties.elements = [elem];
	    newpoint = {};
            newpoint.x = x;
            newpoint.y = y;
	    newpoint.elements = [ elem ];
	    newpoint.id = "cluster_"+(cnt++);
            points[key] = newpoint
        }else{
            //points[key].data.properties.elements.push(elem);
	    points[key].elements.push( elem );
        }
	incidentMap[elem.data.properties.cad] = points[key];
    };
    clusterf.reset = function(){
	cnt = 0;
        points = {};
	incidentMap = {};
    };
    clusterf.sort = function(f) {
	$.each( points, function ( key, value ) {
	    value.elements.sort( f );
	} );
    };
    clusterf.fixedR = 10;
    clusterf.points = function(){
        return points;
    };
    clusterf.pointForCad = function( cad ) {
	return incidentMap[cad];
    }
    clusterf.nodeForCad = function( cad ) {
	return $("#"+incidentMap[cad].id)[0];
    };
    return clusterf;
}




if ( !tmcpe ) var tmcpe = {};

(function()
 {tmcpe.version = "0.1";

  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };


  tmcpe.tipsy = function(opts) {
      var tip;

      /**
       * @private When the mouse leaves the root panel, trigger a mouseleave event
       * on the tooltip span. This is necessary for dimensionless marks (e.g.,
       * lines) when the mouse isn't actually over the span.
       */
      function trigger() {
	  if (tip) {
	      $(tip).tipsy("hide");
	      tip.parentNode.removeChild(tip);
	      tip = null;
	  }
      }

      return function(d) {
	  /* Compute the transform to offset the tooltip position. */
	      /*
	  var t = pv.Transform.identity, p = this.parent;
	  do {
              t = t.translate(p.left(), p.top()).times(p.transform());
	  } while (p = p.parent);
*/
	  var parentContainer = this;
	  for ( ;parentContainer.ownerSVGElement;parentContainer = parentContainer.ownerSVGElement );

/*
	  var t = parentContainer.createSVGMatrix(), p = this.parentNode;
	  do { 
	      var bb = p.getBBox();
	      t = t.translate(bb.x,bb.y).times(p.transform());
	  } while ( p = p.parentNode );
*/



	  /* Create and cache the tooltip span to be used by tipsy. */
	  if (!tip) {
              var c = this.parentNode;//root.canvas();
              c.style.position = "relative";
              $(c).mouseleave(trigger);

              tip = c.appendChild(document.createElement("div"));
              tip.style.position = "absolute";
              tip.style.pointerEvents = "none"; // ignore mouse events
              $(tip).tipsy(opts);
	  }

	  /* Propagate the tooltip text. */
	  tip.setAttribute('title', this.getAttribute('title') || $(this).text());

	  /*
	   * Compute bounding box. TODO support area, lines, wedges, stroke. Also
	   * note that CSS positioning does not support subpixels, and the current
	   * rounding implementation can be off by one pixel.
	   */
	  var bbox = this.getBBox();
	  if (bbox.width) {
              tip.style.width = Math.ceil(bbox.width/* * t.k*/) + 1 + "px";
              tip.style.height = Math.ceil(bbox.height/* * t.k*/) + 1 + "px";
	  } /*else if (this.properties.shapeRadius) {
              var r = this.shapeRadius();
              t.x -= r;
              t.y -= r;
              tip.style.height = tip.style.width = Math.ceil(2 * r * t.k) + "px";
	  }*/
	  else { alert ( "TIPSY CONVERSION BROKEN" ); }
	  var p = parentContainer.createSVGPoint();
	  p.x = bbox.x;
	  p.y = bbox.y;
	  var bbox2 = p.matrixTransform(parentContainer.getScreenCTM().inverse());
	  tip.style.left = Math.floor(bbox2.x/* * t.k + t.x */) + "px";
	  tip.style.top = Math.floor(bbox2.y/* * t.k + t.y*/) + "px";

	  /*
	   * Cleanup the tooltip span on mouseout. Immediately trigger the tooltip;
	   * this is necessary for dimensionless marks. Note that the tip has
	   * pointer-events disabled (so as to not interfere with other mouse
	   * events, such as "click"); thus the mouseleave event handler is
	   * registered on the event target rather than the tip overlay.
	   */
//	  if (tip.style.height) $(pv.event.target).mouseleave(trigger);
	  $(tip).tipsy("show");
      };
  };








  tmcpe.query = function( qstra ) {
      var query = {},
      qmap,
      table,
      detail,
      mapid = "#map",
      inctableid = "#inctableContainer",
      detailid = "#info",

      qstr = qstra;

      
      query.selectCluster = function( cluster ) {

	  // update the detail box
	  detail.cluster( cluster );
      }

      query.selectIncident = function(cad) {
	  qmap.raiseIncident( cad );
	  qmap.highlightIncident( cad );

	  table.highlightIncident( cad );
	  
	  var cluster = qmap.clusterForCad( cad );
	  if ( cluster != detail.cluster() ) { 
	      detail.cluster( cluster );
	  }
	  detail.cad( cad );
      }
      
      d3.json( qstr,
	       function(e) {
		   qmap = tmcpe.query.qmap()
		       .query( query )
		       .container($(mapid)[0])
		       .data(e.features);

		   table = tmcpe.query.table()
		       .query( query )
		       .container($(inctableid)[0])
		       .map(qmap.map)
		       .data(qmap.data());

		   detail = tmcpe.query.detail()
		       .query( query )
		       .container($(detailid)[0]);

		   $("#loading").css('visibility','hidden');
	       });

      return query;
  }

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


  tmcpe.query.detail = function() {
      var detail = {},
      theQuery,
      cluster,
      cad,
      container
      ;

      
      function pageToCad( cad ) {
	  if ( cluster==null || cluster.elements == null  ) return; // throw exception
	  // quick search over cluster elements
	  var idx;
	  for( idx = 0; idx < cluster.elements.length && cluster.elements[idx].data.properties.cad != cad; idx++ ) {};
	  if ( idx == cluster.elements.length ) alert( "Invalid data in cluster" );  // throw exception
	  $('#incidentDetailPager').trigger('setPage',[idx]);
      }


      detail.query = function(x) {
	  if ( !arguments.length ) return thequery;
	  theQuery = x;
	  return detail;
      }

      detail.cluster = function( x ) {
	  if ( !arguments.length ) return cluster;
	  cluster = x;
	  
	  detail.create();
	  
	  return detail;
      }

      detail.cad = function( x ) {
	  if ( !arguments.length ) return cad;
	  var oldCad = cad;
	  cad = x;
	  if ( cad != oldCad ) {
	      pageToCad( x );
	  }
	  return detail;
      }

      detail.container = function( x ) {
	  if ( !arguments.length ) return container;

	  // same as existing
	  if ( container != null && container == x ) return container;

	  container = x;
	  
	  // clear the container
	  $(container).empty()
	  
	  // recreate
	  detail.create();
	  
	  return detail;
      }

      function handlePaginationClick(new_page_index, pagination_container) {
	  // This selects 20 elements from a content array
	  $('#incidentDetail').empty();
	  
	  var max = Array.min( [new_page_index+1,cluster.elements.length] );
	  for ( var i = new_page_index; i<max; ++i ){
	      var id = $('#incidentDetail');
	      id.append('<h3>Incident '+cluster.elements[i].data.properties.cad+'</h3>');
	      id.append('<p><a target="_blank" href="incident/d3_tsd?cad='+cluster.elements[i].data.properties.cad+'">Show detailed analysis</a></p>');
	  }
	  
	  // select the first element
	  theQuery.selectIncident( cluster.elements[new_page_index].data.properties.cad );
	  
	  // update the background color
	  d3.select("#infobox").attr("style","background-color:"+color(220)(cluster.elements[new_page_index].data.properties.tmcpe_delay)); 
	  
	  
	  return false;
      }

      detail.create = function() {
	  // only create if we have a container and a cluster
	  if ( container == null || cluster == null ) return detail;

	  /*
	    $.each( cluster.elements, function( i, inc ) {
	    $(container).append('<h3>'+inc.data.properties.cad+'</h3');
	    });
	  */
	  $(container).append('<div id="incidentDetail"></div>');
	  $(container).append('<div id="incidentDetailPager"></div>');

	  $('#incidentDetailPager').pagination( cluster.elements.length, { 
	      items_per_page: 1,
	      callback:handlePaginationClick
	  } );

	  // for each
	  return detail;
      }

      return detail;
  }



  tmcpe.query.qmap = function() {
      var qmap = {},
      theQuery,
      container,
      theight,// = $(container).height()-2,
      twidth,// = $(container).height()-2,
      theData,
      allTheData,
      map,
      size,
      blobs = {},

      po = org.polymaps;

      function clusterClicked(e,c) {
	  var c = e.currentTarget;

	  theQuery.selectCluster( c.data );
      }


      function Cluster_load(e){
	  if(!e.tile.cluster){
              e.tile.cluster=cluster();
	  }
	  blobs=e.tile.cluster;
	  for (var i = 0; i < e.features.length; i++){
              blobs(e.features[i]);
	  }

	  // sort elements by tmcpe_delay descending
	  blobs.sort( function( a, b ) {
	      return b.data.properties.tmcpe_delay - a.data.properties.tmcpe_delay;
	  });

	  var tile = e.tile, g = tile.element;
	  while (g.lastChild) g.removeChild(g.lastChild);

	  $.each(blobs.points(), function(key, value) {
              var point = g.appendChild(po.svg("circle"));
              point.setAttribute("cx", value.x);
              point.setAttribute("cy", value.y);
	      point.setAttribute("id", value.id );
	      point.setAttribute("cads",
				 $.map(value.elements, function(d,i) { 
				     return d.data.cad;
				 }).join(" "));

              var more_wider = value.elements.length;
              var more_darker = value.elements.length / 10;
              more_darker = more_darker < 0.25 ? more_darker : 0.25;

              point.setAttribute("r", blobs.fixedR + more_wider*3 );
              //point.setAttribute("stroke", "#000000");


	      var arr = $.map(value.elements,function(d){
		  return d.data.properties.tmcpe_delay;
	      });
              point.setAttribute('fill', color(0)(Array.max(arr)));
              //point.setAttribute("stroke-width",0.2);
              point.setAttribute("opacity",0.65+more_darker);
              point.setAttribute("stroke-opacity",0.8);
	      point.setAttribute("title",value.elements.length+" incident" + (value.elements.length==1 ? "" : "s") );
	      $(point).tipsy({gravity:"s"});
	      //$(point).mouseover(tmcpe.tipsy({gravity:"w"}));
	      point.data = value;
	      value.node = point; 
              $(point).click(clusterClicked);
	  });
      }

      qmap.clusterForCad = function( cad ) {
	  if ( !arguments.length || blobs == null ) return null;
	  return blobs.pointForCad( cad );
      }

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

      qmap.query = function(x) {
	  if ( !arguments.length ) return thequery;
	  theQuery = x;
	  return qmap;
      }

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
              .on("load",Cluster_load)
	  ;
	  map.add(incs);

	  /*
	    map.on("move",function(d){
	    //			d3.selectAll("#incidents circle")
	    //			.append("div")
	    //			.data(e.features)
	    //			.on("click", incidentClicked )
	    $("#incidents circle").click( function ( el ) { 
	    var cad = el.currentTarget.getAttribute("cad");
	    table.incidentClicked( cad ); } );
	    });
	  */

      }

      // raise the cluster circle associated with CAD
      qmap.raiseIncident = function( cad ) {
	  if ( blobs == null ) return qmap;
	  var point = blobs.nodeForCad( cad );
	  
	  // In SVG, the z-index is the element's index in the dom.  To raise an
	  // element, just detach it from the dom and append it back to its parent
	  var node = point;
	  if ( node ) {
	      var parent = node.parentNode;
	      $(node).detach().appendTo( parent );
	  }
      }


      qmap.highlightIncident = function( cad) {
	  //	  d3.select(container).selectAll('circle.selected').attr( "class", function (d) { 
	  //var ret = this.className.baseVal.replace(/\s*\bselected\b/i,""); // remove selected
	  //return ret;
	  //	  });
	  // remove all selected
	  var sel = $('circle');
	  sel.removeClass("selected");

	  //var point = blobs.nodeForCad( cad );
	  sel = $('circle[cads~="'+cad+'"]');
	  sel.addClass("selected");
	  //	  $(point.node).attr("className",function (dd,e) { 
	  //	      return this.className.baseVal+" selected";
	  //	  });
      }



      return qmap;
  }

  tmcpe.query.table = function() {
      var qtable = {},
      theQuery,
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

      qtable.highlightIncident = function( cad ) {

	  // restyle row
	  d3.selectAll("#inctable tr.selected")
	      .attr( "style", function(d,i) { 	
		  return "background-color:"+color(160)(d.properties.tmcpe_delay); 
	      });
	  $("#inctable tr.selected").toggleClass("selected");

	  // now restyle the selected row
	  $("#inctable tr[cad='"+cad+"']")
	      .toggleClass("selected");
	  d3.selectAll("#inctable tr[cad='"+cad+"']")
	      .attr( "style", function(d,e) { 
		  scrollIncidentTableToItem( d,e,this );

		  return "background-color:"+color(0)(d.properties.tmcpe_delay); 
	      });
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

      function updateIncidentInfo( d, e ) {
	  // Update the title
	  if ( d.cad ) {
	      $('#incidentTitle').html( 'Incident <a target="_blank" href="incident/d3_tsd?id=' + d.id + '">' + d.cad + '</a>' );
	  } else {
	      $('#incidentTitle').html( 'Incident <a target="_blank" href="incident/d3_tsd?id=' + d.id + '">' + d.id + '</a>' );
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

      qtable.query = function(x) {
	  if ( !arguments.length ) return thequery;
	  theQuery = x;
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
		  return "table_incident_id_"+d.id;
	      } )
	      .attr("cad", function( d ) { 
		  return d.cad
	      } )
	      .attr("class", function(d,i) { return i % 2 ? "even" : "odd"; } )
	      .attr("style", function(d,i) { 
		  return "background-color:"+color(160)(d.properties.tmcpe_delay)/*+";opacity:0.5"*/; })
	      .on("click",function(d,e) { 
		  if ( !featureVisible(d) ) centerOnIncident( d );
		  //qtable.incidentClicked( d.cad );
		  theQuery.selectIncident( d.cad );
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
		      return "table_incident_id_"+d.id ;
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
	      bPaginate:false, sScrollY:"170px","bAutoWidth":false,
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

