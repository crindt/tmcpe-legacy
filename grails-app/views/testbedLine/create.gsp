
<%@ page import="edu.uci.its.tmcpe.TestbedLine" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create TestbedLine</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">TestbedLine List</g:link></span>
        </div>
        <div class="body">
            <h1>Create TestbedLine</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${testbedLineInstance}">
            <div class="errors">
                <g:renderErrors bean="${testbedLineInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="geom">Geom:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:testbedLineInstance,field:'geom','errors')}">
                                    <g:select optionKey="id" from="${org.postgis.Geometry.list()}" name="geom.id" value="${testbedLineInstance?.geom?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="kml">Kml:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:testbedLineInstance,field:'kml','errors')}">
                                    <input type="text" id="kml" name="kml" value="${fieldValue(bean:testbedLineInstance,field:'kml')}"/>
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
