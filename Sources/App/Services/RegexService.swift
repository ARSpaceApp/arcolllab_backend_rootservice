//  RegexService.swift
//  Created by Dmitry Samartcev on 07.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

protocol RegexService {
    func jsonGetAllCases (req: Request,  clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    func jsonRegexStore (req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    func jsonGetAllRegexes (req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse>
    func jsonDeleteAllRegexes (req: Request, clientRoute: String) throws  -> EventLoopFuture<ClientResponse>
}

final class RegexServiceImplementation : RegexService {
    
    func jsonGetAllCases(req: Request,  clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMapThrowing{res in
            return res
        }
    }
    
    func jsonRegexStore(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.post(URI(string: clientRoute), headers: req.headers, beforeSend: { clientRequest in
            let input = try req.content.decode(RegexRegister.self)
            try clientRequest.content.encode(input)
        }).flatMapThrowing {$0}
    }
    
    func jsonGetAllRegexes(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: clientRoute), headers: req.headers).flatMapThrowing{res in
            return res
        }
    }

    func jsonDeleteAllRegexes(req: Request, clientRoute: String) throws -> EventLoopFuture<ClientResponse> {
        return req.client.delete(URI(string: clientRoute), headers: req.headers).flatMapThrowing {$0}
    }
}
