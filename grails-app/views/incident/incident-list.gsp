<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
<head>
  <title>Demo TMCPE Application</title>
  <meta name="layout" content="main" />

  <style> 
    /* NOTE: for a full screen layout, must set body size equal to the viewport. */
       html, body, #main { height: 100%; width: 100%; margin: 0; padding: 0; }
  </style>
  <style type="text/css">
    @import "js/dojo/dojo-1.3.0/dijit/themes/soria/soria.css";
  </style>



<!--    <script type="text/javascript" src="/tmcpe/js/dojo/dojo-1.3.0/dojo/dojo.js" djConfig="parseOnLoad:true,isDebug:false"> -->
    </script>
    <script type="text/javascript">
      dojo.require("dojo.parser");
      dojo.require("dijit.form.Form");
      dojo.require("dijit.form.ValidationTextBox");
      dojo.require("dijit.form.ComboBox");
      dojo.require("dijit.form.FilteringSelect");
      dojo.require("dijit.form.DateTextBox");
      dojo.require("dijit.form.CurrencyTextBox");
      dojo.require("dijit.form.NumberSpinner");
      dojo.require("dijit.form.Slider");
      dojo.require("dijit.form.Textarea");
      dojo.require("dijit.Editor");
      dojo.require("dijit._editor.plugins.FontChoice");
      dojo.require("dijit.form.Button");
      dojo.require("dojox.data.QueryReadStore");
      dojo.require("dojox.grid.DataGrid");
      dojo.require("dijit.layout.BorderContainer");
      dojo.require("dijit.layout.ContentPane");
      dojo.require("dijit.layout.LayoutContainer");
      dojo.require("dijit.ProgressBar");
    </script>

<!--
	<script type="text/javascript" src="src.js" charset="utf-8"></script>
-->

</head>
<body class="soria" role="application">
  <!--
  <div id="preLoader"><p></p></div>
  -->
  <div dojoType="dojo.data.ItemFileReadStore" url="/tmcpe/incident/list.json" jsId="incidentStore" id="incidentStoreNode" />

  <div id="main" dojoType="dijit.layout.BorderContainer" design="headline">

    <!-- TOP PANE/MENU -->
    <div dojoType="dijit.layout.ContentPane" region="top">
      <g:render template="/mainmenu" />
    </div>

    <!-- CENTER PANE -->
    <div dojoType="dijit.layout.ContentPane" region="center" style="font-size: 80%;" >
      
      <table id="incidentGridNode" 
	     jsId="incidentGrid" 
	     dojoType="dojox.grid.DataGrid" 
	     store="incidentStore"
	     rowSelector="20px"
	     query="{locString:'*405 N*'}"
	     >
	<thead>
	  <tr>
	    <th field="id" width="10em">CAD ID</th>
	    <th field="timestamp" width="10em">Timestamp</th>
	    <th field="locString" width="20em">Section</th>
	    <th field="memo" width="60em">Description</th>
	  </tr>
	</thead>
      </table>
    </div>
  </div>
</body>
</html>
