
<%@ page import="edu.uci.its.testbed.VdsData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>VdsData List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New VdsData</g:link></span>
        </div>
        <div class="body">
            <h1>VdsData List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id and Stamp" />
                        
                   	        <g:sortableColumn property="samples_all" title="Samplesall" />
                        
                   	        <g:sortableColumn property="spd_all" title="Spdall" />
                        
                   	        <g:sortableColumn property="pct_obs_all" title="Pctobsall" />
                        
                   	        <g:sortableColumn property="cnt_all" title="Cntall" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${vdsDataInstanceList}" status="i" var="vdsDataInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" params="${vdsDataInstance.getPK()}">${fieldValue(bean:vdsDataInstance, field:'vdsid')} @ ${fieldValue(bean:vdsDataInstance, field:'stamp')}</g:link></td>
                        
                            <td>${fieldValue(bean:vdsDataInstance, field:'samples_all')}</td>
                        
                            <td>${fieldValue(bean:vdsDataInstance, field:'spd_all')}</td>
                        
                            <td>${fieldValue(bean:vdsDataInstance, field:'pct_obs_all')}</td>
                        
                            <td>${fieldValue(bean:vdsDataInstance, field:'cnt_all')}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${vdsDataInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
