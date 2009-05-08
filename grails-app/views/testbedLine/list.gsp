
<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>TestbedLine List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New TestbedLine</g:link></span>
        </div>
        <div class="body">
            <h1>TestbedLine List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <th>Geom</th>
                   	    
                   	        <g:sortableColumn property="kml" title="Kml" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${testbedLineInstanceList}" status="i" var="testbedLineInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${testbedLineInstance.id}">${fieldValue(bean:testbedLineInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:testbedLineInstance, field:'geom')}</td>
                        
                            <td>${fieldValue(bean:testbedLineInstance, field:'kml')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${testbedLineInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
