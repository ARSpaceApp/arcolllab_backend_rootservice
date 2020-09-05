//  UsersController.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor

enum API : Int, CaseIterable {
   
    case usersRoute
    case regexesRoute

    var description : String {
        switch self {
        case .usersRoute:
            return "http://127.0.0.1:8081/v1.1/users"
        case .regexesRoute:
            return "http://127.0.0.1:8081/v1.1/regex"
        }
    }
}

final class UsersController {
}

extension UsersController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
    
        let users = routes.grouped(.anything, "users")
        let usersSignIn = users.post("signin") { req in
            
            
            
            
            
            
            
            
            
            
            
            
            return req.eventLoop.makeSucceededFuture("Dummy")
        }
        
        
        
        
        
//        usersSignIn.userInfo[RouteUserInfoKeys.accessRight] =
//            AccessRight(rights: [], statuses: [])

        /*
         routeUS01.userInfo[RouteUserInfoKeys.accessRight] =
             AccessRight(rights: [.superAdmin, .admin], statuses: [.confirmed])
         
         */
        
        // Regex
        let regexes = routes.grouped(.anything, "regexes")
        regexes.get { req in
            return req.client.get(URI(string: API.regexesRoute.description)).map { response in
                return  response
            }
        }
        
        

        // User statuses
        let statuses = users.grouped("statuses")
        statuses.get { req in
            return req.client.get(URI(string: "\(API.usersRoute.description)/statuses")).map { response in
                return  response
            }
        }
        
        
        
        
    }

}


// Вход по логину и паролю ->
// 1. Передача на сервис + что-то отправить чтобы удостоверить что это я
// 2. Получение от сервиса ответа и валидация по коду
// 3. Если 200 - прилепить токены и отдать
// 3.1 Если не 200 - вернуть как есть

