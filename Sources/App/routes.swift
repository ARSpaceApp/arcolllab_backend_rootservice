
import Vapor

func routes(_ app: Application) throws {
    
    let rootController = RootController(rootService: ProjectServices.rootService)
    try app.register(collection: rootController)
    
    let usersController = UsersController(usersService: ProjectServices.userService)
    try app.register(collection: usersController)
}
