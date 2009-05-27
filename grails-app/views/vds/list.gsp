
<%@ page import="edu.uci.its.testbed.Vds" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Vds List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Vds</g:link></span>
        </div>
        <div class="body">
            <h1>Vds List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="absPostmile" title="Abs Postmile" />
                        
                   	        <g:sortableColumn property="calPostmile" title="Cal Postmile" />
                        
                   	        <g:sortableColumn property="district" title="District" />
                        
                   	        <g:sortableColumn property="freeway" title="Freeway" />
                        
                   	        <g:sortableColumn property="freewayDir" title="Freeway Dir" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${vdsInstanceList}" status="i" var="vdsInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${vdsInstance.id}">${fieldValue(bean:vdsInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:vdsInstance, field:'absPostmile')}</td>
                        
                            <td>${fieldValue(bean:vdsInstance, field:'calPostmile')}</td>
                        
                            <td>${fieldValue(bean:vdsInstance, field:'district')}</td>
                        
                            <td>${fieldValue(bean:vdsInstance, field:'freeway')}</td>
                        
                            <td>${fieldValue(bean:vdsInstance, field:'freewayDir')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${vdsInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
