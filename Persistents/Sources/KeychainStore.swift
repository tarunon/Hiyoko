//
//  KeychainStore.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Base
import KeychainAccess

public class KeychainStore: Storable {
    enum Error: Swift.Error {
        case notFound
    }
    
    let keychain: Keychain
    
    public init(keychain: Keychain) {
        self.keychain = keychain
    }
    
    public static let shared = KeychainStore(keychain: Keychain())
    
    public func bool(_ key: String) -> PersistentStore<Bool> {
        return string(key)
            .converted(translation: { try Bool($0) ??? Error.notFound }, retranslation: { $0.description })
    }
    
    public func int(_ key: String) -> PersistentStore<Int> {
        return string(key)
            .converted(translation: { try Int($0) ??? Error.notFound }, retranslation: { $0.description })
    }
    
    public func float(_ key: String) -> PersistentStore<Float> {
        return string(key)
            .converted(translation: { try Float($0) ??? Error.notFound }, retranslation: { $0.description })
    }
    
    public func string(_ key: String) -> PersistentStore<String> {
        return PersistentStore(restore: { try self.keychain.getString(key) }, store: { try self.keychain.set($0!, key: key) })
            .converted(translation: { try $0 ??? Error.notFound }, retranslation: { $0 })
    }
    
    public func data(_ key: String) -> PersistentStore<Data> {
        return PersistentStore(restore: { try self.keychain.getData(key) }, store: { try self.keychain.set($0!, key: key) })
            .converted(translation: { try $0 ??? Error.notFound }, retranslation: { $0 })
    }
}
