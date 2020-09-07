//  UsersService.swift
//  Created by Dmitry Samartcev on 06.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

protocol UsersService {
    
    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse>
}

final class UsersServiceImplementation : UsersService {
    
    func jsonUserSignUp(req: Request, clientRoute: String) throws -> EventLoopFuture<UserWithTokensResponse> {
  
        return req.client.post(URI(string: clientRoute)).flatMapThrowing {res -> (EventLoopFuture<(Void)>, UserResponse01, UserAccessRights) in
            
            // Проверка успешного ответа
            guard res.status == .ok else {
                throw Abort (res.status, reason: res.body?.description)
            }
            
            // Декодирование тела ответа как UserResponse01
            let userResponse = try res.content.decode(UserResponse01.self)
            
            //  Первичное назначение прав
            let userAccessRights = try UserAccessRights(userId: userResponse.id!, userStatus: .created, userRights: .user)
            
            //  Сохрание прав доступа и роли в БД.
            return (userAccessRights.save(on: req.db),userResponse,userAccessRights )
            
        }.flatMapThrowing {_, userResponse, userAccessRights -> EventLoopFuture<UserWithTokensResponse> in
            
            // Формирование токенов
            let tokens = try self.createTokens(req: req, userId: userResponse.id!, username: userResponse.username!, rights: userAccessRights.userRights, status: userAccessRights.userStatus)
            
            // Response&
            return req.eventLoop.makeSucceededFuture(UserWithTokensResponse(tokens: tokens, user: userResponse))
        }.flatMap{$0}
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
    private func createTokens (req: Request, userId: Int, username: String, rights: UserRights,  status: UserStatus) throws -> RefreshTokenResponse01 {
        
        // 0. Calculating lifetime for tokens.
        let accessTokenLifeTime = Date.createNewDate(originalDate: Date(), byAdding: AppValues.accessTokenLifeTime.component, number: AppValues.accessTokenLifeTime.value)
        
        // 1. Generate the payload
        let accessTokenPayload = Payload(subject: "rootService", expiration: .init(value: accessTokenLifeTime!), userid: userId, username: username, userRights: rights, userStatus: status)
       
        // 2. Generate accessToken.
        let accessToken = try req.application.jwt.signers.sign(accessTokenPayload)
        
        // 3. Generate refreshTokenPayload.
        let refreshTokenPayload = RefreshToken(userId: userId)
        
        // 4. Generate refreshToken
        let refreshToken = try req.application.jwt.signers.sign(refreshTokenPayload)
        
        // 5. Return.
        return RefreshTokenResponse01(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    
}
