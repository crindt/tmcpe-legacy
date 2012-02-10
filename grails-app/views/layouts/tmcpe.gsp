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
	</head>

	<body>

		<nav class="navbar navbar-fixed-top">
			<div class="navbar-inner">
				<div class="container-fluid">
					
<!--
					<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</a>
-->

					<a class="brand" href="${createLink(uri: '/')}">TMCPE</a>

					<ul class="nav">							
					  <li<%= request.forwardURI == "${createLink(uri: '/')}" ? ' class="active"' : '' %>><a href="${createLink(uri: '/')}">Home</a></li>
					  <g:each var="c" in="${grailsApplication.controllerClasses.grep{ it.naturalName in ['Summary Controller', 'Incident Controller' ] } }">
						<li<%= c.logicalPropertyName == controllerName ? ' class="active"' : '' %>><g:link controller="${c.logicalPropertyName}">${c.naturalName.replaceAll(/\s*Controller/,"")}</g:link></li>
					  </g:each>
					</ul>
					<ul class="nav pull-right">
					  <sec:ifLoggedIn>
						<li class="dropdown">
						  <a href="#"
							 class="dropdown-toggle"
							 data-toggle="dropdown">
							<sec:username/>
							<b class="caret"></b>
						  </a>
						  <ul class="dropdown-menu">
							<li><g:link controller='logout'>Logout</g:link></li>
						  </ul>
						</li>
					  </sec:ifLoggedIn>
					  <sec:ifNotLoggedIn>
						<li>
						  <g:link controller='login' title="Log in using CTMLabs CAS server">Login</g:link>
						</li>
					  </sec:ifNotLoggedIn>
					  <li><a href="http://tracker.ctmlabs.net/projects/tb/issues/new" title="Report a problem with this website">Report Problem</a></li>
					</ul>
				</div>
			</div>
		</nav>

		<div class="container-fluid">
			<g:layoutBody/>

			<hr>

			<footer>
				<p>&copy; <a href="http://www.ctmlabs.net/">CTMLabs</a> and <a href="http://dot.ca.gov/">Caltrans</a></p>
			</footer>
		</div>

		<r:layoutResources/>

	</body>
</html>
