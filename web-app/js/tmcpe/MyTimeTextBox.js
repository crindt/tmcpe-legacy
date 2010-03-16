dojo.provide("tmcpe.MyTimeTextBox");

dojo.require("dijit.form.TimeTextBox");

dojo.declare("tmcpe.MyTimeTextBox", dijit.form.TimeTextBox, {
    myFormat: {
        selector: 'time',
        timePattern: 'HH:mm',
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

