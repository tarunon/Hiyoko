//
//  Tag.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Tag {
    public var name: String
    public var url: URL
}

extension Tag: Decodable {
    public static func decode(_ e: Extractor) throws -> Tag {
        return try Tag.init(
            name: e <| "name",
            url: URL.Transformers.string.apply(e <| "url")
        )
    }
}
