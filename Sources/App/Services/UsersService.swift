//  UsersService.swift
//  Created by Dmitry Samartcev on 06.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

protocol UsersService {

    func jsonGetStatusCases (req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    
    func jsonGetGenderCases (req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    
    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
    
    func jsonUserSignIn(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
    
    func jsonUsersGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
}

final class UsersServiceImplementation : UsersService {
    
    func jsonGetStatusCases(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return simpleTransferGeRequest(req: req, clientRoute: clientRoute)
    }
    
    func jsonGetGenderCases(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return simpleTransferGeRequest(req: req, clientRoute: clientRoute)
    }
    
    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
  
        let token = try AppValues.makeMicroservicesAccessToken(req: req)
        let headers = HTTPHeaders([("Authorization", "Bearer \(token)")])
        
        return req.client.post(URI(string: clientRoute), headers: headers,  beforeSend: {clientRequest in
   
            let input = try req.content.decode(UserInputDirectSignUp01.self)
            try clientRequest.content.encode(input)
   
        }).flatMapThrowing {res -> (EventLoopFuture<(Void)>, UserResponse01, UserAccessRights) in
            if res.status == .ok {
                let userResponse = try res.content.decode(UserResponse01.self)
                let userAccessRights = try UserAccessRights(userId: userResponse.id!, userStatus: .created, userRights: .user)
                return (userAccessRights.save(on: req.db),userResponse,userAccessRights)
            } else {
                let jsonDict = try! JSONSerialization.jsonObject(with: Data(buffer: res.body!)) as! [String : Any]
                if let reason = jsonDict["reason"] {
                    throw Abort(res.status, reason: "\(String(describing: reason))")
                } else {
                    throw Abort(res.status, reason: "")
                }
            }
        }.flatMapThrowing {_, userResponse, userAccessRights -> EventLoopFuture<UserWithTokensResponse> in
            let tokens = try AppValues.makeUserTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: userAccessRights.userRights, status: userAccessRights.userStatus)
            return req.eventLoop.makeSucceededFuture(UserWithTokensResponse(tokens: tokens, user: userResponse))
        }.flatMap{$0}
    }
    
    func jsonUserSignIn(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
        
        let token = try AppValues.makeMicroservicesAccessToken(req: req)
        let headers = HTTPHeaders([("Authorization", "Bearer \(token)")])
        
        return req.client.post(URI(string: clientRoute), headers: headers, beforeSend: { request in
            
            let input = try req.content.decode(UserInputDirectSighIn01.self)
            try request.content.encode(input)
            
        }).flatMapThrowing {res -> UserResponse01 in
            
            if res.status == .ok {
                return try res.content.decode(UserResponse01.self)
            } else {
                let jsonDict = try! JSONSerialization.jsonObject(with: Data(buffer: res.body!)) as! [String : Any]
                if let reason = jsonDict["reason"] {
                    throw Abort(res.status, reason: "\(String(describing: reason))")
                } else {
                    throw Abort(res.status, reason: "")
                }
            }
        }.flatMap {userResponse in
            return UserAccessRights.query(on: req.db)
                .group(.and) { group in
                    group
                        .filter(\.$userId == userResponse.id!)
                }
                .first()
                .flatMapThrowing {userAccessRights -> (UserResponse01, UserAccessRights) in
                    
                    guard let existingUserAccessRights = userAccessRights else {
                    throw Abort (.badRequest, reason: "There is no current status and access rights for user '\(userResponse.username!)'")
                }
                
                guard existingUserAccessRights.userStatus != .blocked, existingUserAccessRights.userStatus != .archived else {
                    throw Abort (HTTPStatus.forbidden, reason: "Status of user '\(userResponse.username!)' is blocked or deleted. Contact  administration of service on issue of restoring access.")
                }
                
                return (userResponse, userAccessRights!)
            }
            
        }.flatMapThrowing {userResponse, userAccessRights in
            
            let tokens = try AppValues.makeUserTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: userAccessRights.userRights, status: userAccessRights.userStatus)
            
            return UserWithTokensResponse(tokens: tokens, user: userResponse)
        }
    }
    
    func jsonUsersGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return simpleTransferGeRequest(req: req, clientRoute: clientRoute)
    }
    
    // MARK: Private functions
    /// Sends a GET-request to specified address "as is", copying headers of requested request.
    /// - Parameters:
    ///   - req: Request.
    ///   - clientRoute: Route for request transmission.
    /// - Returns: Returns client's response "as is" to requested party.
    private func simpleTransferGeRequest (req: Request, clientRoute: String) -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMap {res  in
            return req.eventLoop.future(res)
        }
    }

}
