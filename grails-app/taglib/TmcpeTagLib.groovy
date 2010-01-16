class TmcpeTagLib {
  static namespace = 'tmcpe'

  def timeSpaceDiagram = {
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojoUncompressed_1_4 = {
      out << "    <script type=\"text/javascript\">var djConfig = {parseOnLoad: true,isDebug: true};</script>"
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js.uncompressed.js') << '"></script>'
  }
  def dojo_1_4 = {
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js') << '" djConfig="parseOnLoad: true,isDebug:true"></script>'
  }

  def openlayers = {
      out << '<script src="' << createLinkTo(dir:'js/OpenLayers-2.8/lib/',file:'OpenLayers.js') << '"></script>'
  }

  def tmcpe = {
      //out << tmcpe.dojoUncompressed_1_4()
      out << tmcpe.dojo_1_4()
      out << '<link rel="stylesheet" href="' << createLinkTo( dir:'css',file:'tmcpe.css' ) << '" />'
      out << '<script>dojo.registerModulePath("tmcpe","../../../tmcpe");</script>'
  }
}
