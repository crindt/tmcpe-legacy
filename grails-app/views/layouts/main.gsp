<html>
    <head>
      <!-- layouts/main.gsp head -->
      <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

      <!-- The named base url for this site.  This is used by the
	   TMCPE javascript to create valid links programmatically
	   indepdent of the installation -->
      <base id="htmldom"  href="${resource(dir:'/',absolute:true)}" />

      <link rel="stylesheet" href="${resource(dir:'css',file:'main.css')}" />
      <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

      <nav:resources />
      <!-- Now overload the stock navigation.css---must be after nav:resources -->
      <link rel="stylesheet" href="${resource(dir:'css',file:'navigation.css')}" />
      
      <!-- layouts/main.gsp layout head -->
      <g:layoutHead />
      <g:javascript library="application" />
      <g:javascript>
	dojo.require("dijit.dijit");
	dojo.require("dijit.layout.BorderContainer");
	dojo.require("dijit.layout.ContentPane");
	dojo.require("dijit.Tooltip");
      </g:javascript>
	
    </head>
    <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">
      <!-- layouts/main.gsp body -->
        <div id="spinner" class="spinner" style="visibility:visible;z-index:-1;">
            <img src="${resource(dir:'images',file:'spinner.gif')}" alt="Spinner" />
        </div>	
	<!-- Main Window -->
	<div dojoType="dijit.layout.BorderContainer" id="main" design="headline" gutters="false">
	  <!-- Banner -->
	  <div dojoType="dijit.layout.ContentPane" id="banner" region="top" class="nav">
	    <div style="float:left;font-size:30px;padding-left:10px;">
	      TMC Performance Evaluation
	      <!--<g:render template="/mainmenu" />-->
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
    </body>	
</html>
