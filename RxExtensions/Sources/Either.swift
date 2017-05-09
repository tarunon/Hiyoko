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

public protocol Either2Reactor: Reactor {
    associatedtype Reactor1: Reactor
    associatedtype Reactor2: Reactor
    associatedtype State = Either2<Reactor1.State, Reactor2.State>
    associatedtype Action = Either2<Reactor1.Action, Reactor2.Action>
    associatedtype Result = Reactor1.Result
    
    var reactor1: Reactor1 { get }
    var reactor2: Reactor2 { get }
}

extension Either2Reactor where State == Either2<Reactor1.State, Reactor2.State>, Action == Either2<Reactor1.Action, Reactor2.Action>, Result == Reactor1.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor1.process(action: action.flatMap { $0.a })
                .observable
                .map { $0.transform({ State.a($0) }, { $0 }) }
        )
    }
}

extension Either2Reactor where State == Either2<Reactor1.State, Reactor2.State>, Action == Either2<Reactor1.Action, Reactor2.Action>, Result == Reactor2.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor2.process(action: action.flatMap { $0.b })
                .observable
                .map { $0.transform({ State.b($0) }, { $0 }) }
        )
    }
}

public protocol Either3Reactor: Reactor {
    associatedtype Reactor1: Reactor
    associatedtype Reactor2: Reactor
    associatedtype Reactor3: Reactor
    associatedtype State = Either3<Reactor1.State, Reactor2.State, Reactor3.State>
    associatedtype Action = Either3<Reactor1.Action, Reactor2.Action, Reactor3.Action>
    associatedtype Result = Reactor1.Result
    
    var reactor1: Reactor1 { get }
    var reactor2: Reactor2 { get }
    var reactor3: Reactor3 { get }
}

extension Either3Reactor where State == Either3<Reactor1.State, Reactor2.State, Reactor3.State>, Action == Either3<Reactor1.Action, Reactor2.Action, Reactor3.Action>, Result == Reactor1.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor1.process(action: action.flatMap { $0.a })
                .observable
                .map { $0.transform({ State.a($0) }, { $0 }) }
        )
    }
}

extension Either3Reactor where State == Either3<Reactor1.State, Reactor2.State, Reactor3.State>, Action == Either3<Reactor1.Action, Reactor2.Action, Reactor3.Action>, Result == Reactor2.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor2.process(action: action.flatMap { $0.b })
                .observable
                .map { $0.transform({ State.b($0) }, { $0 }) }
        )
    }
}

extension Either3Reactor where State == Either3<Reactor1.State, Reactor2.State, Reactor3.State>, Action == Either3<Reactor1.Action, Reactor2.Action, Reactor3.Action>, Result == Reactor3.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor3.process(action: action.flatMap { $0.c })
                .observable
                .map { $0.transform({ State.c($0) }, { $0 }) }
        )
    }
}

public protocol Either4Reactor: Reactor {
    associatedtype Reactor1: Reactor
    associatedtype Reactor2: Reactor
    associatedtype Reactor3: Reactor
    associatedtype Reactor4: Reactor
    associatedtype State = Either4<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State>
    associatedtype Action = Either4<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action>
    associatedtype Result = Reactor1.Result
    
    var reactor1: Reactor1 { get }
    var reactor2: Reactor2 { get }
    var reactor3: Reactor3 { get }
    var reactor4: Reactor4 { get }
}

extension Either4Reactor where State == Either4<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State>, Action == Either4<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action>, Result == Reactor1.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor1.process(action: action.flatMap { $0.a })
                .observable
                .map { $0.transform({ State.a($0) }, { $0 }) }
        )
    }
}

extension Either4Reactor where State == Either4<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State>, Action == Either4<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action>, Result == Reactor2.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor2.process(action: action.flatMap { $0.b })
                .observable
                .map { $0.transform({ State.b($0) }, { $0 }) }
        )
    }
}

extension Either4Reactor where State == Either4<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State>, Action == Either4<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action>, Result == Reactor3.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor3.process(action: action.flatMap { $0.c })
                .observable
                .map { $0.transform({ State.c($0) }, { $0 }) }
        )
    }
}

extension Either4Reactor where State == Either4<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State>, Action == Either4<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action>, Result == Reactor4.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor4.process(action: action.flatMap { $0.d })
                .observable
                .map { $0.transform({ State.d($0) }, { $0 }) }
        )
    }
}

public protocol Either5Reactor: Reactor {
    associatedtype Reactor1: Reactor
    associatedtype Reactor2: Reactor
    associatedtype Reactor3: Reactor
    associatedtype Reactor4: Reactor
    associatedtype Reactor5: Reactor
    associatedtype State = Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>
    associatedtype Action = Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>
    associatedtype Result = Reactor1.Result
    
    var reactor1: Reactor1 { get }
    var reactor2: Reactor2 { get }
    var reactor3: Reactor3 { get }
    var reactor4: Reactor4 { get }
    var reactor5: Reactor5 { get }
}

extension Either5Reactor where State == Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>, Action == Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>, Result == Reactor1.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor1.process(action: action.flatMap { $0.a })
                .observable
                .map { $0.transform({ State.a($0) }, { $0 }) }
        )
    }
}

extension Either5Reactor where State == Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>, Action == Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>, Result == Reactor2.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor2.process(action: action.flatMap { $0.b })
                .observable
                .map { $0.transform({ State.b($0) }, { $0 }) }
        )
    }
}

extension Either5Reactor where State == Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>, Action == Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>, Result == Reactor3.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor3.process(action: action.flatMap { $0.c })
                .observable
                .map { $0.transform({ State.c($0) }, { $0 }) }
        )
    }
}

extension Either5Reactor where State == Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>, Action == Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>, Result == Reactor4.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor4.process(action: action.flatMap { $0.d })
                .observable
                .map { $0.transform({ State.d($0) }, { $0 }) }
        )
    }
}

extension Either5Reactor where State == Either5<Reactor1.State, Reactor2.State, Reactor3.State, Reactor4.State, Reactor5.State>, Action == Either5<Reactor1.Action, Reactor2.Action, Reactor3.Action, Reactor4.Action, Reactor5.Action>, Result == Reactor5.Result {
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try reactor5.process(action: action.flatMap { $0.e })
                .observable
                .map { $0.transform({ State.e($0) }, { $0 }) }
        )
    }
}
