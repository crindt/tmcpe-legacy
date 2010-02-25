class TmcpeTagLib {
  static namespace = 'tmcpe'

  def timeSpaceDiagram = {
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojoUncompressed_1_4 = {
      out << "    <script type=\"text/javascript\">var djConfig = {parseOnLoad: true,isDebug: true};</script>"
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js.uncompressed.js') << '"></script>'
  }
  def dojoUncompressed_1_4_google = {
      out << '    <script type="text/javascript">var djConfig = {parseOnLoad: true,isDebug: true,baseUrl:"./",modulePaths:{my:"js/tmcpe"}};</script>'
      out << '<script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojo/dojo.xd.js.uncompressed.js"></script>'
  }
  def dojo_1_4 = {
      out << "    <script type=\"text/javascript\">var djConfig = {parseOnLoad: true,isDebug: true};</script>"
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js') << '" djConfig="parseOnLoad: true,isDebug:true"></script>'
  }
  def dojo_1_4_google = {
      out << "    <script type=\"text/javascript\">var djConfig = {parseOnLoad: true,isDebug: true};</script>"
      out << '<script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojo/dojo.xd.js" djConfig="parseOnLoad: true,isDebug:true"></script>'
      
  }

  def openlayers = {
      out << '<script src="' << createLinkTo(dir:'js/OpenLayers-2.8/lib/',file:'OpenLayers.js') << '"></script>'
  }

  def openlayers_latest = {
      out << '<script src="http://www.openlayers.org/api/OpenLayers.js"></script>'
  }

  def tmcpe = {
      out << tmcpe.dojoUncompressed_1_4_google()
      //out << tmcpe.dojo_1_4()
      out << '<link rel="stylesheet" href="' << createLinkTo( dir:'css',file:'tmcpe.css' ) << '" />'

      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dijit/themes/tundra/layout/BorderContainer.css"/>'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojox/grid/resources/Grid.css"/>'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojox/grid/resources/tundraGrid.css"/>'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dijit/themes/tundra/tundra.css"/>'
      out << '<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/resources/dojo.css" />'

      out << '<script>dojo.registerModulePath("tmcpe","js/tmcpe");</script>'
  }
}
