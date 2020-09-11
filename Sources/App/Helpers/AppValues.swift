//  AppValues.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation
import Vapor
import SwiftHelperCode

class AppValues {
    
    // Microservices
    static var USHost   = "127.0.0.1"
    static var USPort   = "8081"
    static var USApiVer = "v1.1"
    
    static var MSHost   = "127.0.0.1"
    static var MSPort   = "8082"
    static var MSApiVer = "v1.1"

    // Tokens lifetime
    static let accessTokenLifeTime  : (component: Calendar.Component, value: Int) = (.hour, 4)
    static let refreshTokenLifeTime : (component: Calendar.Component, value: Int) = (.day, 7)
    
    // Other
    static let microserviceHealthMessage : String = "RootService work!"
    
    /// Creates a payload -> accessToken and refreshToken for user.
    /// - Parameters:
    ///   - req: Request.
    ///   - userId: User id.
    ///   - username: User name.
    ///   - rights: User right.
    ///   - status: User status.
    /// - Throws: Function can throw errors.
    /// - Returns: AccessToken and refreshToken for user as RefreshTokenResponse01.
    static func makeUserTokens (req: Request, userId: Int, username: String, rights: UserRights01,  status: UserStatus01) throws -> RefreshTokenResponse01 {
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
    static func makeMicroservicesAccessToken(req: Request) throws -> String {
        // 1. Calculating lifetime for token.
        let accessTokenLifeTime = Date.createNewDate(originalDate: Date(), byAdding: AppValues.accessTokenLifeTime.component, number: AppValues.accessTokenLifeTime.value)
        // 2. Generate payload.
        let accessTokenPayload = MicroservicesPayload(subject: "rootService", expiration: .init(value: accessTokenLifeTime!))
        // 3. Generate accessToken and return.
        return try req.application.jwt.signers.sign(accessTokenPayload)
    }
    
    /// Retrieves a tuple of user data from request's accessToken payload.
    /// - Parameter req: Request.
    /// - Throws: An error where accessToken cannot be read.
    /// - Returns: User data tuple.
    static func getUserInfoFromAccessToken (req: Request) throws -> (userid: Int?, username: String?, userRights: UserRights01, userStatus: UserStatus01){
        
        if let accessToken = req.headers.bearerAuthorization?.token.utf8 {
            let payload = try req.jwt.verify(Array(accessToken), as: UsersPayload.self)
            return(payload.userid, payload.username, payload.userRights, payload.userStatus)
            
        } else {
            throw Abort(.unauthorized, reason: "Missing required request component - accessToken.")
        }
    }

}

