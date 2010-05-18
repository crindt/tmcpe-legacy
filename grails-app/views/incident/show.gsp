
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show Incident</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Incident List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Incident</g:link></span>
        </div>
        <div class="body">
            <h1>Show Incident</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Cad:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'cad')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Location:</td>
                            
                            <td valign="top" class="value"><a href="http://maps.google.com/?q=${incidentInstance?.locationGeom?.y},${incidentInstance?.locationGeom?.x}">${fieldValue(bean:incidentInstance, field:'locationGeom')}</a></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Start Time:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'startTime')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">First Call:</td>
                            
                            <td valign="top" class="value"><g:link controller="tmcLogEntry" action="show" id="${incidentInstance?.firstCall?.id}">${incidentInstance?.firstCall?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Sigalert End:</td>
                            
                            <td valign="top" class="value"><g:link controller="tmcLogEntry" action="show" id="${incidentInstance?.sigalertEnd?.id}">${incidentInstance?.sigalertEnd?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Sigalert Begin:</td>
                            
                            <td valign="top" class="value"><g:link controller="tmcLogEntry" action="show" id="${incidentInstance?.sigalertBegin?.id}">${incidentInstance?.sigalertBegin?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Section:</td>
                            
                            <td valign="top" class="value"><g:link controller="facilitySection" action="show" id="${incidentInstance?.section?.id}">${incidentInstance?.section?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Tmc Log Entries:</td>
                            <td valign="top" class="value">
			      <ul>
			      <g:each in="${incidentInstance.getTmcLogEntries()}" status="i" var="logEntry">
			         <li><g:link controller="tmcLogEntry" action="show" id="${logEntry.id}">${logEntry.toString()}</g:link></li>
			      </g:each>
			      </ul>
                            </td>
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${incidentInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
