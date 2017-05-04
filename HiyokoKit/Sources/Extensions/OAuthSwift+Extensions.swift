//
//  OAuthSwift+Extensions.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift
import Persistents
import Base

public extension Reactive where Base: OAuth1Swift {
    public func authorize(withCallbackURL callbackURL: URL) -> Observable<(OAuthSwiftCredential, [String : Any])> {
        return Observable<(OAuthSwiftCredential, [String : Any])>
            .create { [weak base] (observer) -> Disposable in
                guard let base = base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let handler = base.authorize(
                    withCallbackURL: callbackURL,
                    success: { (credential, _, parameters) in
                        observer.onNext((credential, parameters))
                        observer.onCompleted()
                    },
                    failure: { (error) in
                        DispatchQueue.global().asyncAfter( // Error occured before dismiss safari vc
                            deadline: DispatchTime(uptimeNanoseconds: 250000),
                            execute: {
                                observer.onError(error)
                            }
                        )
                    }
                )
                return Disposables.create {
                    handler?.cancel()
                }
            }
    }
}

extension OAuthSwiftCredential: PersistentValueProtocol {
    public enum Error: Swift.Error {
        case failToDecode
    }
    
    class func castOrFail<T>(_ arg: Any?) throws -> T {
        return try (arg as? T) ??? Error.failToDecode
    }
    
    public class func decode(data: Data) throws -> Self {
        return try castOrFail(NSKeyedUnarchiver.unarchiveObject(with: data))
    }
    
    public func encode() throws -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}
