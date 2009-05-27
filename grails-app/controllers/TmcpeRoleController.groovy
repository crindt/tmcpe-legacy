import edu.uci.its.auth.TmcpeRole
import edu.uci.its.auth.TmcpeRequestmap

/**
 * Authority Controller.
 */
class TmcpeRoleController {

	// the delete, save and update actions only accept POST requests
	static Map allowedMethods = [delete: 'POST', save: 'POST', update: 'POST']

	def authenticateService

	def index = {
		redirect action: list, params: params
	}

	/**
	 * Display the list authority page.
	 */
	def list = {
		if (!params.max) {
			params.max = 10
		}
		[authorityList: TmcpeRole.list(params)]
	}

	/**
	 * Display the show authority page.
	 */
	def show = {
		def authority = TmcpeRole.get(params.id)
		if (!authority) {
			flash.message = "TmcpeRole not found with id $params.id"
			redirect action: list
			return
		}

		[authority: authority]
	}

	/**
	 * Delete an authority.
	 */
	def delete = {
		def authority = TmcpeRole.get(params.id)
		if (!authority) {
			flash.message = "TmcpeRole not found with id $params.id"
			redirect action: list
			return
		}

		authenticateService.deleteRole(authority)

		flash.message = "TmcpeRole $params.id deleted."
		redirect action: list
	}

	/**
	 * Display the edit authority page.
	 */
	def edit = {
		def authority = TmcpeRole.get(params.id)
		if (!authority) {
			flash.message = "TmcpeRole not found with id $params.id"
			redirect action: list
			return
		}

		[authority: authority]
	}

	/**
	 * Authority update action.
	 */
	def update = {

		def authority = TmcpeRole.get(params.id)
		if (!authority) {
			flash.message = "TmcpeRole not found with id $params.id"
			redirect action: edit, id: params.id
			return
		}

		long version = params.version.toLong()
		if (authority.version > version) {
			authority.errors.rejectValue 'version', 'authority.optimistic.locking.failure',
				'Another user has updated this TmcpeRole while you were editing.'
			render view: 'edit', model: [authority: authority]
			return
		}

		if (authenticateService.updateRole(authority, params)) {
			authenticateService.clearCachedRequestmaps()
			redirect action: show, id: authority.id
		}
		else {
			render view: 'edit', model: [authority: authority]
		}
	}

	/**
	 * Display the create new authority page.
	 */
	def create = {
		[authority: new TmcpeRole()]
	}

	/**
	 * Save a new authority.
	 */
	def save = {

		def authority = new TmcpeRole()
		authority.properties = params
		if (authority.save()) {
			redirect action: show, id: authority.id
		}
		else {
			render view: 'create', model: [authority: authority]
		}
	}
}
