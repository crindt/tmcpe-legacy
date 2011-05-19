<html>
    <head>
      <!-- layouts/main.gsp head -->
      <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

      <!-- The named base url for this site.  This is used by the
	   TMCPE javascript to create valid links programmatically
	   indepdent of the installation -->
      <base id="htmldom"  href="${resource(dir:'/',absolute:true)}" />


      <p:css name="960-fluid" /> <!-- Load the 960 css -->
      <p:css name="ui-lightness/jquery-ui-1.8.13.custom" /> <!-- Load the jquery ui theme css -->
      <p:css name="tmcpe-common" />
      
<!--      <p:favicon src="${resource(dir:'images',file:'favicon.ico')}" /> -->
      <p:favicon src="images/favicon.ico" />

      <!-- layouts/main.gsp layout head -->
      <g:layoutHead />
    </head>

    <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">
      <!-- ================ common banner ================= -->

      <div id="menu">
	<div id="account">
	  <ul>
	    <li id='loginLink'>
	      <sec:ifLoggedIn>
		Logged in as <sec:username/> (<g:link controller='logout'>Logout</g:link>)
	      </sec:ifLoggedIn>
	      <sec:ifNotLoggedIn>
		<g:link controller='login'>Login</g:link>
	      </sec:ifNotLoggedIn>
	    </li>
	    <li><a href="problem/report">Report Problem</a></li>
	    <li><a href="help">Help</a></li>
	  </ul>
	</div>
	<ul>
	  <li><a href="${resource(dir:'/',absolute:true)}">Home</a></li>
	  <li><a href="">CTMLabs</a></li>
	</ul>
      </div>

      <div id="header" class="container_16 clearfix">

	<div style="float:left;margin-left:10px;">
	  <a href="http://www.ctmlabs.net"><img src="images/logo_jem_060.png" alt="CTMLabs" title="" width="140" height="60" /></a>
	  <h1><a href="${resource(dir:'/',absolute:true)}" style="text-decoration:none;color:#fff">TMCPE</a></h1>
	</div>
      </div>


      <!-- ================ layouts/main.gsp BODY ============== -->
	<g:layoutBody />		
      
      <!-- Now render the rest of the page javascript -->
      <p:renderDependantJavascript />
    </body>	

</html>
