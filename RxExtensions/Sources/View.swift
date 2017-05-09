//
//  View.swift
//  Hiyoko
//
//  Created by ST90872 on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

public protocol View {
    associatedtype Action
    associatedtype State

    func present(state: Observable<State>) -> Present<Action>
}

public struct Present<Action> {
    public let action: Observable<Action>

    public init<A: ObservableConvertibleType>(action: A) where A.E == Action {
        self.action = action.asObservable()
    }

    public init<A: ObservableConvertibleType>(action: A, bind: Disposable) where A.E == Action {
        self.action = Observable.create { (observer) in
            return Disposables
                .create(
                    action.asObservable().concat(Observable.never()).bind(to: observer),
                    bind
                )
        }
    }
}
