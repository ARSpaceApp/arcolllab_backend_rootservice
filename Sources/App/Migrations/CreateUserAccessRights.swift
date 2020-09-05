//  CreateUserAccessRights.swift
//  Created by Dmitry Samartcev on 05.09.2020.

import Fluent
import Vapor

struct CreateUserAccessRights: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserAccessRights.schema)
            .field(FieldKey.rightsId,         .int, .identifier(auto: true))
            .field(FieldKey.userId,           .int)
            .field(FieldKey.userStatus,       .int64, .required)
            .field(FieldKey.userRights,       .int64, .required)
            .field(FieldKey.rightsCreatedAt,  .datetime)
            .field(FieldKey.rightsUpdateAt,   .datetime)
            .field(FieldKey.rightsDeleteAt,   .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserAccessRights.schema).delete()
    }
}
