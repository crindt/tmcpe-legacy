
<%@ page import="edu.uci.its.tmcpe.Section" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Section</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Section List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Section</g:link></span>
        </div>
        <div class="body">
            <h1>Edit Section</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${sectionInstance}">
            <div class="errors">
                <g:renderErrors bean="${sectionInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${sectionInstance?.id}" />
                <input type="hidden" name="version" value="${sectionInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="direction">Direction:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:sectionInstance,field:'direction','errors')}">
                                    <input type="text" id="direction" name="direction" value="${fieldValue(bean:sectionInstance,field:'direction')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="endPostmile">End Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:sectionInstance,field:'endPostmile','errors')}">
                                    <input type="text" id="endPostmile" name="endPostmile" value="${fieldValue(bean:sectionInstance,field:'endPostmile')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facility">Facility:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:sectionInstance,field:'facility','errors')}">
                                    <input type="text" id="facility" name="facility" value="${fieldValue(bean:sectionInstance,field:'facility')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="startPostmile">Start Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:sectionInstance,field:'startPostmile','errors')}">
                                    <input type="text" id="startPostmile" name="startPostmile" value="${fieldValue(bean:sectionInstance,field:'startPostmile')}" />
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
