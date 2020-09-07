//  Request + Ext.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import JWT

extension Request {

    public var usersPayload: UsersPayload {
        get {
            self.route?.userInfo[.payload] as! UsersPayload
        }
        set {
            self.route?.userInfo[.payload] = newValue
        }
    }
    
    public var microservicesPayload: MicroservicesPayload {
        get {
            self.route?.userInfo[.microservicesPayload] as! MicroservicesPayload
        }
        set {
            self.route?.userInfo[.microservicesPayload] = newValue
        }
    }

    public var accessRight: AccessRight {
        get {
            self.route?.userInfo[.accessRight] as! AccessRight
        }
        set {
            self.route?.userInfo[accessRight] = newValue
        }
    }
}

extension AnyHashable {
    static let payload: String = "jwt_payload"
    static let microservicesPayload: String = "jwt_microservicesPayload"
    static let accessRight : String = "accessRight"
}
