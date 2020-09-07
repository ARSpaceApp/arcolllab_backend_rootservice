//  UserRights.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation

struct UserRights : OptionSet, Codable, Hashable {
    
    let rawValue: Int64
    
    init(rawValue: Int64) {
        self.rawValue = rawValue
    }
    
    init(from decoder: Decoder) throws {
      rawValue = try .init(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
      try rawValue.encode(to: encoder)
    }
    
    static let user       = UserRights(rawValue: 1 << 0)
    static let admin      = UserRights(rawValue: 1 << 1)
    static let superAdmin = UserRights(rawValue: 1 << 2) // 4
}

