import Vapor
import Fluent
import FluentPostgresDriver
import JWT

public func configure(_ app: Application) throws {
    
    // MARK: ServerConfig
    app.http.server.configuration.port = 8801
    
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
    let checkServicesResult = try checkServiceAvailable(client: app.client, logger: app.logger).wait()
    if checkServicesResult {
        app.logger.notice("All microservices are ready to work together.")
    } else {
        app.logger.error("Not all microservices are ready to work together.")
    }

    // MARK: Routes
    
    // Store superAdmin userAccessRights.
    // By default, userId of superadmin is set to 1.
    let superAdminUserAccessRights = try UserAccessRights(userId: 1, userStatus: .confirmed, userRights: .superadmin)
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
    
    return UserAccessRights.query(on: db)
        .group(.and) { group in
            group
                //.filter(\.$id == accessRights.id!)
                .filter(\.$userId == accessRights.userId)
        }
        .first()
        .flatMap { existingAccessRights in
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

fileprivate func checkServiceAvailable (client: Client, logger: Logger)  -> EventLoopFuture<Bool> {
    
    let promise01 = client.eventLoop.makePromise(of: EventLoopFuture<ClientResponse>.self)
    promise01.succeed(client.get(URI(string: US_USVarsAndRoutes.usersServiceHealthRoute.description)))
    return promise01.futureResult.flatMap {clientResponse01 in
        return clientResponse01.map {response in
            if response.status == .ok {
                let promise02 = client.eventLoop.makePromise(of: EventLoopFuture<ClientResponse>.self)
                promise02.succeed(client.get(URI(string: US_MSVarsAndRoutes.modelsServiceHealthRoot.description)))
                return promise02.futureResult.flatMap {clientResponse02  in
                    return clientResponse02.map {response01 in
                        if response01.status == .ok {
                            return client.eventLoop.makeSucceededFuture(true)
                        } else {
                            logger.notice("No response from ModelsService.")
                            return client.eventLoop.makeSucceededFuture(false)
                        }
                    }.flatMap{$0}
                }
            } else {
                logger.notice("No response from UsersService.")
                return client.eventLoop.makeSucceededFuture(false)
            }
        }.flatMap{$0}
    }
}
