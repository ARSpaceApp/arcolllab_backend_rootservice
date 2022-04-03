//  AppValues.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation
import Vapor
import Fluent
import SwiftHelperCode

class AppValues {

    // Microservices
    static var USHost   = "194.58.104.211"
    static var USPort   = "8802"
    static var USApiVer = "v1.1"

    static var MSHost   = "194.58.104.211"
    static var MSPort   = "8803"
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

    /// Recognizes requestor by data of their access token, checks it in DB for relevance of status (cannot be 'blocked' or 'deleted'), based on verification of rights (superadmin, admin or ordinary user) decides on further possibility of performing actions.
    /// - This check is used for such routes where a requestor as an unblocked/unarchived superadmin/admin can perform actions on resources of any other user, and a requestor in rights of a regular user can only perform actions on his own resources (An example of such routes is a get, update, delete user profile by username or id).
    /// - Parameters:
    ///   - req: Request.
    ///   - userId: User ID from request (optional).
    ///   - userName: Username from request (optional).
    /// - Throws: Function can throw errors.
    /// - Returns: Boolean flag of validation performed.
    static func checkingAccessRightsForRequest (userId: Int?, userName: String?, req: Request) throws -> EventLoopFuture<Bool> {

        // 1. Getting information about requestor from token.
        let valuesFromToken = try AppValues.getUserInfoFromAccessToken(req: req)

        guard let requestorId = valuesFromToken.userid, let requestorUsername = valuesFromToken.username else {
            throw Abort(.badRequest, reason: "Access token of requestor does not contain user's identifier")
        }

        return UserAccessRights
            .query(on: req.db)
            .filter(\.$userId == requestorId)
            .first()
            .unwrap(or: Abort(.notFound, reason: "DB does not contain status and access rights of requestor."))
            .flatMapThrowing { requestorAccessRights  -> Bool in

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
            }.flatMap{return req.eventLoop.makeSucceededFuture($0)}
    }
}
