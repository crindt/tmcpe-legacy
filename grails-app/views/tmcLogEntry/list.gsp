
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
                        
                   	        <g:sortableColumn property="activitysubject" title="Activitysubject" />
                        
                   	        <g:sortableColumn property="cad" title="Cad" />
                        
                   	        <g:sortableColumn property="device_direction" title="Devicedirection" />
                        
                   	        <g:sortableColumn property="device_extra" title="Deviceextra" />
                        
                   	        <g:sortableColumn property="device_fwy" title="Devicefwy" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${tmcLogEntryInstanceList}" status="i" var="tmcLogEntryInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${tmcLogEntryInstance.id}">${fieldValue(bean:tmcLogEntryInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'activitysubject')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'cad')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'device_direction')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'device_extra')}</td>
                        
                            <td>${fieldValue(bean:tmcLogEntryInstance, field:'device_fwy')}</td>
                        
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
