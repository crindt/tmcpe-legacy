
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
                        
                   	        <th>Location</th>
                        
                   	        <g:sortableColumn property="startTime" title="Start Time" />
                        
                   	        <g:sortableColumn property="endTime" title="End Time" />
                        
                   	        <g:sortableColumn property="netDelay" title="Net Delay" />

                   	        <th>Analyzed Sections</th>
                   	    
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentFacilityImpactAnalysisInstanceList}" status="i" var="incidentFacilityImpactAnalysisInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentFacilityImpactAnalysisInstance.id}">${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'id')}</g:link></td>
                        
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'location')}</td>

                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'startTime')}</td>
                        
                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'endTime')}</td>

                            <td>${fieldValue(bean:incidentFacilityImpactAnalysisInstance, field:'netDelay')}</td>
                        
                            <td></td>
                        
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
