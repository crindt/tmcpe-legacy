
<%@ page import="edu.uci.its.tmcpe.IncidentImpactAnalysis" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>IncidentImpactAnalysis List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentImpactAnalysis</g:link></span>
        </div>
        <div class="body">
            <h1>IncidentImpactAnalysis List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="analysisName" title="Analysis Name" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentImpactAnalysisInstanceList}" status="i" var="incidentImpactAnalysisInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentImpactAnalysisInstance.id}">${fieldValue(bean:incidentImpactAnalysisInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:incidentImpactAnalysisInstance, field:'analysisName')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${incidentImpactAnalysisInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
