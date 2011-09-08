class UrlMappings {
    static mappings = {
        "/$controller/$action?/$id?"{
            constraints {
                // apply constraints here
            }
        }
//        "/"(view:"/home/index")
/*
        "/" {
            controller = "home"
            action = [GET: "index"]
        }
*/
        "/" {
            controller = "summary"
            action = [GET: "index"]
        }
        "500"(view:'/error')
    }
}
