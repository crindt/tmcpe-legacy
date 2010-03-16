dojo.provide("tmcpe.MyDateTextBox");

dojo.require("dijit.form.DateTextBox");

dojo.declare("tmcpe.MyDateTextBox", dijit.form.DateTextBox, {
    myFormat: {
        selector: 'date',
        datePattern: 'yyyy-MM-dd',
        locale: 'en-us'
    },
    value: "",
    // prevent parser from trying to convert to Date object
    postMixInProperties: function() { // change value string to Date object
        this.inherited(arguments);
        // convert value to Date object
        this.value = dojo.date.locale.parse(this.value, this.myFormat);
    },
    // To write back to the server in Oracle format, override the serialize method:
    serialize: function(dateObject, options) {
        return dojo.date.locale.format(dateObject, this.myFormat).toUpperCase();
    }
});
