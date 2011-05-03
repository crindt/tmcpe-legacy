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
            controller = "map"
            action = [GET: "d3_show"]
        }
        "500"(view:'/error')
    }
}
