<%@ page import="org.codehaus.groovy.grails.web.servlet.GrailsApplicationAttributes" %>
<!doctype html>
<html lang="en">
  <head>
	<meta charset="utf-8">
	<title><g:layoutTitle default="${meta(name: 'app.name')}"/></title>
	<meta name="description" content="">
	<meta name="author" content="">

	<meta name="viewport" content="initial-scale = 1.0">

	<!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
	<!--[if lt IE 9]>
		<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->

    <!-- require the common resources bundle -->
    <r:require module="common"/>

	<r:require modules="scaffolding"/>

    <!-- common javascript -->
    <g:urlMappings /> <!-- custom grails js to emit controller/action urls -->

	<!-- Le fav and touch icons -->
	<link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico')}" type="image/x-icon">
	<link rel="apple-touch-icon" href="${resource(dir: 'images', file: 'apple-touch-icon.png')}">
	<link rel="apple-touch-icon" sizes="72x72" href="${resource(dir: 'images', file: 'apple-touch-icon-72x72.png')}">
	<link rel="apple-touch-icon" sizes="114x114" href="${resource(dir: 'images', file: 'apple-touch-icon-114x114.png')}">

	<g:layoutHead/>
	<r:layoutResources/>
	<ga:trackPageview/>
  </head>

  <body  data-spy="scroll" data-target=".subnav" data-offset="50" data-rendering="true">

	<g:render template="/ctmlabsmenu"/> 

	<div id="tmcpeapp" class="container-fluid">
	  <g:layoutBody/>

	  <hr>

	  <footer>
		<p>&copy; <a href="http://www.ctmlabs.net/">CTMLabs</a> and <a href="http://dot.ca.gov/">Caltrans</a></p>
	  </footer>
	</div>

    <!-- Some overlays we'll bring up from time to time -->
    <div class="simple_overlay modal" id='loading'>
	  <div class="modal-header" id='loading_block'>
        <h3>Loading data...</h3>
      </div>
    </div>
    
    <div class="simple_overlay modal error" id="error_overlay" style="display:none;">
      <div class="modal-header">
	    <h3>There was a error in the code that resulted in an unexpected program state:</h3>
</div>
      <div class="modal-body">
	    <table>
	      <tr><td class="label">file:</td><td class="errfile"></td></tr>
	      <tr><td class="label">line:</td><td class="errline"></td></tr>
	      <tr><td class="label">message:</td><td class="errmsg"></td></tr>
	    </table>
      </div>
      <div class="modal-footer">
        <div class="modal-footer">
          <a href="#" class="btn btn-primary" data-dismiss="modal">OK</a>
        </div>
      </div>
	  
	  <ul>
	    <li><a href="#" onclick="window.location.reload()">try reloading the page,</a></li>
	    <li class="report"><a target="_blank" href="http://tracker.ctmlabs.net/projects/tmcpe/issues/new?issue[tracker_id]=1&issue[subject]=Logical error">report a problem</a> using the CTMLabs tracker, or</li>
	    <li>try again later...</li>
	  </ul>
    </div>

	<r:layoutResources/>
  </body>
</html>
