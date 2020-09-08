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
    
    func jsonGetUserByParameter (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonGetUserByParameter (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
    func jsonUpdateUserByParameter (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.usersService.jsonUpdateUserByParameter (
            req: req,
            clientRoute: US_usVarsAndRoutes.usersServiceUsersRoute.description
        )
    }
    
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
        let usersAuthRoute001 = auth.get(use: self.jsonUsersGetAll)
        usersAuthRoute001.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8080/v1.1/users/:userParameter
        let usersAuthRoute002 = auth.get(":userParameter", use: self.jsonGetUserByParameter)
        usersAuthRoute002.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8080/v1.1/users/:userParameter
        let usersAuthRoute003 = auth.patch(":userParameter", use: self.jsonUpdateUserByParameter)
        usersAuthRoute003.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // Отдельное оббновление для статуса и прав!!!!!!!
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


//                        // 9.6 If the user's status is passed.
//                        if let statusString = userUpdateInput.status, statusString != "" {
//                            do {
//                                let modifyingUserIsAnAdmin = try UserRights.userIsAnAdmin(roleID: Int64(modifyingUserId))
//
//                                // 9.6.1. If user being modified is a supermin, no changes can be made.
//                                if modifiedUser.userRights == .superAdmin {
//                                    throw Abort(.badRequest, reason: USErrorHelper.UsersError.cantChangeRightsOrStatusOfSuperadmin.localizedDescription)
//                                }
//
//                                // 9.6.2.1 Modifying user belongs to 'admins' group.
//                                if modifyingUserIsAnAdmin {
//                                    // 9.6.2.1.1 If modifying and modified user is one person.
//                                    if modifyingUserId == modifiedUser.id {
//                                        // 9.6.2.1.1.1 Если статус меняется на 'archived' (профиль удаляется (архивируется))
//                                        if statusString == Status.archived.rawValue {
//                                            if let newStatus = Status.allCases.first(where: {$0.rawValue == statusString}) {
//                                                modifiedUser.status = newStatus
//                                            }
//                                        // Error - direct self-hosted change of your own important data is prohibited.
//                                        } else {
//                                            throw Abort(HTTPResponseStatus.forbidden, reason: USErrorHelper.UsersError.cantChangeOwnSignificantData(key: "user status").localizedDescription)
//                                        }
//                                    // 9.6.2.1.2 If modifying user and modified user they are different people.
//                                    } else {
//                                        if let newStatus = Status.allCases.first(where: {$0.rawValue == statusString}) {
//                                            modifiedUser.status = newStatus
//                                        }
//                                    }
//
//
//                                // 9.6.2.2 Modifying user is not a member of 'admins' group.
//                                } else {
//                                    // 9.6.2.2.1 If modifying and modified user is one person.
//                                    if modifyingUserId == modifiedUser.id {
//                                        // 9.6.2.2.1.1 Если статус меняется на 'archived' (профиль удаляется (архивируется))
//                                        if statusString == Status.archived.rawValue {
//                                            if let newStatus = Status.allCases.first(where: {$0.rawValue == statusString}) {
//                                                modifiedUser.status = newStatus
//                                            }
//                                        // Error - direct self-hosted change of your own important data is prohibited.
//                                        } else {
//                                            throw Abort(
//                                                HTTPResponseStatus.forbidden,
//                                                reason: USErrorHelper.UsersError.cantChangeOwnSignificantData(key: "user status").localizedDescription)
//                                        }
//                                    // 9.6.2.2.2 If modifying user and modified user they are different people.
//                                    } else {
//                                        // Error - only administrators or owner of profile can change this data.
//                                        throw Abort(HTTPResponseStatus.forbidden, reason: USErrorHelper.UsersError.accessErrorToMakeChange.localizedDescription)
//                                    }
//                                }
//                            } catch {
//                                throw error
//                            }
//                        }
//
//                        // 9.7 If the user's role is passed
//                        if let userRightsInt = userUpdateInput.rights {
//
//                            do {
//                                let modifyingUserIsAnAdmin = try UserRights.userIsAnAdmin(roleID: Int64(modifyingUserId))
//
//                                // 9.7.1. If user being modified is a supermin, no changes can be made.
//                                if modifiedUser.userRights == .superAdmin {
//                                    throw Abort(.badRequest, reason: USErrorHelper.UsersError.cantChangeRightsOrStatusOfSuperadmin.localizedDescription)
//                                }
//
//                                // 9.7.2.1 Modifying user belongs to 'admins' group.
//                                if modifyingUserIsAnAdmin {
//                                    // 9.7.2.1.1 If modifying and modified user is one person.
//                                    if modifyingUserId == modifiedUser.id {
//                                        // Error - direct self-hosted change of your own important data is prohibited.
//                                        throw Abort(
//                                            HTTPResponseStatus.forbidden,
//                                            reason: USErrorHelper.UsersError.cantChangeOwnSignificantData(key: "user rights").localizedDescription)
//                                    // 9.7.2.1.2 If modifying user and modified user they are different people.
//                                    } else {
//                                        modifiedUser.userRights = try UserRights.getUserRightsBy(roleID: userRightsInt)
//                                    }
//
//                                // 9.7.2.2 Modifying user is not a member of 'admins' group.
//                                } else {
//                                    // Error - only administrators can change this data.
//                                    throw Abort(
//                                        HTTPResponseStatus.forbidden,
//                                        reason: USErrorHelper.UsersError.cantChangeOwnSignificantData(key: "user rigts").localizedDescription)
//                                }
//                            } catch {
//                                throw error
//                            }
//
//                        }


