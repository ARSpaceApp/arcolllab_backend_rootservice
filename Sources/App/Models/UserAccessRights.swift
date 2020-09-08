//  UserAccessRights.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Vapor
import Fluent
import SwiftHelperCode

extension FieldKey {
    // Keys for UserAccessRights
    static var rightsId:        Self    { "rightsId" }
    static var userId:          Self    { "userId" }
    static var userStatus:      Self    { "userStatus" }
    static var userRights:      Self    { "userRights" }
    static var rightsCreatedAt: Self    { "rightsCreatedAt" }
    static var rightsUpdateAt:  Self    { "rightsUpdateAt" }
    static var rightsDeleteAt:  Self    { "rightsDeleteAt" }
}

final class UserAccessRights :  Model, Content {
    static let schema = "userAccessRights"
    
    @ID            (custom: FieldKey.rightsId, generatedBy: .database) var id:         Int?
    @Field         (key: FieldKey.userId)                              var userId:     Int
    @Field         (key: FieldKey.userStatus)                          var userStatus: UserStatus01
    @Field         (key: FieldKey.userRights)                          var userRights: UserRights01
    @Timestamp     (key: FieldKey.rightsCreatedAt, on: .create)        var createdAt:  Date?
    @Timestamp     (key: FieldKey.rightsUpdateAt, on: .update)         var updatedAt:  Date?
    @Timestamp     (key: FieldKey.rightsDeleteAt, on: .delete)         var deleteAt:   Date?
    
    init () {}
    
    init(id: Int? = nil, userId: Int, userStatus: UserStatus01, userRights: UserRights01) throws {
        self.userId = userId
        self.userStatus = userStatus
        self.userRights = userRights
    }
}
