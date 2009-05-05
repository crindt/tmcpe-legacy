
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
                            <td valign="top" class="name">Analyses:</td>
                            
                            <td  valign="top" style="text-align:left;" class="value">
                                <ul>
                                <g:each var="a" in="${incidentInstance.analyses}">
                                    <li><g:link controller="incidentImpactAnalysis" action="show" id="${a.id}">${a?.encodeAsHTML()}</g:link></li>
                                </g:each>
                                </ul>
                            </td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Facility Direction:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'facilityDirection')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Facility Name:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'facilityName')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Location:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'location')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Tmc Log Entries:</td>
                            
                            <td  valign="top" style="text-align:left;" class="value">
                                <ul>
                                <g:each var="t" in="${incidentInstance.tmcLogEntries}">
                                    <li><g:link controller="tmcLogEntry" action="show" id="${t.id}">${t?.encodeAsHTML()}</g:link></li>
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
