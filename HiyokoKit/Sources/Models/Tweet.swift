//
//  Tweet.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/29.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Himotoki
import Illuso
import Barrel
import Barrel_Realm
//import BonMot

public final class Tweet: Object {
    public dynamic var id: Int64 = 0
    public dynamic var createdAt: Date = Date()
    public let currentUserRetweetId: RealmOptional<Int64> = RealmOptional()
    fileprivate dynamic var _entitiesData: Data? = nil // Decoded Entities
    public dynamic var favoriteCount: Int = 0
    public let favorited: RealmOptional<Bool> = RealmOptional()
    public dynamic var filterLevel: String? = nil
    public let inReplyToStatusId: RealmOptional<Int64> = RealmOptional()
    public let inReplyToUserId: RealmOptional<Int64> = RealmOptional()
    public dynamic var lang: String? = nil
    public let possiblySensitive: RealmOptional<Bool> = RealmOptional()
    public dynamic var quotedStatus: Tweet? = nil
    public dynamic var retweetCount: Int = 0
    public let retweeted: RealmOptional<Bool> = RealmOptional()
    public dynamic var retweetedStatus: Tweet? = nil
    public dynamic var usersRetweetStatus: Tweet? = nil
    public dynamic var text: String = ""
    fileprivate dynamic var _user: User? = nil
    public dynamic var timeline: Bool = false
    
    fileprivate var _entities: Entities? = nil
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["_entities", "entities", "user"]
    }
}

extension Tweet {
    public var entities: Entities {
        set {
            _entities = newValue
            _entitiesData = try! JSONSerialization.data(withJSONObject: newValue.encode().asObject(), options: [])
        }
        get {
            if let entities = _entities {
                return entities
            }
            _entities = try! _entitiesData
                .map { try JSONSerialization.jsonObject(with: $0, options: []) }
                .map { try decodeValue($0) as Entities }
            return _entities ?? .empty
        }
    }
    
    public var user: User {
        set {
            _user = newValue
        }
        get {
            return _user!
        }
    }
}

extension Tweet: HasID {
    
}

extension Tweet {
    public enum Action {
        case reply
        case favourite
        case retweet
    }
}

extension Tweet: Decodable {
    static func from(id: Int64, createdAt: Date, currentUserRetweetId: Int64?, entities: Entities, favoriteCount: Int, favorited: Bool?, filterLevel: String?, inReplyToStatusId: Int64?, inReplyToUserId: Int64?, lang: String?, possiblySensitive: Bool?, quotedStatus: Tweet?, retweetCount: Int, retweeted: Bool?, retweetedStatus: Tweet?, usersRetweetStatus: Tweet?, text: String, user: User) -> Tweet {
        let tweet = Tweet()
        tweet.id = id
        tweet.createdAt = createdAt
        tweet.currentUserRetweetId.value = currentUserRetweetId
        tweet.entities = entities
        tweet.favoriteCount = favoriteCount
        tweet.favorited.value = favorited
        tweet.filterLevel = filterLevel
        tweet.inReplyToStatusId.value = inReplyToStatusId
        tweet.inReplyToUserId.value = inReplyToUserId
        tweet.lang = lang
        tweet.possiblySensitive.value = possiblySensitive
        tweet.quotedStatus = quotedStatus
        tweet.retweetCount = retweetCount
        tweet.retweeted.value = retweeted
        tweet.retweetedStatus = retweetedStatus
        tweet.text = text
        tweet.user = user
        return tweet
    }

    public static func decode(_ e: Extractor) throws -> Tweet {
        return try .from(
            id: e <| "id",
            createdAt: Date.Transformers.utcString.apply(e <| "created_at"),
            currentUserRetweetId: e <|? KeyPath(["current_user_retweet", "id"]),
            entities: (e <| "entities" as Entities).extend(e <|? "extended_entities"),
            favoriteCount: e <| "favorite_count",
            favorited: e <|? "favorited",
            filterLevel: e <|? "filter_level",
            inReplyToStatusId: e <|? "in_reply_to_status_id",
            inReplyToUserId: e <|? "in_reply_to_user_id",
            lang: e <|? "lang",
            possiblySensitive: e <|? "possibily_sensitive",
            quotedStatus: e <|? "quoted_status",
            retweetCount: e <| "retweet_count",
            retweeted: e <|? "retweeted",
            retweetedStatus: e <|? "retweeted_status",
            usersRetweetStatus: e <|? "current_user_retweet",
            text: e <| "text",
            user: e <| "user"
        )
    }
}

extension AttributeType where ValueType: Tweet {
    var id: Attribute<Int64> { return attribute() }
    var createdAt: Attribute<Date> { return attribute() }
    var currentUserRetweetId: Attribute<Int64?> { return attribute() }
    var favoriteCount: Attribute<Int> { return attribute() }
    var favorited: Attribute<Bool?> { return attribute() }
    var filterLevel: Attribute<String?> { return attribute() }
    var inReplyToStatusId: Attribute<Int64?> { return attribute() }
    var inReplyToUserId: Attribute<Int64> { return attribute() }
    var lang: Attribute<String?> { return attribute() }
    var possiblySensitive: Attribute<Bool?> { return attribute() }
    var quotedStatus: Attribute<Tweet?> { return attribute() }
    var retweetCount: Attribute<Int> { return attribute() }
    var retweeted: Attribute<Bool?> { return attribute() }
    var retweetedStatus: Attribute<Tweet?> { return attribute() }
    var text: Attribute<String> { return attribute() }
    var user: Attribute<ExpressionWrapper<User>> { return attribute("_user") }
    var timeline: Attribute<Bool> { return attribute() }
}

extension Tweet {
    public var attributedText: NSAttributedString {
        return entities.attributed(text: text)
    }
    
    public var url: URL {
        return URL(string: "https://twitter.com/\(user.screenName)/status/\(id)")!
    }
}

