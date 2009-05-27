
<%@ page import="edu.uci.its.testbed.Route" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Route List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Route</g:link></span>
        </div>
        <div class="body">
            <h1>Route List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="direction" title="Direction" />
                        
                   	        <g:sortableColumn property="network" title="Network" />
                        
                   	        <g:sortableColumn property="number" title="Number" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${routeInstanceList}" status="i" var="routeInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${routeInstance.id}">${fieldValue(bean:routeInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:routeInstance, field:'direction')}</td>
                        
                            <td>${fieldValue(bean:routeInstance, field:'network')}</td>
                        
                            <td>${fieldValue(bean:routeInstance, field:'number')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${routeInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
