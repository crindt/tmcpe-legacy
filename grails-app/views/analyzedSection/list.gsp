
<%@ page import="edu.uci.its.tmcpe.AnalyzedSection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>AnalyzedSection List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New AnalyzedSection</g:link></span>
        </div>
        <div class="body">
            <h1>AnalyzedSection List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <th>Analyzed Timestep</th>
                   	    
                   	        <th>Analysis</th>
                   	    
                   	        <th>Section</th>
                   	    
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${analyzedSectionInstanceList}" status="i" var="analyzedSectionInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${analyzedSectionInstance.id}">${fieldValue(bean:analyzedSectionInstance, field:'id')}</g:link></td>
                        
                            <td>${fieldValue(bean:analyzedSectionInstance, field:'analyzedTimestep')}</td>
                        
                            <td>${fieldValue(bean:analyzedSectionInstance, field:'analysis')}</td>
                        
                            <td>${fieldValue(bean:analyzedSectionInstance, field:'section')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${analyzedSectionInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
