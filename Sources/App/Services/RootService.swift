//  RootService.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import Fluent

protocol RootService {
    
    /// Signals about correct operation of microservice, returns routes available on this microservice.
    /// - Parameter req: Request.
    func jsonHomeRequest (req: Request) -> EventLoopFuture<String>
}

final class RootServiceImplementation : RootService {
    
    // MARK: Routes functions
    func jsonHomeRequest(req: Request) -> EventLoopFuture<String>{
        
        var routes = """
        """
        req.application.routes.all.forEach {route in
            routes.append("---------------------------------------------\n")
            routes.append("\(route)\n")
        }
        return req.eventLoop.makeSucceededFuture("""
            \(AppValues.microserviceHealthMessage)\n\n
            Routes:
            \(routes)
            """)
    }
}
