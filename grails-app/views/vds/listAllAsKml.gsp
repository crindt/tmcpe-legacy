<?xml version="1.0" encoding="UTF-8"?>
<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Testbed Facilities</name>
    <description></description>
    <g:each in="${vdsInstanceList}" status="i" var="vdsInstance">
      <Style id="style@${vdsInstance.id}">
        <LineStyle>
          <color>${[ 200,0,new Random().nextInt(255),255].encodeAsHex()}</color>
          <width>4</width>
        </LineStyle>
      </Style>
    </g:each>
    <g:each in="${vdsInstanceList}" status="i" var="vdsInstance">
       <Placemark>
           <name>${vdsInstance.name.encodeAsHTML()}</name>
	   <description>
	     ${["<table>",
	       "<tr><td>District</td><td>",vdsInstance.district,"</td></tr>",
	       "<tr><td>Facility</td><td>",vdsInstance.freewayDir," ",vdsInstance.freeway,"</td></tr>",
	       "<tr><td>cal Postmile</td><td>",vdsInstance.calPostmile,"</td></tr>",
	       "<tr><td>abs Postmile</td><td>",vdsInstance.absPostmile,"</td></tr>",
	       "<tr><td>lanes</td><td>",vdsInstance.lanes,"</td></tr>",
	       "</table>"].join("").encodeAsHTML()}
	   </description>
	   <vdsLocation>${vdsInstance.geom.getX()} ${vdsInstance.geom.getY()}</vdsLocation>
	   <styleUrl>#style@${vdsInstance.id}</styleUrl>
	   ${vdsInstance.toKml()}
      </Placemark>
    </g:each>
  </Document>
</kml>
