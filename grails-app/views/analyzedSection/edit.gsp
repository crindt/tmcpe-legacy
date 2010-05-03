
<%@ page import="edu.uci.its.tmcpe.AnalyzedSection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'analyzedSection.label', default: 'AnalyzedSection')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${analyzedSectionInstance}">
            <div class="errors">
                <g:renderErrors bean="${analyzedSectionInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${analyzedSectionInstance?.id}" />
                <g:hiddenField name="version" value="${analyzedSectionInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="analyzedTimestep"><g:message code="analyzedSection.analyzedTimestep.label" default="Analyzed Timestep" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: analyzedSectionInstance, field: 'analyzedTimestep', 'errors')}">
                                    
<ul>
<g:each var="a" in="${analyzedSectionInstance?.analyzedTimestep?}">
    <li><g:link controller="incidentSectionData" action="show" id="${a.id}">${a?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="incidentSectionData" params="['analyzedSection.id':analyzedSectionInstance?.id]" action="create">Add IncidentSectionData</g:link>

                                </td>
                            </tr>
                        
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
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
