//  ModelsController.swift
//  Created by Dmitry Samartcev on 11.09.2020.

import Vapor
import SwiftHelperCode

class ModelsController {
    private var modelsService: ModelsService
    
    init(modelsService: ModelsService) {
        self.modelsService = modelsService
    }
    
    // MARK: Categoties
    func jsonCategoriesGetAll (req: Request) throws -> EventLoopFuture <ClientResponse> {
        return try self.modelsService.jsonCategoriesGetAll(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesGetByParameter (req: Request) throws -> EventLoopFuture <ClientResponse> {
        return try self.modelsService.jsonCategoriesGetByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesStore (req: Request) throws -> EventLoopFuture <ClientResponse> {
        return try self.modelsService.jsonCategoriesStore(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesUpdateByParameter (req: Request) throws -> EventLoopFuture <ClientResponse> {
        return try self.modelsService.jsonCategoriesUpdateByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesDeleteByParameter (req: Request) throws -> EventLoopFuture <ClientResponse> {
        return try self.modelsService.jsonCategoriesDeleteByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    // MARK: Models
    func jsonModelsGetAll(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetAll(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetAllPublic(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetAllPublic(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    func jsonModelsGetAllPublicAndByUserId(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetAllPublicAndByUserId(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetAllByUserId(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetAllByUserId(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetByParameter(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetByCategory(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsGetByCategory(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsStore(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsStore(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsUpdateByParameter(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return try self.modelsService.jsonModelsUpdateByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsDeleteByParameter(req: Request) throws -> EventLoopFuture<ClientResponse>  {
        return try self.modelsService.jsonModelsDeleteByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description
        )
    }
}

extension ModelsController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let models = routes.grouped(.anything, "models")
        let categories = models.grouped("categories")
        let categoriesAuth = categories.grouped(JWTMiddleware())
        let modelsAuth = models.grouped(JWTMiddleware())
        
        // MARK: Categoties
        // example: http://127.0.0.1:8801/v1.1/models/categories
        let modelsRoute001 = categories.get(use: self.jsonCategoriesGetAll)
        modelsRoute001.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/models/categories/:categoryParameter
        let modelsRoute002 = categories.get(":categoryParameter", use: self.jsonCategoriesGetByParameter)
        modelsRoute002.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])

        // example: http://127.0.0.1:8801/v1.1/models/categories
        let modelsRoute003 = categoriesAuth.post(use: self.jsonCategoriesStore)
        modelsRoute003.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])

        // example: http://127.0.0.1:8801/v1.1/models/categories/:categoryParameter
        let modelsRoute004 = categoriesAuth.patch(":categoryParameter", use: self.jsonCategoriesUpdateByParameter)
        modelsRoute004.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])

        // example: http://127.0.0.1:8801/v1.1/models/categories/:categoryParameter
        let modelsRoute005 = categoriesAuth.delete(":categoryParameter", use: self.jsonCategoriesDeleteByParameter)
        modelsRoute005.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
    
        
        // MARK: Models
        // example: http://127.0.0.1:8801/v1.1/models
        let modelsRoute006 = modelsAuth.get(use: self.jsonModelsGetAll(req:))
        modelsRoute006.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
    
        // example: http://127.0.0.1:8801/v1.1/models/public
        // modelsRoute007
        models.get("public", use: self.jsonModelsGetAllPublic(req:))

        // example: http://127.0.0.1:8801/v1.1/models/publicAndAuthors/userId
        let modelsRoute008 = modelsAuth.get("publicAndAuthors", ":userId", use: self.jsonModelsGetAllPublicAndByUserId(req:))
        modelsRoute008.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/models/byAuthor/userId
        let modelsRoute009 = modelsAuth.get("byAuthor", ":userId", use: self.jsonModelsGetAllByUserId(req:))
        modelsRoute009.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
       
        // example: http://127.0.0.1:8801/v1.1/models/:modelParameter
        let modelsRoute010 = modelsAuth.get(":modelParameter", use: self.jsonModelsGetByParameter(req:))
        modelsRoute010.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/models/byCategory/:categoryId
        let modelsRoute011 = modelsAuth.get("byCategory", ":categoryId", use: self.jsonModelsGetByCategory(req:))
        modelsRoute011.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
       
        // example: http://127.0.0.1:8801/v1.1/models
        let modelsRoute012 = modelsAuth.on(.POST,  body: .collect(maxSize: "200mb"),  use: jsonModelsStore)
        modelsRoute012.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
       
        // example: http://127.0.0.1:8801/v1.1/models/:modelParameter
        let modelsRoute013 = modelsAuth.patch(":modelParameter", use: self.jsonModelsUpdateByParameter(req:))
        modelsRoute013.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin, .user], statuses: [.confirmed])
        
        // example: http://127.0.0.1:8801/v1.1/models/:modelParameter
        let modelsRoute014 = modelsAuth.delete(":modelParameter", use: self.jsonModelsDeleteByParameter(req:))
        modelsRoute014.userInfo[.accessRight] =
            AccessRight(rights: [.superadmin, .admin], statuses: [.confirmed])
    }
}

enum US_MSVarsAndRoutes : Int, CaseIterable {
    case modelsServiceHealthRoot
    case modelsServiceCategotiesRoot
    case modelsServiceModelsRoot
    
    var description : String {
        switch self {
        case .modelsServiceHealthRoot:
            return "http://\(AppValues.MSHost):\(AppValues.MSPort)/\(AppValues.MSApiVer)/health"
        case .modelsServiceCategotiesRoot:
            return "http://\(AppValues.MSHost):\(AppValues.MSPort)/\(AppValues.MSApiVer)/categories"
        case .modelsServiceModelsRoot:
            return "http://\(AppValues.MSHost):\(AppValues.MSPort)/\(AppValues.MSApiVer)/models"
        }
    }
}
