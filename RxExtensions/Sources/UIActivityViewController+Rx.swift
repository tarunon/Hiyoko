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

public class ActivityViewModel: RxViewModel {
    public typealias Result = (UIActivityType?, Bool, [Any]?)
    public typealias Action = Result
    public typealias State = Never

    public init() {

    }

    public func process(action: Observable<ActivityViewModel.Result>) throws -> Process<Never, (UIActivityType?, Bool, [Any]?)> {
        return .init(
            state: Observable.empty(),
            result: action
        )
    }
}

extension UIActivityViewController {
    public func present(state: Observable<ActivityViewModel.State>) -> Present<ActivityViewModel.Action> {
        return .init(
            action: Observable<ActivityViewModel.Action>
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
