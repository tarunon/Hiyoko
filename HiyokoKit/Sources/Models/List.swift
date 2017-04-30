//
//  List.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/29.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Himotoki
import Illuso
import Barrel
import Barrel_Realm

public final class List: Object {
    public dynamic var id: Int64 = 0
    public dynamic var slug: String = ""
    public dynamic var name: String = ""
    public dynamic var uri: String = ""
    public dynamic var createdAt: Date = Date()
    public dynamic var subscriberCount: Int = 0
    public dynamic var mode: String = ""
    public dynamic var fullName: String = ""
    public dynamic var listDescription: String = ""
    public dynamic var following: Bool = false
    fileprivate dynamic var _user: User? = nil

    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["user"]
    }
}

extension List {
    var user: User {
        set {
            _user = newValue
        }
        get {
            return _user!
        }
    }
}

extension List: Decodable {
    static func from(id: Int64, slug: String, name: String, uri: String, createdAt: Date, subscriberCount: Int, mode: String, fullName: String, listDescription: String, following: Bool, user: User) -> List {
        let list = List()
        list.id = id
        list.slug = slug
        list.name = name
        list.uri = uri
        list.createdAt = createdAt
        list.subscriberCount = subscriberCount
        list.mode = mode
        list.fullName = fullName
        list.listDescription = listDescription
        list.following = following
        list.user = user
        return list
    }
    
    public static func decode(_ e: Extractor) throws -> List {
        return try .from(
            id: e <| "id",
            slug: e <| "slug",
            name: e <| "name",
            uri: e <| "uri",
            createdAt: Date.Transformers.utcString.apply(e <| "created_at"),
            subscriberCount: e <| "subscriber_count",
            mode: e <| "mode",
            fullName: e <| "full_name",
            listDescription: e <| "description",
            following: e <| "following",
            user: e <| "user"
        )
    }
}
