//
//  Zip.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

public enum Either2<A, B> {
    case a(A)
    case b(B)
    
    var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
}

public enum Either3<A, B, C> {
    case a(A)
    case b(B)
    case c(C)
    
    var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
}

public enum Either4<A, B, C, D> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)
    
    var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
    
    var d: Observable<D> {
        switch self {
        case .d(let d): return .just(d)
        default: return .empty()
        }
    }
}

public enum Either5<A, B, C, D, E> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)
    case e(E)
    
    var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
    
    var d: Observable<D> {
        switch self {
        case .d(let d): return .just(d)
        default: return .empty()
        }
    }
    
    var e: Observable<E> {
        switch self {
        case .e(let e): return .just(e)
        default: return .empty()
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

public struct ReactorConverter2<Base: RxExtensions.Reactor, Action1, State1> {
    public struct Reactor1: Reactor {
        public typealias Action = Either2<Base.Action, Action1>
        public typealias State = Either2<Base.State, State1>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.a })
                    .observable
                    .map { $0.transform({ State.a($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor2: Reactor {
        public typealias Action = Either2<Action1, Base.Action>
        public typealias State = Either2<State1, Base.State>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.b })
                    .observable
                    .map { $0.transform({ State.b($0) }, { $0 }) }
            )
        }
    }
}

public struct ReactorConverter3<Base: RxExtensions.Reactor, Action1, State1, Action2, State2> {
    public struct Reactor1: Reactor {
        public typealias Action = Either3<Base.Action, Action1, Action2>
        public typealias State = Either3<Base.State, State1, State2>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.a })
                    .observable
                    .map { $0.transform({ State.a($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor2: Reactor {
        public typealias Action = Either3<Action1, Base.Action, Action2>
        public typealias State = Either3<State1, Base.State, State2>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.b })
                    .observable
                    .map { $0.transform({ State.b($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor3: Reactor {
        public typealias Action = Either3<Action1, Action2, Base.Action>
        public typealias State = Either3<State1, State2, Base.State>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.c })
                    .observable
                    .map { $0.transform({ State.c($0) }, { $0 }) }
            )
        }
    }
}

public struct ReactorConverter4<Base: RxExtensions.Reactor, Action1, State1, Action2, State2, Action3, State3> {
    public struct Reactor1: Reactor {
        public typealias Action = Either4<Base.Action, Action1, Action2, Action3>
        public typealias State = Either4<Base.State, State1, State2, State3>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.a })
                    .observable
                    .map { $0.transform({ State.a($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor2: Reactor {
        public typealias Action = Either4<Action1, Base.Action, Action2, Action3>
        public typealias State = Either4<State1, Base.State, State2, State3>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.b })
                    .observable
                    .map { $0.transform({ State.b($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor3: Reactor {
        public typealias Action = Either4<Action1, Action2, Base.Action, Action3>
        public typealias State = Either4<State1, State2, Base.State, Action3>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.c })
                    .observable
                    .map { $0.transform({ State.c($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor4: Reactor {
        public typealias Action = Either4<Action1, Action2, Action3, Base.Action>
        public typealias State = Either4<State1, State2, State3, Base.State>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.d })
                    .observable
                    .map { $0.transform({ State.d($0) }, { $0 }) }
            )
        }
    }
}

public struct ReactorConverter5<Base: RxExtensions.Reactor, Action1, State1, Action2, State2, Action3, State3, Action4, State4> {
    public struct Reactor1: Reactor {
        public typealias Action = Either5<Base.Action, Action1, Action2, Action3, Action4>
        public typealias State = Either5<Base.State, State1, State2, State3, State4>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.a })
                    .observable
                    .map { $0.transform({ State.a($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor2: Reactor {
        public typealias Action = Either5<Action1, Base.Action, Action2, Action3, Action4>
        public typealias State = Either5<State1, Base.State, State2, State3, State4>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.b })
                    .observable
                    .map { $0.transform({ State.b($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor3: Reactor {
        public typealias Action = Either5<Action1, Action2, Base.Action, Action3, Action4>
        public typealias State = Either5<State1, State2, Base.State, State4, State4>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.c })
                    .observable
                    .map { $0.transform({ State.c($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor4: Reactor {
        public typealias Action = Either5<Action1, Action2, Action3, Base.Action, Action4>
        public typealias State = Either5<State1, State2, Action3, Base.State, Action4>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.d })
                    .observable
                    .map { $0.transform({ State.d($0) }, { $0 }) }
            )
        }
    }

    public struct Reactor5: Reactor {
        public typealias Action = Either5<Action1, Action2, Action3, Action4, Base.Action>
        public typealias State = Either5<State1, State2, Action3, Action4, Base.State>
        public typealias Result = Base.Result

        let base: Base

        init(_ reactor: Base) {
            self.base = reactor
        }

        public func process(action: Observable<Action>) throws -> Process<State, Result> {
            return .init(
                observable: try base.process(action: action.flatMap { $0.e })
                    .observable
                    .map { $0.transform({ State.e($0) }, { $0 }) }
            )
        }
    }
}

prefix operator ~
public prefix func ~<R: Reactor, A, S>(_ reactor: R) -> ReactorConverter2<R, A, S>.Reactor1 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A, S>(_ reactor: R) -> ReactorConverter2<R, A, S>.Reactor2 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2>(_ reactor: R) -> ReactorConverter3<R, A1, S1, A2, S2>.Reactor1 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2>(_ reactor: R) -> ReactorConverter3<R, A1, S1, A2, S2>.Reactor2 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2>(_ reactor: R) -> ReactorConverter3<R, A1, S1, A2, S2>.Reactor3 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3>(_ reactor: R) -> ReactorConverter4<R, A1, S1, A2, S2, A3, S3>.Reactor1 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3>(_ reactor: R) -> ReactorConverter4<R, A1, S1, A2, S2, A3, S3>.Reactor2 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3>(_ reactor: R) -> ReactorConverter4<R, A1, S1, A2, S2, A3, S3>.Reactor3 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3>(_ reactor: R) -> ReactorConverter4<R, A1, S1, A2, S2, A3, S3>.Reactor4 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3, A4, S4>(_ reactor: R) -> ReactorConverter5<R, A1, S1, A2, S2, A3, S3, A4, S4>.Reactor1 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3, A4, S4>(_ reactor: R) -> ReactorConverter5<R, A1, S1, A2, S2, A3, S3, A4, S4>.Reactor2 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3, A4, S4>(_ reactor: R) -> ReactorConverter5<R, A1, S1, A2, S2, A3, S3, A4, S4>.Reactor3 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3, A4, S4>(_ reactor: R) -> ReactorConverter5<R, A1, S1, A2, S2, A3, S3, A4, S4>.Reactor4 {
    return .init(reactor)
}

public prefix func ~<R: Reactor, A1, S1, A2, S2, A3, S3, A4, S4>(_ reactor: R) -> ReactorConverter5<R, A1, S1, A2, S2, A3, S3, A4, S4>.Reactor5 {
    return .init(reactor)
}
