<html>
  <head>
    <title><g:layoutTitle default="TMCPE" /></title>
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'tmcpe.css')}" />
    <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-release-1.3.2/dijit/themes/tundra',file:'/tundra.css')}" />
    
    <g:layoutHead />
    <script src="${createLinkTo(dir:'js/dojo/dojo-release-1.3.2/dojo',file:'/dojo.js.uncompressed.js')}"
	    djConfig="parseOnLoad: true"></script>
    <script>
      dojo.require( "dijit.layout.BorderContainer" );
      dojo.require( "dijit.layout.ContentPane" );
      dojo.require( "dojo.data.ItemFileReadStore" );
      <!-- crindt: The following per: http://www.nabble.com/JS-Error:-Could-not-load-%27dojox.grid._data.model%27-td20805082.html -->
      dojo.require( "dojox.grid.compat.Grid" );
      dojo.require( "dojox.grid.DataGrid" );
      dojo.require( "dojo.date.locale" );
    </script>
    <g:javascript library="application" /> 
  </head>
  <body onload="${pageProperty(name:'body.onload')}" width="100%">
    <g:layoutBody />		
  </body>	
</html>
