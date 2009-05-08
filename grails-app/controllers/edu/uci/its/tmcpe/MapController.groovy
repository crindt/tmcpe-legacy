

package edu.uci.its.tmcpe

class MapController {
    
    def index = { redirect(action:show,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def show = {
        return [ ]
    }
}
