<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>

<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Testbed Facilities</name>
    <description></description>
    <Style id="yellowLineGreenPoly">
      <LineStyle>
        <color>7f00ffff</color>
        <width>4</width>
      </LineStyle>
      <PolyStyle>
        <color>7f00ff00</color>
      </PolyStyle>
    </Style>
    <g:each in="${testbedLineInstanceList}" status="i" var="testbedLineInstance">
       <Placemark>
           <name>facility</name>
           <!--<styleUrl>#yellowLineGreenPoly</styleUrl>-->
	   ${fieldValue(bean:testbedLineInstance, field:'kml')}
      </Placemark>
    </g:each>
  </Document>
</kml>