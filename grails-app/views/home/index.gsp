<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="layout" content="tmcpe-front" />
	<title>TMC Performance Evaulation</title>

	<r:require modules="docs"/>
  </head>

  <body>
	<header class="hero-unit curl">
	  <hgroup>
		<h1>TMC Performance Evaluation</h1>
		<p>
		  A tool for evaluating the benefits of Traffic Management Centers using
		  observed incidents as a baseline for comparison.
		</p>
	  </hgroup>
	  <a class="btn btn-primary btn-large" href="${createLink(controller:'help', action:'overview')}">Learn more &raquo;</a>
	</header>
	<div class="row">
	  <div class="span6">
		<h2>Explore the application</h2>
		<p>
		  Click through to view a summary of analyzed incidents in the database.
		  From there you can select groups of incidents or view individual
		  analyses.
		</p>
		<a class="btn" href="${createLink(controller:'incident', action:'summary')}">
		  View details &raquo;
		</a>
	  </div>
	  <div class="span6">
		<h2>Request access</h2>
		<p>
		  The TMCPE application requires a CTMLabs account.  If you are
		  interested in obtaining access, contact Craig Rindt <a href="mailto:crindt@ctmlabs.net"><code>crindt@ctmlabs.net</code></a> at CTMLabs and we'll
		  create an account for you.
		</p>
		<a class="btn" href="${createLink(controller:'incident', action:'summary')}">
		  View details &raquo;
		</a>
	  </div>
	</div>

  </body>
</html>
