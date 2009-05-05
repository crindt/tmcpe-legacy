
<%@ page import="edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit IncidentFacilityImpactAnalysis</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">IncidentFacilityImpactAnalysis List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentFacilityImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>Edit IncidentFacilityImpactAnalysis</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${incidentFacilityImpactAnalysisInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentFacilityImpactAnalysisInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${incidentFacilityImpactAnalysisInstance?.id}" />
                <input type="hidden" name="version" value="${incidentFacilityImpactAnalysisInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="endSection">End Section:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'endSection','errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.FacilitySection.list()}" name="endSection.id" value="${incidentFacilityImpactAnalysisInstance?.endSection?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="endTime">End Time:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'endTime','errors')}">
                                    <g:datePicker name="endTime" value="${incidentFacilityImpactAnalysisInstance?.endTime}" ></g:datePicker>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityDirection">Facility Direction:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'facilityDirection','errors')}">
                                    <input type="text" id="facilityDirection" name="facilityDirection" value="${fieldValue(bean:incidentFacilityImpactAnalysisInstance,field:'facilityDirection')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityName">Facility Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'facilityName','errors')}">
                                    <input type="text" id="facilityName" name="facilityName" value="${fieldValue(bean:incidentFacilityImpactAnalysisInstance,field:'facilityName')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="incidentImpactAnalysis">Incident Impact Analysis:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'incidentImpactAnalysis','errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.IncidentImpactAnalysis.list()}" name="incidentImpactAnalysis.id" value="${incidentFacilityImpactAnalysisInstance?.incidentImpactAnalysis?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="startSection">Start Section:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'startSection','errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.FacilitySection.list()}" name="startSection.id" value="${incidentFacilityImpactAnalysisInstance?.startSection?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="startTime">Start Time:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentFacilityImpactAnalysisInstance,field:'startTime','errors')}">
                                    <g:datePicker name="startTime" value="${incidentFacilityImpactAnalysisInstance?.startTime}" ></g:datePicker>
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
