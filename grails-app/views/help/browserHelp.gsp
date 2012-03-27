<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="layout" content="tmcpe" />
	<title>Unsupported Browser</title>
  </head>
  <body>
	<div class="alert alert-error">
	  <h1 class="alert-heading">Your browser is not supported</h1>
	  <p>${flash.message}</p>
	  <p>
		See the supported browser list below.  If you still believe you've received this message in error, please <g:link controller='problem' title="Report a problem with this website" params="[subject:'Browser incorrectly identified as incompatible', assigned_to_id: 3]">report a problem</g:link> using the issue tracker.
	  </p>
	</div>
	<div class="alert alert-info">
	  <h2 class="alert-heading">Supported Browsers</h2> 
	  <p>
		The TMCPE application depends on browser support for Scalable Vector
		Graphics.  Most modern, standards-compliant browsers are meet these
		requirements.  We suggest using one of the following:
	  </p>
	  <ul>
		<li>Google Chrome 6.0 or greater</li>
		<li>Mozilla Firefox 3.5 or greater</li>
	  </ul>
	</div>
  </body>
</html>