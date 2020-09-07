//  UsersController.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import SwiftHelperCode

final class UsersController {
    
    private var usersService: UsersService!
    
    init (usersService: UsersService) {
        self.usersService = usersService
    }
    
//    func jsonUserSignUp(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
//        return try self.usersService.jsonUserSignUp (
//            req: req,
//            clientRoute: "\(API.usersRoute.description)/signup"
//        )
//    }
    
    func jsonUserSignIn(req: Request) throws -> EventLoopFuture<UserWithTokensResponse> {
        return try self.usersService.jsonUserSignIn (
            req: req,
            clientRoute: USVarsAndRoutes.usersServiceSignInRoute.description
        )
    }
     
    func jsonUsersGetAll(req: Request) throws -> EventLoopFuture<[UserResponse01]> {
        return try self.usersService.jsonUsersGetAll (
            req: req,
            clientRoute: USVarsAndRoutes.usersServiceUsersRoute.description
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
        
        
        
        // example: http://127.0.0.1:8080/v1.1/users/signin
        // usersRoute002
        users.post("signin", use: self.jsonUserSignIn)
        
        // example: http://127.0.0.1:8080/v1.1/users
        let usersRoute003 = users.get(use: self.jsonUsersGetAll)
        usersRoute003.userInfo[RouteUserInfoKeys.accessRight] =
          AccessRight(rights: [.superAdmin, .admin], statuses: [.confirmed])
        
        
        
//        // example: http://127.0.0.1:8080/v1.1/users/signup
        //usersRoute001
//        users.post("signup", use: self.jsonUserSignUp)
        
//        // example: http://127.0.0.1:8080/v1.1/users/:userParameter
//        let user = users.grouped(":userParameter")
//
//
        
//        user.patch(use: self.jsonUserUpdate)
        
        

//            let data = req.body.string.data(using: .utf8)!
//            do {
//                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,String>]
//                {
//                   print(jsonArray) // use the json here
//                    return req.eventLoop.makeSucceededFuture(jsonArray)
//                } else {
//                    throw Abort(.badRequest, reason: "error")
//                }
//            } catch let error as NSError {
//                throw Abort(.badRequest, reason: "error")
//            }
//
//            //return req.eventLoop.makeSucceededFuture("Dummy")
//        }
        
        
       // users.po
    
        
        //// example: http://127.0.0.1:8080/v1.1/users/signup
       // root.post("signup", use: self.json_userDirectSignUp)
        
        
        
//        let usersSignIn = users.post("signin") { req in
//
//
//
//
//
//
//
//
//
//
//
//
//            return req.eventLoop.makeSucceededFuture("Dummy")
//        }
//
        
        
        
        
//        usersSignIn.userInfo[RouteUserInfoKeys.accessRight] =
//            AccessRight(rights: [], statuses: [])

        /*
         routeUS01.userInfo[RouteUserInfoKeys.accessRight] =
             AccessRight(rights: [.superAdmin, .admin], statuses: [.confirmed])
         
         */
        
//        // Regex
//        let regexes = routes.grouped(.anything, "regexes")
//        regexes.get { req in
//            return req.client.get(URI(string: API.regexesRoute.description)).map { response in
//                return  response
//            }
//        }
//
//
//
//        // User statuses
//        let statuses = users.grouped("statuses")
//        statuses.get { req in
//            return req.client.get(URI(string: "\(API.usersRoute.description)/statuses")).map { response in
//                return  response
//            }
//        }
//
        
        
        
    }

}


enum USVarsAndRoutes : Int, CaseIterable {
    case usersServiceHealthRoute
    case usersServiceUsersRoute
    case usersServiceSignInRoute
    
    var description : String {
        switch self {
        case .usersServiceHealthRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/health"
        case .usersServiceUsersRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users"
        case .usersServiceSignInRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/users/signin"
        
        }
    }
}
