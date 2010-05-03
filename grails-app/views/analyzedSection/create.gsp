
<%@ page import="edu.uci.its.tmcpe.AnalyzedSection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'analyzedSection.label', default: 'AnalyzedSection')}" />
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
            <g:hasErrors bean="${analyzedSectionInstance}">
            <div class="errors">
                <g:renderErrors bean="${analyzedSectionInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="analysis"><g:message code="analyzedSection.analysis.label" default="Analysis" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: analyzedSectionInstance, field: 'analysis', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis.list()}" name="analysis.id" value="${analyzedSectionInstance?.analysis?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="section"><g:message code="analyzedSection.section.label" default="Section" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: analyzedSectionInstance, field: 'section', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.FacilitySection.list()}" name="section.id" value="${analyzedSectionInstance?.section?.id}" ></g:select>
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
