<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="layout" content="tmcpe" />
	<title>Incident ${incidentInstance.cad} Detail</title>

	<!-- app code and stylesheets -->
	<r:require module="tmcpe-incident-tsd" />

  </head>
  <body>
	<div id='cad' name='${incidentInstance.cad}' style="display:none"></div>
	<div id='id' name='${incidentInstance.id}' style="display:none"></div>

	<div class='row-fluid'>
	  <div class="span2">
		<h4>Incident ${incidentInstance.cad}</h4>
		<ul class="nav nav-list">
		  <li class="nav-header">Impacted Facilities</li>
		  <g:each in="${incidentInstance.analyses}">
			<g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
			  <input type="radio" name="ifia" value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</input>
			</g:each>
		  </g:each>	      
		  <li class="nav-header">Views</li>
		  <li><a href="#" id="btn-show-all">4-pane</a><li>
		  <li><a href="#" id="btn-only-show-chart">Chart only</a><li>
		  <li><a href="#" id="btn-only-show-table">Table only</a><li>
		  <li><a href="#" id="btn-only-show-map">Map only</a><li>
		  <li><a href="#" id="btn-only-show-tsd">TSD only</a><li>
          <li class="nav-header">Settings</li>
          <li><a href="#" id="btn-change-settings">Change Settings</a></li>
        </ul>
	  </div>

	  <div id="detail" class="span10">
		<div class="row-fluid">
		  <div id="chartcontainer" class="span6">
			<h3>Cumulative Vehicle Count at <span id="chart_location"></span></h3>	  
			<div id="chartbox"></div>
			<span id="msgtxt">&nbsp;</span>
			<div id="cumflowChartTip" class="tooltip noarrow" style="display:none"></div>
			<div id="cumflowTimebarTip" class="tooltip right" style="display:none"></div>
		  </div>
		  <div id="databox" class="span6">
			<ul class="nav nav-tabs">
			  <li class="active">
				<a href="#generalStatsContainer" data-toggle="tab">
				  General Statistics
				</a>
			  </li>
			  <li>
				<a href="#logtableContainer" data-toggle="tab">
				  Activity Log
				</a>
			  </li>
			</ul>
			<div class="panes tab-content">
			</div>
		  </div>
		</div>
		<div class="row-fluid">
		  <div id="tsdcontainer" class="span6">
			<div id="tsdbox"></div>
		    <div style="text-align:center" class="span6">
			  <div id="cellDetail"></div>
		    </div>
		  </div>
		  <div id="mapbox" class="span6">
			<div id="map" tabindex="1"></div>
		  </div>
		</div>
		
		<div id="tsdParams" class="modal" style="display:none">
          <div class="modal-header">
            <a href="#" class="close" data-dismiss="modal">x</a>
            <h3>Settings</h3>
          </div>
          <div class="modal-body">
            <form>
              <div class="row-fluid">
                <div class="span6">
			      <label>Facility</label>
			      <select id="ifia" name="ifia">
				    <g:each in="${incidentInstance.analyses}">
				      <g:each var="ifia" in="${it.incidentFacilityImpactAnalyses}">
					    <option selected="true" value="${ifia.id}">${ifia.location.freewayId}-${ifia.location.freewayDir}</option>
				      </g:each>
				    </g:each>	      
			      </select>
			      <label>Cell theme</label>
			      <select id="theme" name="theme" title="Select whether to display the speed colors based upon standard deviation from the mean or absolute distance from the mean.">
				    <option value="stdspd" >Std Deviation</option>
				    <option selected="true" value="spd">Absolute</option>
			      </select>
                </div>
                <div class="span6">
                  <label>Delay Unit</label>
			      <form style="display:inline;" title="Choose whether to show delays as vehicle-hours or dollars">
				    <input type="radio" name="delayUnit" checked="true" value="vehhr">veh-hr</input>
				    <input type="radio" name="delayUnit" value="usd">USD</input>
			      </form>
                  <label>Value of Time</label>
			      <input disabled="disabled" type="text" value="13.11" 
                         id="valueOfTime" name="valueOfTime" 
					     title="The factor used to convert minutes of delay into a dollar equivalent" ></input>
		          <div style="display:none"> <!-- hide this -->
				    <label>Max Incident Speed:</label>
				    <div id="maxspdslider" title="Select the percent of observed diversion attributable to TMC actions">
				      <input type="range" name="maxspdslider" min="0" max="80" value="50"></input>
				    </div>
                  </div>
			      <div style="display:none"> <!-- hide this -->
				    <label>Incident Evidence Scale:</label>
				    <div id="scaleslider" title="Select the multiple of stddev speed ">
				      <input type="range" name="scaleslider" min="0" max="5" value="10"></input>
				    </div>
                  </div>
                </div>
              </div>
              <!--
			      <label>Align map to:</label>
			      <form style="display:inline;">
				    <option type="radio" name="align" checked="true" value="cardinal" onclick="rotateMap(this);">Cardinal directions</option>
                    
                    <input type="radio" name="align" value="incident" onclick="rotateMap(this)">Incident</option>
</form>
-->
              <div class="row-fluid">
                <div class="span12 form-horizontal">
                  <div class="control-group">
                    <label>TMC Diversion %:</label>
			        <div id="tmcpctslider" title="Select the percent of observed diversion attributable to TMC actions">
				      <input type="range" class="slider" name="tmcpctslider" min="0" max="100" value="20"></input>
			        </div>
                  </div>
                  <div class="control-group">
			        <label>Verification Delay without TMC</label>
			        <div id="verdel" title="Select the number of additional minutes expected for verification if the TMC wasn't there">
				      <input type="range" class="slider" name="verdelslider" min="0" max="60" value="15"></input>
				      minutes
			        </div>
                  </div>
                  <div class="control-group">
                    <label>
				      Response Delay without TMC
                    </label>
			        <div id="respdel" title="Select the number of additional minutes expected for the response to restore capacity if the TMC wasn't there">
				      <input type="range" class="slider" name="respdelslider" min="0" max="60" value="15"></input>
				      minutes
			        </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <a href="#" class="btn btn-primary" data-dismiss="modal">OK</a>
          </div>
        </div>
	  </div>
    </div>
  </body>
</html>

