//  AppValues.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation

class AppValues {
    
    // Microservices
    static var USHost   = "127.0.0.1"
    static var USPort   = "8081"
    static var USApiVer = "v1.1"

    // Tokens lifetime
    static let accessTokenLifeTime  : (component: Calendar.Component, value: Int) = (.hour, 4)
    static let refreshTokenLifeTime : (component: Calendar.Component, value: Int) = (.day, 7)
    
    // Other
    static let microserviceHealthMessage : String = "RootService work!"
}

