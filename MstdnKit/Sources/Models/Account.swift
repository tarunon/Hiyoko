//
//  Account.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import RealmSwift

public final class Account: Object {
    public dynamic var id: Int = 0
    public dynamic var username: String = ""
    public dynamic var acct: String = ""
    public dynamic var displayName: String = ""
    public dynamic var locked: Bool = false
    public dynamic var created: Date = Date()
    public dynamic var followersCount: Int = 0
    public dynamic var followingCount: Int = 0
    public dynamic var statusesCount: Int = 0
    public dynamic var note: String? = nil
    public dynamic var url: URL? = nil
    public dynamic var avatar: URL? = nil
    public dynamic var avatarStatic: URL? = nil
    public dynamic var header: URL? = nil
    public dynamic var headerStatic: URL? = nil
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public class func from(id: Int, username: String, acct: String, displayName: String, locked: Bool, created: Date, followersCount: Int, followingCount: Int, statusesCount: Int, note: String?, url: URL?, avatar: URL?, avatarStatic: URL?, header: URL?, headerStatic: URL?) -> Account {
        let account = Account()
        account.id = id
        account.username = username
        account.acct = acct
        account.displayName = displayName
        account.locked = locked
        account.created = created
        account.followersCount = followersCount
        account.followingCount = followingCount
        account.statusesCount = statusesCount
        account.note = note
        account.url = url
        account.avatar = avatar
        account.avatarStatic = avatarStatic
        account.header = header
        account.headerStatic = headerStatic
        return account
    }
}

extension Account: Decodable {
    public static func decode(_ e: Extractor) throws -> Account {
        return try Account.from(
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
            url: URL.Transformers.string.apply(e <|? "url"),
            avatar: URL.Transformers.string.apply(e <|? "avatar"),
            avatarStatic: URL.Transformers.string.apply(e <|? "avatar_static"),
            header: URL.Transformers.string.apply(e <|? "header"),
            headerStatic: URL.Transformers.string.apply(e <|? "header_static")
        )
    }
}
