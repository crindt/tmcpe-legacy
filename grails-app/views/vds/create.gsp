
<%@ page import="edu.uci.its.testbed.Vds" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create Vds</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Vds List</g:link></span>
        </div>
        <div class="body">
            <h1>Create Vds</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${vdsInstance}">
            <div class="errors">
                <g:renderErrors bean="${vdsInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
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
                                    <label for="freeway">Freeway:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'freeway','errors')}">
                                    <input type="text" id="freeway" name="freeway" value="${fieldValue(bean:vdsInstance,field:'freeway')}" />
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
                                    <label for="geom">Geom:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'geom','errors')}">
                                    <g:select optionKey="id" from="${org.postgis.Geometry.list()}" name="geom.id" value="${vdsInstance?.geom?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="gid">Gid:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'gid','errors')}">
                                    <input type="text" id="gid" name="gid" value="${fieldValue(bean:vdsInstance,field:'gid')}" />
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
                                    <label for="name">Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'name','errors')}">
                                    <input type="text" id="name" name="name" value="${fieldValue(bean:vdsInstance,field:'name')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="relation">Relation:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'relation','errors')}">
                                    <input type="text" id="relation" name="relation" value="${fieldValue(bean:vdsInstance,field:'relation')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="segGeom">Seg Geom:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'segGeom','errors')}">
                                    <g:select optionKey="id" from="${org.postgis.Geometry.list()}" name="segGeom.id" value="${vdsInstance?.segGeom?.id}" ></g:select>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="segmentLength">Segment Length:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'segmentLength','errors')}">
                                    <input type="text" id="segmentLength" name="segmentLength" value="${fieldValue(bean:vdsInstance,field:'segmentLength')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="vdsType">Vds Type:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'vdsType','errors')}">
                                    <input type="text" id="vdsType" name="vdsType" value="${fieldValue(bean:vdsInstance,field:'vdsType')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="versionTs">Version Ts:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:vdsInstance,field:'versionTs','errors')}">
                                    <g:datePicker name="versionTs" value="${vdsInstance?.versionTs}" ></g:datePicker>
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
