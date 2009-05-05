
<%@ page import="edu.uci.its.tmcpe.Section" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Section List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Section</g:link></span>
        </div>
        <div class="body">
            <h1>Section List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="direction" title="Direction" />
                        
                   	        <g:sortableColumn property="endPostmile" title="End Postmile" />
                        
                   	        <g:sortableColumn property="facility" title="Facility" />
                        
                   	        <g:sortableColumn property="startPostmile" title="Start Postmile" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${sectionInstanceList}" status="i" var="sectionInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${sectionInstance.id}">${fieldValue(bean:sectionInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:sectionInstance, field:'direction')}</td>
                        
                            <td>${fieldValue(bean:sectionInstance, field:'endPostmile')}</td>
                        
                            <td>${fieldValue(bean:sectionInstance, field:'facility')}</td>
                        
                            <td>${fieldValue(bean:sectionInstance, field:'startPostmile')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${sectionInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
