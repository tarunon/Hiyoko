//
//  Tag.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift

public final class Tag: Object {
    public var name: String = ""
    public var url: URL = URL(fileURLWithPath: "/")
    
    public override class func primaryKey() -> String? {
        return "name"
    }
    
    public class func from(name: String, url: URL) -> Tag {
        let tag = Tag()
        tag.name = name
        tag.url = url
        return tag
    }
}

extension Tag: Decodable {
    public static func decode(_ e: Extractor) throws -> Tag {
        return try Tag.from(
            name: e <| "name",
            url: URL.Transformers.string.apply(e <| "url")
        )
    }
}
