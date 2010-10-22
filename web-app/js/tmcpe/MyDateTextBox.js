dojo.provide("tmcpe.MyDateTextBox");

dojo.require("dijit.form.DateTextBox");

dojo.declare("tmcpe.MyDateTextBox", dijit.form.DateTextBox, {
    myFormat: {
        selector: 'date',
        datePattern: 'yyyy-MM-dd',
        locale: 'en-us'
    },

    value: "", /*dojo.date.add( new Date(), "month", -3 ),*/

    // prevent parser from trying to convert to Date object
    postMixInProperties: function() { // change value string to Date object
        this.inherited(arguments);

	if ( this.value ) {
	    // split value to see if it's specifid something like -3 months
	    var diff = this.value.split(" ");
	    if ( diff.length > 1 ) {
		var intvl = diff[ 1 ];
		// remove plural
		if ( intvl.toLowerCase().charAt( intvl.length-1 ) == 's' ) {
		    intvl = intvl.substring( 0, intvl.length-1 );
		}
		amount = parseInt( diff[ 0 ] );
		this.value = dojo.date.add( new Date(), intvl, amount );
	    } else {
		this.value = dojo.date.locale.parse(this.value, this.myFormat);
	    }
	}

        // convert value to Date object
    },

    setDateFromString: function( datestr ) {
	this.value = dojo.date.locale.parse(datestr, this.myFormat);
	this.attr( 'value',  this.value );
    },
    parseDateFromString: function( datestr ) {
	return dojo.date.locale.parse(datestr, this.myFormat);
    },

/*
    parse: function( datestr ) {
	return dojo.date.locale.parse( datestr, this.myFormat);
    },
*/

    // To write back to the server in postgres format, override the serialize method:
    serialize: function(dateObject, options) {
        return dojo.date.locale.format(dateObject, this.myFormat).toUpperCase();
    },
});
