//
//  RxViewModel.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol RxViewModel {
    associatedtype Result
    associatedtype Action
    associatedtype State

    func process(action: Observable<Action>) throws -> Process<State, Result>
}

public struct Process<State, Result> {
    fileprivate let state: Observable<State>
    fileprivate let result: Observable<Result>
    public init<S: ObservableType, R: ObservableType>(state: S, result: R) where S.E == State, R.E == Result {
        self.state = state.asObservable()
        self.result = result.asObservable()
    }
}

public struct Present<Action> {
    fileprivate let action: Observable<Action>
    fileprivate let bind: Disposable
    
    public init<A: ObservableType>(action: A, bind: Disposable = Disposables.create()) where A.E == Action {
        self.action = action.asObservable()
        self.bind = bind
    }
    
    public static func merge(_ presents: Present...) -> Present {
        return .init(
            action: Observable.merge(presents.map { $0.action }),
            bind: Disposables.create(presents.map { $0.bind })
        )
    }
    
    public static func merge(_ presents: [Present]) -> Present {
        return .init(
            action: Observable.merge(presents.map { $0.action }),
            bind: Disposables.create(presents.map { $0.bind })
        )
    }
}
extension RxViewModel {
    public typealias Presenter = (Observable<State>) -> Present<Action>

    internal func emit(presenter: @escaping Presenter) throws -> Observable<Result> {
        let subject = PublishSubject<Action>()
        let process = try self.process(action: subject.asObservable())
        return Observable.create { (observer) -> Disposable in
            let d1 = process.result.bind(to: observer)
            let present = presenter(process.state.concat(Observable.never()).shareReplay(1))
            let d2 = present.action.bind(to: subject)
            return Disposables.create(d1, d2, present.bind)
        }
    }
}
