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
    
    // User can manage regular expressions on service.
    static let canManageRegex        = UserRights(rawValue: 1 << 0)
    // User can manage other users on service.
    static let canManageOtherUsers   = UserRights(rawValue: 1 << 1)
    // User can manage avatars of other users on service.
    static let canManageOtherAvatars = UserRights(rawValue: 1 << 2)
    // User can delete all avatars on service.
    static let canDeleteAllAvatars   = UserRights(rawValue: 1 << 3)

    static let superAdmin : UserRights = [
        .canManageRegex,
        .canManageOtherUsers,
        .canManageOtherAvatars,
        .canDeleteAllAvatars
    ]
    
    static let admin      : UserRights = [
        .canManageOtherUsers,
        .canManageOtherAvatars
    ]

}
