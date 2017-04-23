//
//  Mention.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Mention {
    public var url: URL
    public var username: String
    public var acct: String
    public var id: Int
}

extension Mention: Decodable {
    public static func decode(_ e: Extractor) throws -> Mention {
        return try Mention.init(
            url: URL.Transformers.string.apply(e <| "url"),
            username: e <| "username",
            acct: e <| "acct",
            id: e <| "id"
        )
    }
}
