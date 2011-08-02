<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="bare" />
    <title>Incident List</title>

    <!-- frameworks -->
    <p:javascript src='jquery-1.6.1.min' />
    <p:javascript src='underscore' />
    <p:javascript src='backbone' />

    <!-- formatting -->
    <p:javascript src='jquery.format-1.2.min' />
    <p:javascript src='jquery.dataTables' />
    <p:javascript src='jquery.svg' />    <!-- plugins for manipulating svg using jquery -->
    <p:javascript src='jquery.svgdom' /> <!-- plugins for manipulating svg using jquery -->

    <!-- visualization toolkits -->
    <p:javascript src='polymaps' />
    <p:javascript src='d3' />
    <p:javascript src='protovis' />

    <!-- app code -->
    <p:javascript src='tmcpe-backbone' />
  </head>
  <body>
    <div id='tmcpeapp'>
      <div class='content'>
	<div id='leftbox'>
	  <div id='map'></div>
	  <div id='detail'>Incident test</div>
	</div>
	<div id='content'>
	  <div class='input-block'>
	    <input id='new-incident' placeholder='What data do you want?' type='text' />
	    <span class='ui-tooltip-top'>Press Enter to search</span>
	  </div>
	  <div id='incidents'>
	    <table id='incident-list'>
	      <thead>
		<tr>
		  <th class='col cad'>CAD</th>
		  <th class='col timestamp'>Incident Start</th>
		  <th class='col locString'>Location</th>
		  <th class='col memo'>Memo</th>
		  <th class='col d12_delay'>D12 Delay</th>
		  <th class='col tmcpe_delay'>TMCPE Delay</th>
		  <th class='col savings'>TMC Savings</th>
		</tr>
	      </thead>
	      <tbody>
	      </tbody>
	      <tfoot>
		<tr class='min'>
		  <th class='col cad blank'></th>
		  <th class='col timestamp blank'></th>
		  <th class='col locString blank'></th>
		  <th class='col memo blank'>Min</th>
		  <th class='col d12_delay'></th>
		  <th class='col tmcpe_delay'></th>
		  <th class='col savings'></th>
		</tr>
		<tr class='avg'>
		  <th class='col cad blank'></th>
		  <th class='col timestamp blank'></th>
		  <th class='col locString blank'></th>
		  <th class='col memo blank'>Max</th>
		  <th class='col d12_delay'></th>
		  <th class='col tmcpe_delay'></th>
		  <th class='col savings'></th>
		</tr>
		<tr class='max'>
		  <th class='col cad blank'></th>
		  <th class='col timestamp blank'></th>
		  <th class='col locString blank'></th>
		  <th class='col memo blank'>Avg</th>
		  <th class='col d12_delay'></th>
		  <th class='col tmcpe_delay'></th>
		  <th class='col savings'></th>
		</tr>
	      </tfoot>
	    </table>
	  </div>
	  <div id='incident-stats'></div>
	</div>
      </div>
    </div>
  </body>
</html>
