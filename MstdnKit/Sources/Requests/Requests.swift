//
//  Requests.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import Himotoki

// namespace
public struct Requests {
    public struct MstdnError: Swift.Error {
        public let error: String
    }
}

public protocol RequestBase: Request {
    associatedtype Error = Requests.MstdnError
}

extension Requests.MstdnError: Decodable {
    public static func decode(_ e: Extractor) throws -> Requests.MstdnError {
        return try Requests.MstdnError.init(
            error: e <| "error"
        )
    }
}
