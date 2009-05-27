
<%@ page import="edu.uci.its.testbed.Route" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Route</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Route List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Route</g:link></span>
        </div>
        <div class="body">
            <h1>Edit Route</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${routeInstance}">
            <div class="errors">
                <g:renderErrors bean="${routeInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${routeInstance?.id}" />
                <input type="hidden" name="version" value="${routeInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="direction">Direction:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:routeInstance,field:'direction','errors')}">
                                    <input type="text" id="direction" name="direction" value="${fieldValue(bean:routeInstance,field:'direction')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="network">Network:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:routeInstance,field:'network','errors')}">
                                    <input type="text" id="network" name="network" value="${fieldValue(bean:routeInstance,field:'network')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="number">Number:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:routeInstance,field:'number','errors')}">
                                    <input type="text" id="number" name="number" value="${fieldValue(bean:routeInstance,field:'number')}" />
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
