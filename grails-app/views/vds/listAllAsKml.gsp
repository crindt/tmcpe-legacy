<!-- fixme: crindt: for later completion

<?xml version="1.0" encoding="UTF-8"?>
<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Testbed Facilities</name>
    <description></description>
    <Style id="yellowLine">
      <LineStyle>
        <color>7f00ffff</color>
        <width>4</width>
      </LineStyle>
    </Style>
    <g:each in="${vdsKmlList}" status="i" var="vdsKmlInstance">
       <Placemark>
           <name>facility</name>
	   ${vdsKmlInstance.kml}
      </Placemark>
    </g:each>
  </Document>
</kml>

-->
