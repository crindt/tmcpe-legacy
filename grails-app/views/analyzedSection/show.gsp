
<%@ page import="edu.uci.its.tmcpe.AnalyzedSection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show AnalyzedSection</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">AnalyzedSection List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New AnalyzedSection</g:link></span>
        </div>
        <div class="body">
            <h1>Show AnalyzedSection</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:analyzedSectionInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Analyzed Timestep:</td>
                            
                            <td  valign="top" style="text-align:left;" class="value">
                                <ul>
                                <g:each var="a" in="${analyzedSectionInstance.analyzedTimestep}">
                                    <li><g:link controller="incidentSectionData" action="show" id="${a.id}">${a?.encodeAsHTML()}</g:link></li>
                                </g:each>
                                </ul>
                            </td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Analysis:</td>
                            
                            <td valign="top" class="value"><g:link controller="incidentFacilityImpactAnalysis" action="show" id="${analyzedSectionInstance?.analysis?.id}">${analyzedSectionInstance?.analysis?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Section:</td>
                            
                            <td valign="top" class="value"><g:link controller="facilitySection" action="show" id="${analyzedSectionInstance?.section?.id}">${analyzedSectionInstance?.section?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${analyzedSectionInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
