//  UserStatus01 + Ext.swift
//  Created by Dmitry Samartcev on 08.09.2020.

import Vapor
import SwiftHelperCode

extension UserStatus01 : Content {}


//        validations.add("status", as: String.self,
//                        is: .empty || (!.empty && .in(Status.created.rawValue, Status.confirmed.rawValue, Status.blocked.rawValue, Status.archived.rawValue)),
//                        required: false
//        )
//
//        validations.add("userRights", as: Int64.self,
//                        is: .range(_: UserRights.groupRange()),
//                        required: false
//        )
