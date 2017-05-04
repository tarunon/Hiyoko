//
//  TwitterError.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/30.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct TwitterError: Error {
    public struct Error: Swift.Error {
        public var code: Int
        public var message: String
    }
    public var errors: [Error]
}

extension TwitterError.Error: Decodable {
    public static func decode(_ e: Extractor) throws -> TwitterError.Error {
        return try .init(
            code: e <| "code",
            message: e <| "message"
        )
    }
}

extension TwitterError: Decodable {
    public static func decode(_ e: Extractor) throws -> TwitterError {
        return try .init(
            errors: e <|| "errors"
        )
    }
}
