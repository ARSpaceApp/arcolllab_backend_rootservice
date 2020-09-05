//  UserStatus.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation

struct UserStatus : OptionSet, Codable, CustomStringConvertible, Hashable {
    
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
    
    static let created      = UserStatus(rawValue: 1 << 0)
    static let confirmed    = UserStatus(rawValue: 1 << 1)
    static let blocked      = UserStatus(rawValue: 1 << 2)
    static let archived     = UserStatus(rawValue: 1 << 3)

    var description: String {
        var vals = [String]()

        if self.contains(.created) {
            vals.append("created")
        }
        if self.contains(.confirmed) {
            vals.append("confirmed")
        }
        if self.contains(.blocked) {
            vals.append("blocked")
        }
        if self.contains(.archived) {
            vals.append("archived")
        }
        
        return vals.joined(separator: ",")
    }

}
