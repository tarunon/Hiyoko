//
//  Account.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public struct Account {
    public var id: Int
    public var username: String
    public var acct: String
    public var displayName: String
    public var locked: Bool
    public var created: Date
    public var followersCount: Int
    public var followingCount: Int
    public var statusesCount: Int
    public var note: String?
    public var url: URL
    public var avatar: URL?
    public var avatarStatic: URL?
    public var header: URL?
    public var headerStatic: URL?
}

extension Account: Decodable {
    public static func decode(_ e: Extractor) throws -> Account {
        return try Account(
            id: e <| "id",
            username: e <| "username",
            acct: e <| "acct",
            displayName: e <| "display_name",
            locked: e <| "locked",
            created: Date.Transformers.timeInterval.apply(e <| "created_at"),
            followersCount: e <| "followers_count",
            followingCount: e <| "following_count",
            statusesCount: e <| "statuses_count",
            note: e <|? "note",
            url: URL.Transformers.string.apply(e <| "url"),
            avatar: URL.Transformers.string.apply(e <|? "avatar"),
            avatarStatic: URL.Transformers.string.apply(e <|? "avatar_static"),
            header: URL.Transformers.string.apply(e <|? "header"),
            headerStatic: URL.Transformers.string.apply(e <|? "header_static")
        )
    }
}
