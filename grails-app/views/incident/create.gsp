
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create Incident</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Incident List</g:link></span>
        </div>
        <div class="body">
            <h1>Create Incident</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${incidentInstance}">
            <div class="errors">
                <g:renderErrors bean="${incidentInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="cad">Cad:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'cad','errors')}">
                                    <input type="text" id="cad" name="cad" value="${fieldValue(bean:incidentInstance,field:'cad')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityDirection">Facility Direction:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'facilityDirection','errors')}">
                                    <input type="text" id="facilityDirection" name="facilityDirection" value="${fieldValue(bean:incidentInstance,field:'facilityDirection')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="facilityName">Facility Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'facilityName','errors')}">
                                    <input type="text" id="facilityName" name="facilityName" value="${fieldValue(bean:incidentInstance,field:'facilityName')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="location">Location:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'location','errors')}">
                                    <input type="text" id="location" name="location" value="${fieldValue(bean:incidentInstance,field:'location')}"/>                                    

                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><input class="save" type="submit" value="Create" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
