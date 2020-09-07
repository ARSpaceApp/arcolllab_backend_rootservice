//  ProjectServices.swift
//  Created by Dmitry Samartcev on 06.09.2020.

import Foundation

enum ProjectServices {
    static let rootService: RootService = RootServiceImplementation()
    static let regexService: RegexService = RegexServiceImplementation()
    static let userService: UsersService = UsersServiceImplementation()
}
