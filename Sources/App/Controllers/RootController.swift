//  RootController.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

final class RootController {
    
    private var rootService : RootService
    
    init (rootService : RootService) {
        self.rootService = rootService
    }
    
    func jsonHomeRequest (req: Request) -> EventLoopFuture<String> {
        return self.rootService.jsonHomeRequest(req: req)
    }
    
    func jsonGetStatusCases (req: Request) -> EventLoopFuture<[UserStatus01]> {
        return self.rootService.jsonGetStatusCases(req: req)
    }
    
    func jsonGetRightsCases (req: Request) -> EventLoopFuture<[UserRights01]> {
        return self.rootService.jsonGetRightsCases(req: req)
    }
    
    func jsonRefreshToken(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.rootService.jsonRefreshToken(
            req: req,
            clientRoute: "\(US_usVarsAndRoutes.usersServiceUsersRoute.description)"
        )
    }
}

extension RootController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // example: http://127.0.0.1:8080/v1.1
        let root = routes.grouped(.anything)
        let auth = root.grouped(JWTMiddleware())
        
        // example: http://127.0.0.1:8080/v1.1/health
        root.get("health", use: self.jsonHomeRequest)
        
        // example: http://127.0.0.1:8080/v1.1/statuses
        // Info route.
        auth.get("statuses", use: self.jsonGetStatusCases)
        
        // example: http://127.0.0.1:8080/v1.1/rights
        // Info route.
        auth.get("rights", use: self.jsonGetRightsCases)
        
        // example: http://127.0.0.1:8080/v1.1/refreshToken
        // Info route.
        root.post("refreshToken", use: self.jsonRefreshToken)
    }
}
