//
//  OAuthSwift+Rx.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

public extension Reactive where Base: OAuth1Swift {
    public func authorize(withCallbackURL callbackURL: URL) -> Observable<OAuthSwiftCredential> {
        return Observable
            .create { (observer: AnyObserver<OAuthSwiftCredential>) -> Disposable in
                let handler = self.base.authorize(
                    withCallbackURL: callbackURL,
                    success: { (credential, _, _) in
                        observer.onNext(credential)
                        observer.onCompleted()
                    },
                    failure: { (error) in
                        observer.onError(error)
                    }
                )
                return Disposables.create {
                    handler?.cancel()
                }
            }
    }
}
