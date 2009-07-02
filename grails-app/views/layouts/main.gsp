<html>
    <head>
        <title><g:layoutTitle default="TMCPE" /></title>
        <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${createLinkTo(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

        <g:layoutHead />
	<script src="/tmcpe/js/dojo/dojo-1.3.0/dojo/dojo.js"
		djConfig="parseOnLoad: true"></script>
	<script>
	  dojo.require( "dijit.layout.BorderContainer" );
	  dojo.require( "dijit.layout.ContentPane" );
	</script>
        <g:javascript library="application" /> 
    </head>
    <body onload="${pageProperty(name:'body.onload')}" width="100%">
      <g:layoutBody />		
    </body>	
</html>
