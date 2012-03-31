package edu.uci.its.tmcpe

import grails.plugin.spock.*
import org.springframework.security.access.*

class IncidentControllerIntegrationSpec extends ControllerSpec {
  
  static transactional = true

  def "access denied for anonymous user"() {
  when:
    SpringSecurityUtils.doWithAuth('ROLE_ANONYMOUS') {
      controller.list()
    }

  then:
    thrown(AccessDeniedException)
  }
}
