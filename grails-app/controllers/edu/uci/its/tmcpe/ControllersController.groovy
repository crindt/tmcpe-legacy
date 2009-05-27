package edu.uci.its.tmcpe

class ControllersController {
    
    def index = { redirect(action:list,params:params) }

    def list = {
        []
    }
}
