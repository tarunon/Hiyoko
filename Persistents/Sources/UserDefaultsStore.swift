//
//  UserDefaultsStore.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Base

public class UserDefaultsStore: Storable {
    enum Error: Swift.Error {
        case notFound
    }
    let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public static let standard = UserDefaultsStore(userDefaults: .standard)
    
    public func bool(_ key: String) -> PersistentStore<Bool> {
        return PersistentStore(restore: { self.userDefaults.bool(forKey: key) }, store: { self.userDefaults.set($0, forKey: key) })
    }

    public func int(_ key: String) -> PersistentStore<Int> {
        return PersistentStore(restore: { self.userDefaults.integer(forKey: key) }, store: { self.userDefaults.set($0, forKey: key) })
    }
    
    public func float(_ key: String) -> PersistentStore<Float> {
        return PersistentStore(restore: { self.userDefaults.float(forKey: key) }, store: { self.userDefaults.set($0, forKey: key) })
    }

    public func string(_ key: String) -> PersistentStore<String> {
        return PersistentStore(restore: { self.userDefaults.string(forKey: key) }, store: { self.userDefaults.set($0, forKey: key) })
            .converted(translation: { try $0 ??? Error.notFound }, retranslation: { $0 })
    }
    
    public func data(_ key: String) -> PersistentStore<Data> {
        return PersistentStore(restore: { self.userDefaults.data(forKey: key) }, store: { self.userDefaults.set($0, forKey: key) })
            .converted(translation: { try $0 ??? Error.notFound }, retranslation: { $0 })
    }
}
