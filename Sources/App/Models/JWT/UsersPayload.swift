//  Payload.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import JWT
import Vapor
import SwiftHelperCode

public struct UsersPayload : JWTPayload {

    enum CodingKeys: String, CodingKey {
        case subject        = "sub"
        case expiration     = "exp"
        case userid         = "userid"
        case username       = "username"
        case userRights     = "userRights"
        case userStatus     = "userStatus"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim

    var userid: Int?
    var username: String?
    var userRights: UserRights
    var userStatus: UserStatus

    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

public struct MicroservicesPayload: JWTPayload, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    
    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
