<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="tmcpe-doc" />
    <title>Incident List</title>

    <!-- frameworks -->
    <r:require module="stdui" />

  </head>
  <body>
	<div class="alert alert-error">
       <markdown:renderHtml>
There is no help page for '${page}'.

* path: ${f}
       </markdown:renderHtml>
	</div>
  </body>
</html>
