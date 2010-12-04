<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Incident List</title>
    <meta name="layout" content="main" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->

    <!-- Load the map javascript and css -->
    <tmcpe:openlayers />  
    <tmcpe:tmcpe />              <!-- This loads the tmcpe (dojo-based) interface framework -->

    <g:javascript>
      <!-- Here are all the dojo widgets we use -->
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dijit.Dialog");
      dojo.require("dijit.ProgressBar");
      dojo.require("tmcpe.TestbedMap");

      // Map related variables
      var _map;
      var _tmcpeLayer;
      var _hoverIncident;
      var _selectIncident;

      // For this demo, the URL that returns TMCPE summary data
      var _tmcpeUpdateUrl = document.getElementById("htmldom").href + "incident/list.geojson?max=1000";

      // Helper function to get the map object
      var getMap = function() {
	  if ( !_map ) {
	      _map = dijit.byId( 'map' );
	  }
	  return _map._map;
      };

      var _incidentDetails;
      var getIncidentDetails = function() {
	  if ( _incidentDetails == null ) {
	      _incidentDetails = dojo.byId( 'incidentDetails' );
	  }
	  return _incidentDetails;
      };

      var updateIncidentDetails = function( feature ) {
	  var base = document.getElementById("htmldom").href;
	  var id = feature.attributes.id
	  var cad = feature.attributes.cad
	  this.getIncidentDetails().innerHTML = 
	      "<h3>INCIDENT " + cad + "</h3><dl>" 
	      + "<dt>loc</dt><dd>" + feature.attributes.locString + "</dd>"
	      + "<dt>memo</dt><dd>" + feature.attributes.memo + "</dd>"
              + "</dl>"
	  
	      + '<p><A href="'+base+'incident/showCustom?id='+id+'">Show Incident</a></p>';
      };


      var constructIncidentsParams = function( theParams ) {
	  var w = 0;
	  if ( !theParams || theParams == undefined ) {
	      theParams = {};
	  }
	  var map = getMap();
	  theParams[ 'bbox' ] = [map.getExtent().toBBOX()];
	  theParams[ 'proj' ] = "EPSG:900913";/*map.projection*/
	  return theParams;
      }

      var onFeatureSelectIncident = function(event) {
	  var il = dijit.byId( 'incidentList' );
	  var feature = event.feature;
	  
	  updateIncidentDetails( feature );
      };


      var onFeatureUnselectIncident = function(event) {
	  var feature = event.feature;
	  if(feature.popup) {
              getMap().removePopup(feature.popup);
              feature.popup.destroy();
              delete feature.popup;
	  }
      };

      var updateTmcpeLayer = function( theParams ) {

          /*
	  if ( _tmcpeLayer.protocol.url == "" ) {
	      // update the url
	      _tmcpeLayer.protocol = 
		  new OpenLayers.Protocol.HTTP({
  		      url: _tmcpeUpdateUrl,
		      params: theParams,
		      format: new OpenLayers.Format.GeoJSON({}),
		      callback: function() { console.log( "GOT CALLBACK!" ); }
		  });
	  }
          */
	  _tmcpeLayer.refresh({force: true, params:theParams});
      };

      var updateTmcpeQuery = function() {

	  // clear any existing selections...
	  if ( this._selectIncident )
	      this._selectIncident.unselectAll();
	  
	  var myParams = constructIncidentsParams( );
	  
	  updateTmcpeLayer( myParams );
      };


      var initTmcpeLayer = function() {
	  if ( !this._progressDialog ) {
	      this._progressDialog = new dijit.Dialog({//dojox.widget.Dialog({
		  //		title: "Loading",
		  id: "progressDialog",
		  showTitle: false,
		  style: "width: 300px",
		  modal: true
              });
	      
	      // this hides the title bar of the dialog...
	      dojo.query( '#progressDialog > .dijitDialogTitleBar' ).style( { "display": "none" } ) ;
	      
	      
	      this._progressBar = new dijit.ProgressBar( { id:"downloadProgress", 
							   jsId:"jsProgress", 
							   style: "width:250px",
							   indeterminate: false
							 } );
	      this._progressDialog.attr( 'content', this._progressBar ); 
	  }
	  
	  // Create the incidents layer.  The URL is hardcoded here...
	  var base = document.getElementById("htmldom").href;

	  var map = getMap();
	  
	  _tmcpeLayer = new OpenLayers.Layer.Vector("Incidents", {
              projection: map.displayProjection,
              strategies: [new OpenLayers.Strategy.Fixed()],
              protocol: new OpenLayers.Protocol.HTTP({
		  url: _tmcpeUpdateUrl,//theurl,
		  params: constructIncidentsParams(),
		  style: {strokeWidth: 2, strokeColor: "#0000ff", strokeOpacity: 0.25 },
		  format: new OpenLayers.Format.GeoJSON({}),
	      })
	  });

	  _tmcpeLayer.events.on({
              "featureselected": onFeatureSelectIncident,
              "featureunselected": onFeatureUnselectIncident,
	      
	      /** The following did pops up a loading window in the TMCPE app 
                * but is broken here
                */
              /*
	      "loadstart": function() {
		  // notify IncidentList "app" that we're starting to load
		  obj._loadStart();
		  obj._progressBar.update( { 'maximum': 100, 'progress': 0 } );
	      },
	      "loadend": function() {
		  // notify IncidentList "app" that we've finished loading
		  obj._loadEnd();
	      },
	      "loadcancel": function() {
		  // force IncidentList "app" to recognize that we've finished loading
		  obj._loadCancel();
	      },
              */
	      
	      "beforefeaturesadded": function (feat) { 
		  console.log( "before features added" );
		  console.log( "ADDING " + feat.features.length + " FEATURES" );
	      },
	      "featureadded": function( feat ) { 
	      },
	      "featuresadded": function() { 
		  console.log( "features added" );
		  //obj.updateIncidentsTable();  // TMCPE-specific
	      },
	      "featuresremoved": function() { 
		  console.log( "features removed" );
		  //obj.updateIncidentsTable();  // TMCPE-specific
	      },
	      "moveend": function() { 
		  updateTmcpeQuery(); 
	      }
	  });
	  
	  map.addLayers([_tmcpeLayer]);
	  
	  var hoverSelectStyle = OpenLayers.Util.applyDefaults({
	      fillColor: "yellow",
	      strokeColor: "yellow"
	  }, OpenLayers.Feature.Vector.style["select"]);
	  
	  
	  _hoverIncident = new OpenLayers.Control.SelectFeature(_tmcpeLayer,{ 
 	      hover: true,
 	      highlightOnly: true,
              renderIntent: "temporary",
	      selectStyle: hoverSelectStyle
	      //        eventListeners: {
	      //            beforefeaturehighlighted: report,
	      //            featurehighlighted: report,
	      //            featureunhighlighted: report
	      //        }
	  });
	  map.addControl(_hoverIncident);
	  _hoverIncident.activate();
	  
	  _selectIncident = new OpenLayers.Control.SelectFeature(_tmcpeLayer);
	  map.addControl(_selectIncident);
	  _selectIncident.activate();
      };
      dojo.addOnLoad(function(){ initTmcpeLayer() });
    </g:javascript>
  </head>

  <body onload="" 
	class="tundra">

    <!-- Application -->
