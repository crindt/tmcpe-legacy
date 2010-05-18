
<%@ page import="edu.uci.its.tmcpe.TmcLogEntry" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'tmcLogEntry.label', default: 'TmcLogEntry')}" />
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
            <g:hasErrors bean="${tmcLogEntryInstance}">
            <div class="errors">
                <g:renderErrors bean="${tmcLogEntryInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_number"><g:message code="tmcLogEntry.device_number.label" default="Devicenumber" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'device_number', 'errors')}">
                                    <input type="text" id="device_number" name="device_number" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_number')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="unitin"><g:message code="tmcLogEntry.unitin.label" default="Unitin" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'unitin', 'errors')}">
                                    <input type="text" id="unitin" name="unitin" value="${fieldValue(bean:tmcLogEntryInstance,field:'unitin')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="stamp"><g:message code="tmcLogEntry.stamp.label" default="Stamp" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'stamp', 'errors')}">
                                    <g:datePicker name="stamp" value="${tmcLogEntryInstance?.stamp}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="via"><g:message code="tmcLogEntry.via.label" default="Via" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'via', 'errors')}">
                                    <input type="text" id="via" name="via" value="${fieldValue(bean:tmcLogEntryInstance,field:'via')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="memo"><g:message code="tmcLogEntry.memo.label" default="Memo" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'memo', 'errors')}">
                                    <input type="text" id="memo" name="memo" value="${fieldValue(bean:tmcLogEntryInstance,field:'memo')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="op"><g:message code="tmcLogEntry.op.label" default="Op" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'op', 'errors')}">
                                    <input type="text" id="op" name="op" value="${fieldValue(bean:tmcLogEntryInstance,field:'op')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="status"><g:message code="tmcLogEntry.status.label" default="Status" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'status', 'errors')}">
                                    <input type="text" id="status" name="status" value="${fieldValue(bean:tmcLogEntryInstance,field:'status')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_extra"><g:message code="tmcLogEntry.device_extra.label" default="Deviceextra" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'device_extra', 'errors')}">
                                    <input type="text" id="device_extra" name="device_extra" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_extra')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_direction"><g:message code="tmcLogEntry.device_direction.label" default="Devicedirection" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'device_direction', 'errors')}">
                                    
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_fwy"><g:message code="tmcLogEntry.device_fwy.label" default="Devicefwy" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'device_fwy', 'errors')}">
                                    <input type="text" id="device_fwy" name="device_fwy" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_fwy')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="cad"><g:message code="tmcLogEntry.cad.label" default="Cad" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'cad', 'errors')}">
                                    <input type="text" id="cad" name="cad" value="${fieldValue(bean:tmcLogEntryInstance,field:'cad')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_name"><g:message code="tmcLogEntry.device_name.label" default="Devicename" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'device_name', 'errors')}">
                                    <input type="text" id="device_name" name="device_name" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_name')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="pMeas"><g:message code="tmcLogEntry.pMeas.label" default="PM eas" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'pMeas', 'errors')}">
                                    <g:select optionKey="id" from="${edu.uci.its.tmcpe.TmcPerformanceMeasures.list()}" name="pMeas.id" value="${tmcLogEntryInstance?.pMeas?.id}" ></g:select>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="activitysubject"><g:message code="tmcLogEntry.activitysubject.label" default="Activitysubject" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'activitysubject', 'errors')}">
                                    <input type="text" id="activitysubject" name="activitysubject" value="${fieldValue(bean:tmcLogEntryInstance,field:'activitysubject')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="unitout"><g:message code="tmcLogEntry.unitout.label" default="Unitout" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'unitout', 'errors')}">
                                    <input type="text" id="unitout" name="unitout" value="${fieldValue(bean:tmcLogEntryInstance,field:'unitout')}"/>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="stampDateTime"><g:message code="tmcLogEntry.stampDateTime.label" default="Stamp Date Time" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: tmcLogEntryInstance, field: 'stampDateTime', 'errors')}">
                                    <g:datePicker name="stampDateTime" value="${tmcLogEntryInstance?.stampDateTime}"></g:datePicker>
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
