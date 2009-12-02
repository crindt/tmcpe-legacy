package edu.uci.its.tmcpe

class MapController {

    static navigation = [
        group:'tabs',
        order:1,
        title:'Home'
        ]
    
    def index = { redirect(action:show,params:params) }

    // the delete, save and update actions only accept POST requests
    static allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def show = {
        return [ ]
    }
}
