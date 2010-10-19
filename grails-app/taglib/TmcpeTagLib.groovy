class TmcpeTagLib {
  static namespace = 'tmcpe'

  def timeSpaceDiagram = {
      out << '<script src="' << resource(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojo_config = {
      out << "    <script type=\"text/javascript\">\n"
      out << "       djConfig = {parseOnLoad: true,\n"
      out << "                   isDebug: true,\n"
//      out << '                   baseUrl: "./"' << resource( dir:'',file:'' ) << '",\n'
      out << '                   baseUrl: "' << resource( dir:'js',file:'tmcpe' ) << '/",\n'
      out << "                   modulePaths: { my: \"" << resource( dir:'js/tmcpe',file:'' ) << "\"}\n"
      out << "                  };\n"
      out << "    </script>\n"
  }

  def dojo_1_4_styles = {
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo-uncompressed/dijit/themes/tundra/layout',file:'BorderContainer.css') << '"/>' << "\n"
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo-uncompressed/dojox/grid/resources',file:'Grid.css') << '"/>' << "\n"
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo-uncompressed/dojox/grid/resources',file:'tundraGrid.css') << '"/>' << "\n"
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo-uncompressed/dijit/themes/tundra',file:'tundra.css') << '"/>' << "\n"
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo-uncompressed/dojo/resources',file:'dojo.css') << '" />' << "\n"
  }

  def dojoUncompressed_1_4 = {
      out << tmcpe.dojo_config();
      out << '    <script type="text/javascript">' << "\n"
      out << '       var djConfig = {parseOnLoad: true,isDebug: true,debugAtAllCosts:true};' << "\n"
      out << '    </script>' << "\n"
      out << '<script src="' << resource(dir:'js/dojo-uncompressed/dojo',file:'dojo.js') << '"></script>' << "\n"
  }

  def dojo_1_4_styles_google = {
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dijit/themes/tundra/layout/BorderContainer.css" />\n'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojox/grid/resources/Grid.css" />\n'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojox/grid/resources/tundraGrid.css" />\n'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dijit/themes/tundra/tundra.css" />\n'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/resources/dojo.css" />\n'
  }
  def dojoUncompressed_1_4_google = {
      out << tmcpe.dojo_config();
      out << '<script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojo/dojo.xd.js.uncompressed.js"></script>\n'
      out << '<script>\n'
      out << "    dojo.config.dojoBlankHtmlUrl = '/blank.html';\n"
      out << '</script>\n'

      
  }

  def dojo_1_4 = {
      out << tmcpe.dojo_config()
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo/dijit/themes/tundra/layout',file:'BorderContainer.css') << '"/>\n'
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo/dojox/grid/resources',file:'Grid.css') << '"/>\n'
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo/dojox/grid/resources',file:'tundraGrid.css') << '"/>\n'
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo/dijit/themes/tundra',file:'tundra.css') << '"/>\n'
      out << '<link rel="stylesheet" href="'<< resource(dir:'js/dojo/dojo/resources',file:'dojo.css') << '" />\n'
  }
  def dojo_1_4_google = {
      out << tmcpe.dojo_config();
      out << '<script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.3/dojo/dojo.xd.js"></script>\n'
      out << '<script>\n'
      out << "    dojo.config.dojoBlankHtmlUrl = '/blank.html';\n"
      out << '</script>\n'
  }

  def openlayers = {
      out << '<script src="' << resource(dir:'js/openlayers/lib/',file:'OpenLayers.js') << '"></script>'
      out << '<script src="' << resource(dir:'js/tmcpe/',file:'BBOXHandler.js') << '"></script>'

      if ( grails.util.Environment.getCurrent() == grails.util.Environment.PRODUCTION ) {
         out << '<script src="http://maps.google.com/maps?file=api&amp;v=2&sensor=false&key=ABQIAAAAyBYmSWPVcV0YpoIbSHToHRR7e8w5iNj4_L2k9sczPbHcJZYRIhRedyRq4_pqB4yZdKrJiL7e0ipZQQ" type="text/javascript"></script>'
      } else {
         out << '<script src="http://maps.google.com/maps?file=api&amp;v=2&sensor=false&key=ABQIAAAAyBYmSWPVcV0YpoIbSHToHRQIRESITgsCs0G5rYyVKDmtJMTj6xRaMHwKfNdKW2Hzj0ZAuG7Fi8x48A" type="text/javascript"></script>'
      }
  }

  def openlayers_latest = {
      out << '<script src="http://www.openlayers.org/api/OpenLayers.js"></script>\n'
  }

  def tmcpe_styles = {
      out << '<link rel="stylesheet" href="' << resource( dir:'css',file:'tmcpe.css' ) << '" />\n'
      out << tmcpe.dojo_1_4_styles_google()
  }

  def tmcpe = {
      out << tmcpe.dojo_1_4_google()
//      out << tmcpe.dojoUncompressed_1_4_google()
//      out << tmcpe.dojo_1_4()

  }

  def version = { out << '0.4.0' << ' [' << grails.util.Environment.getCurrent() << ']' }
}
