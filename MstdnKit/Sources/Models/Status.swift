//
//  Status.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import Base

public struct Status {
    public var id: Int
    public var uri: String
    public var url: URL
    public var account: Account
    public var inReplyToId: Int?
    public var inReplyToAccountId: Int?
    public var reblog: Box<Status?>
    public var content: String
    public var created: Date
    public var reblogsCount: Int
    public var favouritesCount: Int
    public var reblogged: Bool
    public var favourited: Bool
    public var sensitive: Bool
    public var spoilerText: String?
    public var visibility: String
    public var mediaAttachments: [Attachment]
    public var mentions: [Mention]
    public var tags: [Tag]
    public var application: Application
}

extension Status: Decodable {
    public static func decode(_ e: Extractor) throws -> Status {
        return try Status.init(
            id: e <| "id",
            uri: e <| "uri",
            url: URL.Transformers.string.apply(e <| "url"),
            account: e <| "account",
            inReplyToId: e <|? "in_reply_to_id",
            inReplyToAccountId: e <|? "in_reply_to_account_id",
            reblog: Box.init(e <|? "reblog"),
            content: e <| "content",
            created: Date.Transformers.timeInterval.apply(e <| "created_at"),
            reblogsCount: e <| "reblogs_count",
            favouritesCount: e <| "favourites_count",
            reblogged: e <| "reblogged",
            favourited: e <| "favourited",
            sensitive: e <| "sensitive",
            spoilerText: e <|? "spoiler_text",
            visibility: e <| "visibility",
            mediaAttachments: e <|| "media_attachments",
            mentions: e <|| "mentions",
            tags: e <|| "tags",
            application: e <| "application"
        )
    }
}
