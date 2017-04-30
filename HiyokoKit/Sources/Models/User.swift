//
//  User.swift
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

public final class User: Object {
    public struct Entities {
        public var url: HiyokoKit.Entities
        public var userDescription: HiyokoKit.Entities
    }
    
    public dynamic var id: Int64 = 0
    public dynamic var createdAt: Date = Date()
    public dynamic var name: String = ""
    public dynamic var screenName: String = ""
    public dynamic var userDescription: String? = nil
    fileprivate dynamic var _entitiesData: Data? = nil // Decoded Entities
    public dynamic var favouritesCount: Int = 0
    public dynamic var followersCount: Int = 0
    public dynamic var friendsCount: Int = 0
    public dynamic var statusesCount: Int = 0
    public dynamic var listedCount: Int = 0
    public dynamic var location: String? = nil
    fileprivate dynamic var _profileImageURLString: String? = nil // Decoded Profile Image URL
    fileprivate dynamic var _backgroundImageURLString: String? = nil // Decoded Background Image URL
    public dynamic var protected: Bool = false
    public dynamic var _urlString: String? = nil // Decoded URL
    
    fileprivate var _entities: Entities? = nil // On memory cache of Entitities
    fileprivate var _profileImageURL: URL? = nil // On memory cache of Profile Image URL
    fileprivate var _backgroundImageURL: URL? = nil // On memory cache of Background Image URL
    fileprivate var _url: URL? = nil // On memory cache of URL
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["_entities", "entities", "_profileImageURL", "profileImageURL", "_backgroundImageURL", "backgroundImageURL", "_url", "url"]
    }
    
    public override class func indexedProperties() -> [String] {
        return ["screenName"]
    }
}

extension User.Entities: Decodable {
    public static func decode(_ e: Extractor) throws -> User.Entities {
        return try .init(
            url: e <| "url",
            userDescription: e <| "description"
        )
    }
}

extension User.Entities: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "url": url,
                "description": userDescription
            ]
        )
    }
}

extension User {
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
            return _entities ?? Entities(url: .empty, userDescription: .empty)
        }
    }
    
    public var profileImageURL: URL? {
        set {
            _profileImageURL = newValue
            _profileImageURLString = newValue?.absoluteString
        }
        get {
            if let profileImageURL = _profileImageURL {
                return profileImageURL
            }
            _profileImageURL = _profileImageURLString.flatMap(URL.init)
            return _profileImageURL
        }
    }
    
    public var backgroundImageURL: URL? {
        set {
            _backgroundImageURL = newValue
            _backgroundImageURLString = newValue?.absoluteString
        }
        get {
            if let backgroundImageURL = _backgroundImageURL {
                return backgroundImageURL
            }
            _backgroundImageURL = _backgroundImageURLString.flatMap(URL.init)
            return _backgroundImageURL
        }
    }
    
    public var url: URL? {
        set {
            _url = newValue
            _urlString = newValue?.absoluteString
        }
        get {
            if let url = _url {
                return url
            }
            _url = _urlString.flatMap(URL.init)
            return _url
        }
    }
}

extension User: Decodable {
    static func from(id: Int64, createdAt: Date, name: String, screenName: String, userDescription: String?, entities: Entities, favouritesCount: Int, followersCount: Int, friendsCount: Int, statusesCount: Int, listedCount: Int, location: String?, profileImageURL: URL?, backgroundImageURL: URL?, protected: Bool, url: URL) -> User {
        let user = User()
        user.id = id
        user.createdAt = createdAt
        user.name = name
        user.screenName = screenName
        user.userDescription = userDescription
        user.entities = entities
        user.favouritesCount = favouritesCount
        user.followersCount = followersCount
        user.friendsCount = friendsCount
        user.statusesCount = statusesCount
        user.listedCount = listedCount
        user.location = location
        user.profileImageURL = profileImageURL
        user.backgroundImageURL = backgroundImageURL
        user.protected = protected
        user.url = url
        return user
    }
    
    public static func decode(_ e: Extractor) throws -> User {
        return try .from(
            id: e <| "id",
            createdAt: Date.Transformers.utcString.apply(e <| "created_at"),
            name: e <| "name",
            screenName: e <| "screen_name",
            userDescription: e <| "description",
            entities: e <| "entities",
            favouritesCount: e <| "favourites_count",
            followersCount: e <| "followers_count",
            friendsCount: e <| "friends_count",
            statusesCount: e <| "statuses_count",
            listedCount: e <| "listed_count",
            location: e <|? "location",
            profileImageURL: e <|? "profile_image_url_https",
            backgroundImageURL: e <|? "profile_background_image_url_https",
            protected: e <| "protected",
            url: e <| "url"
        )
    }
}

extension AttributeType where ValueType: User {
    var id: Attribute<Int64> { return attribute() }
    var createdAt: Attribute<Date> { return attribute() }
    var name: Attribute<String> { return attribute() }
    var screenName: Attribute<String> { return attribute() }
    var userDescription: Attribute<String> { return attribute() }
    var favouritesCount: Attribute<Int> { return attribute() }
    var followersCount: Attribute<Int> { return attribute() }
    var friendsCount: Attribute<Int> { return attribute() }
    var statusesCount: Attribute<Int> { return attribute() }
    var listedCount: Attribute<Int> { return attribute() }
    var location: Attribute<String?> { return attribute() }
    var protected: Attribute<Bool> { return attribute() }
}
