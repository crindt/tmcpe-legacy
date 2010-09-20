<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>TMC Performance Evaulation</title>
    <meta name="layout" content="main" />
<!--
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
-->
    <!-- Load the map javascript and css -->
    <!-- <tmcpe:openlayers_latest /> --> <!--  brings in the openlayers stuff -->
    <tmcpe:tmcpe />              <!-- This loads the tmcpe (dojo-based) interface framework -->

    <g:javascript>
      dojo.require("dijit.layout.StackContainer");
      dojo.require("dijit.Tooltip");
    </g:javascript>
<style type='text/css' media='screen'>
#login {
	margin:15px 0px; padding:0px;
	text-align:center;
}
#login .inner {
	width:260px;
	margin:0px auto;
	text-align:left;
	padding:10px;
	border-top:1px dashed #499ede;
	border-bottom:1px dashed #499ede;
	background-color:#EEF;
}
#login .inner .fheader {
	padding:4px;margin:3px 0px 3px 0;color:#2e3741;font-size:14px;font-weight:bold;
}
#login .inner .cssform p {
	clear: left;
	margin: 0;
	padding: 5px 0 8px 0;
	padding-left: 105px;
	border-top: 1px dashed gray;
	margin-bottom: 10px;
	height: 1%;
}
#login .inner .cssform input[type='text'] {
	width: 120px;
}
#login .inner .cssform label {
	font-weight: bold;
	float: left;
	margin-left: -105px;
	width: 100px;
}
#login .inner .login_message {color:red;}
#login .inner .text_ {width:120px;}
#login .inner .chk {height:12px;}
</style>
    
    
  </head>

  <body onload="" 
	class="tundra">
    <!-- Application -->
         <!-- (none) -->

    <!-- Viewport -->
<div dojoType="dijit.layout.ContentPane" region="center">
	<div class='errors'>Sorry, you're not authorized to view this page. Contact the CTMLabs adminstrator to elevate your privileges.</div>
</div>
</body>
