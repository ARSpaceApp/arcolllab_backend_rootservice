//  UsersController.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import SwiftHelperCode

final class UsersController {
    
    private var usersService: UsersService!
    
    init (usersService: UsersService) {
        self.usersService = usersService
    }
    
    func jsonGetGenderCases (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonGetGenderCases (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceGenderCasesRoute.description
        )
    }
    
    func jsonUserSignUp(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.usersService.jsonUserSignUp (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceSignUpRoute.description
        )
    }
    
    func jsonUserSignIn(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.usersService.jsonUserSignIn (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceSignInRoute.description
        )
    }
     
    func jsonUsersGetAll(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonUsersGetAll (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
//    func jsonUserUpdate(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
//        return try self.usersService.jsonUserSignUp (
//            req: req,
//            clientRoute: "\(API.usersRoute.description)/signup"
//        )
//    }
}

extension UsersController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
    
        // example: http://127.0.0.1:8080/v1.1/users
        let users = routes.grouped(.anything, "users")
        
        let auth = users.grouped(JWTMiddleware())
        
        // example: http://127.0.0.1:8080/v1.1/users/genders
        // Info route.
        users.get("genders", use: self.jsonGetGenderCases)
        
        // example: http://127.0.0.1:8080/v1.1/users/signup
        // There are no requirements for restricting access to route.
        users.post("signup", use: self.jsonUserSignUp)
        
        // example: http://127.0.0.1:8080/v1.1/users/signin
        // There are no requirements for restricting access to route.
        users.post("signin", use: self.jsonUserSignIn)

        // example: http://127.0.0.1:8080/v1.1/users
        let usersRoute001 = auth.get(use: self.jsonUsersGetAll)
        usersRoute001.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
    }

}


enum US_usVarsAndRoutes : Int, CaseIterable {
    case usersServiceHealthRoute
    case usersServiceGenderCasesRoute
    case usersServiceUsersRoute
    case usersServiceSignInRoute
    case usersServiceSignUpRoute
    
    var description : String {
        switch self {
        case .usersServiceHealthRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/health"
        case .usersServiceUsersRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users"
        case .usersServiceSignInRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users/signin"
        case .usersServiceSignUpRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users/signup"
        case .usersServiceGenderCasesRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users/genders"
        }
    }
}

//// example: http://127.0.0.1:8080/v1.1/users/:userParameter
