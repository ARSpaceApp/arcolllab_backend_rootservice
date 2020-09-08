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
    
    func jsonUsersByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
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
    
    func jsonUsersByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {

        if let userParameter = req.parameters.get("userParameter") {
            
            if let userId = Int(userParameter.trimmingCharacters(in: .whitespacesAndNewlines))  {
                return try checkingAccessRightsForRequest(userId: userId, userName: nil, req: req).flatMapThrowing {result in
                    return req.client.get(URI(string: "\(clientRoute)/\(userId)"), headers: req.headers).flatMapThrowing {res in
                        return res
                    }
                }.flatMap{$0}
            } else  {
                let userParameter =  userParameter.trimmingCharacters(in: .whitespacesAndNewlines)
                return try checkingAccessRightsForRequest(userId: nil, userName: userParameter, req: req).flatMapThrowing {result in
                    return req.client.get(URI(string: "\(clientRoute)/\(userParameter)"), headers: req.headers).flatMapThrowing {res in
                        return res
                    }
                }.flatMap{$0}
            }
        } else {
            throw Abort (.badRequest, reason: "Request parameter is invalid.")
        }
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
    
    /// Recognizes requestor by data of their access token, checks it in DB for relevance of status (cannot be 'blocked' or 'deleted'), based on verification of rights (superadmin, admin or ordinary user) decides on further possibility of performing actions.
    /// This check is used for such routes where a requestor as an unblocked/unarchived superadmin/admin can perform actions on resources of any other user, and a requestor in rights of a regular user can only perform actions on his own resources (An example of such routes is a get, update, delete user profile by username or id).
    /// - Parameters:
    ///   - req: Request.
    ///   - userId: User ID from request (optional).
    ///   - userName: Username from request (optional).
    /// - Throws: Function can throw errors.
    /// - Returns: Boolean flag of validation performed.
    private func checkingAccessRightsForRequest (userId: Int?, userName: String?, req: Request) throws -> EventLoopFuture<Bool> {
       
        // 1. Getting information about requestor from token.
        let valuesFromToken = try AppValues.getUserInfoFromAccessToken(req: req)
        
        guard let requestorId = valuesFromToken.userid, let requestorUsername = valuesFromToken.username else {
            throw Abort(.badRequest, reason: "Access token of requestor does not contain user's identifier")
        }
        
        // 2. Getting status and access rights of requestor.
        return UserAccessRights
            .query(on: req.db)
            .filter(\.$userId == requestorId)
            .first()
            .unwrap(or: Abort(.notFound, reason: "DB does not contain status and access rights of requestor."))
            .flatMapThrowing { requestorAccessRights -> Bool  in
                
                // 3. Check - status of requestor cannot be "blocked" or "archived".
                guard requestorAccessRights.userStatus != .blocked, requestorAccessRights.userStatus != .archived else {
                    throw Abort (HTTPStatus.forbidden, reason: "Status of user is blocked or deleted. Contact administration of service on issue of restoring access.")
                }
                
                // 4. If requestor is superadmin or admin - further actions are allowed.
                if requestorAccessRights.userRights == .admin || requestorAccessRights.userRights == .superadmin {
                    return true
                    
                // 4.1 If requestor is user - only profile owner can access this resource.
                } else {
                        // 4.1.1 If userId is recognized.
                        if let userId = userId, userName == nil {
                            if userId == requestorId {
                                return true
                            } else {
                                throw Abort (HTTPStatus.forbidden, reason: "Only profile owner can access this resource.")
                            }
                        // 4.1.2 If username is recognized.
                        } else if let userName = userName, userId == nil {
                            if userName == requestorUsername {
                                return true
                            } else {
                                throw Abort (HTTPStatus.forbidden, reason: "Only profile owner can access this resource.")
                            }
                        // 4.1.3 If nothing is recognized.
                        } else {
                            throw Abort (.badRequest, reason: "Request parameter is invalid.")
                        }
                }
            }.flatMap{flag in
                return req.eventLoop.makeSucceededFuture(true)
            }
    }

}
