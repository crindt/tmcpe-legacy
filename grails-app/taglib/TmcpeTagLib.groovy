class TmcpeTagLib {
  static namespace = 'tmcpe'

  def timeSpaceDiagram = {
      out << '<script src="' << resource(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojo_config = {
      out << 
      """    
         <script type=\"text/javascript\">
            djConfig = {parseOnLoad: true,
                        isDebug:     true,
                        baseUrl:     '${resource( dir:'js',file:'tmcpe' )}/',
                        modulePaths: { my: '${resource( dir:'js/tmcpe',file:'' )}' }
                       };
         </script>
      """
  }

  def dojo_1_4_styles = {
      out << 
      '''
         <link rel="stylesheet" href="${resource(dir:'js/dojo-uncompressed/dijit/themes/tundra/layout',file:'BorderContainer.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo-uncompressed/dojox/grid/resources',file:'Grid.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo-uncompressed/dojox/grid/resources',file:'tundraGrid.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo-uncompressed/dijit/themes/tundra',file:'tundra.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo-uncompressed/dojo/resources',file:'dojo.css')}" />
      '''
  }

  def dojoUncompressed_1_4 = {
      out << tmcpe.dojo_config()
      out << 
      '''
         <script type="text/javascript">
            var djConfig = { parseOnLoad: true, isDebug: true, debugAtAllCosts:true };
         </script>
         <script src="${resource(dir:'js/dojo-uncompressed/dojo',file:'dojo.js')}"></script>
      '''
  }
  
  def dojo_1_4_styles_google = {
      out << 
      '''
          <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dijit/themes/tundra/layout/BorderContainer.css" />
          <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojox/grid/resources/Grid.css" />
          <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojox/grid/resources/tundraGrid.css" />
          <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dijit/themes/tundra/tundra.css" />
          <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/resources/dojo.css" />
      '''
  }
  def dojoUncompressed_1_4_google = {
      out << tmcpe.dojo_config()
      out << 
      '''
         <script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojo/dojo.xd.js.uncompressed.js"></script>
         <script>
            dojo.config.dojoBlankHtmlUrl = "/blank.html";
         </script>
      '''
  }

  def dojo_1_4 = {
      out << tmcpe.dojo_config()
      out << 
      '''
         <link rel="stylesheet" href="${resource(dir:'js/dojo/dijit/themes/tundra/layout',file:'BorderContainer.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo/dojox/grid/resources',file:'Grid.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo/dojox/grid/resources',file:'tundraGrid.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo/dijit/themes/tundra',file:'tundra.css')}" />
         <link rel="stylesheet" href="${resource(dir:'js/dojo/dojo/resources',file:'dojo.css')}" />
      '''
  }
  def dojo_1_4_google = {
      out << tmcpe.dojo_config();
      out << 
      '''
         <script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojo/dojo.xd.js"></script>
         <script>
            dojo.config.dojoBlankHtmlUrl = "/blank.html";
         </script>
      '''
  }

  def openlayers_local = {
      out << 
      """
         <script src=\"${resource(dir:'js/openlayers/lib/',file:'OpenLayers.js')}\"></script>
      """
  }

  def openlayers_hosted = {
      out << '<script src="http://www.openlayers.org/api/OpenLayers.js"></script>\n'
  }

  def openlayers = {
      out << tmcpe.openlayers_local()
  }

  def init_g_map_api = {
      // dump google map api
      if ( grails.util.Environment.getCurrent() == grails.util.Environment.PRODUCTION ) {
         out << '<script src="http://maps.google.com/maps?file=api&amp;v=2&sensor=false&key=ABQIAAAAyBYmSWPVcV0YpoIbSHToHRR7e8w5iNj4_L2k9sczPbHcJZYRIhRedyRq4_pqB4yZdKrJiL7e0ipZQQ" type="text/javascript"></script>'
      } else {
         out << '<script src="http://maps.google.com/maps?file=api&amp;v=2&sensor=false&key=ABQIAAAAyBYmSWPVcV0YpoIbSHToHRQIRESITgsCs0G5rYyVKDmtJMTj6xRaMHwKfNdKW2Hzj0ZAuG7Fi8x48A" type="text/javascript"></script>'
      }
  }


  def tmcpe_styles = {
      out << "<link rel=\"stylesheet\" href=\"${resource( dir:'css',file:'tmcpe.css' )}\" />\n"
      out << tmcpe.dojo_1_4_styles_google()
  }

  def tmcpe = {
      out << tmcpe.dojo_1_4_google()
//      out << tmcpe.dojoUncompressed_1_4_google()
//      out << tmcpe.dojo_1_4()

  }

  def version = { out << "0.4.0 [${grails.util.Environment.getCurrent()}]" }
}
