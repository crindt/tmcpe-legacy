<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="bare" />
    <title>Incident ${incidentInstance.cad} Detail</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1.min' />
    <p:javascript src='underscore-min' />
    <p:javascript src='mustache' />

    <!-- formatting -->
    <p:javascript src='jquery-1.6.1.min' />
    <p:javascript src='jquery.tools.min' />
<!--
    <p:javascript src='jquery-ui-1.8.13.custom.min' />
-->
    <p:javascript src='jquery.format-1.2.min' />
    <p:javascript src='jquery.dataTables' />
    
    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='d3' />
    <p:javascript src='d3.geom' />
    <p:javascript src='protovis' />


    <!-- app code -->
    <p:javascript src='tmcpe/incident-tsd' />


    <!-- supporting css -->

    <!-- less stylesheets -->
    <less:stylesheet name="tmcpe-incident-tsd" />
    <less:stylesheet name="tabs-no-images" />
    <less:stylesheet name="range-input" />

  </head>
  <body>
    <div id='cad' name='${incidentInstance.cad}' />
    <div id='id' name='${incidentInstance.id}' />

    <div id='tmcpeapp'>
      <div class='content'>
	<div id="tsdParams">
	  <table style="float:left;">
	    <tr>
	      <th>Facility:</th>
	      <td>
		<select id="ifia" name="ifia">
		  <g:each in="${incidentInstance.analyses}">
		    <g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
		      <option selected="true" value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</option>
		    </g:each>
		  </g:each>	      
		</select>
	      </td>
	    </tr>
	  </table>
	  <table style="float:left">
	    <tr>
	      <th>Cell theme:</th>
	      <td>
		<select id="theme" name="theme">
		  <option value="stdspd">Standard Deviation of Speed from Mean</option>
		  <option selected="true" value="spd">Speed Scaled between max speed and jam speed</option>
		</select>
	      </th>
	    </tr>
	  </table>
	  <table style="float:left;border:solid 1px white">
	    <!--
		<tr >
		<th>Align map to:</th>
		<td>
		<form style="display:inline;">
		<input type="radio" name="align" checked="true" value="cardinal" onclick="rotateMap(this);">Cardinal directions</option>
		<input type="radio" name="align" value="incident" onclick="rotateMap(this)">Incident</option>
		</form>
		</td>
		</tr>
	    -->
	    <tr>
	      <th>TMC Diversion %:</th>
	      <td>
		<div id="tmcpctslider">
		  <input type="range" name="tmcpctslider" min="0" max="100" value="50"/>
		</div>
	      </td>
	    </tr>
	    <tr>
	      <th>Display delay as:</th>
	      <td>
		<form style="display:inline;">
		  <input type="radio" name="delayUnit" checked="true" value="vehhr">veh-hr</option>
		  <input type="radio" name="delayUnit" value="usd">USD</option>
		</form>
	      </td>
	    </tr>
	    <tr>
	      <th>Value of Time</th>
	      <td>
		<input disabled="disabled" type="text" value="13.11" id="valueOfTime" name="valueOfTime"/>
	      </td>
	    </tr>
	  </table>
	</div>
	
	<div id="msg" class="fullcontainer">
	  <p><h3 style="display:inline;color:yellow;">Incident ${incidentInstance.cad}:&nbsp;</h3><span id="msgtxt">&nbsp;</span></p>
	</div>
	
	<div id="detail">
	  
	  <div class="fullcontainer">
	    <div id="tsdcontainer" class="leftbox">
	      <div id="tsdbox">
	      </div>
	    </div>
	    <div id="mapbox" class="mapcontainer rightbox">
	      <div id="map" tabindex="1"></div>
	    </div>
	  </div>
	  <div class="fullcontainer">
	    <div id="chartcontainer" class="leftbox">
	      <div id="chartbox"></div>
	      <h3>Cumulative Vehicle Count at <span id="chart_location"></span></h3>	  
	    </div>
	    <div id="databox" class="rightbox">
	      <ul class="tabs">
		<li><a href="#">General Statistics</a></li>
		<li><a href="#">Activity Log</a></li>
	      </ul>
	      <div class="panes">
		<div id="generalStatsContainer">
		  <table id="generalStats">
                   <thead>
                     <tr>
                       <th class="label">Facility</th>
                       <th class="numlabel">Delay<35</th>
                       <th class="numlabel">Delay</th>
                       <!--
                           <th class="label">&Delta;q</th>
                           <th class="label">max(q)</th>
                       -->
                       <th class="numlabel">Delay<br/>(no TMC)</th>
                       <th class="numlabel">TMC Savings</th>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td class="facilityName" id="facility"></td>
                       <td class="delayValue" id="d12Delay"></td>
                       <!--              <td class="unit delayUnit" id="d12DelayUnit">veh-hr</td> -->

                       <td class="delayValue" id="netDelay"></td>
                       <!--              <td class="unit delayUnit" id="netDelayUnit">veh-hr</td> -->

                       <!--              <td class="value" id="computedDiversion"></td> -->
                       <!--              <td class="unit" id="computedDiversionUnit">veh</td> -->

                       <!--              <td class="value" id="computedMaxq"></td> -->
                       <!--              <td class="unit" id="computedMaxqUnit">veh</td> -->

                       <td class="delayValue" id="whatIfDelay"></td>
                       <!--              <td class="unit delayUnit" id="whatIfDelayUnit">veh-hr</td> -->

                       <td class="delayValue" id="tmcSavings"></td>
                       <!--              <td class="unit delayUnit" id="tmcSavingsUnit">veh-hr</td> -->
                     </tr>
                   </tbody>
                 </table>
                 <a id="tmcpe_tsd_download_link"></a>
                 &nbsp;|&nbsp;
                 <a id="tmcpe_report_analysis_problem_link"></a>
               </div>
               <div id="logtableContainer">
                 <table id="activityLog">
                 </table>
               </div>
             </div>
	  </div>
	</div>
      </div>
    </div>
  </body>
</html>
  