if ( !tmcpe ) var tmcpe = {};
(function() 
 {

     // A wrapper for loading data that integrates with the UI
     var loadingOverlay;
     tmcpe.loadData = function( url, callback, what ) {
	 // show the loading overlay
	 $(window).trigger("tmcpe.loadingStart");
	 if ( what != null ) $("#loading").text(what);
	 loadingOverlay = $("#loading").overlay({load:true, closeOnClick:false, api:true});

         try {
	     d3.json(url,function(e) {
	         if ( e == null ) {
		     // this is an error condition
                     throw "Invalid (or no) data returned from the server";
	         }
                 
	         // run the callback to manage the data
	         callback(e);
	         
	         if ( loadingOverlay ) loadingOverlay.close();
	         $(window).trigger("tmcpe.loadingFinished");
                 
	     });
         } catch ( err ) {
             alert( err );
         }
     }

     $(document).ready(function() {
     
	 // Add loading overlay handling
	 $(window).bind("tmcpe.loadingStart", function( caller, what ) {
	 });
	 // Event called when a new analysis has been processed from the server
	 $(window).bind("tmcpe.loadingFinished", function(caller, what) {
	 });
	 
	 
	 // Add common error handling overlay
	 $(window).error(function(e){
	     var ee = e.originalEvent;
	     var msg = ee.message.replace(/Uncaught */,"");
	     $('#error_overlay > h1').text(msg);
	     $('#error_overlay td.errfile').text(ee.filename);
  	     $('#error_overlay td.errline').text(ee.lineno);
  	     $('#error_overlay td.errmsg').text(ee.message);
	     
	     jQuery.each(jQuery.browser, function(i, val) {
		 $("<div>" + i + " : <span>" + val + "</span>")
                     .appendTo( document.body );
	     });
	     
	     var params = {
		 'issue[tracker_id]': 1,
		 'issue[subject]': "Logical error executing " + window.location,
		 'issue[description]': "An error occured @ " + ee.filename + ":" + ee.lineno + " with the message\n\n     " + ee.message + "\n\nPlease track down the problem.\n\nDetails:\n\n"+_.map($.browser,function(val,key){ return "* *"+key+"*: "+val }).join("\n")+"\n",
		 'issue[assigned_to_id]': 3  // Hardcode Craig Rindt
	     };
	     var keyPairs = [];
	     for (var key in params) {
		 keyPairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(params[key]));
	     }
	     
	     $('#error_overlay li.report a').attr("href","http://tracker.ctmlabs.net/projects/tmcpe/issues/new?"+keyPairs.join("&"));
	     $('#error_overlay').overlay({load:true});
	 });
     });
 })();
