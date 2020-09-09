//  UserStatus01 + Ext.swift
//  Created by Dmitry Samartcev on 08.09.2020.

import Vapor
import SwiftHelperCode

extension UserStatus01 : Content {}

extension UserStatus01 {
    var description : String {
        switch self {

        case .created:
            return "created"
        case .confirmed:
            return "confirmed"
        case .blocked:
            return "blocked"
        case .archived:
            return "archived"
        }
    }
}
