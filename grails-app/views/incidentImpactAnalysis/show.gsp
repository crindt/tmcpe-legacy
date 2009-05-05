
<%@ page import="edu.uci.its.tmcpe.IncidentImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show IncidentImpactAnalysis</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">IncidentImpactAnalysis List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>Show IncidentImpactAnalysis</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentImpactAnalysisInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Analysis Name:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentImpactAnalysisInstance, field:'analysisName')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Incident Facility Impact Analyses:</td>
                            
                            <td  valign="top" style="text-align:left;" class="value">
                                <ul>
                                <g:each var="i" in="${incidentImpactAnalysisInstance.incidentFacilityImpactAnalyses}">
                                    <li><g:link controller="incidentFacilityImpactAnalysis" action="show" id="${i.id}">${i?.encodeAsHTML()}</g:link></li>
                                </g:each>
                                </ul>
                            </td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${incidentImpactAnalysisInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
