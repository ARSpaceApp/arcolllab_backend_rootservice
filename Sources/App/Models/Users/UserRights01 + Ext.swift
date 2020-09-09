//  UserRights01 + Ext.swift
//  Created by Dmitry Samartcev on 08.09.2020.

import Vapor
import SwiftHelperCode

extension UserRights01 : Content {}

extension UserRights01 {
    var description : String {
        switch self {
        case .user:
            return "user"
        case .admin:
            return "admin"
        case .superadmin:
            return "superadmin"
        }
    }
}
