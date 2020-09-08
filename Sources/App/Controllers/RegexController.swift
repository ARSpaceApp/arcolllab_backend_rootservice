//  RegexController.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import SwiftHelperCode

final class RegexController {
    
    private var regexService : RegexService
    
    init (regexService : RegexService) {
        self.regexService = regexService
    }
    
    func jsonGetAllCases (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.regexService.jsonGetAllCases(
            req: req,
            clientRoute: US_RSVarsAndRoutes.us_rs_CasesRoute.description)
    }
    func jsonRegexStore (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.regexService.jsonRegexStore(
            req: req,
            clientRoute: US_RSVarsAndRoutes.us_rs_RegexRoute.description)
    }
    func jsonGetAllRegexes (req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.regexService.jsonGetAllRegexes(
            req: req,
            clientRoute: US_RSVarsAndRoutes.us_rs_RegexRoute.description
        )
    }
    func jsonDeleteAllRegexes (req: Request) throws  -> EventLoopFuture<ClientResponse> {
        return try self.regexService.jsonDeleteAllRegexes(
            req: req,
            clientRoute: US_RSVarsAndRoutes.us_rs_RegexRoute.description
        )
    }
}

extension RegexController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // example: http://127.0.0.1:8080/v1.1/regexes
        let regexes = routes.grouped(.anything, "regexes").grouped(JWTMiddleware())
        
        // example: http://127.0.0.1:8080/v1.1/regexes/cases
        // Info Route
        let regexesRoute001 = regexes.get("cases", use: self.jsonGetAllCases)
        regexesRoute001.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
    
        // example: http://127.0.0.1:8080/v1.1/regexes
        let regexesRoute002 = regexes.post(use: self.jsonRegexStore)
        regexesRoute002.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8080/v1.1/regexes
        let regexesRoute003 = regexes.get(use: self.jsonGetAllRegexes)
        regexesRoute003.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8080/v1.1/regexes
        let regexesRoute004 = regexes.delete(use: self.jsonDeleteAllRegexes)
        regexesRoute004.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin], statuses: [.confirmed])
    }
}

enum US_RSVarsAndRoutes : Int, CaseIterable {
    case us_rs_RegexRoute
    case us_rs_CasesRoute

    var description : String {
        switch self {
        case .us_rs_RegexRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/regexes"
        case .us_rs_CasesRoute:
            return "http://\(AppValues.USHost):\(AppValues.USPort)/\(AppValues.USApiVer)/regexes/cases"
        }
    }
}
