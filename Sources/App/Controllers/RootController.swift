//  RootController.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import Fluent

final class RootController {
    
    private var rootService : RootService
    
    init (rootService : RootService) {
        self.rootService = rootService
    }
    
    func jsonHomeRequest (req: Request) -> EventLoopFuture<String> {
        return self.rootService.jsonHomeRequest(req: req)
    }
    
}

extension RootController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // example: http://127.0.0.1:8080/v1.1
        let root = routes.grouped(.anything)

        // example: http://127.0.0.1:8080/v1.1/health
        root.get("health", use: self.jsonHomeRequest)
    }
}
