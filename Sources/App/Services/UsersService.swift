//  UsersService.swift
//  Created by Dmitry Samartcev on 06.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

protocol UsersService {

    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
    
    func jsonUserSignIn(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
    
    func jsonUsersGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
}

final class UsersServiceImplementation : UsersService {
 
    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
  
        let token = try makeMicroservicesAccessToken(req: req)
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
            let tokens = try self.makeUserTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: userAccessRights.userRights, status: userAccessRights.userStatus)
            return req.eventLoop.makeSucceededFuture(UserWithTokensResponse(tokens: tokens, user: userResponse))
        }.flatMap{$0}
    }
    
    func jsonUserSignIn(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
        
        let token = try makeMicroservicesAccessToken(req: req)
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
            
            return UserAccessRights.find(userResponse.id!, on: req.db).flatMapThrowing {userAccessRights -> (UserResponse01, UserAccessRights) in
                
                guard let existingUserAccessRights = userAccessRights else {
                    throw Abort (.badRequest, reason: "There is no current status and access rights for user '\(userResponse.username!)'")
                }
                
                guard existingUserAccessRights.userStatus != .blocked, existingUserAccessRights.userStatus != .archived else {
                    throw Abort (HTTPStatus.forbidden, reason: "Status of user '\(userResponse.username!)' is blocked or deleted. Contact  administration of service on issue of restoring access.")
                }
                
                return (userResponse, userAccessRights!)
            }
            
        }.flatMapThrowing {userResponse, userAccessRights in
            
            let tokens = try self.makeUserTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: userAccessRights.userRights, status: userAccessRights.userStatus)
            
            return UserWithTokensResponse(tokens: tokens, user: userResponse)
        }
    }
    
    func jsonUsersGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMap {res  in
            return req.eventLoop.future(res)
        }
    }
    
    // MARK: Private functions
    /// Creates a payload -> accessToken and refreshToken for user.
    /// - Parameters:
    ///   - req: Request.
    ///   - userId: User id.
    ///   - username: User name.
    ///   - rights: User right.
    ///   - status: User status.
    /// - Throws: Function can throw errors.
    /// - Returns: AccessToken and refreshToken for user as RefreshTokenResponse01.
    private func makeUserTokens (req: Request, userId: Int, username: String, rights: UserRights,  status: UserStatus) throws -> RefreshTokenResponse01 {
        // 1. Calculating lifetime for tokens.
        let accessTokenLifeTime = Date.createNewDate(originalDate: Date(), byAdding: AppValues.accessTokenLifeTime.component, number: AppValues.accessTokenLifeTime.value)
        // 2. Generate payload.
        let accessTokenPayload = UsersPayload(subject: "rootService", expiration: .init(value: accessTokenLifeTime!), userid: userId, username: username, userRights: rights, userStatus: status)
        // 3. Generate accessToken.
        let accessToken = try req.application.jwt.signers.sign(accessTokenPayload)
        // 4. Generate refreshTokenPayload.
        let refreshTokenPayload = RefreshToken(userId: userId)
        // 5. Generate refreshToken
        let refreshToken = try req.application.jwt.signers.sign(refreshTokenPayload)
        // 6. Return.
        return RefreshTokenResponse01(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    /// Creates a payload -> accessToken for microservice.
    /// - Parameter req: Request.
    /// - Throws: Function can throw errors.
    /// - Returns: AccessToken for microservice as String.
    fileprivate func makeMicroservicesAccessToken(req: Request) throws -> String {
        // 1. Calculating lifetime for token.
        let accessTokenLifeTime = Date.createNewDate(originalDate: Date(), byAdding: AppValues.accessTokenLifeTime.component, number: AppValues.accessTokenLifeTime.value)
        // 2. Generate payload.
        let accessTokenPayload = MicroservicesPayload(subject: "rootService", expiration: .init(value: accessTokenLifeTime!))
        // 3. Generate accessToken and return.
        return try req.application.jwt.signers.sign(accessTokenPayload)
    }

}
