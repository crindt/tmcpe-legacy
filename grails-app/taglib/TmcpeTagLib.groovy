class TmcpeTagLib {
  static namespace = 'tmcpe'

  def testbedMap = {
      out << '<script src="' << createLinkTo(dir:'js/openlayers/lib/',file:'OpenLayers.js') << '"></script>'
  }
}
