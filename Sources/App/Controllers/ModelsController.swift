//  ModelsController.swift
//  Created by Dmitry Samartcev on 11.09.2020.

import Vapor
import SwiftHelperCode

class ModelsController {
    private var modelsService: ModelsService
    
    init(modelsService: ModelsService) {
        self.modelsService = modelsService
    }
    
    func dummy (req: Request) -> EventLoopFuture <String> {
        return req.eventLoop.makeSucceededFuture("Dummy")
    }
    
    // MARK: Categoties
    func jsonCategoriesGetAll (req: Request) throws -> EventLoopFuture <[ThreeDModelCategoryInput01]> {
        return try self.modelsService.jsonCategoriesGetAll(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesGetByParameter (req: Request) throws -> EventLoopFuture <ThreeDModelCategoryInput01> {
        return try self.modelsService.jsonCategoriesGetByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesStore (req: Request) throws -> EventLoopFuture <HTTPResponseStatus> {
        return try self.modelsService.jsonCategoriesStore(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesUpdateByParameter (req: Request) throws -> EventLoopFuture <ThreeDModelCategoryInput01> {
        return try self.modelsService.jsonCategoriesUpdateByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    
    func jsonCategoriesDeleteByParameter (req: Request) throws -> EventLoopFuture <HTTPResponseStatus> {
        return try self.modelsService.jsonCategoriesDeleteByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceCategotiesRoot.description)
    }
    // MARK: Models
    func jsonModelsGetAll(req: Request) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        return try self.modelsService.jsonModelsGetAll(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetAllPublic(req: Request) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        return try self.modelsService.jsonModelsGetAllPublic(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    func jsonModelsGetAllPublicAndByUserId(req: Request) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        return try self.modelsService.jsonModelsGetAllPublicAndByUserId(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetAllByUserId(req: Request) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        return try self.modelsService.jsonModelsGetAllByUserId(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetByParameter(req: Request) throws -> EventLoopFuture<ThreeDModelResponse01> {
        return try self.modelsService.jsonModelsGetByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsGetByCategory(req: Request) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        return try self.modelsService.jsonModelsGetByCategory(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsStore(req: Request) throws -> EventLoopFuture<ThreeDModelResponse01> {
        return try self.modelsService.jsonModelsStore(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
    
    func jsonModelsUpdateByParameter(req: Request) throws -> EventLoopFuture<ThreeDModelResponse01> {
        return try self.modelsService.jsonModelsUpdateByParameter(
            req: req,
            clientRoute: US_MSVarsAndRoutes.modelsServiceModelsRoot.description)
    }
}

extension ModelsController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let models = routes.grouped(.anything, "models")
        let categories = models.grouped(.anything, "categories")
        let categoriesAuth = categories.grouped(JWTMiddleware())
        let modelsAuth = models.grouped(JWTMiddleware())
        
        // MARK: Categoties
        // example: http://127.0.0.1:8082/v1.1/models/categories
        categories.get(use: self.jsonCategoriesGetAll)
        
        // example: http://127.0.0.1:8082/v1.1/models/categories/:categoryParameter
        categories.get(":categoryParameter", use: self.jsonCategoriesGetByParameter)

        // example: http://127.0.0.1:8082/v1.1/models/categories
        categoriesAuth.post(use: self.jsonCategoriesStore)

        // example: http://127.0.0.1:8082/v1.1/models/categories/:categoryParameter
        categoriesAuth.patch(":categoryParameter", use: self.jsonCategoriesUpdateByParameter)

        // example: http://127.0.0.1:8082/v1.1/models/categories/:categoryParameter
        categoriesAuth.delete(":categoryParameter", use: self.jsonCategoriesDeleteByParameter)
       
        // MARK: Models
        // example: http://127.0.0.1:8082/v1.1/models
        modelsAuth.get(use: self.jsonModelsGetAll(req:))
    
        // example: http://127.0.0.1:8082/v1.1/models/public
        models.get("public", use: self.jsonModelsGetAllPublic(req:))

        // example: http://127.0.0.1:8082/v1.1/models/publicAndAuthors/userId
        modelsAuth.get("publicAndAuthors", ":userId", use: self.jsonModelsGetAllPublicAndByUserId(req:))
        
        // example: http://127.0.0.1:8082/v1.1/models/byAuthor/userId
        modelsAuth.get("byAuthor", ":userId", use: self.jsonModelsGetAllByUserId(req:))
       
        // example: http://127.0.0.1:8082/v1.1/models/:modelParameter
        modelsAuth.get(":modelParameter", use: self.jsonModelsGetByParameter(req:))
        
        // example: http://127.0.0.1:8082/v1.1/models/byCategory/:categoryId
        modelsAuth.get("byCategory", ":categoryId", use: self.jsonModelsGetByCategory(req:))
       
        // example: http://127.0.0.1:8082/v1.1/models
        modelsAuth.post(use: self.jsonModelsStore(req:))
       
        // example: http://127.0.0.1:8082/v1.1/models/:modelParameter
        modelsAuth.patch(":modelParameter", use: self.jsonModelsUpdateByParameter(req:))
    }
}

enum US_MSVarsAndRoutes : Int, CaseIterable {
    case modelsServiceCategotiesRoot
    case modelsServiceModelsRoot
    
    var description : String {
        switch self {
        case .modelsServiceCategotiesRoot:
            return "http://\(AppValues.MSHost):\(AppValues.MSPort)/\(AppValues.MSApiVer)/categories"
        case .modelsServiceModelsRoot:
            return "http://\(AppValues.MSHost):\(AppValues.MSPort)/\(AppValues.MSApiVer)/models"
        }
    }
}
