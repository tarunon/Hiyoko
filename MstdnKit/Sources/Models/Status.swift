//
//  Status.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift
import Barrel
import Barrel_Realm

public final class Status: Object {
    public dynamic var id: Int = 0
    public dynamic var uri: String = ""
    public dynamic var url: URL = URL(fileURLWithPath: "/")
    public dynamic var account: Account?
    public let inReplyToId: RealmOptional<Int> = RealmOptional()
    public let inReplyToAccountId: RealmOptional<Int> = RealmOptional()
    public dynamic var reblog: Status?
    public dynamic var content: String = ""
    public dynamic var created: Date = Date()
    public dynamic var reblogsCount: Int = 0
    public dynamic var favouritesCount: Int = 0
    public dynamic var reblogged: Bool = false
    public dynamic var favourited: Bool = false
    public dynamic var sensitive: Bool = false
    public dynamic var spoilerText: String? = nil
    public dynamic var visibility: String = ""
    public let mediaAttachments: List<Attachment> = List()
    public let mentions: List<Mention> = List()
    public let tags: List<Tag> = List()
    public dynamic var applicationName: String = ""
    public dynamic var applicationUrl: URL? = nil
    
    public override class func primaryKey() -> String? {
        return "id"
    }

    public class func from(id: Int, uri: String, url: URL, account: Account?, inReplyToId: Int?, inReplyToAccountId: Int?, reblog: Status?, content: String, created: Date, reblogsCount: Int, favouritesCount: Int, reblogged: Bool, favourited: Bool, sensitive: Bool, spoilerText: String?, visibility: String, mediaAttachments: [Attachment], mentions: [Mention], tags: [Tag], applicationName: String, applicationUrl: URL?) -> Status {
        let status = Status()
        status.id = id
        status.uri = uri
        status.url = url
        status.account = account
        status.inReplyToId.value = inReplyToId
        status.inReplyToAccountId.value = inReplyToAccountId
        status.reblog = reblog
        status.content = content
        status.created = created
        status.reblogsCount = reblogsCount
        status.favouritesCount = favouritesCount
        status.reblogged = reblogged
        status.favourited = favourited
        status.sensitive = sensitive
        status.spoilerText = spoilerText
        status.visibility = visibility
        status.mediaAttachments.append(objectsIn: mediaAttachments)
        status.mentions.append(objectsIn: mentions)
        status.tags.append(objectsIn: tags)
        status.applicationName = applicationName
        status.applicationUrl = applicationUrl
        return status
    }
}

extension Status: Decodable {
    public static func decode(_ e: Extractor) throws -> Status {
        return try Status.from(
            id: e <| "id",
            uri: e <| "uri",
            url: URL.Transformers.string.apply(e <| "url"),
            account: e <| "account",
            inReplyToId: e <|? "in_reply_to_id",
            inReplyToAccountId: e <|? "in_reply_to_account_id",
            reblog: e <|? "reblog",
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
            applicationName: e <| KeyPath(["application", "name"]),
            applicationUrl: URL.Transformers.string.apply(e <|? KeyPath(["application", "url"]))
        )
    }
}

extension AttributeType where ValueType: Status {
    public var id: Attribute<Int> { return attribute() }
    public var uri: Attribute<String> { return attribute() }
    public var url: Attribute<String> { return attribute() }
    public var account: Attribute<Account?> { return attribute() }
    public var inReplyToId: Attribute<Int?> { return attribute() }
    public var inReplyToAccountId: Attribute<Int?> { return attribute() }
    public var reblog: Attribute<Status?> { return attribute() }
    public var content: Attribute<String> { return attribute() }
    public var created: Attribute<Date> { return attribute() }
    public var reblogsCount: Attribute<Int> { return attribute() }
    public var favouritesCount: Attribute<Int> { return attribute() }
    public var reblogged: Attribute<Bool> { return attribute() }
    public var favourited: Attribute<Bool> { return attribute() }
    public var sensitive: Attribute<Bool> { return attribute() }
    public var spoilerText: Attribute<String?> { return attribute() }
    public var visibility: Attribute<String> { return attribute() }
    public var mediaAttachments: Attribute<List<Attachment>> { return attribute() }
    public var mentions: Attribute<List<Mention>> { return attribute() }
    public var tags: Attribute<List<Tag>> { return attribute() }
    public var applicationName: Attribute<String> { return attribute() }
    public var applicationUrl: Attribute<String?> { return attribute() }
}
