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
    <div id='cad' name='${incidentInstance.cad}' style="display:none"></div>
    <div id='id' name='${incidentInstance.id}' style="display:none"></div>

    <div id='tmcpeapp'>
      <div class='content'>
        <h3 style="display:inline;color:yellow;">Incident ${incidentInstance.cad}</h3>
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
            <tr style="display:none"> <!- hide this -->
	      <th>Max Incident Speed:</th>
	      <td>
		<div id="maxspdslider" title="Select the percent of observed diversion attributable to TMC actions">
		  <input type="range" name="maxspdslider" min="0" max="80" value="50"/>
		</div>
	      </td>
            </tr>
            <tr style="display:none"> <!- hide this -->
	      <th>Incident Evidence Scale:</th>
	      <td>
		<div id="scaleslider" title="Select the multiple of stddev speed ">
		  <input type="range" name="scaleslider" min="0" max="5" value="10"/>
		</div>
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
		<div id="tmcpctslider" title="Select the percent of observed diversion attributable to TMC actions">
		  <input type="range" name="tmcpctslider" min="0" max="100" value="20"/>
		</div>
	      </td>
	    </tr>
            <tr>
              <th>
                Verification Delay without TMC
              </th>
              <td>
		<div id="verdel" title="Select the number of additional minutes expected for verification if the TMC wasn't there">
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
		  <div id="respdel" title="Select the number of additional minutes expected for the response to restore capacity if the TMC wasn't there">
		    <input type="range" name="respdelslider" min="0" max="60" value="15"/>
                    minutes
		  </div>
                </td>
                
            </tr>
	  </table>
	</div>
	
	<div id="msg" class="fullcontainer">
	  <p style="text-align:center">
            <div id="cellDetail"/>
          </p>
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
              <span id="msgtxt">&nbsp;</span>
	      <div id="cumflowChartTip" class="tooltip noarrow" style="display:none"></div>
	      <div id="cumflowTimebarTip" class="tooltip right" style="display:none"></div>
	    </div>
	    <div id="databox" class="rightbox">
	      <ul class="tabs">
		<li><a href="#">General Statistics</a></li>
		<li><a href="#">Activity Log</a></li>
	      </ul>
	      <div class="panes">
              </div>
             </div>
	  </div>
	</div>
      </div>
    </div>
  </body>
</html>
  
