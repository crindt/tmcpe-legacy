
<%@ page import="edu.uci.its.testbed.VdsRawData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit VdsRawData</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">VdsRawData List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New VdsRawData</g:link></span>
        </div>
        <div class="body">
            <h1>Edit VdsRawData</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${vdsRawDataInstance}">
            <div class="errors">
                <g:renderErrors bean="${vdsRawDataInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${vdsRawDataInstance?.id}" />
                <input type="hidden" name="version" value="${vdsRawDataInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="fivemin">Fivemin:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsRawDataInstance,field:'fivemin','errors')}">
                                    <g:datePicker name="fivemin" value="${vdsRawDataInstance?.fivemin}" ></g:datePicker>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="intervals">Intervals:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsRawDataInstance,field:'intervals','errors')}">
                                    <input type="text" id="intervals" name="intervals" value="${fieldValue(bean:vdsRawDataInstance,field:'intervals')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="occ">Occ:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsRawDataInstance,field:'occ','errors')}">
                                    <input type="text" id="occ" name="occ" value="${fieldValue(bean:vdsRawDataInstance,field:'occ')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vdsid">Vdsid:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsRawDataInstance,field:'vdsid','errors')}">
                                    <input type="text" id="vdsid" name="vdsid" value="${fieldValue(bean:vdsRawDataInstance,field:'vdsid')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="volume">Volume:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsRawDataInstance,field:'volume','errors')}">
                                    <input type="text" id="volume" name="volume" value="${fieldValue(bean:vdsRawDataInstance,field:'volume')}" />
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
