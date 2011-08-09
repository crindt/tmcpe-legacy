<html>
    <head>
      <!-- layouts/main.gsp head -->
      <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

      <!-- The named base url for this site.  This is used by the
	   TMCPE javascript to create valid links programmatically
	   indepdent of the installation -->
      <base id="htmldom"  href="${resource(dir:'/',absolute:true)}" />


      <p:css name="ui-lightness/jquery-ui-1.8.13.custom" /> <!-- Load the jquery ui theme css -->
      <p:css name="tmcpe-bare" />
      
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
	    <li><a target="_blank" href="problem/report">Report Problem</a></li>
	    <li><a target="_blank" href="help">Help</a></li>
	  </ul>
	</div>
	<ul>
	  <li><a href="${resource(dir:'/',absolute:true)}">Home</a></li>
	  <li><a href="">CTMLabs</a></li>
	</ul>
      </div>

      <div class="header">
	<a href="http://www.ctmlabs.net">
	<h1>TMCPE</h1>
	</a>
      </div>


      <!-- ================ layouts/main.gsp BODY ============== -->
	<g:layoutBody />		
      
      <!-- Now render the rest of the page javascript -->
      <p:renderDependantJavascript />
    </body>	

</html>
