<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Testbed Network View Using Openlayers</title>
    <script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAjpkAC9ePGem0lIq5XcMiuhR_wWLPFku8Ix9i2SXYRVK3e45q1BQUd_beF8dtzKET_EteAjPdGDwqpQ'></script>
    <link rel="stylesheet" href="../theme/default/style.css" type="text/css" />
    <link rel="stylesheet" href="style.css" type="text/css" />

    <style type="text/css">
        #map {
            width: 100%;
            height: 80%;
            border: 1px solid black;
        }
        .olPopup p { margin:0px; font-size: .9em;}
        .olPopup h2 { font-size:1.2em; }
    </style>

    <script src="/tmcpe/js/openlayers/lib/OpenLayers.js"></script>
    <script type="text/javascript">
        var lon = 5;
        var lat = 40;
        var zoom = 5;
        var map, select;

        function init(){
            var options = {
                projection: new OpenLayers.Projection("EPSG:900913"),
                displayProjection: new OpenLayers.Projection("EPSG:4326"),
                units: "m",
//	        minZoomLevel: 3,
//	        numZoomLevels: 17
                maxResolution: 156543.0339,
                maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34,
                                                 20037508.34, 20037508.34)
            };
            map = new OpenLayers.Map('map', options);
            var mapnik = new OpenLayers.Layer.TMS(
                "OpenStreetMap (Mapnik)",
                "http://tile.openstreetmap.org/",
                {
                    type: 'png', getURL: osm_getTileURL,
                    displayOutsideMaxExtent: true,
                    attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>'
                }
            );
            var gmap = new OpenLayers.Layer.Google("Google", {sphericalMercator:true});

            var networkLines = new OpenLayers.Layer.Vector("KML", {
                projection: map.displayProjection,
                strategies: [new OpenLayers.Strategy.Fixed()],
                protocol: new OpenLayers.Protocol.HTTP({
	            url: "/tmcpe/testbedLine/listAllAsKml",
                    format: new OpenLayers.Format.KML({
                        extractStyles: true,
                        extractAttributes: true
                    })
                })
            });


	    // FIXME: crindt: for later completion
//             var vds = new OpenLayers.Layer.Vector("KML", {
//                 projection: map.displayProjection,
//                 strategies: [new OpenLayers.Strategy.Fixed()],
//                 protocol: new OpenLayers.Protocol.HTTP({
// 	            url: "/tmcpe/vds/listAllAsKml",
//                     format: new OpenLayers.Format.KML({
//                         extractStyles: true,
//                         extractAttributes: true
//                     })
//                 })
//             });

//             map.addLayers([mapnik, gmap, networkLines, vds]);


            selectNetwork = new OpenLayers.Control.SelectFeature(networkLines);
            
            networkLines.events.on({
                "featureselected": onFeatureSelectNetwork,
                "featureunselected": onFeatureUnselectNetwork
            });
  
            map.addControl(selectNetwork);
            selectNetwork.activate();   

            map.addControl(new OpenLayers.Control.LayerSwitcher());

            map.zoomToExtent(
                new OpenLayers.Bounds(
	           -117.9784, 33.594, -117.6832, 33.7768
                ).transform(map.displayProjection, map.projection)
            );
        }
        function onPopupClose(evt) {
            selectNetwork.unselectAll();
        }
        function onFeatureSelectNetwork(event) {
            var feature = event.feature;
            var selectedFeature = feature;
            var popup = new OpenLayers.Popup.FramedCloud("chicken", 
                feature.geometry.getBounds().getCenterLonLat(),
                new OpenLayers.Size(100,100),
                "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
                null, true, onPopupClose
            );
            feature.popup = popup;
            map.addPopup(popup);
        }
        function onFeatureUnselectNetwork(event) {
            var feature = event.feature;
            if(feature.popup) {
                map.removePopup(feature.popup);
                feature.popup.destroy();
                delete feature.popup;
            }
        }
        function osm_getTileURL(bounds) {
            var res = this.map.getResolution();
            var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
            var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
            var z = this.map.getZoom();
            var limit = Math.pow(2, z);

            if (y < 0 || y >= limit) {
                return OpenLayers.Util.getImagesLocation() + "404.png";
            } else {
                x = ((x % limit) + limit) % limit;
                return this.url + z + "/" + x + "/" + y + "." + this.type;
            }
        }
    </script>
  </head>
  <body onload="init()">
      <h1 id="title">OSM + Google Maps + KML Reprojection</h1>

      <div id="tags"></div>

      <p id="shortdesc">
          Demonstrates loading and displaying a KML file on top of OpenStreetMap (OSM) and Google Maps data. Loads data from a KML file of networkLines.
    </p>

    <div id="map" class="smallmap"></div>

    <div id="docs"></div>
  </body>
</html>
