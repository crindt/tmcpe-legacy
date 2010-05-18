
<%@ page import="edu.uci.its.tmcpe.TmcLogEntry" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>TmcLogEntry List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New TmcLogEntry</g:link></span>
        </div>
        <div class="body">
            <h1>TmcLogEntry List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="device_number" title="Devicenumber" />
                        
                   	        <g:sortableColumn property="unitin" title="Unitin" />
                        
                   	        <g:sortableColumn property="stamp" title="Stamp" />
                        
                   	        <g:sortableColumn property="via" title="Via" />
                        
                   	        <g:sortableColumn property="memo" title="Memo" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${tmcLogEntryInstanceList}" status="i" var="tmcLogEntryInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${tmcLogEntryInstance.id}">${fieldValue(bean:tmcLogEntryInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'device_number')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'unitin')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'stamp')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'via')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'memo')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${tmcLogEntryInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
