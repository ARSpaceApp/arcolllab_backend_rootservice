//  AccessRight.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation
import SwiftHelperCode

/// Sets access right to a specific route indicating allowed role and status on service.
public class AccessRight : Hashable, Codable {
    var rights   : [UserRights01]?
    var statuses : [UserStatus01]?
    
    init (rights: [UserRights01]?, statuses: [UserStatus01]?) {
        self.rights = rights
        self.statuses = statuses
    }
    
    public static func == (lhs: AccessRight, rhs: AccessRight) -> Bool {
        
        var hashRoleAndStatus: Bool = false
        if lhs.rights != nil && rhs.rights != nil {
            lhs.rights!.forEach {
                hashRoleAndStatus = rhs.rights!.contains($0)
            }
        } else {
            return false
        }
        if lhs.statuses != nil && rhs.statuses != nil {
            lhs.statuses!.forEach {
                hashRoleAndStatus = rhs.statuses!.contains($0)
            }
        } else {
           return false
        }
        return hashRoleAndStatus
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rights)
        hasher.combine(statuses)
    }
}
 
