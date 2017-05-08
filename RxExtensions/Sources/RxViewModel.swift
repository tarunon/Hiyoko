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

    func state(action: Observable<Action>, result: AnyObserver<Result>) -> Observable<State>
}

internal class RxViewModelSubject<Result, Action> {
    fileprivate let resultSubject = PublishSubject<Result>()
    fileprivate let actionSubject = ReplaySubject<Action>.create(bufferSize: 1)
    
    public init() {}
}

public class RxViewModelEmitter<State, Action> {
    public let state: Observable<State>
    public let action: AnyObserver<Action>
    init<S: ObservableType, A: ObserverType>(_ state: S, _ action: A) where S.E == State, A.E == Action {
        self.state = state.asObservable()
        self.action = action.asObserver()
    }
}

extension RxViewModel {
    public typealias Emitter = RxViewModelEmitter<State, Action>

    internal func emitter() -> (Emitter, Observable<Result>) {
        let subject = RxViewModelSubject<Result, Action>()
        let state = self.state(action: subject.actionSubject.asObservable(), result: subject.resultSubject.asObserver())
        return (RxViewModelEmitter(state, subject.actionSubject.asObserver()), subject.resultSubject.asObservable())
    }
}
