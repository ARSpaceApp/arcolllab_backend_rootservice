//  Request + Ext.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import JWT

extension Request {

    public var payload: Payload {
        get {
            self.route?.userInfo[.payload] as! Payload
        }
        set {
            self.route?.userInfo[.payload] = newValue
        }
    }

    public var accessRight: AccessRight {
        get {
            self.route?.userInfo[.init(RouteUserInfoKeys.accessRight)] as! AccessRight
        }
        set {
            self.route?.userInfo[.init(RouteUserInfoKeys.accessRight)] = newValue
        }
    }
}

enum RouteUserInfoKeys : Int, CaseIterable {
    case accessRight

    var name : String {
        switch self {
  
        case .accessRight:
            return "accessRight"
        }
    }
}

