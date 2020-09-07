import Vapor
import Fluent
import FluentPostgresDriver
import JWT

public func configure(_ app: Application) throws {
    
    // MARK: ServerConfig
    app.http.server.configuration.port = 8080
    
    // MARK: Middlewares
    app.middleware.use(CORSMiddleware())
    app.middleware.use(ErrorMiddleware.default(environment: .development))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // MARK: JWT
    guard let jwksString = Environment.process.JWKS else {
        app.logger.critical("No value for key 'JWKS' was found in environment.")
        fatalError()
    }
    try app.jwt.signers.use(jwksJSON: jwksString)
    
    // MARK: DB
    // db -> register
    var psqlUrl : String = ""
    if app.environment.name == "testing" {
        guard let url = Environment.process.PSQL_CRED_SERVICE_ROOT_TEST else {
            let error = "No value for key 'PSQL_CRED_SERVICE_ROOT_TEST' was found in environment."
            throw Abort (HTTPResponseStatus.internalServerError, reason: error)
        }
        psqlUrl = url
        
    } else {
        guard let url = Environment.process.PSQL_CRED_SERVICE_ROOT else {
            let error = "No value for key 'PSQL_CRED_SERVICE_ROOT' was found in environment."
            app.logger.critical("\(error)")
            throw Abort (HTTPResponseStatus.internalServerError, reason: error)
        }
        psqlUrl = url
    }
    
    guard let url = URL(string: psqlUrl) else {
        let error = "Can`t parse correctly \(psqlUrl)"

        app.logger.critical("\(error)")
        throw Abort (HTTPResponseStatus.internalServerError, reason: error)
    }
    app.databases.use(try .postgres(url: url), as: .psql)

    // db -> migrations
    if app.environment.name == "testing" {
        app.migrations.add(CreateUserAccessRights())
        try app.autoMigrate().wait()
        app.logger.notice("Migration complete.")
    } else {
        app.migrations.add(CreateUserAccessRights())
        try app.autoMigrate().wait()
        app.logger.notice("Migration complete.")
    }
    
    // MARK: Check services
    // UsersService check
    let checkServicesResult = try checkServiceAvailable(client: app.client).wait()
    if checkServicesResult {
        app.logger.notice("All microservices are ready to work together.")
    } else {
        app.logger.error("Not all microservices are ready to work together.")
    }
    
    
//
//    // ModelsService check
//    let modelsServiceEnvKey = ServicesRoutes.modelsServiceEnvKey.description
//    guard let modelsService = Environment.process.modelsServiceEnvKey else {
//
//        let error = "No value was found in environment for key: '\(modelsServiceEnvKey))'"
//        app.logger.critical("\(error)")
//        throw Abort(HTTPStatus.internalServerError, reason: "\(error)")
//    }
//    AppValues.servicesRoutes[.modelsServiceHomeRoute] = modelsService
//
//    // TODO: Подклються на home роуты и проверить на 200
//    // ...

    // MARK: Routes
    
    // Store superAdmin userAccessRights.
    // By default, userId of superadmin is set to 1.
    let superAdminUserAccessRights = try UserAccessRights(userId: 1, userStatus: .confirmed, userRights: .superAdmin)
    let saveResult = try storeSuperAdminUserAccessRights(db: app.db, accessRights: superAdminUserAccessRights, logger: app.logger).wait()
    
    if saveResult {
        try routes(app)
    } else {
        let error = "Unable to save UserAccessRights for superadmin."
        app.logger.critical("\(error)")
        throw Abort(HTTPStatus.internalServerError, reason: "\(error)")
    }
}

fileprivate func storeSuperAdminUserAccessRights (db: Database, accessRights: UserAccessRights, logger: Logger) -> EventLoopFuture<Bool> {
    
    return UserAccessRights.find(accessRights.id, on: db).flatMap {existingAccessRights in
        
        if let superAdminAccessRights = existingAccessRights {
            superAdminAccessRights.userId = accessRights.userId
            superAdminAccessRights.userRights = accessRights.userRights
            superAdminAccessRights.userStatus = accessRights.userStatus
            
            return superAdminAccessRights.update(on: db).map { _ in
                logger.notice("UserAccessRights for superadmin updated.")
                return true
            }
            
        } else {
            return accessRights.save(on: db).map{ _ in
                logger.notice("UserAccessRights for superadmin updated.")
                return true
            }
        }
    }
}

fileprivate func checkServiceAvailable (client: Client)  -> EventLoopFuture<Bool> {
    
    return client.get(
        URI(string: USVarsAndRoutes.usersServiceHealthRoute.description)).flatMap {res in
        if res.status == .ok {
            return client.eventLoop.future(true)
        } else {
            return client.eventLoop.future(false)
        }
    }
}
