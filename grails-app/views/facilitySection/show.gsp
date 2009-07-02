
<%@ page import="edu.uci.its.tmcpe.FacilitySection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show FacilitySection</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">FacilitySection List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New FacilitySection</g:link></span>
        </div>
        <div class="body">
            <h1>Show FacilitySection</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Abs Postmile:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'absPostmile')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">District:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'district')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Freeway Dir:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'freewayDir')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Freeway Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'freewayId')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Lanes:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'lanes')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Name:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'name')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Segment Length:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:facilitySectionInstance, field:'segmentLength')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${facilitySectionInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
