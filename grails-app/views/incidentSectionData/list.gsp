
<%@ page import="edu.uci.its.tmcpe.IncidentSectionData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>IncidentSectionData List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentSectionData</g:link></span>
        </div>
        <div class="body">
            <h1>IncidentSectionData List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="occ_avg" title="Occavg" />
                        
                   	        <g:sortableColumn property="vol_avg" title="Volavg" />
                        
                   	        <g:sortableColumn property="pct_obs_avg" title="Pctobsavg" />
                        
                   	        <th>Section</th>
                   	    
                   	        <g:sortableColumn property="tmcpe_delay" title="Tmcpedelay" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentSectionDataInstanceList}" status="i" var="incidentSectionDataInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentSectionDataInstance.id}">${fieldValue(bean:incidentSectionDataInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:incidentSectionDataInstance, field:'occ_avg')}</td>
                        
                            <td>${fieldValue(bean:incidentSectionDataInstance, field:'vol_avg')}</td>
                        
                            <td>${fieldValue(bean:incidentSectionDataInstance, field:'pct_obs_avg')}</td>
                        
                            <td>${fieldValue(bean:incidentSectionDataInstance, field:'section')}</td>
                        
                            <td>${fieldValue(bean:incidentSectionDataInstance, field:'tmcpe_delay')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${incidentSectionDataInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
