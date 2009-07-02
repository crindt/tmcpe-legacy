
<%@ page import="edu.uci.its.tmcpe.FacilitySection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit FacilitySection</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">FacilitySection List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New FacilitySection</g:link></span>
        </div>
        <div class="body">
            <h1>Edit FacilitySection</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${facilitySectionInstance}">
            <div class="errors">
                <g:renderErrors bean="${facilitySectionInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${facilitySectionInstance?.id}" />
                <input type="hidden" name="version" value="${facilitySectionInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="absPostmile">Abs Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'absPostmile','errors')}">
                                    <input type="text" id="absPostmile" name="absPostmile" value="${fieldValue(bean:facilitySectionInstance,field:'absPostmile')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="district">District:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'district','errors')}">
                                    <input type="text" id="district" name="district" value="${fieldValue(bean:facilitySectionInstance,field:'district')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="freewayDir">Freeway Dir:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'freewayDir','errors')}">
                                    <input type="text" id="freewayDir" name="freewayDir" value="${fieldValue(bean:facilitySectionInstance,field:'freewayDir')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="freewayId">Freeway Id:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'freewayId','errors')}">
                                    <input type="text" id="freewayId" name="freewayId" value="${fieldValue(bean:facilitySectionInstance,field:'freewayId')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="lanes">Lanes:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'lanes','errors')}">
                                    <input type="text" id="lanes" name="lanes" value="${fieldValue(bean:facilitySectionInstance,field:'lanes')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name">Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'name','errors')}">
                                    <input type="text" id="name" name="name" value="${fieldValue(bean:facilitySectionInstance,field:'name')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="segmentLength">Segment Length:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'segmentLength','errors')}">
                                    <input type="text" id="segmentLength" name="segmentLength" value="${fieldValue(bean:facilitySectionInstance,field:'segmentLength')}" />
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
