<html>
  <head>
    <title><g:layoutTitle default="TMCPE" /></title>
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
    <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'tmcpe.css')}" />
    <link rel="stylesheet" href="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dijit/themes/tundra',file:'/tundra.css')}" />
    
    <g:layoutHead />
    <script src="${createLinkTo(dir:'js/dojo/dojo-1.3.0/dojo',file:'/dojo.js')}"
	    djConfig="parseOnLoad: true"></script>
    <script>
      dojo.require( "dijit.layout.BorderContainer" );
      dojo.require( "dijit.layout.ContentPane" );
      dojo.require( "dojo.data.ItemFileReadStore" );
      dojo.require( "dojox.grid.DataGrid" );
      dojo.require( "dojo.date.locale" );
    </script>
    <g:javascript library="application" /> 
  </head>
  <body onload="${pageProperty(name:'body.onload')}" width="100%">
    <g:layoutBody />		
  </body>	
</html>
