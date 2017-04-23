//
//  Token.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Token {
    public var accessToken: String
    public var tokenType: String
    public var scope: String
    public var created: Date
}

extension Token: Decodable {
    public static func decode(_ e: Extractor) throws -> Token {
        return try Token(
            accessToken: e <| "access_token",
            tokenType: e <| "token_type",
            scope: e <| "scope",
            created: Date.Transformers.timeInterval.apply(e <| "created_at")
        )
    }
}
