
<%@ page import="edu.uci.its.tmcpe.TmcLogEntry" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show TmcLogEntry</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">TmcLogEntry List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New TmcLogEntry</g:link></span>
        </div>
        <div class="body">
            <h1>Show TmcLogEntry</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Activitysubject:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'activitysubject')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Cad:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'cad')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Devicedirection:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'device_direction')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Deviceextra:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'device_extra')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Devicefwy:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'device_fwy')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Devicename:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'device_name')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Devicenumber:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'device_number')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Memo:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'memo')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Op:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'op')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Stampdate:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'stampdate')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Stamptime:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'stamptime')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Status:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'status')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Unitin:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'unitin')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Unitout:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'unitout')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Via:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:tmcLogEntryInstance, field:'via')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${tmcLogEntryInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
