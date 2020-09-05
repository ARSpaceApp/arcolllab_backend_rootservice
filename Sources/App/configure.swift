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

    // MARK: Routes
    try routes(app)
}
