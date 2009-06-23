<?xml version="1.0" encoding="UTF-8"?>
<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Incidents</name>
    <description></description>
    <Style id="redLine">
      <LineStyle>
        <color>220000ff</color>
        <width>10</width>
      </LineStyle>
      <PolyStyle>
        <color>220000ff</color>
	<fill>0</fill>
	<outline>1</outline>
      </PolyStyle>     
    </Style>
    <g:each in="${incidentInstanceList}" status="i" var="incidentInstance">
       <Placemark>
           <name>incident</name>
           <styleUrl>#redLine</styleUrl>
	   ${incidentInstance.toKml()}
      </Placemark>
    </g:each>
  </Document>
</kml>
