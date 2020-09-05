//  AppValues.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Foundation

class AppValues {
    
    // Tokens lifetime
    static let accessTokenLifeTime  : (component: Calendar.Component, value: Int) = (.hour, 4)
    static let refreshTokenLifeTime : (component: Calendar.Component, value: Int) = (.day, 7)
}

