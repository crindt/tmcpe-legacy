<html>
    <head>
      <!-- layouts/main.gsp head -->
      <title><g:layoutTitle default="Grails" /></title>
      <base id="htmldom" href="${createLinkTo(dir:'/')}"/>
      <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
      <link rel="shortcut icon" href="${createLinkTo(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
      <nav:resources />
      
      <!-- layouts/main.gsp layout head -->
      <g:layoutHead />
      <g:javascript library="application" />
      <g:javascript>
	dojo.require("dijit.dijit");
	dojo.require("dijit.layout.BorderContainer");
	dojo.require("dijit.layout.ContentPane");
      </g:javascript>
	
    </head>
    <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">
      <!-- layouts/main.gsp body -->
        <div id="spinner" class="spinner" style="display:none;">
            <img src="${createLinkTo(dir:'images',file:'spinner.gif')}" alt="Spinner" />
        </div>	
        <div class="logo"><!--<img src="${createLinkTo(dir:'images',file:'grails_logo.jpg')}" alt="Grails" />--></div>
	<div dojoType="dijit.layout.BorderContainer" id="main" design="headline" gutters="false">
	  <div dojoType="dijit.layout.ContentPane" region="top" id="menu" class="nav" splitter="false">
	    <!--<g:render template="/mainmenu" />-->
	    <nav:render/>
	  </div>
 	    <!-- layouts/main.gsp: layout body-->

            <g:layoutBody />		

	</div>
    </body>	
</html>
