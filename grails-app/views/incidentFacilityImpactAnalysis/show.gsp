
<%@ page import="edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show IncidentFacilityImpactAnalysis</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">IncidentFacilityImpactAnalysis List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentFacilityImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>Show IncidentFacilityImpactAnalysis</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Total Delay:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'totalDelay')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Start Time:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'startTime')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Location:</td>
                            
                            <td valign="top" class="value"><g:link controller="facilitySection" action="show" id="${incidentFacilityImpactAnalysisInstance?.location?.id}">${incidentFacilityImpactAnalysisInstance?.location?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">End Time:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'endTime')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Analyzed Sections:</td>
                            
                            <td  valign="top" style="text-align:left;" class="value">
                                <ul>
                                <g:each var="a" in="${incidentFacilityImpactAnalysisInstance.analyzedSections}">
                                    <li><g:link controller="analyzedSection" action="show" id="${a.id}">${a?.encodeAsHTML()}</g:link></li>
                                </g:each>
                                </ul>
                            </td>
                            
                        </tr>
                    
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${incidentFacilityImpactAnalysisInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
