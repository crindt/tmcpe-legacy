
<%@ page import="edu.uci.its.testbed.VdsRawData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>VdsRawData List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New VdsRawData</g:link></span>
        </div>
        <div class="body">
            <h1>VdsRawData List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="fivemin" title="Fivemin" />
                        
                   	        <g:sortableColumn property="intervals" title="Intervals" />
                        
                   	        <g:sortableColumn property="occ" title="Occ" />
                        
                   	        <g:sortableColumn property="vdsid" title="Vdsid" />
                        
                   	        <g:sortableColumn property="volume" title="Volume" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${vdsRawDataInstanceList}" status="i" var="vdsRawDataInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${vdsRawDataInstance.id}">${fieldValue(bean:vdsRawDataInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:vdsRawDataInstance, field:'fivemin')}</td>
                        
                            <td>${fieldValue(bean:vdsRawDataInstance, field:'intervals')}</td>
                        
                            <td>${fieldValue(bean:vdsRawDataInstance, field:'occ')}</td>
                        
                            <td>${fieldValue(bean:vdsRawDataInstance, field:'vdsid')}</td>
                        
                            <td>${fieldValue(bean:vdsRawDataInstance, field:'volume')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">

            </div>
        </div>
    </body>
</html>
