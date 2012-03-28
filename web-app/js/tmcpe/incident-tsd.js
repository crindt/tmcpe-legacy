if ( !tmcpe ) var tmcpe = {};

(function()
 {tmcpe.version = 0.1;
  
  Array.max = function( array ){
      return Math.max.apply( Math, array );
  };
  Array.min = function( array ){
      return Math.min.apply( Math, array );
  };

  tmcpe.tsd = {};

  tmcpe.hh = function() { return $("#tsdbox").height()-2; };
  tmcpe.ww = function() { return $("#tsdbox").width()-2; };

  tmcpe.ns = {
      svg: "http://www.w3.org/2000/svg",
      xlink: "http://www.w3.org/1999/xlink"
  };


  tmcpe.svg = function(type) {
      return document.createElementNS(tmcpe.ns.svg, type);
  };

  tmcpe.tsdParams = function() {
      var tsdparams = {}
      ;      
      
      return tsdparams;
  };

  // Handle view elements for the TSD parameters
  tmcpe.tsdParamsView = function () {
      var tsdParamsView = {},
      container,
      tsdParams,   // the tsdParams (model) this view is tied to
      tmcpctslider,
      verdelslider,
      respdelslider,
      maxspdslider
      ;


      function formAsModel() {
	      var form = [];
          $('input.slider',container).each(function(i,e) {
              var t = e.value;
              form[e.name] = t;
          });
	      $('input:radio:checked',container).each(function(i, e) {
	          var t = e.value;
	          form[e.name] = t;
	      });
	      $('input:text',container).each(function(i,e) {
	          form[e.name] = e.value;
	      });
	      $('select',container).each(function(i,e) {
	          form[e.name] = e.value;
	      });
	      return {data:form};
      }

      function init() {

	      // handle some element styling
          tmcpctslider =
              $('input[name=tmcpctslider]')
              //.rangeinput()
	          .tooltip({placement: "right"})
              .change(function(e,v){
		          $(window).trigger("tmcpe.tsd.tmcPctChanged", formAsModel() );
              });
          verdelslider =
              $('input[name=verdelslider]')
              //.rangeinput()
	          .tooltip({placement: "right", tipClass: "tooltip right"})
              .change(function(e,v){
		          $(window).trigger("tmcpe.tsd.verificationDelayChanged", formAsModel() );
              });
          respdelslider =
              $('input[name=respdelslider]')
              //.rangeinput()
	          .tooltip({placement: "right", tipClass: "tooltip right"})
              .change(function(e,v){
		          $(window).trigger("tmcpe.tsd.responseDelayChanged", formAsModel() );
              });

          maxspdslider = 
              $('input[name=maxspdslider]')
              //.rangeinput({api:true})
              .change(function(e,v){
		          $(window).trigger("tmcpe.tsd.maxSpeedChanged", formAsModel() );
              });

          scaleslider = 
              $('input[name=scaleslider]')
              //.rangeinput({api:true})
              .change(function(e,v){
		          $(window).trigger("tmcpe.tsd.scaleChanged", formAsModel() );
              });


          $('input[name="delayUnit"]').change(function(e,v){
              d3.select('#valueOfTime').property("disabled",this.value=='usd'?false:true);
              $(window).trigger("tmcpe.tsd.delayUnitChanged", formAsModel() );
          });

          $('input[name=valueOfTime]').change(function(e,v){
              $(window).trigger("tmcpe.tsd.valueOfTimeChanged", formAsModel() );
          });

	      // connect form elements to change events
	      $('input[type=radio]')
	          .change(function(d){
		          $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	          });
	      $('input[type=text]')
	          .change(function(d){
		          $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	          });
	      $('select')
	          .change(function(d){
		          $(window).trigger("tmcpe.tsd.paramsChanged", formAsModel() );
	          });

	      // set up tooltips
	      $('input[title]').tooltip({placement: "right"});
	      $('select[title]').tooltip({placement: "right"});
      }

      tsdParamsView.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
	      init();
	      return tsdParamsView;
      }

      tsdParamsView.params = function(x) {
	      if ( x == null ) return tsdParams;
	      tsdParams = x;
	      matchFormToModel();
	      tsdParamsView.touch();
      }

      /**
       * Make the form match the tsdParams (model)
       */
      function matchFormToModel() {
          maxspdslider[0].value = tsdParams.maxspdslider;
	      scaleslider[0].value  = tsdParams.scaleslider;
      }

      /**
       * Function to simulate update to parameters (for initialization)
       */
      tsdParamsView.touch = function() {
	      $(window).trigger("tmcpe.tsd.paramsChanged",formAsModel());
      }

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	      if ( tsdParams == null ) tsdParams = {};

	      // copy analysis parameters to model
	      tsdParams.maxspdslider = json.parameters.maxIncidentSpeed;
	      tsdParams.scaleslider  = json.parameters.band;

	      // reset the model
	      tsdParamsView.params( tsdParams ); // reset
      });

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, adata) {
          if ( adata.t0 && adata.t1 && adata.onScene && false /* FIXME: Broken */) {
              var t1 = new Date( adata.t1 ).getTime();
              var os = new Date( adata.onScene ).getTime();
              // We have an CHP onscene marker, use that as 
              // verification time in the non-TMC case
              osdel = Math.floor((os - t1)/60000);
              if ( osdel < 0 ) osdel = 0;
              verdelslider[0].value = osdel;
              respdelslider[0].value = osdel;
          } else {
              verdelslider[0].value = 15;  // default delay is 15 mins
              respdelslider[0].value = 15;  // default delay is 15 mins
          }
          tsdParamsView.touch();
      });



      return tsdParamsView;
  };


  // view of the affected sections in time and space on one facility
  tmcpe.tsd = function() {
      var tsd = {},
      container,
      size,
      sizeActual,
      json,
      dw,      // total number of columns
      dh,      // total numbers of rows
      szs,     // size per section in px
      szt,     // size per timestep in px
      twidth,
      theight,
      svg,
      cellStyle,
      cellAugmentStyle,
      selectedTime,
      seclensum,
      startTime = 0,
      endTime,// = 20,
      params,
      
      p = 20  // padding, in px
      ;

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      tsd.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
	      d3.select(container).classed("tsd",true);
          //	  container.appendChild(rect);
          //	  return tsd.resize(); // infer size
	      return tsd;
      }

      tsd.params = function(x) {
	      if (!arguments.length) return params;
	      params = x;
	      paramsChanged();
	      return tsd;
      }


      tsd.resize = function() {
	      if (!size) {
	          rect.setAttribute("width", "100%");
	          rect.setAttribute("height", "100%");
	          b = rect.getBBox();
	          sizeActual = {x: b.width, y: b.height};
	          //resizer.add(map);
	      } else {
	          sizeActual = size;
	          //resizer.remove(map);
	      }
	      rect.setAttribute("width", sizeActual.x);
	      rect.setAttribute("height", sizeActual.y);
	      return tsd;
      };

      // update the data (model)
      tsd.data = function(x) {
	      if ( !arguments.length ) return json;
	      json = x;
	      tsd.redraw();

	      // set active timestep
	      // hackish: scan timesteps until t > t2
	      // t2 is approximate worst queue
	      if ( json.t2 != null ) {
	          var t2 = new Date( json.t2 ).getTime();
	          var tt = _.map( json.timesteps, function (d) { return new Date(d).getTime(); });
	          var jj;
	          for(jj = 0; jj < json.timesteps.length; jj++ ) {
		          if (t2 < tt[jj]) break;
	          }
	          if ( jj > 0 && jj <= json.timesteps.length ) {
		          jj--;  // set to timestep before the one greater than t2
		          
		          $(window).trigger("tmcpe.tsd.activeTimestep", jj);
		          
	          } else {
		          // outside of range
	          }
	      }
	      
	      return tsd;
      }

      tsd.hh = function() { return $(container).height()-2; };
      tsd.ww = function() { return $(container).width()-2; };



      function translateY(d, i) { return "translate(0,"+(i*szs)+")"; };
      function translateX(d, i) { return "translate("+(i*szt)+",0)"; };

      function grid0(x,y) {
	      if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	      return json.data[y][x].inc==0;
      }
      function grid1(x,y) {
	      if (x < 0 || y < 0 || x >= dw || y >= dh) return 0;
	      return json.data[y][x].inc==1;
      }



      function updateText( newText ) {
	      d3.select("#msgtxt").html( newText );
      }


      tsd.cellAugmentStyle = function(x) {
	      if (!arguments.length) return cellAugmentStyle;
	      cellAugmentStyle = x;
	      return tsd.updateCellAugmentation();
      }

      tsd.updateCellStyle = function( ) {
	      d3.select(container).selectAll("g")
	          .selectAll("rect")
	          .attr("style", cellStyle );
	      return tsd;
      }

      tsd.updateCellAugmentation = function() {
	      d3.select(container).selectAll("g").selectAll("circle")
	          .attr("style", cellAugmentStyle );
	      return tsd;
      }

      function showSelectedTime() {
	      var data = json.data,
	      sections = json.sections

	      // assertions
	      if ( sections == null || sections.length == 0 ) throw "Missing section data to show selected time";
	      if ( selectedTime < 0 ) throw "Asked to throw undefined (<0) selected time in TSD";

	      // update cross line by translating it to the proper section
	      var cross = tsd.svg.selectAll("#tsdsec")
	          .data([1])
	          .attr("transform", function(dd, ii) { 
		          var dist = 0;
		          var j;
		          for ( j = 0; j<selectedTime; ++j ) { dist += sections[j].seglen; }
		          var val = theight*(dist+sections[selectedTime].seglen/2)
		              /seclensum;
		          return "translate(0,"+(val)+")"; 
	          });


	      // create cross line if it doesn't exist
	      cross.enter()
	          .append("svg:line")
	          .attr("id","tsdsec")
	          .attr("transform", function(dd, ii) { 
		          var dist = 0;
		          var j;
		          for ( j = 0; j<selectedTime; ++j ) { dist += sections[j].seglen; }
		          var val = theight*(dist+sections[selectedTime].seglen/2)
		              /seclensum;
		          return "translate(0,"+(val)+")"; 
	          })
	          .attr("x1",0)
	          .attr("y1",0)
	          .attr("x2",tsd.twidth)
	          .attr("y2",0)
	          .attr("style","stroke:purple;stroke-width:3");

	      // highlight edge
	      var seg = $('path[id^='+sections[selectedTime].vdsid+']');
	      seg.map( function (jj, s) { s.style.setProperty("stroke-width",6 ) } );
      }

      tsd.selectedTime = function(x) {
	      if (!arguments.length) return selectedTime;
	      selectedTime = x;

	      showSelectedTime();

	      return tsd;
      }

      tsd.redraw = function() {
	      // assertions
	      if ( json == null ) throw "Can't redraw cumflow diagram without data";
	      if ( json.analysis == null ) throw "Can't display data without a solution result";

	      // clear any existing
	      $(container).children().remove();


	      if ( json.analysis.badSolution ) {
              /*
	          // catch bad solution and display info
	          $(container).append('<p style="text-align:right">NO ANALYSIS PERFORMED'+(json.analysis.badSolution 
	          ? ' BECAUSE: '+json.analysis.badSolution 
	          : '' )+'</p>');
	          // nothing to see here.
	          return tsd;
              */
	      }

	      if ( json.data == null || 
	           json.data.length == 0 || 
	           json.data[0].length == 0 ) throw "Bad solution data returned from server";

	      // Insert dummy elements to pull styling from css into tsd construction
	      $(container).append("<div class='dummy-tsd-speed-start-color'/>");
	      $(container).append("<div class='dummy-tsd-speed-mid-color'/>");
	      $(container).append("<div class='dummy-tsd-speed-end-color'/>");

	      var data = json.data,
	      sections = json.sections
	      fn       = [grid0, grid1],      // contouring functions
	      grid = grid1;

	      dh = data.length,        // how many time steps
	      dw = timeSlice(data[0]).length,     // how many sections

	      szs = (tsd.hh()-2*p)/dh;
	      szt = (tsd.ww()-7*p)/dw;

	      twidth = szt*dw;
	      tsd.twidth = twidth;
          theight = szs*dh;

	      seclensum = 0;
	      $.each(sections, function(i,s){ seclensum+=s.seglen; } );

	      function scale(p) { 
	          var dist = 0;
	          var j;
	          for ( j = 0; j<p[1]; ++j ) { 
		          dist += sections[j].seglen; 
	          }
	          var val = theight*dist/seclensum;
	          return [p[0]*szt, val]; 
	      }

	      function contour(svg, agrid, start) {
	          svg.selectAll("path")
		          .data([d3.geom.contour( agrid, start).map(scale)])
		          .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
		          .enter().append("svg:path")
		          .attr("d", function(d) { return "M" + d.join("L") + "Z"; })
		          .attr("class","incidentBoundary");
	      }

	      function timeSlice( d ) {
	          return d.slice( startTime?startTime:0,endTime!=null?endTime:d.length );
	      }

	      svg = d3.select(container)
              .append("svg:svg")
	          .attr("id", "tsdsvg" )
              .attr("width", twidth + 7*p/*theight/*twidth*/ )
              .attr("height", theight + 2*p/*twidth/*theight*/ )
	          .append("svg:g")
	          .attr("transform", "translate(" + 6*p + "," + p + ")")
	          .on("keydown",function( k ) {
		          console.log( k );
	          });
	      tsd.svg = svg;

	      // now, create the rows of data.
	      var secrow = svg.selectAll("g.sectionrow")
              .data(data)
              .enter().append("svg:g")
	          .attr("class","sectionrow")
	          .attr("id",function(d,i) { return "row"+i; })
	          .attr("vdsid",function(d,i) { 
		          return json.sections[i].vdsid; })
              .attr("transform", function(d, i) { 
		          var dist = 0;
		          var j;
		          for ( j = 0; j<i; ++j ) { dist += sections[j].seglen; }
  		          var val = theight*dist/seclensum;
		          return "translate(0,"+(val)+")"; 
	          });

	      // next, in each row, create the time-space cells
	      secrow.selectAll("rect")
              .data(function(d) { return timeSlice(d); })
              .enter().append("svg:rect")
	          .attr("i", function(d){return d.i;} )
	          .attr("j", function(d){return d.j;} )
              .attr("width", szt )
              .attr("transform", translateX )
              .attr("height", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum); })
	          .attr("class", "tsdcell")
	          .attr("style", cellStyle)
	          .on("click", function(d,i) {
		          // when clicked, create a tmcpe selection event
		          $(window).trigger("tmcpe.tsd.selectedSection", 
				                    {sectionidx: d.i }
				                   );
	          })
              .on("mouseover", function(d) {
                  // broadcast the active cell
                  $(window).trigger("tmcpe.tsd.activeTsdCell", d);

                  // broadcast the active timestep
                  $(window).trigger("tmcpe.tsd.activeTimestep", d.j);
              })
	      ;

	      // create ylabels
	      secrow.append("svg:text")
	          .attr("x", -4 )  // shift 4 px left of axis
	          .attr("class", "ylabels" )
	          .attr("dy",function (d,i) { 
		          return theight*sections[d[0].i].seglen/seclensum/2+5; } ) // put midway down
	          .attr("text-anchor","end")
	          .text(function(d,i){ 
		          // only show avery other segment name
		          return i%2 ? "" : sections[i].name; 
	          })
	          .attr("class","ylabels");

          // now, create the rows of data to show evidence as black dots in the
	      // center of cells suspected of being impacted by an incident
	      var evrow = svg.selectAll("g.evidence")
              .data(data)
              .enter().append("svg:g")
	          .attr("class","evidence")
              .attr("transform", function(d, i) { 
		          var dist = 0;
		          var j;
		          for ( j = 0; j<i; ++j ) { dist += sections[j].seglen; }
  		          var val = theight*dist/seclensum;
		          return "translate(0,"+(val)+")"; 
	          });

	      // next, in each row, create the evidence
	      evrow.selectAll("circle")
              .data(function(d) { return timeSlice(d); })
              .enter().append("svg:circle")
	      //.attr("class", function(d) { return "d"+d.inc; })
	          .attr("style", cellAugmentStyle )
              .attr("cx", function (d, i ) { return ((i+0.5)*szt) } )
              .attr("cy", function (d, i ) { return Math.floor(theight*sections[d.i].seglen/seclensum)/2; })
	          .attr("r", 1.5 );


	      // make sure there's at least one cell with the incident
	      // flag set to 1, d3.contour infinite loops if that's not
	      // the case.  Issue #680
	      var incsum = 0;
	      for ( y in json.data ) {
	          for ( x in json.data[y] ) {
		          incsum += (json.data[y][x].inc==1?1:0);
	          }
	      }

	      // Only contour if there's a solution
	      if ( incsum > 0 && json.analysis.badSolution == null ) { 
	          contour( svg, grid );
	      } else {
	          //updateText( "NO DELAY SOLUTION AVAILBLE BECAUSE: " + json.analysis.badSolution );
	      }

	      return tsd;

      }


      function activeTimestep(j) {

	      // update cross hatch (moving the x position)
 	      var cross = svg.selectAll("#tsdtime")
	          .data([1])
	          .attr("x1",(j+1)*szt)
	          .attr("x2",(j+1)*szt)
              .attr("class","timebar")
          ;

	      // create cross hatch if it doesn't yet exist
	      cross.enter()
	          .append("svg:line")
	          .attr("id","tsdtime" )
	          .attr("x1",(j+1)*szt)
	          .attr("y1",0)
	          .attr("x2",(j+1)*szt)
	          .attr("y2",theight-1)
              .attr("class","timebar")
          ;
          
      }

      function getCellStyle() {
	      if ( params.theme == "stdspd" ) {
	          var pscale = params.scale == null ? 1.0 : params.scale;
	          var stdSpdColor = d3.scale.linear()
		          .domain([-pscale,-(pscale/2),0] )
		          .range(["#ff0000","#ffff00","#00ff00"]);
	          return function(d) {
		          // return grey if evidence is uncertain (imputed data)
		          if ( d.p_j_m > 0 && d.p_j_m < 1 ) {
		              d3.select(this).classed('datapoor',true);
		              return "";
		          } else {
		              d3.select(this).classed('datapoor',false);
		              // bound the stddev value between 0 and -4 stddevs  (FIXME: hardcode
		              vv = Math.min(0,Math.max((d.spd-d.spd_avg)/d.spd_std,-4));
		              return "fill:"+stdSpdColor(vv);
		          }
	          }
	      } else {
	          var minSpd = params.minspdslider == null ? 10 : params.minspdslider;
	          var maxSpd = params.maxspdslider == null ? 50 : params.maxspdslider;
	          var spdColor = d3.scale.linear()
		          .domain([minSpd,minSpd+(maxSpd-minSpd)/2,maxSpd] )
		          .range(["#ff0000","#ffff00","#00ff00"]);
	          return function(d) {
		          // return grey if evidence is uncertain (imputed data)
		          if ( d.p_j_m > 0 && d.p_j_m < 1 ) {
		              d3.select(this).classed('datapoor',true);
		              return "";
		          } else {
		              d3.select(this).classed('datapoor',false);
		              return "fill:"+spdColor( d.spd );
		          }
	          }
	      }
      }

      function getEvidenceOfIncident() {
	      return function ( d ) {
	          var maxSpd = params.maxspdslider == null ? 50 : params.maxspdslider;
	          var pscale = params.scaleslider == null ? 1.0 : params.scaleslider;

	          var stdlev = (d.spd - d.spd_avg)/d.spd_std;
	          var tmppjm = 1; // no incident probability is default
	          if ( d.p_j_m != 0 && d.p_j_m != 1 )  // fixme: a proxy to indicate that the historical speed estimate is not tained
		          tmppjm = 0.5;

	          else if ( stdlev < 0 && stdlev < -pscale && d.spd < maxSpd )
		          tmppjm = 0.0;

	          return tmppjm == 0 ? "fill:black;" : "fill:none;";
	      }

      }

      function paramsChanged() {
	      // update scales
	      cellStyle = getCellStyle();
	      cellAugmentStyle = getEvidenceOfIncident();

	      tsd.updateCellStyle();
	      tsd.updateCellAugmentation();
      }


      // some events this view listens to
      $(window).bind("tmcpe.tsd.selectedSection", function( caller, data ) {
	      // new selection selected, update the time selection in the tsd
	      tsd.selectedTime( data.sectionidx );
      });

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	      // new analysis loaded, update the data
	      tsd.data( json );
      });

      $(window).bind("tmcpe.tsd.activeTsdCell", function(caller, data ) {
      });

      $(window).bind("tmcpe.tsd.activeTimestep", function(caller, data ) {
          activeTimestep( data );
      });

      $(window).bind("tmcpe.tsd.paramsChanged", function( caller, params ) {
	      // update params model

	      tsd.params(params.data);

      });


      return tsd;
  }

  function safe_fixed(v,f) {
      if ( v != null ) return v.toFixed(f);
  }
  function safe_date(d,dft) {
      if ( d != null ) return 
  }

  // http://stackoverflow.com/questions/2998784/how-to-output-integers-with-leading-zeros-in-javascript
  function zfill(num, len) {return (Array(len).join("0") + num).slice(-len);}

  tmcpe.cellDetailView = function() {
      _.templateSettings = {
	      interpolate : /\{\{(.+?)\}\}/g
      };

      var cellDetail = {},
      container = d3.select('#cellDetail'),
      json,
      secTemplate = _.template("<th>{{what?what:'&nbsp;'}}</th><td>{{(vol?vol:'&nbsp;')}}</td><td>{{(occ?(occ*100).toFixed(0):'&nbsp;')}}</td><td>{{(spd?spd:'&nbsp;')}}</td><td>{{inc==1?'Yes':'No'}}</td>"),
      //      domtTemplate = _.template("{{(date!=null?['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Nov','Dec'][date.getMonth()]:'&nbsp;')}} {{(date.getDate())}} @ {{(date.getHours())}}:{{(date.getMinutes())}}"),
      table
      ;


      function update(dataa) {
          if ( table == null ) throw "Can't update null table in cellDetail"; 

          var d = null;
          if ( json != null && json.timesteps != null )
              d = json.timesteps[dataa.j];

          var th = table.selectAll('th.title')
              .data([d])
              .html(d!=null?(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Nov','Dec'][d.getMonth()]
                             + " " + d.getDate() 
                             + " @ " 
                             + d.getHours()
                             + ":"
                             + zfill(d.getMinutes(),2)):'&nbsp;');
          

          var tr = table.selectAll('tr.data')
              .data([{what:"Obs:",vol:safe_fixed(dataa.vol),occ:safe_fixed(dataa.occ,2),spd:safe_fixed(dataa.spd),inc:dataa.inc},
                     {what:"Avg" +(d!=null?(
                         ' on ' + ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][d.getDay()]
                             + " @ " 
                             + d.getHours()
                             + ":"
                             + zfill(d.getMinutes(),2)):'&nbsp'),
                      vol:safe_fixed(dataa.vol_avg),occ:safe_fixed(dataa.occ_avg,2),spd:safe_fixed(dataa.spd_avg),inc:dataa.inc_avg}])
              .html(function(d) { return secTemplate( d ) })
          ;

          tr.enter()
              .append("tr")
              .attr("class","data")
              .html(function(d) { return secTemplate( d ) })
          ;

          tr.exit().remove();
      }

      function init() {
          // assert
          if ( container == null || container.length == 0 ) 
              throw "Can't initialize cell detail view in null container";

          table = container.append('table').classed('cellDetail',true);
          
          var tr = table.append("tr");
          tr.append("th").classed('title',true).html("&nbsp;");
          tr.append("th").html("Volume (veh)");
          tr.append("th").html("Occ (%)");
          tr.append("th").html("Speed (mph)");
          tr.append("th").classed('incident',true).html("Incident");
          update( {vol:null,occ:null,spd:null,spd_avg:null,vol_avg:null,occ_avg:null,inc:null,date:null} ); // create empty data
      }

      cellDetail.data = function(x) {
	      if ( !arguments.length ) return json;
	      json = x;
          return cellDetail;
      }
      
      cellDetail.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
          init();
          return cellDetail;
      }

      $(window).bind("tmcpe.tsd.activeTsdCell", function(caller, adata ) {
          update( adata )
      });

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, adata) {
	      cellDetail.data( adata );
      });

      return cellDetail;
      
  }

  // view of the cumulative flow past an affected section during the timeframe
  // of the incident
  tmcpe.cumflow = function() {
      var cumflow = {},
      container,
      size,
      sizeActual,
      json,
      dw,
      dh,
      szs,
      szt,
      twidth,
      theight,
      svg,
      section,
      startTime = 0,
      endTime,// = 20,
      params = {
          tmcDivPct: 20,
          verificationDelay: 5,
          responseDelay: 5,
          valueOfTime: 13.11,
      },
      
      p = 20
      ;

      // recursive function to sum all of a given cell property from time 0 to time j
      function sfunc (i,j,ff,vol) {
	      if ( vol == null ) vol = 0;
	      if ( j < 0 ) 
	          return vol;
	      else 
	          return sfunc( i, j-1, ff, vol + ff(json.data[i][j]) ); 
      }

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      cumflow.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
	      container.setAttribute("class", "tsd");
	      //container.appendChild(rect);
	      return cumflow.resize(); // infer size
	      //return cumflow;
      }

      cumflow.params = function(x) {
	      if (!arguments.length) return params;
	      params = x;
	      paramsChanged();
	      return tsd;
      }

      cumflow.resize = function() {
	      if (!size) {
	          rect.setAttribute("width", "100%");
	          rect.setAttribute("height", "100%");
              return cumflow;
	          b = rect.getBBox();
	          sizeActual = {x: b.width, y: b.height};
	          //resizer.add(map);
	      } else {
	          sizeActual = size;
	          //resizer.remove(map);
	      }
	      rect.setAttribute("width", sizeActual.x);
	      rect.setAttribute("height", sizeActual.y);
	      return cumflow;
      };

      cumflow.data = function(x) {
	      if ( !arguments.length ) return json;
	      json = x;

          cumflow.updateStats();

	      return cumflow;
      }

      cumflow.section = function(x) {
	      if ( !arguments.length ) return section != null ? section : json.getSectionIndex( json.sec )-1;
	      section = x;
          
	      cumflow.redraw();
          
	      return cumflow;
      }

      var data;


      function zeroOrBetter( x ) {
	      return x < 0 ? 0 : x;
      }

      cumflow.updateStats = function() {

          // FIXME: foreach(facility) do {

	      // compute delay from implied queuing
	      var delay2 = 0;
	      var delay3 = 0;
	      var delay4 = 0;
	      var tmcSavings = 0;

	      if ( !data ) return cumflow;

	      if ( json.analysis.badSolution != null ) {
              // if a bad solution, set all values to n/a
	          $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
		          d3.select("#"+v).html( "n/a" );
	          });	
              return cumflow;
	      }


		  var d3tmp = []
		  d3tmpsum = []
	      $.each( data, function(i, d) {
	          delay2 += (d.divavg-d.obs)*5/60;       // div adj avg - obs
			  d3tmp[i] = (d.adjdivavg-d.obs)*5/60
	          delay3 += (d.adjdivavg-d.obs)*5/60;       // avg - obs
			  d3tmpsum[i] = delay3
	          delay4 += (d.adjdivavg-d.incflow)*5/60; // avg - inc projected
	      });

	      // scale to convert div adj avg to netdelay
	      var factor = json.analysis.netDelay/(delay2)//+(delay3-delay2)*(1-params.tmcDivPct/100.0));

	      delay4 *= factor;
	      delay4 = zeroOrBetter( delay4 );
	      tmcSavings = delay4-zeroOrBetter(json.analysis.netDelay);
	      tmcSavings = ( tmcSavings < 0 ? 0 : tmcSavings );

	      $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
	          if ( json.analysis[v] != null  && v != 'computedMaxqTime' ) {
		          d3.select("#"+v).html( zeroOrBetter( json.analysis[v].toFixed(0) ) );
	          }
	      });

	      d3.select("#chartDelay2").html( delay2 );
	      d3.select("#chartDelay3").html( delay3 );
	      d3.select("#whatIfDelay").html( delay4 );
	      d3.select("#tmcSavings").html( tmcSavings );

		  cumflow.updateStatsUnit();

          //          return cumflow;
      }

	  cumflow.updateStatsUnit = function() {

          var unit = params.delayUnit;
          var unitFactor = 1;
          if ( unit == 'usd' ) {
              var vot = params.valueOfTime;

              unitFactor = vot;
              d3.selectAll(".delayUnitHolder").text("($)");

          } else {
              d3.selectAll(".delayUnitHolder").text("(veh-h)");
              unitFactor = 1;
          }


          // refactor *delays* depending on the unit
          var sel = d3.selectAll(".delayValue")
              .each(function() {
                  var val = parseFloat(this.innerText) * unitFactor;
                  d3.select(this).html( function(d) {
                      return val.toFixed(0)
                  });
				  // FIXME: hardcoded colors
                  d3.select(this).style("background","yellow");
                  d3.select(this).transition().duration(3000).style("background","#8BA9D3");
              });

		  return cumflow;
		  
	  }

      function timeSlice( d ) {
	      return d.slice( startTime?startTime:0,endTime!=null?endTime:d.length );
      }


      cumflow.redraw = function() {
	      // assertions
	      if ( json == null ) throw "Can't redraw cumflow diagram without data";
	      if ( json.analysis == null ) throw "Can't display data without a solution result";

          if ( section == null ) return; // do this quietly, as it's expected


	      // clear any existing
	      $(container).children().remove();


	      if ( json.analysis.badSolution ) {
	          // catch bad solution and display info
	          $(container).append('<p style="text-align:right">NO ANALYSIS PERFORMED'+(json.analysis.badSolution 
							                                                           ? ' BECAUSE: '+json.analysis.badSolution 
							                                                           : '' )+'</p>');
	          // nothing to see here.
	          return tsd;
	      }

	      if ( json.data == null || 
	           json.data.length == 0 || 
	           json.data[0].length == 0 || 
	           section < 0 ) throw "Bad solution data returned from server";


          // measured
	      var t0 = new Date( json.t0 ).getTime()/1000;
	      var t1 = new Date( json.t1 ).getTime()/1000;
	      var t2 = new Date( json.t2 ).getTime()/1000;
	      var t3 = new Date( json.t3 ).getTime()/1000;

		  //if ( t1 < t0 ) t1 = t0 + 300
		  //if ( t2 < t1 ) t2 = t1 + 300

          // what-if
	      var t1p = t1 + params.verificationDelay*60;
	      var t2p = t2 + (params.verificationDelay + params.responseDelay)*60;

          // FIXME: t3p will be the point where projected cumulative
          // capacity equals adjusted expected demand
          // var t3p = t3;

	      var volscale = 1/1000;
	      var volscale = 1;

	      var incidentSectionIndex = json.getSectionIndex(json.sec)-1;

	      d3.select("#chart_location").html(json.sections[section].name);

		  var timestampIndex = function( d ) {
			  var base = json.timesteps[0].getTime()/1000;
			  var idx = Math.floor( (d-base) / (60*5.0) );

			  if ( idx < 0 || 
				   idx >= json.timesteps.length ) console.log ( "Bad timestep" )
			  return idx;
		  }

          // find the cells associated with each critical time
		  var t0Cell = timestampIndex( t0 );
		  var startCell = timestampIndex( t1 );
		  var t2Cell = timestampIndex( t2 );
		  var t2pCell = timestampIndex( t2p );
	      var finishCell = timestampIndex( t3 );

	      if ( finishCell >= json.timesteps.length ) {
	          finishCell = json.timesteps.length-1;
	      }


	      if ( t0Cell < 0 ) {
	          // BAD DATA
	          $(container).append('<p>NO INCIDENT START FOUND, <a href="http://tracker.ctmlabs.net/projects/tmcpe/issues/new">REPORT AN ISSUE</a></p>');
	          // nothing to see here.
	          return tsd;
	      }


	      // fixme: crindt: we really want to use the incident section by default, not the downstream section.
	      var diversion = sfunc(incidentSectionIndex,finishCell,function(v){
	          return v == null || v.vol_avg == null ? 0 : Math.round(v.vol_avg)/volscale;
	      }) - sfunc(incidentSectionIndex,finishCell,function(v){
	          return v == null || v.vol == null ? 0 : v.vol/volscale;
	      });

	      data = d3.range( json.timesteps.length ).map(function(m) {
	          return {x:json.timesteps[m].getTime()/1000+300,
		              obs: sfunc(section,m,function(v){return v.vol/volscale}), 
		              avg: sfunc(section,m,function(v){return Math.round(v.vol_avg)/volscale}), // crindt: FIXME: floor to match GAMS precision
					 }
		  } )
		  
		  $.each( data, function( m, d ) {
			  d.divavg = ( m < startCell
			               ?  d.avg
			               : ( m > finishCell
				               ? d.obs
				               : d.avg - diversion*(m-startCell)/(finishCell-startCell) ) );
			  d.adjdivavg = ( m < startCell
			                  ? d.avg
			                  : ( m > finishCell
				                  ? d.obs + (params.tmcDivPct/100)*diversion
				                  : ( d.avg - 
									  (1-params.tmcDivPct/100)*diversion // nonTmcDiversion
									  *(m-startCell)/(finishCell-startCell) ) ) );
			  //console.log( "" + m + ": [" + [startCell,finishCell,d.obs,d.avg,diversion].join(",")+ "] = "+ d.divavg + "," + d.adjdivavg )
	      })

	      var incflowrate = (data[t2Cell].obs - data[t0Cell].obs)/(5*60*(t2Cell-t0Cell)) ;
	      var clearflowrate = (data[finishCell].obs - data[t2Cell].obs)/(5*60*(finishCell-t2Cell)) ;
          // clearflow rate is max obs flow rate
          var maxclearflowrate = Array.max(d3.range( 1, json.timesteps.length ).map(function(j){
			  return (data[j].obs-data[j-1].obs)/(5*60)}));
		  if ( clearflowrate < maxclearflowrate )
			  // take the max (FIXME: this is stupid, maxclearflowrate is
			  // always >= clearflowrate so we should just use the former
			  clearflowrate = maxclearflowrate

		  // hold the obs cum flow at the point the road was cleared
		  var base = data[t2Cell].obs

	      // compute what-if flow rate
          var t3p = null;
	      $.each(data,function(j,d){
	          if ( j < t2Cell ) {
		          // before t2 (clearance), what-if flow is equivalent to measured
		          d.incflow = d.obs //sfunc(section,j,function(v){return v.vol/volscale})
	          } else if ( j < t2pCell ) {
		          // between t2 and t2p, what-if flow is the base vvalue 
		          d.incflow = base + incflowrate*(j-t2Cell)*60*5;
	          } else {
		          d.incflow = base + incflowrate*(t2pCell-t2Cell)*60*5 + clearflowrate*(j-t2pCell)*60*5;
	          }


	          // don't allow projection to be greater than avg.
	          if ( d.incflow > d.adjdivavg && j > startCell ) {
                  if ( t3p == null ) {
                      t3p = json.timesteps[j].getTime()/1000;
                  }
                  d.incflow = d.adjdivavg;
              }

			  // don't allow projection to be greater than observed
			  if ( d.incflow > d.obs && j <= finishCell ) {
				  d.incflow = d.obs;
			  }

			  // set the baseline for "observed"
			  // should be max of d.obs and d.incflow
			  d.incbl = d.obs;
			  if ( d.obs < d.incflow ) {
				  d.incbl = d.incflow
			  }

	      });

          // project t3p
		  // if t3p is null at this point, it means we haven't found
		  // the place where measured flow catches projected demand
		  // (for now we just cap it at the max)
		  if ( t3p == null ) 
			  t3p = (json.timesteps[json.timesteps.length-1].getTime()+900000)/1000;

		  // don't allow t3p to be less than t2p
		  if ( t3p < t2p ) t3p = t2p;


	      // add zeroed elements at the beginning
	      data.unshift( { x:json.timesteps[0].getTime()/1000,obs:0,avg:0,divavg:0,adjdivavg:0,incflow:0,incbl:0} );
	      
	      // Compute the maximum cumulative flow across all sections (to set the max scale)
	      var maxflow = Array.max( json.data.map( function( r ) { 
	          return Array.max( [ sfunc( r[0].i,r.length-1, function(v){return v.vol/volscale}), 
				                  sfunc( r[0].i,r.length-1, function(v){return Math.round(v.vol_avg)/volscale}) ] );
	      } ) );


	      var w = $(container).width()-2,
	      h = $(container).height()-2,
	      ww = w - 7*p,       // width available for plot
	      hh = h - 4*p,   // height available for plot
	      x = d3.scale.linear()
	          .domain([json.timesteps[startTime ? startTime : 0 /*0*/].getTime()/1000,
		               json.timesteps[endTime ? endTime-1: json.timesteps.length-1].getTime()/1000+300])
	          .range([0, ww]),
	      y = d3.scale.linear().domain([0, maxflow]).range([hh, 0]),
	      now = new Date();
	      
	      var vis = d3.select("#chartbox")
	          .append("svg:svg")
	          .attr("class", "flowchart" )
	          .data([timeSlice(data)])
	          .attr("width", w) // margin of 100
	          .attr("height", h)
	          .append("svg:g")
	          .attr("transform", "translate(" 
		            + 6*p      // shift left 5p (1p margin on right)
		            + "," + 1.5*p  // shift down 1p (1p margin on top)
		            + ")");
	      
	      // create some data for the section rules
	      var rr = d3.range( json.timesteps[0].getTime()/1000,
			                 json.timesteps[json.timesteps.length-1].getTime()/1000+300,
			                 300 );
	      rr = timeSlice( rr );

	      // create some data for the time rules
	      var rr2 = x.ticks(json.timesteps.length);
	      rr2 = timeSlice( rr2 );

	      
	      // Now, for each section, create a group
	      var rules = vis.selectAll("g.rule")
	          .data( rr )
	          .enter().append("svg:g")
	          .attr("class", "rule");
	      
	      // within each section group, create a line (it's vertical here, 
	      // but will be horizontal on the rotated plot
	      rules.append("svg:line")
	          .attr("x1", x)
	          .attr("x2", x)
	          .attr("y1", 0)
	          .attr("y2", hh - 1);

	      // For each time, create a group
	      var rules2 = vis.selectAll("g.rule2")
	          .data(y.ticks(10))
	          .enter().append("svg:g")
	          .attr("class","rule2");
	      
	      // within each time group, create a line (it's horizontal here,
	      // but will be vertical on the rotated plot
	      rules2.append("svg:line")
	          .attr("class", function(d) { return d ? null : "axis"; })
	          .attr("y1", y)
	          .attr("y2", y)
	          .attr("x1", 0)
	          .attr("x2", ww );
	      
	      // a function to rotate the time axis labels
	      function xlabel_rotate (xx) {
	          return "rotate("+[90,x(xx),(hh+3)].join(",")+")"
	      }
	      
	      // now, add labels for each section
	      rules2.append("svg:text")
	          .attr("y", y)
	          .attr("x", -4)  // shift 4px to left of axis
	          .attr("dy", "8pt")
	          .attr("text-anchor", "end")
	          .text(y.tickFormat(10))
	          .attr("class","ylabels");

	      // finally, add labels for each time step
          var rulefreq = Math.floor( rr.length/10);  // we want approx 10 rules
          if ( rulefreq < 1 ) rulefreq = 1;
	      rules.append("svg:text")
	          .attr("x", x )
	          .attr("y", hh + 5 )
	          .attr("dy", ".25em")
	          .attr("text-anchor", "start")
	          .attr("transform",function(d) { return xlabel_rotate(d); } )
	          .text(/*x.tickFormat(10)*/ function (x,i) { 
                  if ( i % rulefreq == 0 ) {  // show rules as appropriate frequency
		              return $.format.date(new Date( x*1000 ), "HH:mm");
                  } else {
                      return "";
                  }
                  //		  return new Date( x*1000 ).toLocaleTimeString();
	          } )
	          .attr("class","xlabels");
	      
	      

	      // averages
	      var chg = vis.append("svg:g")
	          .attr("class","areas")
	          .attr("title", "" );
	      chg.append("svg:path")
	          .attr("class", "area expectedflow")
	          .attr("d", d3.svg.area()
		            .x(function(d) { 
			            return x(d.x); })
					/* subtract from divavg */
                    .y0(function(d) { return y(d.adjdivavg); })
		            .y1(function(d) { return y(d.avg); }))
	          .on("mouseover", function( d,i ) { 
				  setChartTip("Diverted Flow");
		          //$('#cumflowChartTip').html("Diverted Flow" );
	          } )
	          .on("mouseout", function (d,i) { 
				  setChartTip("");
		          //$('#cumflowChartTip').html("" );
	          } );
          
	      // adjdivavg
	      if ( section == incidentSectionIndex ) {
	          chg.append("svg:path")
		          .attr("class", "area adjexpectedflowafterdiv")
		          .attr("d", d3.svg.area()
			            .x(function(d) { return x(d.x); })
						/* subtract from obs */
			            .y0(function(d) { return y(d.incbl);})
			            .y1(function(d) { return y(d.adjdivavg); }))
		          .on("mouseover", function( d,i ) { 
					  setChartTip("TMC Savings due to diversion");
		              //$('#cumflowChartTip').html( "TMC Savings due to diversion");
		          } )
		          .on("mouseout", function (d,i) { 
					  setChartTip("");
		              //$('#cumflowChartTip').html( "");
		          } );
	          
              /*
	            chg.append("svg:path")
		        .attr("class", "line adjexpectedflowafterdiv")
		        .attr("d", d3.svg.line()
		        .x(function(d) { return x(d.x); })
		        .y(function(d) { return y(d.adjdivavg); }));
              */

	      }

	      // divavg
	      if ( section == incidentSectionIndex ) {
	          chg.append("svg:path")
		          .attr("class", "area expectedflowafterdiv")
		          .attr("d", d3.svg.area()
			            .x(function(d) { return x(d.x); })
						// subtract from obs
			            .y0(function(d) { return y(d.obs);})
			            .y1(function(d) { return y(d.divavg); }))
		          .on("mouseover", function( d,i ) { 
					  setChartTip("TMC Savings due to diversion");
		              //$('#cumflowChartTip').html( "TMC Savings due to diversion");
		          } )
		          .on("mouseout", function (d,i) { 
					  setChartTip("");
		              //$('#cumflowChartTip').html( "");
		          } );
	          
			  // add line to show diverted flow
/*
	          chg.append("svg:path")
		          .attr("class", "line expectedflowafterdiv")
		          .attr("d", d3.svg.line()
						.x(function(d) { return x(d.x); })
						.y(function(d) { return y(d.divavg); }));
*/			  
	      }

	      // observed
		  // this needs to be split into two sections
	      chg.append("svg:path")
	          .attr("class", "area observed")
	          .attr("d", d3.svg.area()
		            .x(function(d) { return x(d.x); })
					/* subtract from whatif */
		            .y0(function(d) {return y(d.incflow);})
		            .y1(function(d) { return y(d.incbl); })
				   )
	          .on("mouseover", obsmouseover )
	          .on("mouseout", function () { setChartTip("") } )
		  ;

	      
	        chg.append("svg:path")
	        .attr("class", "line observed")
	        .attr("d", d3.svg.line()
	        .x(function(d) { return x(d.x); })
	        .y(function(d) { return y(d.obs); }));

	      // what-if
	      chg.append("svg:path")
	          .attr("class", "area whatif")
	          .attr("d", d3.svg.area()
		            .x(function(d) { return x(d.x); })
		            .y0(hh - 1)
		            .y1(function(d) { return y(d.incflow); }))
	          .on("mouseover", function() { 
	          } )
	          .on("mouseout", function () {  
			  } );

	      
/*
	      chg.append("svg:path")
	          .attr("class", "line whatif")
	          .attr("d", d3.svg.line()
					.x(function(d) { return x(d.x); })
					.y(function(d) { return y(d.incflow); }))
		  ;
*/

	      $(chg[0]).tooltip({placement:"center right", tip: '#cumflowChartTip'});


	      // draw start of incident

	      var tr = [ 
	          { t:t0, b: "obs",  n: "t0", l:"Onset of incident" }, //"t<tspan baseline-shift='sub'>0</tspan>" },
	          { t:t1+300, b: "obs", n: "t1", l:"Verification" }, 
	          { t:t2+300, b: "obs", n: "t2", l:"Roadway clear" }, 
	          { t:t3+300, b: "obs", n: "t3", l:"Queue dissipated" }, 
	          { t:t1p+300, n: "t1p", l:"Verification without TMC (estimated)", adjtop: 12},
	          { t:t2p+300, n: "t2p", l:"Clearance time without TMC (estimated)", adjtop: 12},
              { t:t3p+300, n: "t3p", l:"Queue dissipated without TMC (estimated)", adjtop: 12},
	      ].filter( function( d ) { return d.t != null; } );

	      var times = vis.selectAll("g.timebar")
	          .data( tr )
	          .enter().append("svg:g")
	          .attr("class", "timebar")
	          .attr("critevent", function(d) { return d.n } )
	      ;

	      times.append("svg:line")
	          .attr("x1", function (d) { 
		          return x(d.t) } )
	          .attr("x2", function (d) { 
		          return x(d.t) } )
	          .attr("y1", function(d) { return  0 - ( d.adjtop ? d.adjtop : 0 ) } )
	          .attr("y2", 
					//function(d) { return y(d[obs]) }
					hh - 1
				   )
	          .on("mouseover", function(d,i) {
		          this.style.stroke="red";
		          $('#cumflowTimebarTip').html( $.format.date( new Date(d.t*1000), "HH:mm" ) + ":: " + d.l );

	          })
	          .on("mouseout", function(d,i) {
		          this.style.stroke="";
	          })
	      ;

	      d3.selectAll("g.timebar")
	          .append("svg:text")
	          .attr("class","critical-time")
	          .attr("x", function (d) { 
		          return x(d.t) } )
	          .attr("y", function (d) {
				  return d.adjtop ? - d.adjtop : 0
			  })
	          .attr("text-anchor", "start")
	          .text( function(d) { 
		          return d.n; } )
	      ;

	      // Add activity log entries
	      var times2 = vis.selectAll("g.timebar")
	          .data( json.log, 
		             // use an ID function to allow for logtimebars in addition to timebars
		             // so we can highligh them onmouseover
		             function(d,i) { return "log_"+d.id; }  
		           )
	          .enter().append("svg:g")
	          .attr("class", "logtimebar activitylog hidden")
	          .attr("logid", function(d,i) { return d.id; } )
	      ;

	      times2.append("svg:line")
	          .attr("x1", function( d ) { 
		          var dd = new Date( d.stampDateTime ).getTime()/1000; 
		          return x( dd ); } )
	          .attr("x2", function( d ) { 
		          var dd = new Date( d.stampDateTime ).getTime()/1000; 
		          return x( dd ); } )
	          .attr("y1", 0 )
	          .attr("y2", hh - 1 )
	          .on("mouseover", function(d,i) { 
		          this.style.stroke="red";
				  $('#chartbox').tooltip('hide')
					  .attr('data-original-title',"Log: " + new Date(d.stampDateTime).toLocaleTimeString() + ": " + d.memoOnly)
					  .tooltip('fixTitle')
					  .tooltip('show');

	          })
	          .on("mouseout", function(d,i) {
		          this.style.stroke="";
	          })
	      ;



	      $(container).find('.timebar').tooltip({placement:"center right", tip: '#cumflowTimebarTip', offset: [20, 0]});


	      cumflow.updateStats();

	      function avgmouseover(d,i) {
			  $('#chartbox').tooltip('hide')
				  .attr('data-original-title',"Expected Cumulative Flow")
				  .tooltip('fixTitle')
				  .tooltip('show');
	      }

	      function obsmouseover(d,i) {
	          //$('#cumflowChartTip').html( "TMC Savings due to restoration");
			  setChartTip( "Estimated cumulative flow without TMC")
	      }

	      function updateText(msg) {
	          d3.select("#msgtxt").html(msg);
	      }

      }

	  function setChartTip(msg) {
		  $('#chartbox').tooltip('hide')
			  .attr('data-original-title',msg)
			  .tooltip('fixTitle')
			  .tooltip('show');
	  }

      function updateCumFlowStats() {
          //cumflow.tmcDivPct( $("#tmcpct").text() );
      }

      function paramsChanged() {
          cumflow.redraw();
          cumflow.updateStats();
      }


      /////// some application events this view listens to ///////

      // core data (model) changes
      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	      // new analysis loaded, update the data
	      cumflow.data( json );
      });

      // parameter changes
      $(window).bind("tmcpe.tsd.tmcPctChanged", function(e, paramsa ) {
          params.tmcDivPct = parseInt(paramsa.data.tmcpctslider);
          cumflow.redraw();
          cumflow.updateStats();
      });
      $(window).bind("tmcpe.tsd.verificationDelayChanged", function( e, paramsa ) {
          params.verificationDelay = parseInt(paramsa.data.verdelslider);
          // should really have a remodel here, then a redraw
          cumflow.redraw();
      });
      $(window).bind("tmcpe.tsd.responseDelayChanged", function( e, paramsa ) {
          params.responseDelay = parseInt(paramsa.data.respdelslider);
          // should really have a remodel here, then a redraw
          cumflow.redraw();
      });
      $(window).bind("tmcpe.tsd.delayUnitChanged", function( e, paramsa ) {
          params.delayUnit = paramsa.data.delayUnit;
          cumflow.updateStatsUnit();
      });
      $(window).bind("tmcpe.tsd.valueOfTimeChanged", function( e, paramsa ) {
          params.valueOfTime = parseFloat(paramsa.data.valueOfTime);
          cumflow.updateStatsUnit();
      });

      $(window).bind("tmcpe.tsd.d12DelayHover", function( caller, paramsa ) {
          d3.select('path.expectedflowafterdiv').classed("highlight",true);
		  setChartTip("Region of Net Delay<35");
		  $("#chartbox").tooltip('show');
      });
      $(window).bind("tmcpe.tsd.d12DelayUnhover", function( caller, paramsa ) {
          d3.select('path.expectedflowafterdiv').classed("highlight",false);
		  $("#chartbox").tooltip('hide');
	      setChartTip("");
      });

      $(window).bind("tmcpe.tsd.netDelayHover", function( caller, paramsa ) {
          d3.select('path.expectedflowafterdiv').classed("highlight",true);
		  setChartTip("Region of Net Delay w/TMC");
		  $("#chartbox").tooltip('show');
      });

      $(window).bind("tmcpe.tsd.netDelayUnhover", function( caller, paramsa ) {
          d3.select('path.expectedflowafterdiv').classed("highlight",false);
		  setChartTip("");
		  $("#chartbox").tooltip('hide');
      });

      $(window).bind("tmcpe.tsd.whatIfDelayHover", function( caller, paramsa ) {
          d3.select('path.adjexpectedflowafterdiv').classed("highlight",true);
          d3.select('path.expectedflowafterdiv').classed("highlight",true);
          d3.select('path.observed').classed("highlight",true);
		  setChartTip("Region of Net Delay w/out TMC");
		  $("#chartbox").tooltip('show');

      });
      $(window).bind("tmcpe.tsd.whatIfDelayUnhover", function( caller, paramsa ) {
          d3.select('path.adjexpectedflowafterdiv').classed("highlight",false);
          d3.select('path.observed').classed("highlight",false);
          d3.select('path.expectedflowafterdiv').classed("highlight",false);
		  setChartTip("");
		  $("#chartbox").tooltip('hide');
      });

      $(window).bind("tmcpe.tsd.tmcSavingsHover", function( caller, paramsa ) {
          d3.select('path.adjexpectedflowafterdiv').classed("highlight",true);
          d3.select('path.observed').classed("highlight",true);
		  setChartTip("Region of TMC Savings");
		  $("#chartbox").tooltip('show');
      });
      $(window).bind("tmcpe.tsd.tmcSavingsUnhover", function( caller, paramsa ) {
          d3.select('path.adjexpectedflowafterdiv').classed("highlight",false);
          d3.select('path.observed').classed("highlight",false);
          $('#cumflowChartTip').css('display','none');
	      $('#cumflowChartTip').html("" );
		  setChartTip("");
		  $("#chartbox").tooltip('hide');
      });

      $(window).bind("tmcpe.tsd.paramsChanged", function( caller, paramsa ) {
	      // update params model
	      cumflow.params({
              tmcDivPct: parseInt(paramsa.data.tmcpctslider),
              verificationDelay: parseInt(paramsa.data.verdelslider),
              responseDelay: parseInt(paramsa.data.respdelslider),
              valueOfTime: parseFloat(paramsa.data.valueOfTime),
			  delayUnit: paramsa.data.delayUnit
          });

      });


      // UI changes
      $(window).bind("tmcpe.tsd.selectedSection", function( caller, data ) {
	      cumflow.section( data.sectionidx );
      });

      return cumflow;
  };

  // view of the traffic conditions during the incident displayed on a map using
  // vds line segments
  tmcpe.segmap = function() {
      var segmap = {},
      container,
      theight,// = $(container).height()-2,
      twidth,// = $(container).height()-2,
      data,
      json,
      map,
      usearrow = true,
      rotate = "cardinal",  // default = incident
      secjson,
      segments,
      ends,
      legend,
      //theme = tmcpe.tsdTheme(), /* theme using defaults */
      color = d3.scale.linear()
	      .domain([10,10+(60-10)/2,60])
	      .range(['#f00','#ff0','#0f0']),   /* red to yellow to green */
      activeTimestep

      po = org.polymaps;

      segmap.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
	      container.setAttribute("class", "map");
	      //container.appendChild(rect);
	      return cumflow.resize(); // infer size
      }

      var rect = tmcpe.svg("rect");
      rect.setAttribute("visibility", "hidden");
      rect.setAttribute("pointer-events", "all");

      segmap.resize = function() {
	      if (!size) {
	          rect.setAttribute("width", "100%");
	          rect.setAttribute("height", "100%");
	          b = rect.getBBox();
	          sizeActual = {x: b.width, y: b.height};
	          //resizer.add(map);
	      } else {
	          sizeActual = size;
	          //resizer.remove(map);
	      }
	      rect.setAttribute("width", sizeActual.x);
	      rect.setAttribute("height", sizeActual.y);
	      return segmap;
      };

      segmap.data = function(x) {
	      if ( !arguments.length ) return json;
	      json = x;
	      segmap.redraw();
	      readSegments();
	      return segmap;
      }

      segmap.secjson = function(x) {
	      if ( !arguments.length ) return secjson;

	      secjson = x;
	      
		  segmap.redrawSegments();

	      return segmap;
      }

	  segmap.redrawSegments = function() {
	      // 
	      addSegmentLayer();
	      // order is important here if we're drawing arrows
	      zoomExtents();
	      rotateLayer();
	      addEndsLayer();

		  return segmap;
	  }


      segmap.hh = function() { return $(container).height()-2; };
      segmap.ww = function() { return $(container).width()-2; };


      segmap.container = function(x) {
	      if ( !arguments.length ) return container;
	      container = x;
	      return segmap;
      }

      segmap.redraw = function() {
	      if ( container ) $(container).children().remove();
	      create();
	      addImageLayer();
	      renderMaptext();
	      return segmap;
      }

      segmap.rotate = function(x) {
	      if ( !arguments.length ) return rotate;
	      rotate = x;
	      rotateLayer()
	      return segmap;
      }

      function create() {

	      // create the map
	      var svg = d3.select(container)
	          .append("svg:svg")
	          .attr("id","segmapsvg")
	          .attr("class","map")
	          .attr("height",segmap.hh())
	          .attr("width",segmap.ww())[0][0];

	      map = po.map()
	          .container(svg)
	          .zoom(13)
	          .zoomRange([1,/*6*/, 18])
	          .add(po.interact());

	      return segmap;
      }

      function renderMaptext() {
	      var svg = d3.select('#segmapsvg');
	      if ( svg == null || svg.length == 0 ) throw "Can't create maptext without SVG element";

	      // Add the maptext as a foreign object (for more consistent font handling)
	      svg.append("svg:foreignObject")
	          .attr("xmlns","http://www.w3.org/1999/xhtml")
	          .attr('x',30)
	          .attr('y',segmap.hh()-20)
	          .attr('width',250)
	          .attr('height',40)
	          .append('p')
	          .attr('id','maptext')
	      ;
      }

      function renderLegend() {
	      var svg = d3.select('#segmapsvg');
	      if ( svg == null || svg.length == 0 ) throw "Can't create legend without SVG element";

	      // remove existing
	      svg.select("g.legend").remove();

	      legend = tmcpe.legendForLinearScale()
	          .title("Speed (mph)")
	          .barlength(segmap.hh()-100-100)  // 100's are margins for top and bottom
	          .scale(color)
	          .render(svg)
	          .attr('transform',"translate(30,100)") // place just below compass
	          .attr('class',"legend")
	      ;
      }
      
      function addImageLayer() {

	      map.add(po.image()
		          .url(po.url("http://{S}tile.openstreetmap.org"
			                  + "/{Z}/{X}/{Y}.png")
		               .hosts(["a.", "b.", "c.", ""])));
	      return segmap;
      }

      function rotateLayer() {
	      if ( rotate == "incident" ) {

	          var ff = secjson.features.slice(0,secjson.features.length-1).sort(function(a,b){
		          var diff =  a.pm - b.pm;
		          if ( a.dir == 'N' || a.dir == 'E' )
		              return -diff;
		          else
		              return diff;
	          });

	          var startll = ff[0].geometry.coordinates;
	          start = map.coordinatePoint(map.locationCoordinate(map.center()),
					                      map.locationCoordinate( {lon:startll[0][0],lat:startll[0][1] } ) );
	          var endll = ff[ff.length-1].geometry.coordinates;
	          end = map.coordinatePoint(map.locationCoordinate(map.center()),
					                    map.locationCoordinate( {lon:endll[endll.length-1][0],lat:endll[endll.length-1][1] } ) );

	          // x,y screen coords are flipped on the x axis (y increases downward)
	          // we negate the y coords here for the angle calc
	          var dy = -((end.y)-(start.y));
	          var dx = (end.x-start.x);
	          var angle = Math.atan2( dy, dx );
	          var aa = angle * 180 / Math.PI;

	          rr = angle + Math.PI/2.0;

	          var rra = rr * 180 / Math.PI;

	          //console.log( "Angle,rra:"+aa+","+rra );

	          map.angle( rr )
              //	      map.angle( 90*Math.PI/180.0 );

	      } else {
	          // default is cardinal
	          map.angle( 0 );
	      }
      }

      function screenAngleBetweenGeoJsonPoints(a,b) {
	      var p1 = map.coordinatePoint(map.locationCoordinate(map.center()),map.locationCoordinate({lon:a[0],lat:a[1]}));
	      var p2 = map.coordinatePoint(map.locationCoordinate(map.center()),map.locationCoordinate({lon:b[0],lat:b[1]}));
	      return {a:Math.atan2( p2.y - p1.y, p2.x - p1.x ),p1:p1,p2:p2};
      }

      function addEndsLayer() {
	      // remove existing
	      $("#ends").remove();

	      var ends = po.geoJson().features(secjson.features.map( function (f) {

	          var p3 = f.geometry.coordinates[ f.geometry.coordinates.length-1 ]; // end of segment/arrow

	          if ( !usearrow ) {
		          // draw a circle
		          return {data: f.properties, 
			              geometry: { type:"Point", 
				                      coordinates: p3
				                    }};

	          } else {
		          // draw an arrow
		          var p1 = f.geometry.coordinates[ f.geometry.coordinates.length-2 ]; // base of shaft
		          
		          var aa = screenAngleBetweenGeoJsonPoints( p1, p3 );

		          var angle1 = aa.a;
		          var angle2 = angle1 +Math.PI/2;

		          var shaftlen = Math.pow(2, map.zoom() - 9);;
		          var shaftlen2 = Math.pow(2, map.zoom() - 9.5);;
		          var arrowwid = Math.pow(2, map.zoom() - 10);

		          var c1b = {x:aa.p2.x - Math.cos(angle1)*shaftlen,y:aa.p2.y - Math.sin(angle1)*shaftlen};  // convert pixels
		          var c1c = {x:aa.p2.x - Math.cos(angle1)*shaftlen2,y:aa.p2.y - Math.sin(angle1)*shaftlen2};  // convert pixels
		          var c2 = {x:c1b.x + Math.cos(angle2)*arrowwid,y:c1b.y + Math.sin(angle2)*arrowwid};  // convert pixels
		          var c4 = {x:c1b.x - Math.cos(angle2)*arrowwid,y:c1b.y - Math.sin(angle2)*arrowwid};  // convert pixels

		          p1 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c1c));
		          p2 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c2));
		          p3 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),aa.p2));
		          p4 = map.coordinateLocation(map.pointCoordinate(map.locationCoordinate(map.center()),c4));


		          return {data: f.properties, 
			              geometry: { type:"Polygon",
				                      coordinates: [[[p1.lon,p1.lat],
						                             [p2.lon,p2.lat],
						                             [p3.lon,p3.lat],
						                             [p4.lon,p4.lat],
						                             [p1.lon,p1.lat]]] }
			             }; 
	          }
	      } ) );

	      ends.id("ends")
	          .zoom( function(z) { return Math.max(4, Math.min(18, z)); } )
	          .tile(false)
	          .on("load", po.stylist()
		          .attr("id", function(d) { 
		              return "node:"+d.data.id } )
		          .attr("r", 2 )
		          /*
		            function(d) { 
		            var zz = map.zoom()
		            var lev = 2+Math.floor(((zz-1))/17*(8-2));
		            return Math.min( Math.max( 2, lev ), 8 ) } )
		          */
		          .attr("stroke", "black" )
		          .attr("fill", "blue" )
		          .title(function(d) { 
		              return [d.data.id,d.data.name].join(":"); }));
	      map.add(ends);
      }

      function zoomExtents() {


	      var x = Array();
	      var y = Array();
	      for (var i = 0; i < secjson.features.length; i++) {
	          var feature = secjson.features[i];
	          var coords = feature.geometry.coordinates;
	          var polygons = $.map(coords, function(a){
		          return [a];});
	          var points = $.map(polygons, function(a){
		          return [a];
		          // convert to screen coordinates to compute extent
		          //		       var p = map.coordinatePoint( map.locationCoordinate(map.center()),map.locationCoordinate({lon:a[0],lat:a[1]}) )
		          //		       return p;
	          });
	          $.map(points, function(a){
		          if(!isNaN(a[0])){
		              x.push(a[0])
		          }; 
		          if(!isNaN(a[1])){
		              y.push(a[1])
		          };
	          });
	      }
	      xMax = Array.max(x);
	      xMin = Array.min(x);
	      yMax = Array.max(y);
	      yMin = Array.min(y);

	      map.extent([{lon:xMin,lat:yMin},{lon:xMax,lat:yMax}])
          //	      .zoomBy(segmap.ww()/segmap.hh())
	          .zoomBy((yMax-yMin)/(xMax-xMin)*(Math.abs(Math.sin(map.angle()))))
	          .zoomBy(-0.75)
	      ;

	      map.add(po.compass().pan("none"));

      }

      function readSegments() {
	      // assertions
	      if ( json == undefined || json.sections == undefined ) throw "Missing TSD analysis data";
	      
	      var url = tmcpe.createFormattedLink({controller:'vds', 
				                               action:'list.geojson',
				                               params: {freewayDir: json.sections[0].dir,
					                                    idIn: json.sections.map( function( sec ) {return sec.vdsid;}).join(",")}
				                              });

	      tmcpe.loadData( url, function(e) {
	          // update the section layer json
	          segmap.secjson( e );

	          $(window).trigger( "tmcpe.tsd.segmentsLoaded", e );
	      }, "VDS Segment Data");
      }

      segmap.getSectionIndex = function( sec, e  ) {
	      for (var i = 0; i < e.features.length; i++) {
	          if ( e.features[i].data.id == sec ) {
		          return i;
	          }
	      }
	      return null;
      }

      function addSegmentLayer() {
	      // remove existing
	      $("#segments").remove();

	      var secs = po.geoJson().features(secjson.features)
	          .id("segments")
	          .zoom( function(z) { return Math.max(4, Math.min(18, z)); } )
	          .tile(false)
	          .on("load", 
		          function (e) {
		              for (var i = 0; i < e.features.length; i++) {
			              var f = e.features[i];
			              var c = $(f.element);
			              var g = c.parent().add("svg:g", c);
			              g.add(c);
		              }
		              
		              // Find the incident section

		              var i;
		              var incsecIndex=segmap.getSectionIndex(json.sec, e);
		              var incsec=e.features[incsecIndex];

		              if ( incsec ) {
			              var c = $(incsec.element);
			              var g = c.parent().add("svg:g", c );
			              g.add(c);
			              
			              var point = g[0].appendChild(po.svg("circle"));
			              point.setAttribute("id", "location");
			              // mark at end of incsec
			              var crd = incsec.data.geometry.coordinates[incsec.data.geometry.coordinates.length-1];
                          //			  var lc = map.locationCoordinate({lon:crd[0],lat:crd[1]});
                          //			  var cc = map.coordinatePoint(map.locationCoordinate(map.center()),lc)
			              point.setAttribute("class", "incidentLocation" )
			              point.setAttribute("cx", crd.x);
			              point.setAttribute("cy", crd.y);
			              //point.setAttribute("r", Math.pow(2, tile.zoom - 11) * Math.sqrt(cluster.cluster.length));
			              point.setAttribute("r", Math.pow(2, map.zoom() - 7) );
		              }


		              po.stylist()
			              .attr("id", function( d ) { return d.id; } )
			              .attr("i", function( d ) { return d.i; } )
			              .attr("stroke", function( d ) {
			                  //var el = $('g[vdsid^="'+d.id+'"] rect[j^=11]')[0]; // fixme: j == 11?  this is a hanging hardcode
			                  //return el == null ? "black" : el.style.fill; 
			                  return color(60);
			              } )
			              .attr("stroke-width", 4 )
			              .title(function(d) { 
			                  return [d.id,d.name].join(":"); })(e);
		          });

	      map.add(secs);

	      // force color redraw
	      if ( activeTimestep != null ) setActiveTimestep( activeTimestep );

      }

      /**
       * Update the segment map based upon the given active timestep
       */
      function setActiveTimestep( j ) {
	      activeTimestep = j;
	      if ( json == null ) return;  // incase we've not received data yet

          var sections = json.sections;

	      // Next, foreach el, find the corresponding segment and update the stroke
	      // FIXME: THIS IS A HACK ATTACK!
	      d3.select(container).select('#segments')
	          .selectAll('path[id]')
	          .style('stroke',function(d) {
		          var id = d3.select(this).attr('id');
		          var si = json.getSectionIndex(id);
		          var x = json.data[si][j];
		          if ( x.p_j_m > 0 && x.p_j_m < 1 ) {
		              d3.select(this).classed('datapoor',true);
		              return "";
		          } else {
		              d3.select(this).classed('datapoor',false);
		              return color(json.data[si][j].spd)
		          }
	          });

	      /*
	        d3.select(container).select('#ends')
	        .selectAll('circle[id]')
	        .style('fill',function(d) {
	        var id = d3.select(this).attr('id');
	        var nodsec = id.split(":");
	        var si = json.getSectionIndex(nodsec[1]);
	        return json.data[si][j].inc ? "blue" : d3.select(this).style('fill');
	        });
	      */
	      d3.select(container).select('#ends')
	          .selectAll('path[id]')
	          .style('fill',function(d) {
		          var id = d3.select(this).attr('id');
		          var nodsec = id.split(":");
		          var si = json.getSectionIndex(nodsec[1]);
		          return json.data[si][j].inc ? "blue" : color(json.data[si][j]);
	          });

	      // finally, update the map text
	      d3.select("#maptext")
	          .text(json.timesteps[j]);
      }

      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, adata) {
	      segmap.data( adata ).redraw();
      });

      $(window).bind("tmcpe.tsd.activeTimestep", function(caller, adata) {
          setActiveTimestep( adata );
      });

      $(window).bind("tmcpe.tsd.paramsChanged", function( caller, params ) {
	      // update speed scale
	      //tsd.updateScale();
	      renderLegend()
      });


      return segmap;
  };


  tmcpe.statsView = function() {
      var statsView = {},
      container,
      data
      ;

      function init() {
          if ( container == null ) throw "Can't initialize statsView in null container";

          // get the panes we'll fill
          var panes = d3.select(container).selectAll('.panes');

          // ditch all the children
          panes.selectAll('div').remove();
          
	      // create the children
          var genstats = panes.append('div')
			  .attr('id','generalStatsContainer')
			  .attr('class', 'tab-pane' )
			  .attr('data-toggle', 'tab') // twitter bootstrap
		  ;
          var ltc = panes.append('div')
			  .attr('id','logtableContainer')
			  .attr('class', 'tab-pane' )
			  .attr('data-toggle', 'tab') // twitter bootstrap
		  ;


          // Create the tabs. These must be created before we execute the
	      // dataTable() call on the child elements because otherwise the size
	      // of the container is not determined for the dataTable().
          //$("#databox .tabs").tabs( 'div.panes > div' );


          var gst = genstats.append('table')
              .attr('id','generalStats');
          var gsthr = gst.append('thead').append('tr');
          gsthr.selectAll('th')
              .data([{class:"label",html:"Facility"},
                     {class:"numlabel",html:'Net Delay<35<br/>(w/TMC)<br/><span class="delayUnitHolder"></span>'},
                     {class:"numlabel",html:'Net Delay<br/>(w/TMC)<br/><span class="delayUnitHolder"></span>'},
                     {class:"numlabel",html:'Net Delay<br/>(no TMC)<br/><span class="delayUnitHolder"></span>'},
                     {class:"numlabel",html:'TMC Savings<br/><span class="delayUnitHolder"></span>'},
                    ])
              .enter()
              .append('th')
              .attr('class',function(d){return d.class;})
              .html(function(d){return d.html;})
          ;

          // FIXME: for each ifia
          var gstbr = gst.append('tbody').append('tr');
          gstbr.selectAll('td')
              .data([{class:"facilityName",id:"facility"},
                     {class:"delayValue",id:"d12Delay"},
                     {class:"delayValue",id:"netDelay"},
                     {class:"delayValue",id:"whatIfDelay"},
                     {class:"delayValue",id:"tmcSavings"},
                    ])
              .enter()
              .append('td')
              .attr('class',function(d){
                  return d.class;})
              .attr('id',function(d){return d.id;})
              .on('mouseover',function(d){
	              $(window).trigger( "tmcpe.tsd."+d.id+"Hover", d );
              })
              .on('mouseout',function(d){
	              $(window).trigger( "tmcpe.tsd."+d.id+"Unhover", d );
              })
          ;

          var gs = $("#generalStats");
          gs.dataTable({
	          "bPaginate": false,
	          "sScrollY": gs.parent().height()*.5,
	          "bLengthChange": false,
	          "bFilter": false,
	          "bSort": false,
	          "bInfo": false,
	          "aoColumns": [
	              {"sWidth": "20%", "sType":"string", "sClass":"right" },
	              {"sWidth": "20%", "sType":"number", "sClass":"left" },
	              {"sWidth": "20%", "sType":"number", "sClass":"left" },
	              {"sWidth": "20%", "sType":"number", "sClass":"left" },
	              {"sWidth": "20%", "sType":"number", "sClass":"left" }
	          ]
          } );
          


          
		  /*
          var ul = genstats.append('ul');
          ul.append('li').append('a').attr('id','tmcpe_tsd_download_link');
          ul.append('li').append('a').attr('id','tmcpe_report_analysis_problem_link');
		  */

		  // show the first tab
		  $('.nav-tabs a').tab('show');
		  $('.nav-tabs a:first').tab('show');

      }

      function update() {
      }

      statsView.container = function(x) {
	      if (!arguments.length) return container;
	      container = x;
          init();
	      return cumflow;
      }

      statsView.data = function(x) {
	      if ( !arguments.length ) return data;
	      data = x;
          update();
	      return segmap;
      }

      
      
      
      return statsView;
  };



  var i = 0;
  var tsd;
  var cumflow;
  var map;

  function rotateMap( v ) {
      map.rotate( v.value );
  }

  function updateStats( json ) {
      if ( json.analysis.badSolution != null ) {
          //$( '#generalStats td' ).text( "" );   // clear everything
	      $( '#generalStats_wrapper').remove();
	      $( '#generalStatsContainer').append("<p>ANALYSIS FOR THIS FACILITY FAILED: "+json.analysis.badSolution+"</p>");
      } else {
	      // FIXME: This dups a similar function in tsd.js
	      $.each(["netDelay","d12Delay","computedDiversion","computedMaxq","whatIfDelay","tmcSavings"], function (i,v) {
              if ( json.analysis[v] != null  && v != 'computedMaxqTime' ) {
		          var val = json.analysis[v].toFixed(0);
		          d3.select("#"+v).html( val < 0 ? 0 : val  );
              }
	      });

	      // Update the download analysis link.  Currently tied to the currently displayed analysis...
		  /*
	      $('#tmcpe_tsd_download_link').html( 'Download spreadsheet for facility analysis ' + json.id );
	      $('#tmcpe_tsd_download_link').attr( 'href', 
                                              g.createLink({controller:'incidentFacilityImpactAnalysis', 
			                                                action:'show.xls',
			                                                params: {id: json.id} 
			                                               })
                                            );
											*/


	      // Update the report problem link
		  /*
	      $('#tmcpe_report_analysis_problem_link').html( 'Report problem with this analysis' );
	      url = "http://tracker.ctmlabs.net/projects/tmcpe/issues/new?tracker_id=3&"
	          + encodeURIComponent( "issue[subject]=Problem with analysis of Incident "+json.cad+"["+json.id+"]" )
	          + "&" + encodeURIComponent( "issue[description]=Bad analysis for available for ["+json.cad+"["+json.id+"]"+"]("
					                      +window.location.href
					                      +")\n\n"
					                      +"User Agent: " + navigator.userAgent
					                    )
	      $('#tmcpe_report_analysis_problem_link').attr('href',url);
	      $('#tmcpe_report_analysis_problem_link').attr('target', "_blank" );
		  */
      }
  }


  function renderLogTimestamp(obj) {
      dd = new Date( obj );
      return $.format.date(dd,'yyyy-MM-dd kk:mm');
  }

  function renderLogTime(obj) {
      dd = new Date( obj );
      return $.format.date(dd,'kk:mm');
  };

  function raiseLogEntry( d ) {
      // In SVG, the z-index is the element's index in the dom.  To raise an
      // element, just detach it from the dom and append it back to its parent

      // FIXME: this should reside in cumflow and be triggered by an event
      var targets = $("g[logid="+d.id+"]");
      var target = targets[0];
      var parent = target.parentNode;
      targets.detach().appendTo( parent );
      return 
  }

  function updateLog( json ) {
      // clear existing
      var container = d3.select( '#logtableContainer' );

      $('#logtableContainer').children().remove();

      // select table element (for d3)
      var tab = container
	      .append("table")
	      .attr("id","activityLog")
	      .style("width","100%")
      ;
      
      var head = tab.append("thead");

      var aoCols = [
	      {key: "stampDateTime",   "sTitle": "Date", "render": renderLogTimestamp, "sType":"date", "bVisible": false }, // hidden, just used for sorting
	      {key: "stampDateTime",   "sTitle": "Time", "render": renderLogTime, "sWidth": "20%", "sType":"date" },
	      {key: "activitySubject", "sTitle": "Activity", "sWidth": "20%", "sType":"string" },
	      {key: "memoOnly",        "sTitle": "Description", "sWidth": "60%", "sType":"string" }
      ];

      head.append("tr").selectAll("th").data(aoCols).enter()
	      .append("th")
	      .attr("class",function(d){return d.key ? d.key : d;})
	      .html(function(d){return d.sTitle ? d.sTitle : d});

      var body = tab.append("tbody");


      // create log rows
      var rows = body.selectAll("tr")
	      .data(json.log,function(d) {return d.id})
	      .enter().append("tr")
	      .attr("id", function( d ) { return ["log",d.id].join("-"); })
	      .attr("logid", function( d ) { return d.id; })
	      .attr("class", function( d, i ) { return ( i % 2 ? "even" : "odd" ) + " " + d.type } )
	      .on("mouseover",function(d,e) {
	          // placehold, should highlight on TSD
	          d3.selectAll('g.activitylog').attr("class","logtimebar activitylog hidden");
	          d3.selectAll('g.activitylog[logid="'+d.id+'"]')
		          .attr("class",function(dd,e){
		              raiseLogEntry(dd);
		              return "logtimebar activitylog";
		          });
	      } );
      
      // now populate rows
      rows.selectAll("td")
	      .data(function(d) {
	          var props = [];
	          $.each( aoCols, function( i, dd ) {
		          var item = d[dd.key];
		          props.push( dd.render ? dd.render( item ) : item );
	          });
	          return props;
	      })
	      .enter().append("td")
	      .attr("class", function(d,i) { return aoCols[i].key } )
	      .text( function(dd) { return dd; } );

      $("#activityLog").dataTable({ 
	      bPaginate: false, sScrollY:"200px","bAutoWidth":false,"bFilter": false,
	      "aoColumns": aoCols 
      });

  }

  function loadLog( id ) {
      // assert
      if ( id == null ) throw "Can't load log for null incident";

      var url = tmcpe.createFormattedLink({controller:'incident', 
			                               action:'getTmcLog',
			                               params: {id: id} 
			                              });
      tmcpe.loadData(url,function(e){
	      updateLog( e );
	      $(window).trigger( "tmcpe.tsd.logLoaded", e );
      },"TMC Activity Log Data");
  }

  function updateAnalysis( id ) {
      var url = tmcpe.createFormattedLink({controller:'incidentFacilityImpactAnalysis', 
			                               action:'tsdData',
			                               params: {id: id.value} 
			                              });
      
      tmcpe.loadData(url,function(e){
	      if ( e == null || e.timesteps == null ) {
	          // this is an error condition
	          $('#server_error').modal();
	          return;
	      }

	      // convert date strings to date objects
	      e.timesteps = e.timesteps.map( function( d ) { return new Date(d); } ); 

	      // add the sectionindex conversion function
	      // get section index from vdsid
	      e.getSectionIndex = function( id ) {
	          if ( e.sections == null || e.sections.length == 0 ) {
		          return null;
	          }
	          var sec = e.sections.length-1; // default to the last
	          var ii;
	          for( ii = 0; ii < e.sections.length; ++ii ) {
		          if ( e.sections[ii].vdsid == id ) 
		              sec = (ii==e.sections.length-1?ii:ii+1);
	          }
	          return sec;
	      }
	      
	      // broadcast the new data
	      $(window).trigger( "tmcpe.tsd.analysisLoaded", e );
      }, "Analysis " + id.value);
      
      $('#generalStats #facility').html(id.children[0].innerHTML);
  }


  /************ MAIN APP CODE ************/
  $(document).ready(function() {

      ///// create the various views to show the data /////

      var tsdView = tmcpe.tsd()
	      .container( $("#tsdbox")[0] );

      var cumflowView = tmcpe.cumflow().container( $("#chartbox")[0] );

      var mapView = tmcpe.segmap().container( $("#mapbox")[0] );

      var tsdParamsView = tmcpe.tsdParamsView().container($('#tsdParams'));
      ;

      var statsView = tmcpe.statsView().container( $('#databox')[0] );

      var cellDetailView = tmcpe.cellDetailView().container( d3.select('#cellDetail') );

      // put the settings in the true header (from base.gsp)
      var settings = $("#settings").detach();
      settings.appendTo('.header');

      // update the params
      //tsdParamsView.touch();

	  // attach the action buttons
	  var orgheight = $('#chartcontainer').css('height');
	  $('#btn-show-all').click(function(e){
		  e.preventDefault();
		  $('#databox')
			  .removeClass('span12')
			  .addClass('span6')
			  .css('height',orgheight)
			  .css('display','block')
		  ;

		  $('#tsdcontainer')
			  .removeClass('span12')
			  .addClass('span6')
			  .css('display','block')
		  ;
		  $('#tsdbox')
			  .css('height',orgheight);
		  tsdView.container( $('#tsdbox')[0]);
		  tsdView.resize();
		  tsdView.redraw();

		  $('#mapbox')
			  .removeClass('span12')
			  .addClass('span6')
			  .css('height',orgheight)
			  .css('display','block')
		  ;
		  //mapView.resize();
		  mapView.redraw();
		  mapView.redrawSegments();

		  $('#chartcontainer')
			  .removeClass('span12')
			  .addClass('span6')
			  .css('height',orgheight)
			  .css('display','block')
		  ;
		  cumflowView.resize();
		  cumflowView.redraw();
	  });
	  $('#btn-only-show-table').click(function(e){
		  e.preventDefault();
		  var fullheight = $(window).height() - 150;
		  $('#databox')
			  .removeClass('span6')
			  .addClass('span12')
			  .css('min-height',orgheight)
			  .css('height',fullheight)
			  .css('display','block')
		  $('#tsdcontainer').css('display','none');
		  $('#mapbox').css('display','none');
		  $('#chartcontainer').css('display','none');
	  });

	  $('#btn-only-show-chart').click(function(e){
		  e.preventDefault();
		  $('#databox').css('display','none');
		  $('#tsdcontainer').css('display','none');
		  $('#mapbox').css('display','none');
		  var fullheight = $(window).height() - 150;
		  $('#chartcontainer')
			  .removeClass('span6')
			  .addClass('span12')
			  .css('min-height',orgheight)
			  .css('height',fullheight)
			  .css('display','block')
		  ;
		  cumflowView.resize();
		  cumflowView.redraw();
	  });
	  $('#btn-only-show-map').click(function(e){
		  e.preventDefault();
		  $('#databox').css('display','none');
		  $('#tsdcontainer').css('display','none');
		  $('#chartcontainer').css('display','none');
		  var fullheight = $(window).height() - 150;
		  $('#mapbox')
			  .removeClass('span6')
			  .addClass('span12')
			  .css('min-height',orgheight)
			  .css('height',fullheight)
			  .css('display','block')
		  ;
		  mapView.redraw();
		  mapView.redrawSegments();
	  });
	  $('#btn-only-show-tsd').click(function(e){
		  e.preventDefault();
		  $('#databox').css('display','none');
		  $('#chartcontainer').css('display','none');
		  $('#mapbox').css('display','none');
		  var fullheight = $(window).height() - 150;
		  $('#tsdcontainer')
			  .removeClass('span6')
			  .addClass('span12')
			  .css('display','block')
		  ;
		  $('#tsdbox')
			  .css('min-height',orgheight)
			  .css('height',fullheight);
		  tsdView.resize();
		  tsdView.redraw();
	  });
      
	  $('#btn-change-settings').click(function(e){
		  $('#tsdParams').modal('show');
	  });

      ///// bind events /////

      // Event called when a new analysis has been processed from the server
      $(window).bind("tmcpe.tsd.analysisLoaded", function(caller, json) {
	      updateViews( json );
      });


      // attach tooltips
      //$('[title]').tooltip({placement: "bottom center", tipClass:"tooltip bottom"});

      
      // Grab the TSD for the first incident, success callback is updateData, which redraws the TSD

      $("#ifia").each(function() {
	      if ( this.value != "" ) {
  	          updateAnalysis( this ); 
 	      } else {
	          $("#msgtxt").text("NO ANALYSES AVAILABLE");
	      }
      });
      //d3.select('#ifia').on("change",function(d){this.options[this.selectedIndex]});
      //d3.select('#theme').on("change",function(d){updateTsd()});
      //d3.select('#valueOfTime').on("change",function(d){updateCumFlowStats()});

      var cad = $('#id');
      
      loadLog( cad.attr('name') );


      /*
        {
	    // hack to resize columns in a tab: http://datatables.net/examples/api/tabs_and_scrolling.html
	    "show": function(event, ui) {
	    var oTable = $('div.dataTables_scrollBody>table', ui.panel).dataTable();
	    if ( oTable.length > 0 ) {
	    oTable.fnAdjustColumnSizing();
	    }
	    }
        } );
      */

      // Helper function to update views based upon (analysis) data received from the server
      function updateViews( data ) {

	      // Select a time to synchronize
	      $(window).trigger("tmcpe.tsd.selectedSection",{sectionidx:cumflowView.section()});

	      updateStats( data );

	      //updateLog( data );


	      // if the window is resized, recompute the bounds of all the components.
	      $(window).resize(function() { 
              tsdView.resize(); 
              tsdView.redraw(); 
	          cumflowView.resize( );
	          cumflowView.redraw( );
	          updateStats( data );
	          //updateLog( data );
	          //	 doMap( data );
              mapView.data(data).redraw();
	      });

      }
  });
 })();
