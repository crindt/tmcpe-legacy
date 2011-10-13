<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- Streamlined GSP for rendering incident list view -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="help" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1' />
    <p:javascript src="jquery.tools.min" />

    <!-- formatting -->

    <!-- visualization toolkits -->

    <!-- app code -->
    <p:javascript src='tmcpe/help' />

    <!-- supporting css -->

    <!-- less stylesheets -->
    <g:if env="development">
    </g:if>
    <g:if env="production">
    </g:if>
      

   <!-- note: less:scripts loaded by base.gsp -->

  </head>
  <body>
    <markdown:renderHtml>
${content}
    </markdown:renderHtml>
  </body>
</html>
