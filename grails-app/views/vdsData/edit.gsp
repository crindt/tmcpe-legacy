
<%@ page import="edu.uci.its.testbed.VdsData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'vdsData.label', default: 'VdsData')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${vdsDataInstance}">
            <div class="errors">
                <g:renderErrors bean="${vdsDataInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${vdsDataInstance?.id}" />
                <g:hiddenField name="version" value="${vdsDataInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="stamp"><g:message code="vdsData.stamp.label" default="Stamp" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'stamp', 'errors')}">
                                    <g:datePicker name="stamp" value="${vdsDataInstance?.stamp}" ></g:datePicker>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="samples_all"><g:message code="vdsData.samples_all.label" default="Samplesall" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'samples_all', 'errors')}">
                                    <input type="text" id="samples_all" name="samples_all" value="${fieldValue(bean:vdsDataInstance,field:'samples_all')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="spd_all"><g:message code="vdsData.spd_all.label" default="Spdall" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'spd_all', 'errors')}">
                                    <input type="text" id="spd_all" name="spd_all" value="${fieldValue(bean:vdsDataInstance,field:'spd_all')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="pct_obs_all"><g:message code="vdsData.pct_obs_all.label" default="Pctobsall" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'pct_obs_all', 'errors')}">
                                    <input type="text" id="pct_obs_all" name="pct_obs_all" value="${fieldValue(bean:vdsDataInstance,field:'pct_obs_all')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="cnt_all"><g:message code="vdsData.cnt_all.label" default="Cntall" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'cnt_all', 'errors')}">
                                    <input type="text" id="cnt_all" name="cnt_all" value="${fieldValue(bean:vdsDataInstance,field:'cnt_all')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="occ_all"><g:message code="vdsData.occ_all.label" default="Occall" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'occ_all', 'errors')}">
                                    <input type="text" id="occ_all" name="occ_all" value="${fieldValue(bean:vdsDataInstance,field:'occ_all')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="vdsid"><g:message code="vdsData.vdsid.label" default="Vdsid" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: vdsDataInstance, field: 'vdsid', 'errors')}">
                                    <input type="text" id="vdsid" name="vdsid" value="${fieldValue(bean:vdsDataInstance,field:'vdsid')}" />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
