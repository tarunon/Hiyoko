//
//  Account.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Himotoki
import Barrel
import Barrel_Realm

public final class Account: Object {
    public dynamic var id: Int64 = 0
    public dynamic var userName: String = ""
    public dynamic var screenName: String = ""
    fileprivate dynamic var _profileImageURLString: String? = nil
    public dynamic var createdAt: Date = Date()
    
    fileprivate var _profileImageURL: URL? = nil
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["_profileImageURL", "profileImageURL"]
    }
}

extension Account {
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
}

extension AttributeType where ValueType: Account {
    public var id: Attribute<Int64> { return attribute() }
    public var userName: Attribute<String> { return attribute() }
    public var screenName: Attribute<String> { return attribute() }
    public var createdAt: Attribute<Date> { return attribute() }
}
