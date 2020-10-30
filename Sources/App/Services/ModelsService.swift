//  ModelsService.swift
//  Created by Dmitry Samartcev on 11.09.2020.

import Vapor
import SwiftHelperCode

protocol ModelsService {
    
    // MARK: Categoties
    func jsonCategoriesGetAll (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse>
    func jsonCategoriesGetByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse>
    func jsonCategoriesStore (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse>
    func jsonCategoriesUpdateByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse>
    func jsonCategoriesDeleteByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse>
    
    //MARK: Models
    // For admins.
    func jsonModelsGetAll(req: Request,  clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // For anonymous users.
    func jsonModelsGetAllPublic(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // For registered users (feed).
    func jsonModelsGetAllPublicAndByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // For registered users (profile).
    func jsonModelsGetAllByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // Get model by id or name.
    func jsonModelsGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // Get models by category.
    func jsonModelsGetByCategory(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // Post new model.
    func jsonModelsStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // Update existing model by parameter.
    func jsonModelsUpdateByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    // Delete existing model by id.
    func jsonModelsDeleteByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
}

final class ModelsServiceImplementation : ModelsService {

    // MARK: Categoties
    func jsonCategoriesGetAll(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonCategoriesGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        guard let categoryParameter = req.parameters.get("categoryParameter") else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        let string = "\(clientRoute)/\(categoryParameter)"
        return req.client.get(URI(string: string), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonCategoriesStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.post(URI(string: clientRoute), headers: req.headers, beforeSend: {clientRequest in
            let input = try req.content.decode(ThreeDModelCategoryInput01.self)
            try clientRequest.content.encode(input)
        }).flatMapThrowing{$0}
    }
    
    func jsonCategoriesUpdateByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse> {
        guard let categoryParameter = req.parameters.get("categoryParameter") else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        let string = "\(clientRoute)/\(categoryParameter)"
        return req.client.patch(URI(string: string), headers: req.headers, beforeSend: {clientRequest in
            let input = try req.content.decode(ThreeDModelCategoryInput01.self)
            try clientRequest.content.encode(input)
        }).flatMapThrowing{$0}
    }
    
    func jsonCategoriesDeleteByParameter (req: Request, clientRoute: String) throws -> EventLoopFuture <ClientResponse> {
        guard let categoryParameter = req.parameters.get("categoryParameter") else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        let string = "\(clientRoute)/\(categoryParameter)"
        return req.client.delete(URI(string: string), headers: req.headers).flatMapThrowing{$0}
    }
    
    //MARK: Models
    func jsonModelsGetAll(req: Request,  clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonModelsGetAllPublic(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        let string = "\(clientRoute)/public"
        return req.client.get(URI(string: string), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonModelsGetAllPublicAndByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        guard let userIdString = req.parameters.get("userId"), let userId = Int(userIdString) else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        // Validation - a regular user can only request their own models (+ public)
        return try AppValues.checkingAccessRightsForRequest(userId: userId, userName: nil, req: req).flatMapThrowing {_ in
            let string = "\(clientRoute)/publicAndAuthors/\(userId)"
            return req.client.get(URI(string: string), headers: req.headers).flatMapThrowing{$0}
        }.flatMap{$0}
    }
    
    func jsonModelsGetAllByUserId(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        guard let userIdString = req.parameters.get("userId"), let userId = Int(userIdString) else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        return try AppValues.checkingAccessRightsForRequest(userId: userId, userName: nil, req: req).flatMapThrowing {_ in
            let string = "\(clientRoute)/byAuthor/\(userId)"
            return req.client.get(URI(string: string), headers: req.headers).flatMapThrowing{$0}
        }.flatMap{$0}
    }
    
    func jsonModelsGetByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        guard let modelParameter = req.parameters.get("modelParameter") else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        return req.client.get(URI(string: "\(clientRoute)/\(modelParameter)"), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonModelsGetByCategory(req: Request,  clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        
        guard let categoryIdString = req.parameters.get("categoryId"), let categoryId = Int(categoryIdString) else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        
        let string = "\(clientRoute)/byCategory/\(categoryId)"
        return req.client.get(URI(string: string), headers: req.headers).flatMapThrowing{$0}
    }
    
    func jsonModelsStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        
        let userData = try AppValues.getUserInfoFromAccessToken(req: req)
        guard let requestorId = userData.userid else {
            throw Abort(HTTPStatus.forbidden, reason: "Unable to determine user id.")
        }
        
        return req.client.post(URI(string: clientRoute), headers: req.headers, beforeSend: {clientRequest in
            let input = try req.content.decode(ThreeDModelInput.self)
            guard requestorId == input.userId else {
                throw Abort(HTTPStatus.forbidden, reason: "Author must publish model with reference only to his profile (user ID).")
            }
            try clientRequest.content.encode(input)
        }).flatMapThrowing{$0}
    }
    
    func jsonModelsUpdateByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        
        guard let modelParameter = req.parameters.get("modelParameter") else {
            throw Abort(.badRequest, reason: "Request parameter is invalid.")
        }
        
        let userData = try AppValues.getUserInfoFromAccessToken(req: req)
        
        if userData.userRights == .user {
            guard let userId = userData.userid else {
                throw Abort(.badRequest, reason: "Unable to determine user id.")
            }
            
            let string = "\(clientRoute)/\(modelParameter)"
            return req.client.get(URI(string:string), headers: req.headers).flatMapThrowing{response in
                
                let threeDModelResponse = try response.content.decode(ThreeDModelResponse01.self)
                
                guard userId == threeDModelResponse.modelUserId else {
                    throw Abort (HTTPStatus.forbidden, reason: "User can change only own model.")
                }
                
                return req.client.patch(URI(string: string), headers: req.headers, beforeSend: {clientRequest in
                    let input = try req.content.decode(ThreeDModelUpdateInput01.self)
                    try clientRequest.content.encode(input)
                }).flatMapThrowing{$0}
            }.flatMap{$0}
        } else {
            let string = "\(clientRoute)/\(modelParameter)"
            return req.client.patch(URI(string: string), headers: req.headers, beforeSend: {clientRequest in
                let input = try req.content.decode(ThreeDModelUpdateInput01.self)
                try clientRequest.content.encode(input)
            }).flatMapThrowing{$0}
        }
    }
    
    func jsonModelsDeleteByParameter(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        
        guard let modelParameter = req.parameters.get("modelParameter"),
              let modelId = Int(modelParameter) else {
            throw Abort(.badRequest, reason: " Model ID is invalid.")
        }
        
        let userData = try AppValues.getUserInfoFromAccessToken(req: req)
        
        if userData.userRights == .superadmin || userData.userRights == .admin {
            let string = "\(clientRoute)/\(modelId)"
            return req.client.delete(URI(string: string)).flatMapThrowing{$0}
        } else {
            throw Abort(HTTPResponseStatus.forbidden, reason: "Direct deletion of models is available only to administrators")
        }
    }
    
}
