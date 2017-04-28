//
//  Attachment.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift

public final class Attachment: Object {
    public dynamic var id: Int = 0
    public dynamic var type: String = ""
    public dynamic var url: URL? = nil
    public dynamic var remoteURL: URL? = nil
    public dynamic var previewURL: URL = URL(fileURLWithPath: "/")
    public dynamic var textURL: URL = URL(fileURLWithPath: "/")

    public override class func primaryKey() -> String? {
        return "id"
    }

    public class func from(id: Int, type: String, url: URL?, remoteURL: URL?, previewURL: URL, textURL: URL) -> Attachment {
        let attachment = Attachment()
        attachment.id = id
        attachment.type = type
        attachment.url = url
        attachment.remoteURL = remoteURL
        attachment.previewURL = previewURL
        attachment.textURL = textURL
        return attachment
    }
}

extension Attachment: Decodable {
    public static func decode(_ e: Extractor) throws -> Attachment {
        return try Attachment.from(
            id: e <| "id",
            type: e <| "type",
            url: URL.Transformers.string.apply(e <|? "url"),
            remoteURL: URL.Transformers.string.apply(e <|? "remote_url"),
            previewURL: URL.Transformers.string.apply(e <| "preview_url"),
            textURL: URL.Transformers.string.apply(e <| "text_url")
        )
    }
}
