
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'incident.label', default: 'Incident')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.create.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${incidentInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="cad"><g:message code="incident.cad.label" default="Cad" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'cad', 'errors')}">
                                    <input type="text" id="cad" name="cad" value="${fieldValue(bean:incidentInstance,field:'cad')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="startTime"><g:message code="incident.startTime.label" default="Start Time" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'startTime', 'errors')}">
                                    <g:datePicker name="startTime" value="${incidentInstance?.startTime}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="firstCall"><g:message code="incident.firstCall.label" default="First Call" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'firstCall', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.TmcLogEntry.list()}" name="firstCall.id" value="${incidentInstance?.firstCall?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="sigalertEnd"><g:message code="incident.sigalertEnd.label" default="Sigalert End" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'sigalertEnd', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.TmcLogEntry.list()}" name="sigalertEnd.id" value="${incidentInstance?.sigalertEnd?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="sigalertBegin"><g:message code="incident.sigalertBegin.label" default="Sigalert Begin" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'sigalertBegin', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.TmcLogEntry.list()}" name="sigalertBegin.id" value="${incidentInstance?.sigalertBegin?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="section"><g:message code="incident.section.label" default="Section" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'section', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.FacilitySection.list()}" name="section.id" value="${incidentInstance?.section?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="stampDateTime"><g:message code="incident.stampDateTime.label" default="Stamp Date Time" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentInstance, field: 'stampDateTime', 'errors')}">
                                    
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:submitButton name="create" class="save" value="${message(code: 'default.button.create.label', default: 'Create')}" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
