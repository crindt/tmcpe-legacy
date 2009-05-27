
<%@ page import="edu.uci.its.testbed.Route" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show Route</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Route List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Route</g:link></span>
        </div>
        <div class="body">
            <h1>Show Route</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:routeInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Direction:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:routeInstance, field:'direction')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Network:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:routeInstance, field:'network')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Number:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:routeInstance, field:'number')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${routeInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
