<html>
  <head>
    <!-- layouts/bare.gsp head -->
    <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

    <g:external uri="images/favicon.ico" />

    <!-- target page layout head -->
    <g:layoutHead />

    <!-- require the common resources bundle -->
    <r:require module="common"/>

	<!-- require the resources for the ctmlabs bar -->
	<r:require module="ctmlabs-bar"/>

    <!-- common javascript -->
    <g:urlMappings /> <!-- custom grails js to emit controller/action urls -->

	<g:javascript>
	  var testservice = 'http://anne.its.uci.edu/banner';
      var loginlink='https://cas.ctmlabs.net/cas/login?service=https://localhost:8443/tmcpe';
      var logoutlink='https://cas.ctmlabs.net/cas/logout';
	  jQuery = $;
	</g:javascript>

    <r:layoutResources />
  </head>

  <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">

    <!-- ================ common banner ================= -->
	<div id="ctmlabsbanner">
	  <nav class="ctmlabs" id="menu">
		<ul>
		  <li>
			<a class="home" href="http://www.ctmlabs.net" title="CTMLabs home">&nbsp;</a></li>
		  <li>
			<a href="/projects">Project Websites</a>
			<ul>
			  <li>
				<a href="https://tmcpe.ctmlabs.net/tmcpe-1.1">TMC Performance Evaulation</a></li>
			  <li>
				<a href="http://128.200.36.104:8080/SATMSWeb">Ramp Meter Evaluation Platform</a></li>
			  <li>
				<a href="http://moon.its.uci.edu/inside">INSIDE Laboratory</a></li>
			  <li>
				<a href="https://safety.ctmlabs.net/">Safety</a></li>
			</ul>
		  </li>
		</ul>
	  </nav>
	  <div id="title">
		<span>TMC Performance Evaluation</span>
	  </div>
	  <nav class="account" id="account">
		<ul>
		  <sec:ifLoggedIn>
			<li><span><sec:username/></span>
			  <ul>
				<!--
					<li id="loginLink"></li>
				<li id="logoutLink"></li>
				-->
				<li><g:link controller='logout'>Logout</g:link></li>
			  </ul>
			</li>
		  </sec:ifLoggedIn>
		  <sec:ifNotLoggedIn>
			<li>
              <span title="Logged in using CTMLabs CAS server">
                <g:link controller='login'>Login</g:link>
              </span>
			</li>
		  </sec:ifNotLoggedIn>
		  <li><span>Help</span>
			<ul>
			  <li>
				<a href="http://tracker.ctmlabs.net/projects/tb/issues/new" title="Report a problem with this website">Report Problem</a></li>
			  <li>
				<a href="http://www.ctmlabs.net/about" title="About CTMLabs">About</a></li>
			</ul>
		  </li>
	  </nav>
	</div>


    <!-- ================ target BODY ============== -->
    <g:layoutBody />		
    

    <!-- Some overlays we'll bring up from time to time -->
	<div class="overlay_container">
      <div class="simple_overlay" id='loading'>
		<div id='loading_block'>Loading data...</div>
      </div>

      <div class="simple_overlay error" id="error_overlay">
		<h1>There was a error in the code that resulted in an unexpected program state:</h1>
		
		<table>
	      <tr><td class="label">file:</td><td class="errfile"></td></tr>
	      <tr><td class="label">line:</td><td class="errline"></td></tr>
	      <tr><td class="label">message:</td><td class="errmsg"></td></tr>
		</table>
		
		<ul>
	      <li><a href="#" onclick="window.location.reload()">try reloading the page,</a></li>
	      <li class="report"><a target="_blank" href="http://tracker.ctmlabs.net/projects/tmcpe/issues/new?issue[tracker_id]=1&issue[subject]=Logical error">report a problem</a> using the CTMLabs tracker, or</li>
	      <li>try again later...</li>
		</ul>
      </div>
	</div>

    <r:layoutResources/>
    </body>	

</html>
