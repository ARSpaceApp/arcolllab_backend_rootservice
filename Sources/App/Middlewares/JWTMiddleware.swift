//  JWTMiddleware.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import JWT

public final class JWTMiddleware: Middleware {
    
    public init() { }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // 1. Get accessToken from request.
        guard let token = request.headers.bearerAuthorization?.token.utf8 else {
            return request.eventLoop.makeFailedFuture(
                Abort(.unauthorized, reason: "Missing authorization bearer header."))
        }
        
        do {
            // 2. Verifies payload from accessToken.
            request.usersPayload = try request.jwt.verify(Array(token), as: UsersPayload.self)
            
            // 2.1 Check compliance of route access rules with user rights.
            try self.checkingComplianceWithAccessRightsForCurrentRoute(req: request, accessToken: token)
            
        } catch let JWTError.claimVerificationFailure(name: name, reason: reason){
            // 3.1 Custom verification error.
            request.logger.error("JWT Verification Failure: \(name), \(reason).")
            return request.eventLoop.makeFailedFuture( JWTError.claimVerificationFailure( name: name, reason: reason))
        } catch {
            // 3.2 General verification error.
            return request.eventLoop.makeFailedFuture(error)
        }
        // 4. If verification is successful, work continues.
        return next.respond(to: request)
    }
    
    /// Checks for presence of access conditions by status and role of user in current route, compliance of such conditions with status and role of user from payload of received accessToken.
    /// - Parameters:
    ///   - req: Current request.
    ///   - accessToken: Received accessToken.
    /// - Throws: Access errors by status and (or) role indicating allowed values for this route.
     private func checkingComplianceWithAccessRightsForCurrentRoute (req: Request, accessToken: String.UTF8View) throws {

         // 1. Getting payload from access Token.
         let payload = try req.jwt.verify(Array(accessToken), as: UsersPayload.self)

         // 2. Getting access rules from userInfo of passed route.
         // 2.1 If access rights are present in passed route.
        if let routeAccessRight = req.route?.userInfo[.accessRight] as? AccessRight {
            // 3. If route contains access rights by status:
            if let routeAccessRightStatuses = routeAccessRight.statuses {
                // 3.1 If access rights of route by status and user status do not match:
                if !routeAccessRightStatuses.contains(payload.userStatus) {
                    var allowedStatuses = ""
                    routeAccessRightStatuses.forEach {allowedStatuses.append("'\($0.description)' ")}
                    // 3.3 Access error by status with indication of allowed statuses.
                    throw Abort(HTTPStatus.forbidden, reason: "This request supports statuses: \(allowedStatuses).")
                }
            }
             // 4. If route contains access rights by role:
             if let routeAccessRightRoles = routeAccessRight.rights {
                 // 4.1 If access rights of route by role and user role do not match:
                if !routeAccessRightRoles.contains(payload.userRights) {
                    var allowedRights = ""
                    routeAccessRightRoles.forEach {allowedRights.append("'\($0.description)' ")}
                    // 4.3 Access error by role with indication of allowed roles.
                    throw Abort(HTTPStatus.forbidden, reason: "This request supports roles: \(allowedRights).")
                }
             }
         }
     }
}
