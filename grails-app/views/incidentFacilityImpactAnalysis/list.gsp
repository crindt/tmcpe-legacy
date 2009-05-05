
<%@ page import="edu.uci.its.tmcpe.IncidentFacilityImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>IncidentFacilityImpactAnalysis List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentFacilityImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>IncidentFacilityImpactAnalysis List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <th>End Section</th>
                   	    
                   	        <g:sortableColumn property="endTime" title="End Time" />
                        
                   	        <g:sortableColumn property="facilityDirection" title="Facility Direction" />
                        
                   	        <g:sortableColumn property="facilityName" title="Facility Name" />
                        
                   	        <th>Incident Impact Analysis</th>
                   	    
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentFacilityImpactAnalysisInstanceList}" status="i" var="incidentFacilityImpactAnalysisInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentFacilityImpactAnalysisInstance.id}">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'endSection')}</td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'endTime')}</td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'facilityDirection')}</td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'facilityName')}</td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'incidentImpactAnalysis')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${incidentFacilityImpactAnalysisInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
