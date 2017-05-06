//
//  SavedSearch.swift
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

public final class SavedSearch: Object {
    public dynamic var id: Int64 = 0
    public dynamic var query: String = ""
    public dynamic var createdAt: Date = Date()
    
    public override class func primaryKey() -> String? {
        return "id"
    }
}

extension SavedSearch: HasID {
    
}

extension SavedSearch: Decodable {
    static func from(id: Int64, query: String, createdAt: Date) -> SavedSearch {
        let search = SavedSearch()
        search.id = id
        search.query = query
        search.createdAt = createdAt
        return search
    }
    
    public static func decode(_ e: Extractor) throws -> SavedSearch {
        return try .from(
            id: e <| "id",
            query: e <| "query",
            createdAt: Date.Transformers.utcString.apply(e <| "created_at")
        )
    }
}

extension AttributeType where ValueType: SavedSearch {
    var id: Attribute<Int64> { return attribute() }
    var query: Attribute<String> { return attribute() }
    var createdAt: Attribute<Date> { return attribute() }
}
