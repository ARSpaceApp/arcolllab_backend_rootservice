
import Vapor

func routes(_ app: Application) throws {
    
    let rootController = RootController(rootService: ProjectServices.rootService)
    try app.register(collection: rootController)
    
    let regexController = RegexController(regexService: ProjectServices.regexService)
    try app.register(collection: regexController)
    
    let usersController = UsersController(usersService: ProjectServices.userService)
    try app.register(collection: usersController)
    
    let modelsController = ModelsController(modelsService: ProjectServices.modelsService)
    try app.register(collection: modelsController)
}
