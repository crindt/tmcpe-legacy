
<%@ page import="edu.uci.its.tmcpe.FacilitySection" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit FacilitySection</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
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
                                    <label for="endPostmile">End Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'endPostmile','errors')}">
                                    <input type="text" id="endPostmile" name="endPostmile" value="${fieldValue(bean:facilitySectionInstance,field:'endPostmile')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityDirection">Facility Direction:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'facilityDirection','errors')}">
                                    <input type="text" id="facilityDirection" name="facilityDirection" value="${fieldValue(bean:facilitySectionInstance,field:'facilityDirection')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityName">Facility Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'facilityName','errors')}">
                                    <input type="text" id="facilityName" name="facilityName" value="${fieldValue(bean:facilitySectionInstance,field:'facilityName')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="startPostmile">Start Postmile:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'startPostmile','errors')}">
                                    <input type="text" id="startPostmile" name="startPostmile" value="${fieldValue(bean:facilitySectionInstance,field:'startPostmile')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vdsId">Vds Id:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:facilitySectionInstance,field:'vdsId','errors')}">
                                    <input type="text" id="vdsId" name="vdsId" value="${fieldValue(bean:facilitySectionInstance,field:'vdsId')}" />
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
