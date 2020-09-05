//  RefreshToken.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import JWT

struct RefreshToken: JWTPayload {
    let id: Int
    let iat: TimeInterval
    let exp: TimeInterval
    
    init(userId: Int) {
        let lifeTime = Date.createNewDate(originalDate: Date(), byAdding: AppValues.refreshTokenLifeTime.component, number: AppValues.refreshTokenLifeTime.value)

        self.id = userId
        self.iat = Date().timeIntervalSinceNow
        self.exp = lifeTime!.timeIntervalSince1970
    }
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired() }
}

struct RefreshTokenInput: Content {
    let refreshToken: String
}

struct RefreshTokenResponse: Content {
    let accessToken: String
    let refreshToken: String
}
