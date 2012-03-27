import org.codehaus.groovy.grails.plugins.springsecurity.cas.DomainUserMapper;
import org.jasig.cas.client.authentication.AttributePrincipal;
import net.ctmlabs.*
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser
import org.springframework.security.core.userdetails.User

class DomainUserMapperService implements DomainUserMapper{

    static transactional = true

	Object newUser(String username, AttributePrincipal principal){
		//TODO:  Use the correct attributes given from your CAS installation and the correct User Profile Class in your application
		def user = new GrailsUser(
			username:	username
            /*
			name:  		principal.attributes["name"],
			fname: 		principal.attributes["fName"],
			lname: 		principal.attributes["lName"],
			email:  		principal.attributes["email"]
		*/
		 )
		try{
			user.save()
		}catch(Exception e){
			throw new Exception("Unable to create and save user to the database", e)
		}
		
		user
	}
	
	//TODO: How can I find your user's profiles?
	Object findUserByUsername(String username){
		GrailsUser.findByUsername(username)
	}
}
