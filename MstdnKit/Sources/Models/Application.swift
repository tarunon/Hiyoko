//
//  Application.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Application {
    public var name: String
    public var website: URL?
}

extension Application: Decodable {
    public static func decode(_ e: Extractor) throws -> Application {
        return try Application(
            name: e <| "name",
            website: URL.Transformers.string.apply(e <|? "website")
        )
    }
}
