
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show Incident</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
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
                            <td valign="top" class="name">Section:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentInstance, field:'section')}</td>
                            
                        </tr>
			<tr class="prop">
			  <td valign="top" class="name">CAD Duration:</td>
			  <td valign="top" class="value">${incidentInstance.cadDurationString()}</td>
			</tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Tmc Log Entries:</td>			    
                            
                            <td valign="top" class="value">
			      <ul>
				<g:each in="${incidentInstance.getTmcLogEntries()}" status="l" var="logEntry">
				  <li>${logEntry.stamptime} : ${logEntry.activitysubject} : ${logEntry.memo}</li>
				</g:each>
			      </ul>
			    </td>
                        </tr>

                        <tr class="prop">
                            <td valign="top" class="name">Incident Analyses: 
			      (<g:link class="analyze" action="analyze" id="${incidentInstance.id}">Reanalyze</g:link>)
			    </td>			    
                            
                            <td valign="top" class="value">
			      <ul>
				<g:each in="${incidentInstance.analyses}" status="l" var="analysis">
				  <li><g:link controller="incidentImpactAnalysis" action="show" id="${analysis.id}">${analysis.analysisName}</g:link></li>
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
