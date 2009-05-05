
<%@ page import="edu.uci.its.tmcpe.IncidentImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit IncidentImpactAnalysis</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">IncidentImpactAnalysis List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>Edit IncidentImpactAnalysis</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${incidentImpactAnalysisInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentImpactAnalysisInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${incidentImpactAnalysisInstance?.id}" />
                <input type="hidden" name="version" value="${incidentImpactAnalysisInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="analysisName">Analysis Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentImpactAnalysisInstance,field:'analysisName','errors')}">
                                    <input type="text" id="analysisName" name="analysisName" value="${fieldValue(bean:incidentImpactAnalysisInstance,field:'analysisName')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="incidentFacilityImpactAnalyses">Incident Facility Impact Analyses:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentImpactAnalysisInstance,field:'incidentFacilityImpactAnalyses','errors')}">
                                    
<ul>
<g:each var="i" in="${incidentImpactAnalysisInstance?.incidentFacilityImpactAnalyses?}">
    <li><g:link controller="incidentFacilityImpactAnalysis" action="show" id="${i.id}">${i?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="incidentFacilityImpactAnalysis" params="['incidentImpactAnalysis.id':incidentImpactAnalysisInstance?.id]" action="create">Add IncidentFacilityImpactAnalysis</g:link>

                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
