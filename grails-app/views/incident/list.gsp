
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Incident List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Incident</g:link></span>
        </div>
        <div class="body">
            <h1>Incident List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="paginateButtons">
                <g:paginate params="${params}" total="${incidentInstanceTotal}" />
            </div>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="cad" title="Cad" />
                        
                   	        <g:sortableColumn property="startTime" title="Start Time" />
                   	    
			        <th>CAD Location</th>

			        <th>Section</th>

                   	        <th>Sigalert Begin</th>
                   	    
                   	        <th>Sigalert End</th>
                   	    
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentInstanceList}" status="i" var="incidentInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentInstance.id}">${fieldValue(bean:incidentInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:incidentInstance, field:'cad')}</td>
                        
                            <td>${fieldValue(bean:incidentInstance, field:'startTime')}</td>
                        
                            <td>${incidentInstance?.locationGeom}</td>

                            <td>${incidentInstance?.section}</td>

                            <td>${incidentInstance?.sigalertBegin?.stamp}</td>
                        
                            <td>${incidentInstance?.sigalertEnd?.stamp}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate params="${params}" total="${incidentInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
