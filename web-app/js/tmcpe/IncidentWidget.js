dojo.provide("tmcpe.IncidentWidget");
// stuff needed:
dojo.require("dijit._Widget");
// declare it:
dojo.declare(
    "tmcpe.IncidentWidget",
    dijit._Widget, // inherit from _Widget
    {
	postCreate: function(){
	    // summary: my widget setup
	    this.inherited(arguments);
	}
    }
);