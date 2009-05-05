
<%@ page import="edu.uci.its.tmcpe.Vds" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Vds</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Vds List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Vds</g:link></span>
        </div>
        <div class="body">
            <h1>Edit Vds</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${vdsInstance}">
            <div class="errors">
                <g:renderErrors bean="${vdsInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${vdsInstance?.id}" />
                <input type="hidden" name="version" value="${vdsInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="absPostmile">Abs Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'absPostmile','errors')}">
                                    <input type="text" id="absPostmile" name="absPostmile" value="${fieldValue(bean:vdsInstance,field:'absPostmile')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="calPostmile">Cal Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'calPostmile','errors')}">
                                    <input type="text" id="calPostmile" name="calPostmile" value="${fieldValue(bean:vdsInstance,field:'calPostmile')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="district">District:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'district','errors')}">
                                    <input type="text" id="district" name="district" value="${fieldValue(bean:vdsInstance,field:'district')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="freewayDir">Freeway Dir:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'freewayDir','errors')}">
                                    <input type="text" id="freewayDir" name="freewayDir" value="${fieldValue(bean:vdsInstance,field:'freewayDir')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="freewayId">Freeway Id:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'freewayId','errors')}">
                                    <input type="text" id="freewayId" name="freewayId" value="${fieldValue(bean:vdsInstance,field:'freewayId')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="geom">Geom:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'geom','errors')}">
                                    <input type="text" id="geom" name="geom" value="${fieldValue(bean:vdsInstance,field:'geom')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="lanes">Lanes:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'lanes','errors')}">
                                    <input type="text" id="lanes" name="lanes" value="${fieldValue(bean:vdsInstance,field:'lanes')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="lastModified">Last Modified:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'lastModified','errors')}">
                                    <g:datePicker name="lastModified" value="${vdsInstance?.lastModified}" ></g:datePicker>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name">Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'name','errors')}">
                                    <input type="text" id="name" name="name" value="${fieldValue(bean:vdsInstance,field:'name')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="type">Type:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'type','errors')}">
                                    <input type="text" id="type" name="type" value="${fieldValue(bean:vdsInstance,field:'type')}"/>
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
