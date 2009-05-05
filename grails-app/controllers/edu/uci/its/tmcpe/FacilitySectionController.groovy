

package edu.uci.its.tmcpe

class FacilitySectionController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        params.max = Math.min( params.max ? params.max.toInteger() : 10,  100)
        [ facilitySectionInstanceList: FacilitySection.list( params ), facilitySectionInstanceTotal: FacilitySection.count() ]
    }

    def show = {
        def facilitySectionInstance = FacilitySection.get( params.id )

        if(!facilitySectionInstance) {
            flash.message = "FacilitySection not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ facilitySectionInstance : facilitySectionInstance ] }
    }

    def delete = {
        def facilitySectionInstance = FacilitySection.get( params.id )
        if(facilitySectionInstance) {
            try {
                facilitySectionInstance.delete()
                flash.message = "FacilitySection ${params.id} deleted"
                redirect(action:list)
            }
            catch(org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "FacilitySection ${params.id} could not be deleted"
                redirect(action:show,id:params.id)
            }
        }
        else {
            flash.message = "FacilitySection not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def facilitySectionInstance = FacilitySection.get( params.id )

        if(!facilitySectionInstance) {
            flash.message = "FacilitySection not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ facilitySectionInstance : facilitySectionInstance ]
        }
    }

    def update = {
        def facilitySectionInstance = FacilitySection.get( params.id )
        if(facilitySectionInstance) {
            if(params.version) {
                def version = params.version.toLong()
                if(facilitySectionInstance.version > version) {
                    
                    facilitySectionInstance.errors.rejectValue("version", "facilitySection.optimistic.locking.failure", "Another user has updated this FacilitySection while you were editing.")
                    render(view:'edit',model:[facilitySectionInstance:facilitySectionInstance])
                    return
                }
            }
            facilitySectionInstance.properties = params
            if(!facilitySectionInstance.hasErrors() && facilitySectionInstance.save()) {
                flash.message = "FacilitySection ${params.id} updated"
                redirect(action:show,id:facilitySectionInstance.id)
            }
            else {
                render(view:'edit',model:[facilitySectionInstance:facilitySectionInstance])
            }
        }
        else {
            flash.message = "FacilitySection not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def facilitySectionInstance = new FacilitySection()
        facilitySectionInstance.properties = params
        return ['facilitySectionInstance':facilitySectionInstance]
    }

    def save = {
        def facilitySectionInstance = new FacilitySection(params)
        if(!facilitySectionInstance.hasErrors() && facilitySectionInstance.save()) {
            flash.message = "FacilitySection ${facilitySectionInstance.id} created"
            redirect(action:show,id:facilitySectionInstance.id)
        }
        else {
            render(view:'create',model:[facilitySectionInstance:facilitySectionInstance])
        }
    }
}
