

package edu.uci.its.testbed

class RouteController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ routeInstanceList: Route.list( params ), routeInstanceTotal: Route.count() ]
    }

    def show = {
        def routeInstance = Route.get( params.id )

        if(!routeInstance) {
            flash.message = "Route not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ routeInstance : routeInstance ] }
    }

    def delete = {
        def routeInstance = Route.get( params.id )
        if(routeInstance) {
            try {
                routeInstance.delete()
                flash.message = "Route ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "Route ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "Route not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def routeInstance = Route.get( params.id )

        if(!routeInstance) {
            flash.message = "Route not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ routeInstance : routeInstance ]
        }
    }

    def update = {
        def routeInstance = Route.get( params.id )
        if(routeInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(routeInstance.version > version) {
                    
                    routeInstance.errors.rejectValue("version", "route.optimistic.locking.failure", "Another user has updated this Route while you were editing.")
                    render(view:'edit',model:[routeInstance:routeInstance])
                    return
                }
            }
            routeInstance.properties = params
            if(!routeInstance.hasErrors() && routeInstance.save()) {
                flash.message = "Route ${params.id} updated"
                redirect(action:show,id:routeInstance.id)
            }
            else {
                render(view:'edit',model:[routeInstance:routeInstance])
            }
        }
        else {
            flash.message = "Route not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def routeInstance = new Route()
        routeInstance.properties = params
        return ['routeInstance':routeInstance]
    }

    def save = {
        def routeInstance = new Route(params)
        if(!routeInstance.hasErrors() && routeInstance.save()) {
            flash.message = "Route ${routeInstance.id} created"
            redirect(action:show,id:routeInstance.id)
        }
        else {
            render(view:'create',model:[routeInstance:routeInstance])
        }
    }
}
