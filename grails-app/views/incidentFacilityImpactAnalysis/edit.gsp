
<%@ page import="edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'incidentFacilityImpactAnalysis.label', default: 'IncidentFacilityImpactAnalysis')}" />
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
            <g:hasErrors bean="${incidentFacilityImpactAnalysisInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentFacilityImpactAnalysisInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${incidentFacilityImpactAnalysisInstance?.id}" />
                <g:hiddenField name="version" value="${incidentFacilityImpactAnalysisInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="totalDelay"><g:message code="incidentFacilityImpactAnalysis.totalDelay.label" default="Total Delay" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'totalDelay', 'errors')}">
                                    <input type="text" id="totalDelay" name="totalDelay" value="${fieldValue(bean:incidentFacilityImpactAnalysisInstance,field:'totalDelay')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="startTime"><g:message code="incidentFacilityImpactAnalysis.startTime.label" default="Start Time" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'startTime', 'errors')}">
                                    <g:datePicker name="startTime" value="${incidentFacilityImpactAnalysisInstance?.startTime}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="location"><g:message code="incidentFacilityImpactAnalysis.location.label" default="Location" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'location', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.FacilitySection.list()}" name="location.id" value="${incidentFacilityImpactAnalysisInstance?.location?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="endTime"><g:message code="incidentFacilityImpactAnalysis.endTime.label" default="End Time" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'endTime', 'errors')}">
                                    <g:datePicker name="endTime" value="${incidentFacilityImpactAnalysisInstance?.endTime}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="analyzedSections"><g:message code="incidentFacilityImpactAnalysis.analyzedSections.label" default="Analyzed Sections" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'analyzedSections', 'errors')}">
                                    
<ul>
<g:each var="a" in="${incidentFacilityImpactAnalysisInstance?.analyzedSections?}">
    <li><g:link controller="analyzedSection" action="show" id="${a.id}">${a?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="analyzedSection" params="['incidentFacilityImpactAnalysis.id':incidentFacilityImpactAnalysisInstance?.id]" action="create">Add AnalyzedSection</g:link>

                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="fileName"><g:message code="incidentFacilityImpactAnalysis.fileName.label" default="File Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'fileName', 'errors')}">
                                    <input type="text" name="fileName" id="fileName" value="${fieldValue(bean:incidentFacilityImpactAnalysisInstance,field:'fileName')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="incident"><g:message code="incidentFacilityImpactAnalysis.incident.label" default="Incident" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentFacilityImpactAnalysisInstance, field: 'incident', 'errors')}">
                                    
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
