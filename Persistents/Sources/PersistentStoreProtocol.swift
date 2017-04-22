//
//  Storable.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Base

public class PersistentStore<T> {
    let _restore: () throws -> T
    let _store: (T) throws -> ()
    
    public init(restore: @escaping () throws -> T, store: @escaping (T) throws -> ()) {
        self._restore = restore
        self._store = store
    }

    public func restore() throws -> T {
        return try _restore()
    }
    
    public func store(_ value: T) throws {
        try _store(value)
    }
}

extension PersistentStore {
    public func converted<U>(translation: @escaping (T) throws -> U, retranslation: @escaping (U) throws -> T) -> PersistentStore<U> {
        return PersistentStore<U>(
            restore: { () -> U in
                try translation(self.restore())
            },
            store: { (value) in
                try self.store(retranslation(value))
            }
        )
    }
}

public protocol Storable {
    func bool(_ key: String) -> PersistentStore<Bool>
    func int(_ key: String) -> PersistentStore<Int>
    func float(_ key: String) -> PersistentStore<Float>
    func string(_ key: String) -> PersistentStore<String>
    func data(_ key: String) -> PersistentStore<Data>
}

public extension Storable {
    public func typed<P: PersistentValueProtocol>(_ type: P.Type=P.self, _ key: String) -> PersistentStore<PersistentValueProtocol> {
        return data(key).converted(translation: P.decode, retranslation: { try $0.encode() })
    }
}
