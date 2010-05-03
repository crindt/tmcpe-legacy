
<%@ page import="edu.uci.its.testbed.VdsData" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show VdsData</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">VdsData List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New VdsData</g:link></span>
        </div>
        <div class="body">
            <h1>Show VdsData</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'id')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Stamp:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'stamp')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Samplesall:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'samples_all')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Spdall:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'spd_all')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Pctobsall:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'pct_obs_all')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Cntall:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'cnt_all')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Occall:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'occ_all')}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Vdsid:</td>
                            
                            <td valign="top" class="value">${fieldValue(bean:vdsDataInstance, field:'vdsid')}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <input type="hidden" name="id" value="${vdsDataInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" value="Edit" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
