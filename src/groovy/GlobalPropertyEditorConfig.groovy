import org.springframework.beans.BeanWrapperImpl
import org.springframework.beans.propertyeditors.CustomNumberEditor
import org.codehaus.groovy.grails.web.binding.GrailsDataBinder
import org.postgis.Geometry
import org.apache.log4j.*

class GlobalPropertyEditorConfig { 
    static newDataBinder = { request, object -> 
        def binder = GrailsDataBinder.createBinder(object, GrailsDataBinder.DEFAULT_OBJECT_NAME, request) 
        registerCustomEditors(request, binder) 
        return binder 
    }

static newBeanWrapper = { request, object -> 
        def beanWrapper = new BeanWrapperImpl(object) 
        registerCustomEditors(request, beanWrapper) 
        return beanWrapper 
    }

private static void registerCustomEditors(request, binder) { 
        // Tell grails to handle geometry types using the LocationEditor
        // This basically just converts the field to or from EWKT
        // FIXME:crindt:Should probably define a Location type
        //              or at least restrict the class to be a Point
        binder.registerCustomEditor(Geometry.class, new LocationEditor())
    } 
}
