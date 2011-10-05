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
    <g:if env="development">
      <less:stylesheet name="tmcpe-incident-tsd" />
      <less:stylesheet name="tabs-no-images" />
      <less:stylesheet name="range-input" />
    </g:if>
    <g:if env="production">
      <p:css name="tmcpe-incident-tsd" />
      <p:css name="tabs-no-images" />
      <p:css name="range-input" />
    </g:if>

  </head>
  <body>
    <div id='cad' name='${incidentInstance.cad}' />
    <div id='id' name='${incidentInstance.id}' />

    <div id='tmcpeapp'>
      <div class='content'>
	<div id="tsdParams">
	  <table style="float:left;display:none;">
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
	  <table class="parambox">
	    <tr>
	      <th>Cell theme:</th>
	      <td>
		<select id="theme" name="theme" title="Select whether to display the speed colors based upon standard deviation from the mean or absolute distance from the mean.">
		  <option value="stdspd" >Std Deviation</option>
		  <option selected="true" value="spd">Absolute</option>
		</select>
	      </th>
	    </tr>
	    <tr>
	      <th>Display delay as:</th>
	      <td>
		<form style="display:inline;" title="Choose whether to show delays as vehicle-hours or dollars">
		  <input type="radio" name="delayUnit" checked="true" value="vehhr">veh-hr</option>
		  <input type="radio" name="delayUnit" value="usd">USD</option>
		</form>
	      </td>
	    </tr>
	    <tr>
	      <th>Value of Time</th>
	      <td>
		<input disabled="disabled" type="text" value="13.11" id="valueOfTime" name="valueOfTime" 
                       title="The factor used to convert minutes of delay into a dollar equivalent" />
	      </td>
	    </tr>
	  </table>
	  <table class="parambox">
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
		  <input type="range" name="tmcpctslider" min="0" max="100" value="20"/>
		</div>
	      </td>
	    </tr>
            <tr>
              <th>
                Verification Delay without TMC
              </th>
              <td>
		<div id="verdel">
		  <input type="range" name="verdelslider" min="0" max="60" value="15"/>
                  minutes
		</div>
              </td>
            </tr>
              <tr>
                <th>
                  Response Delay without TMC
                </th>
                <td>
		  <div id="respdel">
		    <input type="range" name="respdelslider" min="0" max="60" value="15" title="Select the number of additional minutes expected for the response to restore capacity"/>
                    minutes
		  </div>
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
	      <div id="cumflowChartTip" class="tooltip noarrow"></div>
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
  
