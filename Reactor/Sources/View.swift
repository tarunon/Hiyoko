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

public protocol Either2View: View {
    associatedtype View1: View
    associatedtype View2: View
    associatedtype State = Either2<View1.State, View2.State>
    associatedtype Action = Either2<View1.Action, View2.Action>

    var view1: View1 { get }
    var view2: View2 { get }
}

extension Either2View where State == Either2<View1.State, View2.State>, Action == Either2<View1.Action, View2.Action> {
    public func present(state: Observable<State>) -> Present<Action> {
        let p1 = state
            .flatMap { $0.a }
            .shareReplay(1)
            .bind { (state) -> Observable<View1.Action> in
                state.flatMapFirst { _  -> Observable<View1.Action> in
                    self.view1.present(state: state).action
                }
            }
            .map { Action.a($0) }
        let p2 = state
            .flatMap { $0.b }
            .shareReplay(1)
            .bind { (state) -> Observable<View2.Action> in
                state.flatMapFirst { _  -> Observable<View2.Action> in
                    self.view2.present(state: state).action
                }
            }
            .map { Action.b($0) }
        return .init(action: p1.amb(p2))
    }
}

public protocol Either3View: View {
    associatedtype View1: View
    associatedtype View2: View
    associatedtype View3: View
    associatedtype State = Either3<View1.State, View2.State, View3.State>
    associatedtype Action = Either3<View1.Action, View2.Action, View3.Action>

    var view1: View1 { get }
    var view2: View2 { get }
    var view3: View3 { get }
}

extension Either3View where State == Either3<View1.State, View2.State, View3.State>, Action == Either3<View1.Action, View2.Action, View3.Action> {
    public func present(state: Observable<State>) -> Present<Action> {
        let p1 = state
            .flatMap { $0.a }
            .shareReplay(1)
            .bind { (state) -> Observable<View1.Action> in
                state.flatMapFirst { _  -> Observable<View1.Action> in
                    self.view1.present(state: state).action
                }
            }
            .map { Action.a($0) }
        let p2 = state
            .flatMap { $0.b }
            .shareReplay(1)
            .bind { (state) -> Observable<View2.Action> in
                state.flatMapFirst { _  -> Observable<View2.Action> in
                    self.view2.present(state: state).action
                }
            }
            .map { Action.b($0) }
        let p3 = state
            .flatMap { $0.c }
            .shareReplay(1)
            .bind { (state) -> Observable<View3.Action> in
                state.flatMapFirst { _  -> Observable<View3.Action> in
                    self.view3.present(state: state).action
                }
            }
            .map { Action.c($0) }
        return .init(action: p1.amb(p2).amb(p3))
    }
}

public protocol Either4View: View {
    associatedtype View1: View
    associatedtype View2: View
    associatedtype View3: View
    associatedtype View4: View
    associatedtype State = Either4<View1.State, View2.State, View3.State, View4.State>
    associatedtype Action = Either4<View1.Action, View2.Action, View3.Action, View4.Action>

    var view1: View1 { get }
    var view2: View2 { get }
    var view3: View3 { get }
    var view4: View4 { get }
}

extension Either4View where State == Either4<View1.State, View2.State, View3.State, View4.State>, Action == Either4<View1.Action, View2.Action, View3.Action, View4.Action> {
    public func present(state: Observable<State>) -> Present<Action> {
        let p1 = state
            .flatMap { $0.a }
            .shareReplay(1)
            .bind { (state) -> Observable<View1.Action> in
                state.flatMapFirst { _  -> Observable<View1.Action> in
                    self.view1.present(state: state).action
                }
            }
            .map { Action.a($0) }
        let p2 = state
            .flatMap { $0.b }
            .shareReplay(1)
            .bind { (state) -> Observable<View2.Action> in
                state.flatMapFirst { _  -> Observable<View2.Action> in
                    self.view2.present(state: state).action
                }
            }
            .map { Action.b($0) }
        let p3 = state
            .flatMap { $0.c }
            .shareReplay(1)
            .bind { (state) -> Observable<View3.Action> in
                state.flatMapFirst { _  -> Observable<View3.Action> in
                    self.view3.present(state: state).action
                }
            }
            .map { Action.c($0) }
        let p4 = state
            .flatMap { $0.d }
            .shareReplay(1)
            .bind { (state) -> Observable<View4.Action> in
                state.flatMapFirst { _  -> Observable<View4.Action> in
                    self.view4.present(state: state).action
                }
            }
            .map { Action.d($0) }
        return .init(action: p1.amb(p2).amb(p3).amb(p4))
    }
}

public protocol Either5View: View {
    associatedtype View1: View
    associatedtype View2: View
    associatedtype View3: View
    associatedtype View4: View
    associatedtype View5: View
    associatedtype State = Either5<View1.State, View2.State, View3.State, View4.State, View5.State>
    associatedtype Action = Either5<View1.Action, View2.Action, View3.Action, View4.Action, View5.Action>

    var view1: View1 { get }
    var view2: View2 { get }
    var view3: View3 { get }
    var view4: View4 { get }
    var view5: View5 { get }
}

extension Either5View where State == Either5<View1.State, View2.State, View3.State, View4.State, View5.State>, Action == Either5<View1.Action, View2.Action, View3.Action, View4.Action, View5.Action> {
    public func present(state: Observable<State>) -> Present<Action> {
        let p1 = state
            .flatMap { $0.a }
            .shareReplay(1)
            .bind { (state) -> Observable<View1.Action> in
                state.flatMapFirst { _  -> Observable<View1.Action> in
                    self.view1.present(state: state).action
                }
            }
            .map { Action.a($0) }
        let p2 = state
            .flatMap { $0.b }
            .shareReplay(1)
            .bind { (state) -> Observable<View2.Action> in
                state.flatMapFirst { _  -> Observable<View2.Action> in
                    self.view2.present(state: state).action
                }
            }
            .map { Action.b($0) }
        let p3 = state
            .flatMap { $0.c }
            .shareReplay(1)
            .bind { (state) -> Observable<View3.Action> in
                state.flatMapFirst { _  -> Observable<View3.Action> in
                    self.view3.present(state: state).action
                }
            }
            .map { Action.c($0) }
        let p4 = state
            .flatMap { $0.d }
            .shareReplay(1)
            .bind { (state) -> Observable<View4.Action> in
                state.flatMapFirst { _  -> Observable<View4.Action> in
                    self.view4.present(state: state).action
                }
            }
            .map { Action.d($0) }
        let p5 = state
            .flatMap { $0.e }
            .shareReplay(1)
            .bind { (state) -> Observable<View5.Action> in
                state.flatMapFirst { _  -> Observable<View5.Action> in
                    self.view5.present(state: state).action
                }
            }
            .map { Action.e($0) }
        return .init(action: p1.amb(p2).amb(p3).amb(p4).amb(p5))
    }
}
