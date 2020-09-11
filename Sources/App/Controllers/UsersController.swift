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
            clientRoute: US_USVarsAndRoutes.usersServiceGenderCasesRoute.description
        )
    }
    
    // ---
    func jsonUserSignUp(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.usersService.jsonUserSignUp (
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceSignUpRoute.description
        )
    }
    
    func jsonUserSignIn(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.usersService.jsonUserSignIn (
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceSignInRoute.description
        )
    }
     
    func jsonUsersGetAll(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonUsersGetAll (
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonGetUserByParameter (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonGetUserByParameter (
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonUpdateUserByParameter (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonUpdateUserByParameter (
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonUpdateAccessRightsByUserId (req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        return try self.usersService.jsonUpdateAccessRightsByUserId (req: req)
    }
    
    // ---
    func jsonStoreAvatarsByUserId(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonStoreAvatarsByUserId(
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonGetAllAvatarsByUserId(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonGetAllAvatarsByUserId(
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonDeletelAvatarByUserIdAndAvatarId(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonDeletelAvatarByUserIdAndAvatarId(
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonDeleteAllAvatars(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonDeleteAllAvatars(
            req: req,
            clientRoute: US_USVarsAndRoutes.usersServiceAvatarsRoute.description
        )
    }
    
}

extension UsersController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
    
        // example: http://127.0.0.1:8801/v1.1/users
        let users = routes.grouped(.anything, "users")
        
        let auth = users.grouped(JWTMiddleware())
        
        // example: http://127.0.0.1:8801/v1.1/users/genders
        // Info route.
        users.get("genders", use: self.jsonGetGenderCases)
        
        // ---
        
        // example: http://127.0.0.1:8801/v1.1/users/signup
        // There are no requirements for restricting access to route.
        users.post("signup", use: self.jsonUserSignUp)
        
        // example: http://127.0.0.1:8801/v1.1/users/signin
        // There are no requirements for restricting access to route.
        users.post("signin", use: self.jsonUserSignIn)

        // example: http://127.0.0.1:8801/v1.1/users
        let usersAuthRoute001 = auth.get(use: self.jsonUsersGetAll)
        usersAuthRoute001.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/users/:userParameter
        let usersAuthRoute002 = auth.get(":userParameter", use: self.jsonGetUserByParameter)
        usersAuthRoute002.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/users/:userParameter
        let usersAuthRoute003 = auth.patch(":userParameter", use: self.jsonUpdateUserByParameter)
        usersAuthRoute003.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/users/:userId
        let usersAuthRoute004 = auth.put(":userId", use: self.jsonUpdateAccessRightsByUserId)
        usersAuthRoute004.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
        
        // ---
        // example: http://127.0.0.1:8801/v1.1/users/avatars/:userId
        let usersAuthRoute005 =  auth.on(.POST, "avatars", ":userId", body: .collect(maxSize: "5mb"),  use: jsonStoreAvatarsByUserId)
        usersAuthRoute005.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        
        // example: http://127.0.0.1:8801/v1.1/users/avatars/:userId
        let usersAuthRoute006 = auth.get ("avatars",":userId", use: jsonGetAllAvatarsByUserId)
        usersAuthRoute006.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        
        // example: http://127.0.0.1:8801/v1.1/users/avatars/:userId/:avatarId
        let usersAuthRoute007 = auth.delete("avatars", ":userId", ":avatarId", use: jsonDeletelAvatarByUserIdAndAvatarId)
        usersAuthRoute007.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
       
        // example: http://127.0.0.1:8801/v1.1/users/avatars
        let usersAuthRoute008 = auth.delete ("avatars", use: jsonDeleteAllAvatars)
        usersAuthRoute008.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin], statuses: [.confirmed])
    }

}

enum US_USVarsAndRoutes : Int, CaseIterable {
    case usersServiceHealthRoute
    case usersServiceGenderCasesRoute
    case usersServiceUsersRoute
    case usersServiceSignInRoute
    case usersServiceSignUpRoute
    case usersServiceAvatarsRoute
    
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
        case .usersServiceAvatarsRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users/avatars"
        }
    }
}
