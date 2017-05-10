//
//  UIActivityViewController+Rx.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ActivityReactor: Reactor {
    public typealias Result = (UIActivityType?, Bool, [Any]?)
    public typealias Action = Result
    public typealias State = Never

    public init() {

    }

    public func process(action: Observable<ActivityReactor.Result>) throws -> Process<Never, (UIActivityType?, Bool, [Any]?)> {
        return .init(
            state: Observable.never(),
            result: action
        )
    }
}

extension UIActivityViewController: View {
    public typealias Action = ActivityReactor.Result
    public typealias State = Never

    public func present(state: Observable<Never>) -> Present<ActivityReactor.Action> {
        return .init(
            action: Observable<ActivityReactor.Action>
                .create { [unowned self] (observer) -> Disposable in
                    self.completionWithItemsHandler = { (type, success, parameters, error) in
                        if let error = error {
                            if (error as NSError).code != CocoaError.userCancelled.rawValue {
                                observer.onError(error)
                            } else {
                                observer.onCompleted()
                            }
                        } else {
                            observer.onNext((type, success, parameters))
                            observer.onCompleted()
                        }
                        self.completionWithItemsHandler = nil
                    }
                    return Disposables.create()
            }
        )
    }
}
