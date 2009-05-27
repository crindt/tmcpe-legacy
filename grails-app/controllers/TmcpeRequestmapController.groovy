import edu.uci.its.auth.TmcpeRequestmap

import org.springframework.util.StringUtils

/**
 * Requestmap controller.
 */
class TmcpeRequestmapController {

	def authenticateService

	// the delete, save and update actions only accept POST requests
	static Map allowedMethods = [delete: 'POST', save: 'POST', update: 'POST']

	def index = {
		redirect action: list, params: params
	}

	def list = {
		if (!params.max) {
			params.max = 10
		}
		[requestmapList: TmcpeRequestmap.list(params)]
	}

	def show = {
		def requestmap = TmcpeRequestmap.get(params.id)
		if (!requestmap) {
			flash.message = "TmcpeRequestmap not found with id $params.id"
			redirect action:list
			return
		}
		[requestmap: requestmap]
	}

	def delete = {
		def requestmap = TmcpeRequestmap.get(params.id)
		if (!requestmap) {
			flash.message = "TmcpeRequestmap not found with id $params.id"
			redirect action:list
			return
		}

		requestmap.delete()

		authenticateService.clearCachedRequestmaps()

		flash.message = "TmcpeRequestmap $params.id deleted."
		redirect(action: list)
	}

	def edit = {
		def requestmap = TmcpeRequestmap.get(params.id)
		if (!requestmap) {
			flash.message = "TmcpeRequestmap not found with id $params.id"
			redirect(action: list)
			return
		}

		[requestmap: requestmap]
	}

	/**
	 * Update action, called when an existing Requestmap is updated.
	 */
	def update = {

		def requestmap = TmcpeRequestmap.get(params.id)
		if (!requestmap) {
			flash.message = "TmcpeRequestmap not found with id $params.id"
			redirect(action: edit, id :params.id)
			return
		}

		long version = params.version.toLong()
		if (requestmap.version > version) {
			requestmap.errors.rejectValue 'version', "requestmap.optimistic.locking.failure",
				"Another user has updated this TmcpeRequestmap while you were editing."
			render view: 'edit', model: [requestmap: requestmap]
			return
		}

		requestmap.properties = params
		if (requestmap.save()) {
			authenticateService.clearCachedRequestmaps()
			redirect action: show, id: requestmap.id
		}
		else {
			render view: 'edit', model: [requestmap: requestmap]
		}
	}

	def create = {
		[requestmap: new TmcpeRequestmap(params)]
	}

	/**
	 * Save action, called when a new Requestmap is created.
	 */
	def save = {
		def requestmap = new TmcpeRequestmap(params)
		if (requestmap.save()) {
			authenticateService.clearCachedRequestmaps()
			redirect action: show, id: requestmap.id
		}
		else {
			render view: 'create', model: [requestmap: requestmap]
		}
	}
}
