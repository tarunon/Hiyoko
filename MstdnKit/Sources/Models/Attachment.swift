//
//  Attachment.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Attachment {
    public var id: Int
    public var type: String
    public var url: URL?
    public var remoteURL: URL?
    public var previewURL: URL
    public var textURL: URL
}

extension Attachment: Decodable {
    public static func decode(_ e: Extractor) throws -> Attachment {
        return try Attachment.init(
            id: e <| "id",
            type: e <| "type",
            url: URL.Transformers.string.apply(e <|? "url"),
            remoteURL: URL.Transformers.string.apply(e <|? "remote_url"),
            previewURL: URL.Transformers.string.apply(e <| "preview_url"),
            textURL: URL.Transformers.string.apply(e <| "text_url")
        )
    }
}
