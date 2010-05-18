
<%@ page import="edu.uci.its.tmcpe.IncidentSectionData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'incidentSectionData.label', default: 'IncidentSectionData')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.create.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${incidentSectionDataInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentSectionDataInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="occ_avg"><g:message code="incidentSectionData.occ_avg.label" default="Occavg" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'occ_avg', 'errors')}">
                                    <input type="text" id="occ_avg" name="occ_avg" value="${fieldValue(bean:incidentSectionDataInstance,field:'occ_avg')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vol_avg"><g:message code="incidentSectionData.vol_avg.label" default="Volavg" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'vol_avg', 'errors')}">
                                    <input type="text" id="vol_avg" name="vol_avg" value="${fieldValue(bean:incidentSectionDataInstance,field:'vol_avg')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="pct_obs_avg"><g:message code="incidentSectionData.pct_obs_avg.label" default="Pctobsavg" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'pct_obs_avg', 'errors')}">
                                    <input type="text" id="pct_obs_avg" name="pct_obs_avg" value="${fieldValue(bean:incidentSectionDataInstance,field:'pct_obs_avg')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="section"><g:message code="incidentSectionData.section.label" default="Section" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'section', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.AnalyzedSection.list()}" name="section.id" value="${incidentSectionDataInstance?.section?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="tmcpe_delay"><g:message code="incidentSectionData.tmcpe_delay.label" default="Tmcpedelay" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'tmcpe_delay', 'errors')}">
                                    <input type="text" id="tmcpe_delay" name="tmcpe_delay" value="${fieldValue(bean:incidentSectionDataInstance,field:'tmcpe_delay')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="d12_delay"><g:message code="incidentSectionData.d12_delay.label" default="D12delay" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'd12_delay', 'errors')}">
                                    <input type="text" id="d12_delay" name="d12_delay" value="${fieldValue(bean:incidentSectionDataInstance,field:'d12_delay')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vol"><g:message code="incidentSectionData.vol.label" default="Vol" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'vol', 'errors')}">
                                    <input type="text" id="vol" name="vol" value="${fieldValue(bean:incidentSectionDataInstance,field:'vol')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="spd_avg"><g:message code="incidentSectionData.spd_avg.label" default="Spdavg" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'spd_avg', 'errors')}">
                                    <input type="text" id="spd_avg" name="spd_avg" value="${fieldValue(bean:incidentSectionDataInstance,field:'spd_avg')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="fivemin"><g:message code="incidentSectionData.fivemin.label" default="Fivemin" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'fivemin', 'errors')}">
                                    <g:datePicker name="fivemin" value="${incidentSectionDataInstance?.fivemin}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="days_in_avg"><g:message code="incidentSectionData.days_in_avg.label" default="Daysinavg" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'days_in_avg', 'errors')}">
                                    <input type="text" id="days_in_avg" name="days_in_avg" value="${fieldValue(bean:incidentSectionDataInstance,field:'days_in_avg')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="spd"><g:message code="incidentSectionData.spd.label" default="Spd" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'spd', 'errors')}">
                                    <input type="text" id="spd" name="spd" value="${fieldValue(bean:incidentSectionDataInstance,field:'spd')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="incident_flag"><g:message code="incidentSectionData.incident_flag.label" default="Incidentflag" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'incident_flag', 'errors')}">
                                    <input type="text" id="incident_flag" name="incident_flag" value="${fieldValue(bean:incidentSectionDataInstance,field:'incident_flag')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="p_j_m"><g:message code="incidentSectionData.p_j_m.label" default="Pjm" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'p_j_m', 'errors')}">
                                    <input type="text" id="p_j_m" name="p_j_m" value="${fieldValue(bean:incidentSectionDataInstance,field:'p_j_m')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="occ"><g:message code="incidentSectionData.occ.label" default="Occ" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'occ', 'errors')}">
                                    <input type="text" id="occ" name="occ" value="${fieldValue(bean:incidentSectionDataInstance,field:'occ')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="spd_std"><g:message code="incidentSectionData.spd_std.label" default="Spdstd" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: incidentSectionDataInstance, field: 'spd_std', 'errors')}">
                                    <input type="text" id="spd_std" name="spd_std" value="${fieldValue(bean:incidentSectionDataInstance,field:'spd_std')}" />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:submitButton name="create" class="save" value="${message(code: 'default.button.create.label', default: 'Create')}" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
