
<%@ page import="edu.uci.its.tmcpe.Vds" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show Vds</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Vds List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Vds</g:link></span>
        </div>
        <div class="body">
            <h1>Show Vds</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Abs Postmile:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'absPostmile')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Cal Postmile:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'calPostmile')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">District:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'district')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Freeway Dir:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'freewayDir')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Freeway Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'freewayId')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Geom:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'geom')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Lanes:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'lanes')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Last Modified:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'lastModified')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Name:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'name')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Type:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsInstance, field:'type')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${vdsInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
