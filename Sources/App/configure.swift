import Vapor
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
    
    // MARK: Routes
    try routes(app)
}
