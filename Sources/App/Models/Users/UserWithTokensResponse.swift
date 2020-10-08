//  UserWithTokensResponse.swift
//  Created by Dmitry Samartcev on 06.09.2020.

import Vapor
import SwiftHelperCode

extension RefreshTokenResponse01 : Content {}

extension UserResponse01 : Content {}

// Depricate -> Go to SHC!
struct UserWithTokensResponse : Content {
    let tokens : RefreshTokenResponse01
    let user   : UserResponse01
}

