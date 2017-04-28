//
//  Mention.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift

public final class Mention: Object {
    public dynamic var url: URL = URL(fileURLWithPath: "/")
    public dynamic var username: String = ""
    public dynamic var acct: String = ""
    public dynamic var id: Int = 0
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public class func from(url: URL, username: String, acct: String, id: Int) -> Mention {
        let mention = Mention()
        mention.url = url
        mention.username = username
        mention.acct = acct
        mention.id = id
        return mention
    }
}

extension Mention: Decodable {
    public static func decode(_ e: Extractor) throws -> Mention {
        return try Mention.from(
            url: URL.Transformers.string.apply(e <| "url"),
            username: e <| "username",
            acct: e <| "acct",
            id: e <| "id"
        )
    }
}
