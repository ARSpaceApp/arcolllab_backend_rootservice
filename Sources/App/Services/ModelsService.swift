//  ModelsService.swift
//  Created by Dmitry Samartcev on 11.09.2020.

import Vapor
import SwiftHelperCode

protocol ModelsService {
    
    // MARK: Categoties
    func jsonCategoriesGetAll (req: Request, clientRoute: String) throws -> EventLoopFuture <[ThreeDModelCategoryInput01]>
    func jsonCategoriesGetByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ThreeDModelCategoryInput01>
    func jsonCategoriesStore (req: Request, clientRoute: String) throws -> EventLoopFuture <HTTPResponseStatus>
    func jsonCategoriesUpdateByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ThreeDModelCategoryInput01>
    func jsonCategoriesDeleteByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <HTTPResponseStatus>
    
    //MARK: Models
    // For admins.
    func jsonModelsGetAll(req: Request,  clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]>
    // For anonymous users.
    func jsonModelsGetAllPublic(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]>
    // For registered users (feed).
    func jsonModelsGetAllPublicAndByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]>
    // For registered users (profile).
    func jsonModelsGetAllByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]>
    // Get model by id or name.
    func jsonModelsGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01>
    // Get models by category.
    func jsonModelsGetByCategory(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]>
    // Post new model.
    func jsonModelsStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01>
    // Update existing model by parameter.
    func jsonModelsUpdateByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01>
}

final class ModelsServiceImplementation : ModelsService {

    // MARK: Categoties
    func jsonCategoriesGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelCategoryInput01]> {
        /// http://{{host}}:{{port}}/{{apiversion}}/categories
        fatalError()
    }
    
    func jsonCategoriesGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelCategoryInput01> {
        /// http://{{host}}:{{port}}/{{apiversion}}/categories/:categoryParameter
        fatalError()
    }
    
    func jsonCategoriesStore(req: Request, clientRoute: String) throws -> EventLoopFuture<HTTPResponseStatus> {
        ///http://{{host}}:{{port}}/{{apiversion}}/categories
        fatalError()
    }
    
    func jsonCategoriesUpdateByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ThreeDModelCategoryInput01> {
        /// http://{{host}}:{{port}}/{{apiversion}}/categories/:categoryParameter
        fatalError()
    }
    
    func jsonCategoriesDeleteByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <HTTPResponseStatus> {
        ///http://{{host}}:{{port}}/{{apiversion}}/categories/:categoryParameter
        fatalError()
    }
    
    //MARK: Models
    func jsonModelsGetAll(req: Request,  clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models
        fatalError()
    }
    
    func jsonModelsGetAllPublic(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models/public
        fatalError()
    }
    
    func jsonModelsGetAllPublicAndByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models/publicAndAuthors/:userId
        fatalError()
    }
    
    func jsonModelsGetAllByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models/byAuthor/:userId
        fatalError()
    }
    
    func jsonModelsGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01> {
        /// http://{{host}}:{{port}}/{{apiversion}}/models/:modelParameter
        fatalError()
    }
    
    func jsonModelsGetByCategory(req: Request,  clientRoute: String) throws -> EventLoopFuture<[ThreeDModelResponse01]> {
        /// http://{{host}}:{{port}}/{{apiversion}}/models/byCategory/:categoryId
        fatalError()
    }
    
    func jsonModelsStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models
        fatalError()
    }
    
    func jsonModelsUpdateByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ThreeDModelResponse01> {
        ///http://{{host}}:{{port}}/{{apiversion}}/models/:modelParameter
        fatalError()
    }
    
}
