
<%@ page import="edu.uci.its.tmcpe.FacilitySection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>FacilitySection List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New FacilitySection</g:link></span>
        </div>
        <div class="body">
            <h1>FacilitySection List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="absPostmile" title="Abs Postmile" />
                        
                   	        <g:sortableColumn property="district" title="District" />
                        
                   	        <g:sortableColumn property="freewayDir" title="Freeway Dir" />
                        
                   	        <g:sortableColumn property="freewayId" title="Freeway Id" />
                        
                   	        <g:sortableColumn property="lanes" title="Lanes" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${facilitySectionInstanceList}" status="i" var="facilitySectionInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${facilitySectionInstance.id}">${fieldValue(bean:facilitySectionInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:facilitySectionInstance, field:'absPostmile')}</td>
                        
                            <td>${fieldValue(bean:facilitySectionInstance, field:'district')}</td>
                        
                            <td>${fieldValue(bean:facilitySectionInstance, field:'freewayDir')}</td>
                        
                            <td>${fieldValue(bean:facilitySectionInstance, field:'freewayId')}</td>
                        
                            <td>${fieldValue(bean:facilitySectionInstance, field:'lanes')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${facilitySectionInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
