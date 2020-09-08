//  RootService.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

protocol RootService {
    
    /// Signals about correct operation of microservice, returns routes available on this microservice.
    /// - Parameter req: Request.
    func jsonHomeRequest (req: Request) -> EventLoopFuture<String>
    
    func jsonGetStatusCases (req: Request) -> EventLoopFuture<[UserStatus01]>
    
    func jsonGetRightsCases (req: Request) -> EventLoopFuture<[UserRights01]>
    
    func jsonRefreshToken(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
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
    
    func jsonGetStatusCases(req: Request) -> EventLoopFuture<[UserStatus01]> {
        return req.eventLoop.makeSucceededFuture(UserStatus01.allCases)
    }
    
    func jsonGetRightsCases(req: Request) -> EventLoopFuture<[UserRights01]> {
        return req.eventLoop.makeSucceededFuture(UserRights01.allCases)
    }
    
    func jsonRefreshToken(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
        
        // 1. Decode RefreshTokenInput01 from request body.
        let refreshTokenInput = try req.content.decode(RefreshTokenInput01.self)
        // 2. Receiving RefreshToken
        let refreshToken = try req.application.jwt.signers.verify(refreshTokenInput.refreshToken, as: RefreshToken.self)
        // 3. User request for UserService.
        let routeString = "\(clientRoute)/\(refreshToken.id)"
        // 4. Make microservice token, add to header.
        let microserviceToken = try AppValues.makeMicroservicesAccessToken(req: req)
        let headers = HTTPHeaders([("Authorization", "Bearer \(microserviceToken)")])
        
        return req.client.get(URI(string: routeString), headers: headers).flatMapThrowing{res -> EventLoopFuture<(UserAccessRights, UserResponse01)> in
 
            if res.status == .ok {
                let userResponse = try res.content.decode(UserResponse01.self)
                // 4. Find UserAccessRights for this user.
                return UserAccessRights.query(on: req.db)
                    .filter(\.$userId == userResponse.id!)
                    .first()
                    .flatMapThrowing {rights  in
                        guard let existingRights = rights else { throw Abort (HTTPStatus.notFound)}
                        return req.eventLoop.makeSucceededFuture((existingRights, userResponse))
                    }.flatMap{$0}
            } else {
                let jsonDict = try! JSONSerialization.jsonObject(with: Data(buffer: res.body!)) as! [String : Any]
                if let reason = jsonDict["reason"] {
                    throw Abort(res.status, reason: "\(String(describing: reason))")
                } else {
                    throw Abort(res.status, reason: "")
                }
            }
        }.flatMap {values -> EventLoopFuture<UserWithTokensResponse>  in
            return values.flatMapThrowing { existingRights, userResponse in
                // 5. Create new tokens & response.
                let tokens = try AppValues.makeUserTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: existingRights.userRights, status: existingRights.userStatus)
                return req.eventLoop.makeSucceededFuture(UserWithTokensResponse(tokens: tokens, user: userResponse))
            }.flatMap{$0}
        }
    }
}



