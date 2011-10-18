import org.codehaus.groovy.grails.commons.ApplicationHolder

class TmcpeTagLib {
  static namespace = 'tmcpe'

  def timeSpaceDiagram = {
      out << '<script src="' << resource(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojo_config = {
      out << 
      """    
         <script type='text/javascript'>
            djConfig = {parseOnLoad: false,
                        isDebug:     true,
                        baseUrl:     '${resource( dir:'js',file:'tmcpe' )}/',
                        modulePaths: { my: '${resource( dir:'js/tmcpe',file:'' )}' },
                        debugAtAllCosts: true
                       };
         </script>
      """
  }

  def dojo_styles( uncompressed ) {
      def mod = ""
      if ( uncompressed ) mod = '-src';
      out << 
      """
         <link rel='stylesheet' href='${resource(dir:"js/dojo$mod/dijit/themes/tundra/layout",file:'BorderContainer.css')}' />
         <link rel='stylesheet' href='${resource(dir:"js/dojo$mod/dojox/grid/resources",file:'Grid.css')}' />
         <link rel='stylesheet' href='${resource(dir:"js/dojo$mod/dojox/grid/resources",file:'tundraGrid.css')}' />
         <link rel='stylesheet' href='${resource(dir:"js/dojo$mod/dijit/themes/tundra",file:'tundra.css')}' />
         <link rel='stylesheet' href='${resource(dir:"js/dojo$mod/dojo/resources",file:'dojo.css')}' />
      """
  }

  def dojo( uncompressed ) {
      def mod = ""
      if ( uncompressed ) mod = '-src';

      out << tmcpe.dojo_config()
      out << 
      """
         <script src='${resource(dir:"js/dojo$mod/dojo",file:'dojo.js')}'></script>
      """
  }
  
  def dojo_styles_google( version ) {
      out << 
      """ <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/$version/dijit/themes/tundra/layout/BorderContainer.css' />
          <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/$version/dojox/grid/resources/Grid.css' />
          <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/$version/dojox/grid/resources/tundraGrid.css' />
          <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/$version/dijit/themes/tundra/tundra.css' />
          <link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/dojo/$version/resources/dojo.css' />
      """
  }

  def dojo_google( version, uncompressed ) {
      def mod = ""
      if ( uncompressed ) mod = '.uncompressed.js'
      out << tmcpe.dojo_config()
      out << 
      """
         <script src='http://ajax.googleapis.com/ajax/libs/dojo/$version/dojo/dojo.xd.js$mod'></script>
         <script>
            dojo.config.dojoBlankHtmlUrl = '/blank.html';
         </script>
      """
  }

  def openlayers_local = {
      out << 
      """
         <script src='${resource(dir:'js/openlayers/lib/',file:'OpenLayers.js')}'></script>
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
      //out << "<link rel='stylesheet' href='${resource( dir:'css',file:'tmcpe.css' )}' />\n"
      //p.css( name: tmcpe );
      //out << "<link rel='stylesheet' href='${resource( dir:'js/openlayers/theme/default',file:'style.css' )}' />\n"
      //tmcpe.dojo_styles_google( '1.5' )
      //out << tmcpe.dojo_styles()
  }

  def tmcpe = {
      //tmcpe.dojo_google( '1.5', true )
      //out << tmcpe.dojo( true )

  }

  def dojo_version = { out << "1.5" }

  def version = { out << "[${ApplicationHolder.application.metadata['app.minorversion']} [${grails.util.Environment.getCurrent()}]" }
}
