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

public protocol Reactor {
    associatedtype Result
    associatedtype Action
    associatedtype State

    func process(action: Observable<Action>) throws -> Process<State, Result>
}

public struct Process<State, Result> {
    public enum Either {
        case state(Event<State>)
        case result(Event<Result>)

        public var state: Observable<Event<State>> {
            switch self {
            case .state(let state): return .just(state)
            default: return .empty()
            }
        }

        public var result: Observable<Event<Result>> {
            switch self {
            case .result(let result): return .just(result)
            default: return .empty()
            }
        }

        public func transform<S, R>(_ sf: (State) throws -> S, _ rf: (Result) throws -> R) -> Process<S, R>.Either {
            switch self {
            case .state(let event):
                return Process<S, R>.Either.state(event.map(sf))
            case .result(let event):
                return Process<S, R>.Either.result(event.map(rf))
            }
        }
    }

    fileprivate let observable: Observable<Either>

    public init<S: ObservableConvertibleType, R: ObservableConvertibleType>(state: S, result: R) where S.E == State, R.E == Result {
        self.init(
            observable: Observable
                .merge(
                    state.asObservable().materialize().map { Either.state($0) },
                    result.asObservable().materialize().map { Either.result($0) }
                )
        )
    }

    fileprivate init(observable: Observable<Either>) {
        self.observable = observable
    }

    public var state: Observable<State> {
        return observable.flatMap { $0.state }.dematerialize()
    }

    public var result: Observable<Result> {
        return observable.flatMap { $0.result }.dematerialize()
    }
}
