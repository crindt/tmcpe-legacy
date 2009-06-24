<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
<head>
	<title>Demo TMCPE Application</title>

	<link rel="stylesheet" href="demo.css">

    <style type="text/css">
      @import "/tmcpe/js/dojo-release-1.2b/dojo/resources/dojo.css";
      @import "/tmcpe/js/dojo-release-1.2b/dijit/themes/soria/soria.css";
      @import "/tmcpe/js/dojo-release-1.2b/dijit/themes/soria/soria_rtl.css";
      @import "/tmcpe/js/dojo-release-1.2b/dijit/tests/css/dijitTests.css";
    </style
    <style> 
      /* NOTE: for a full screen layout, must set body size equal to the viewport. */
      html, body { height: 100%; width: 100%; margin: 0; padding: 0; }
    </style>

	<script type="text/javascript" src="/tmcpe/js/dojo-release-1.2b/dojo/dojo.js" charset="utf-8"
	    djConfig="isDebug: false, parseOnLoad: true"></script>
    <script type="text/javascript">
      dojo.require("dojo.parser");
      dojo.require("dijit.form.Form");
      dojo.require("dijit.form.ValidationTextBox");
      dojo.require("dijit.form.ComboBox");
      dojo.require("dijit.form.FilteringSelect");
      dojo.require("dijit.form.CheckBox");
      dojo.require("dijit.form.DateTextBox");
      dojo.require("dijit.form.CurrencyTextBox");
      dojo.require("dijit.form.NumberSpinner");
      dojo.require("dijit.form.Slider");
      dojo.require("dijit.form.Textarea");
      dojo.require("dijit.Editor");
      dojo.require("dijit._editor.plugins.FontChoice");
      dojo.require("dijit.form.Button");
      dojo.require("dojo.data.ItemFileReadStore");
      dojo.require("dijit.layout.ContentPane");
      dojo.require("dijit.layout.LayoutContainer");
      dojo.require("dijit.ProgressBar");
    </script>

<!--
	<script type="text/javascript" src="src.js" charset="utf-8"></script>
-->

</head>
<body class="soria" role="application">
	<div id="preLoader"><p></p></div>
      <!-- TOP PANE/MENU -->
      <div dojoType="dijit.layout.ContentPane" layoutAlign="top" style="text-align: center; background-color: blue; color: white; font-size: 150%;" >
	TMC Performance Evaluation Demo Interface
      </div>

      <!-- CENTER PANE -->
      <div dojoType="dijit.layout.ContentPane" layoutAlign="client">
	<div dojoType="dijit.layout.LayoutContainer" style="width: 100%; height: 100%; padding: 0; margin: 0; border: 0;">

	<div dojoType="dojo.data.ItemFileReadStore" jsId="incidentStore"
		url="/tmcpe/incident/list.json"></div>

				<!-- list of messages pane -->
				<table dojoType="dojox.grid.DataGrid"
					region="top" minSize="20" splitter="true"
					jsId="table"
					id="table"
					store="incidentStore"
					style="height: 150px;">
					<thead>
						<tr>
							<th field="id" width="10%">id</th>
							<th field="vdsid" width="80%">vdsid</th>
						</tr>
					</thead>
				</table> <!-- end of listPane -->
	</div>
	<script type="text/javascript">
	      tab=dojo.byId("table");
	      is=dojo.byId("incidentStore");
	      is;
	</script>
</body>
</html>
