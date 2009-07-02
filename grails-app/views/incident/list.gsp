
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Incident List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Incident</g:link></span>
        </div>
        <div class="body">
            <h1>Incident List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <th>Timestamp</th>
<!--
                   	        <th>Location</th>
-->
                   	    
                   	        <g:sortableColumn property="vdsId" title="Vds Id" />
                   	        <th> section </th>
				<th> Memo </th>
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${incidentInstanceList}" status="i" var="incidentInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${incidentInstance.id}">${fieldValue(bean:incidentInstance, field:'id')}</g:link></td>
                        
			    <td>${
			    new java.util.Date(incidentInstance.stampDate.getTime() + incidentInstance.stampTime.getTime()).toString()
			    }</td>
<!--
                            <td>${fieldValue(bean:incidentInstance, field:'location')}</td>
-->
                        
                            <td>${incidentInstance.section.id}</td>
			    <td>${incidentInstance.section.toString()}</td>
                            <td>${fieldValue(bean:incidentInstance, field:'memo')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${incidentInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
