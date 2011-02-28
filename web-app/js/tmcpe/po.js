var doMap = function( data ) {
    var po = org.polymaps;

    var color = d3.scale.linear()
	.domain(0, 50, 70, 100)
	.range("#F00", "#930", "#FC0", "#3B0");

    var mc = document.getElementById("map");

    var map = po.map()
	.container(mc.appendChild(po.svg("svg")))
	.center({lat: 33.739, lon: -117.830})
	.on("move",resize)
	.on("resize",resize)
	.zoom(13)
	.zoomRange([1,/*6*/, 18])
	.add(po.interact());
    map.add(po.image()
	    .url(po.url("http://{S}tile.openstreetmap.org"
//			+ "/d0e69d3db84141a5b0ba9c4bf6c6eded" // http://cloudmade.com/register
			+ "/{Z}/{X}/{Y}.png")
		 .hosts(["a.", "b.", "c.", ""])));

    // map.add(po.geoJson()
    //     .url("streets.json")
    //     .id("streets")
    //     .zoom(12)
    //     .tile(false)
    //   .on("load", po.stylist()
    //     .attr("stroke", function(d) { return color(d.properties.PCI).color; })
    //     .title(function(d) { return d.properties.STREET + ": " + d.properties.PCI + " PCI"; })));

    map.add(po.compass()
	    .pan("none"));

    var secjson;
    d3.json("/tmcpe/vds/list.geojson?idIn="+data.sections.map( function( sec ) {return sec.vdsid;}).join(","), 
			  function(e){
			      var x = Array();
			      var y = Array();
			      for (var i = 0; i < e.features.length; i++) {
				  var feature = e.features[i];
				  var coords = feature.geometry.coordinates;
				  var polygons = $.map(coords, function(a){
				      return [a];});
				  var points = $.map(polygons, function(a){
				      return [a];});
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
			      secjson = e;

			      var start = secjson.features[0].geometry.coordinates;
			      start = start[0];
			      var end = secjson.features[secjson.features.length-1].geometry.coordinates;
			      end = end[end.length-1];


			      var angle = Math.atan2( end[1]-start[1], end[0]-start[0] );


			      map.angle( Math.PI-angle );

			      map.extent([{lon:xMin,lat:yMin},{lon:xMax,lat:yMax}]);


			      var secs = po.geoJson().features(secjson.features)
				  .id("segments")
				  .zoom( function(z) { return Math.max(4, Math.min(18, z)); } )
				  .tile(false)
				  .on("load", po.stylist()
				      .attr("id", function( d ) { return d.id; } )
				      .attr("i", function( d ) { return d.i; } )
				      .attr("stroke", function( d ) { 
					  var el = $('g[vdsid^="'+d.id+'"] rect[j^=11]')[0];
					  return el == null ? "black" : el.style.fill; 
				      } )
				      .attr("stroke-width", 4 )
/*
				      function(d) { 
					  var zz = map.zoom()
					  var lev = 4+Math.floor(((zz-1))/17*(10-4));
					  return Math.min( Math.max( 4, lev ), 10 ) } )
*/
				      .title(function(d) { return [d.id,d.name].join(":"); }));

			      var ends = po.geoJson().features(secjson.features.map( function (f) { 
				  return {data: f.properties, 
					  geometry: { type:"Point", 
						      coordinates: f.geometry.coordinates[ f.geometry.coordinates.length-1 ] 
						    }}; 
			      } ) )
				  .id("ends")
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
				      .attr("fill", "none" )
				      .title(function(d) { return [d.data.id,d.data.name].join(":"); }));
			      map.add(secs);
			      map.add(ends);
			      


			  });
    function resize() {
	$("#segments path").map( function( i,p ) {
	    var zz = map.zoom()
	    var lev = 2+Math.floor(((18-(zz-1)))/17*(8-2));
	    var w = Math.min( Math.max( 2, lev ), 8 );

	    p.style = "stroke-width:"+w+";";
	});

	$("#ends circle").map( function( i,c ) {
	    var zz = map.zoom()
	    var lev = 2+Math.floor(((18-(zz-1)))/17*(8-2));
	    var r = Math.min( Math.max( 2, lev ), 8 );
	    p.r = r;
	});
    }


}
