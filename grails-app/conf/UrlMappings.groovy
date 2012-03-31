class UrlMappings {
  static mappings = {
	"/help/browserHelp"{
		controller="help"
		action = [GET: "browserHelp"]
	}
    "/help/$term?"{
      controller="help"
      action = [GET: "page"]
    }
    "/$controller/$action?/$id?"{
      constraints {
        // apply constraints here
      }
    }
    //        "/"(view:"/home/index")
    "/" {
      controller = "home"
      action = [GET: "index"]
    }
	/*
    "/" {
      controller = "incident"
      action = [GET: "summary"]
    }
	*/
    "500"(view:'/error')
  }
}
