
<%@ page import="edu.uci.its.tmcpe.TmcLogEntry" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create TmcLogEntry</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">TmcLogEntry List</g:link></span>
        </div>
        <div class="body">
            <h1>Create TmcLogEntry</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${tmcLogEntryInstance}">
            <div class="errors">
                <g:renderErrors bean="${tmcLogEntryInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="activitysubject">Activitysubject:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'activitysubject','errors')}">
                                    <input type="text" id="activitysubject" name="activitysubject" value="${fieldValue(bean:tmcLogEntryInstance,field:'activitysubject')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="cad">Cad:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'cad','errors')}">
                                    <input type="text" id="cad" name="cad" value="${fieldValue(bean:tmcLogEntryInstance,field:'cad')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_direction">Devicedirection:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'device_direction','errors')}">
                                    
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_extra">Deviceextra:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'device_extra','errors')}">
                                    <input type="text" id="device_extra" name="device_extra" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_extra')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_fwy">Devicefwy:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'device_fwy','errors')}">
                                    <input type="text" id="device_fwy" name="device_fwy" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_fwy')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_name">Devicename:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'device_name','errors')}">
                                    <input type="text" id="device_name" name="device_name" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_name')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="device_number">Devicenumber:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'device_number','errors')}">
                                    <input type="text" id="device_number" name="device_number" value="${fieldValue(bean:tmcLogEntryInstance,field:'device_number')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="memo">Memo:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'memo','errors')}">
                                    <input type="text" id="memo" name="memo" value="${fieldValue(bean:tmcLogEntryInstance,field:'memo')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="op">Op:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'op','errors')}">
                                    <input type="text" id="op" name="op" value="${fieldValue(bean:tmcLogEntryInstance,field:'op')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="stampdate">Stampdate:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'stampdate','errors')}">
                                    <g:datePicker name="stampdate" value="${tmcLogEntryInstance?.stampdate}" ></g:datePicker>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="stamptime">Stamptime:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'stamptime','errors')}">
                                    <g:datePicker name="stamptime" value="${tmcLogEntryInstance?.stamptime}" ></g:datePicker>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="status">Status:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'status','errors')}">
                                    <input type="text" id="status" name="status" value="${fieldValue(bean:tmcLogEntryInstance,field:'status')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="unitin">Unitin:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'unitin','errors')}">
                                    <input type="text" id="unitin" name="unitin" value="${fieldValue(bean:tmcLogEntryInstance,field:'unitin')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="unitout">Unitout:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'unitout','errors')}">
                                    <input type="text" id="unitout" name="unitout" value="${fieldValue(bean:tmcLogEntryInstance,field:'unitout')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="via">Via:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:tmcLogEntryInstance,field:'via','errors')}">
                                    <input type="text" id="via" name="via" value="${fieldValue(bean:tmcLogEntryInstance,field:'via')}"/>
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