<!--    <div dojoType="tmcpe.IncidentList" jsId="incidentList" id="incidentList"></div> -->

    <!-- Viewport -->
    <div dojoType="dijit.layout.BorderContainer" id="mapView" design="headline" region="center" gutters="true" liveSplitters="false">
      <!-- Query Pane -->
      <div dojoType="dijit.layout.ContentPane" id="queryspec" region="top">
      </div> <!-- Query Pane -->
      <!-- Map Pane -->
      <div dojoType="dijit.layout.BorderContainer" id="mapgrid" region="center" design="sidebar" style="background:green;" splitter="false" liveSplitters="false">
	<div dojoType="dijit.layout.ContentPane" id="mapPane" region="center" style="background:yellow;" splitter="false" liveSplitters="false">
	  <div dojoType="tmcpe.TestbedMap" id="map" jsId="map"></div>
	</div>
	<div dojoType="dijit.layout.ContentPane" gutters="true" region="right" style="width: 300px">
	  <p id="incidentDetails">Select an incident on the map to view its details here.</p>

	</div>


      </div>
    </div>
   <!-- Incident Data -->
   <div dojoType="dojo.data.ItemFileReadStore" data="{items:[]}" jsId="incidentStore" id="incidentStoreNode" defaultTimeout="20000"></div>
  </body>
</html>
