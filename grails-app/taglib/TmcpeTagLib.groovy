class TmcpeTagLib {
  static namespace = 'tmcpe'

  def testbedMap = {
//      out << '<script src="' << createLinkTo(dir:'js/openlayers/lib/',file:'OpenLayers.js') << '"></script>'
      out << '<link rel="stylesheet" href="' << createLinkTo( dir:'css',file:'tmcpe.css' ) << '" />'
      out << '<script src="' << createLinkTo(dir:'js/OpenLayers-2.8/lib/',file:'OpenLayers.js') << '"></script>'
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/tmcpe.js') << '"></script>'
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/TestbedMap.js') << '"></script>'
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/ItemVectorLayerReadStore.js') << '"></script>'
  }

  def timeSpaceDiagram = {
      out << '<script src="' << createLinkTo(dir:'js/tmcpe',file:'/TimeSpaceDiagram.js') << '"></script>'
  }

  def dojoUncompressed_1_4 = {
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js.uncompressed.js') << '"></script>'
  }
  def dojo_1_4 = {
      out << '<script src="' << createLinkTo(dir:'js/dojo/dojo-1.4/dojo',file:'dojo.js') << '" djConfig="parseOnLoad: true"></script>'
  }
}
