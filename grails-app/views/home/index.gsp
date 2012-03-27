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
		<h2>Summary Statistics Page</h2>
		<p>
		  This tool summarizes the analyses performed on incidents in the database.
		</p>
		<a class="btn" href="${createLink(controller:'incident', action:'summary')}">
		  View details &raquo;
		</a>
	  </div>
	  <div class="span6">
		<h2>Custom report generator</h2>
		<p>
		  This tool allows one to generate reports for groups of incidents based
		  upon criteria specified by the user.
		</p>
		<a class="btn" href="${createLink(controller:'incident', action:'summary')}">
		  View details &raquo;
		</a>
	  </div>
	</div>

  </body>
</html>
