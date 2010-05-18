
<%@ page import="edu.uci.its.tmcpe.IncidentSectionData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show IncidentSectionData</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">IncidentSectionData List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New IncidentSectionData</g:link></span>
        </div>
        <div class="body">
            <h1>Show IncidentSectionData</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Occavg:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'occ_avg')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Volavg:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'vol_avg')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Pctobsavg:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'pct_obs_avg')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Section:</td>
                            
                            <td valign="top" class="value"><g:link controller="analyzedSection" action="show" id="${incidentSectionDataInstance?.section?.id}">${incidentSectionDataInstance?.section?.encodeAsHTML()}</g:link></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Tmcpedelay:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'tmcpe_delay')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">D12delay:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'d12_delay')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Vol:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'vol')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Spdavg:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'spd_avg')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Fivemin:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'fivemin')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Daysinavg:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'days_in_avg')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Spd:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'spd')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Incidentflag:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'incident_flag')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Pjm:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'p_j_m')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Occ:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'occ')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Spdstd:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:incidentSectionDataInstance, field:'spd_std')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${incidentSectionDataInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
