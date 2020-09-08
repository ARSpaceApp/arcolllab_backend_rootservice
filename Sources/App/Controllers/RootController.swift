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
        fatalError()
    }
    
    func jsonGetRightsCases (req: Request) -> EventLoopFuture<[UserRights01]> {
        fatalError()
    }
}

extension RootController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // example: http://127.0.0.1:8080/v1.1
        let root = routes.grouped(.anything)
        
        let rootAuth = routes.grouped(JWTMiddleware())

        // example: http://127.0.0.1:8080/v1.1/health
        root.get("health", use: self.jsonHomeRequest)
        
        // example: http://127.0.0.1:8080/v1.1/statuses
        // Info route.
        rootAuth.get("statuses", use: self.jsonGetStatusCases)
        
        // example: http://127.0.0.1:8080/v1.1/rights
        // Info route.
        rootAuth.get("rights", use: self.jsonGetRightsCases)

        
    }
}
