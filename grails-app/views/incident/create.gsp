
<%@ page import="edu.uci.its.tmcpe.Incident" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create Incident</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${resource(dir:'')}">Home</a></span>
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
                                    <label for="location">Location:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'location','errors')}">
                                    <g:select optionKey="id" from="${org.postgis.Geometry.list()}" name="location.id" value="${incidentInstance?.location?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vdsId">Vds Id:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'vdsId','errors')}">
                                    <input type="text" id="vdsId" name="vdsId" value="${fieldValue(bean:incidentInstance,field:'vdsId')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="afterLoad">After Load:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:incidentInstance,field:'afterLoad','errors')}">
                                    
                                </td>
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
