<html>
    <head>
      <!-- layouts/main.gsp head -->
      <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

      <!-- The named base url for this site.  This is used by the
	   TMCPE javascript to create valid links programmatically
	   indepdent of the installation -->
      <base id="htmldom"  href="${resource(dir:'/',absolute:true)}" />

      <!-- The preloader style so the user doesn't see the unformatted screen -->
      <style type="text/css">
	#preloader {
	width:100%; height:100%; margin:0; padding:0;
	background:#fff 
	url('http://o.aolcdn.com/dojo/1.2/dojox/image/resources/images/loading.gif')
	no-repeat center center;
	position:absolute;
	z-index:999;
	}
      </style>

      <!-- must come before css:bundled, we override navigation -->
      <nav:resources />

      <p:css name='bundled' />

      <!-- The dojo styles -->
      <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/1.5/dijit/themes/tundra/layout/BorderContainer.css' />
      <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/1.5/dojox/grid/resources/Grid.css' />
      <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/1.5/dojox/grid/resources/tundraGrid.css' />
      <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/1.5/dijit/themes/tundra/tundra.css' />
      
      <p:favicon src="${resource(dir:'/images',file:'favicon.ico')}" />

      <!-- layouts/main.gsp layout head -->
      <g:layoutHead />
    </head>

    <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">
      <!-- ================ layouts/main.gsp BODY ============== -->

      <!-- Used to blank the screen until its rendered -->
      <div id="preloader"></div>

      <!-- Main Window -->
      <div dojoType="dijit.layout.BorderContainer" id="main" design="headline" gutters="false">
	<!-- Banner -->
	<div dojoType="dijit.layout.ContentPane" id="banner" region="top" class="nav">
	  <div style="float:left;font-size:30px;padding-left:10px;">
	    TMC Performance Evaluation
	  </div>
	  <div style="float:right;">
	    <nav:render/>
	    <div style="float:right;"><sec:ifLoggedIn>Logged in as <sec:loggedInUserInfo field="username"/></sec:ifLoggedIn></div>
	    <span dojoType="dijit.Tooltip"
		  connectId="problemButton">
	      Click to open a new issue on the issue tracker (you must already be logged in)
	    </span>
	  </div>
	</div>
	<!-- layouts/main.gsp: layout body-->

	<g:layoutBody />		
      </div>

      <!-- The common core application javascript -->
      <p:javascript src="application-core" />
      
      <tmcpe:dojo_config />
      <g:javascript base="http://ajax.googleapis.com/ajax/libs/dojo/1.5/" src="dojo/dojo.xd.js" />

      <g:javascript>
         // our fancy preloader-hider-function:
         var hideLoader = function(){
             dojo.fadeOut({
         	 node:"preloader",
         	 duration:700,
		 onEnd: function(){
		     dojo.style("preloader", "display", "none");
		     // $("#preloader").css("display","none"); 
		 }
	     }).play();
	 }
         dojo.addOnLoad(function(){
	     // after page load, load more stuff (spinner is already spinning)
	     dojo.require("dijit.layout.BorderContainer");
	     dojo.require("dijit.layout.ContentPane");
	     dojo.require("dijit.Tooltip");

	     dojo.require("dojo.parser");	     

	     dojo.addOnLoad(function(){
	        dojo.parser.parse();
	        hideLoader();
             });

	 });
      </g:javascript>
      
      <!-- Now render the rest of the page javascript -->
      <p:renderDependantJavascript />
    </body>	

</html>
