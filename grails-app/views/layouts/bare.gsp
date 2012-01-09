<html>
  <head>
    <!-- layouts/bare.gsp head -->
    <title>Caltrans D12 TMC Performance Evaluation (Version <tmcpe:version />) <g:layoutTitle default="" /></title>

    <g:external uri="images/favicon.ico" />

    <!-- target page layout head -->
    <g:layoutHead />

    <!-- require the common resources bundle -->
    <r:require module="common"/>

    <!-- common javascript -->
    <g:urlMappings /> <!-- custom grails js to emit controller/action urls -->

    <r:layoutResources />
  </head>

  <body onload="${pageProperty(name:'body.onload')}" class="${pageProperty(name:'body.class')}">

    <!-- ================ common banner ================= -->
    <div id="menu">
	  <!-- Link block -->
	  <ul>
	    <li><a href="${resource(dir:'/',absolute:true)}">Home</a></li>
	    <li><a href="http://www.ctmlabs.net/">CTMLabs</a></li>
	  </ul>

	  <!-- account block -->
	  <div id="account">
	    <ul>
	      <li id='loginLink'>
	        <sec:ifLoggedIn>
		      <span title="Logged in via CTMLabs">
		        Logged in as <sec:username/> (<g:link controller='logout'>Logout</g:link>)
		      </span>
	        </sec:ifLoggedIn>
	        <sec:ifNotLoggedIn>
		      <span title="Logged in using CTMLabs CAS server">
		        <g:link controller='login'>Login</g:link>
		      </span>
	        </sec:ifNotLoggedIn>
	      </li>
	      <li><a target="_blank" href="${createLink(controller:'problem',action:'report')}" title="Report a problem using the CTMLabs issue tracker">Report Problem</a></li>
	      <li><a target="_blank" href="${createLink(controller:'help')}">Help</a></li>
	    </ul>
	  </div>
    </div>

    <div class="header">
	  <a href="http://www.ctmlabs.net">
	    <h1>TMCPE</h1>
	  </a>
    </div>


    <!-- ================ target BODY ============== -->
    <g:layoutBody />		
    

    <!-- Some overlays we'll bring up from time to time -->
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

    <r:layoutResources/>
    </body>	

</html>
