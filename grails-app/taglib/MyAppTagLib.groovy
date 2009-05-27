class MyAppTagLib {
  def redirectMainPage = {
    response.sendRedirect("${request.contextPath}/map/show.gsp")
  }
}
