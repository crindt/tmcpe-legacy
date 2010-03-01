
<%@ page import="edu.uci.its.testbed.VdsRawData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show VdsRawData</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">VdsRawData List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New VdsRawData</g:link></span>
        </div>
        <div class="body">
            <h1>Show VdsRawData</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Fivemin:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'fivemin')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Intervals:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'intervals')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Occ:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'occ')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Vdsid:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'vdsid')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Volume:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsRawDataInstance, field:'volume')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${vdsRawDataInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
