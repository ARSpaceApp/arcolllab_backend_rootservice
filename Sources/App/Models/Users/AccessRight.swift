//  AccessRight.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation

/// Sets access right to a specific route indicating allowed role and status on service.
public class AccessRight : Hashable, Codable {
    var rights   : [UserRights]?
    var statuses : [UserStatus]?
    
    init (rights: [UserRights]?, statuses: [UserStatus]?) {
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
 
