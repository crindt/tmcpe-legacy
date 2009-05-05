class BootStrap {

     def init = { servletContext ->
         servletContext.setAttribute("newDataBinder", GlobalPropertyEditorConfig.&newDataBinder)
         servletContext.setAttribute("newBeanWrapper", GlobalPropertyEditorConfig.&newBeanWrapper)         
     }
     def destroy = {
     }
} 
