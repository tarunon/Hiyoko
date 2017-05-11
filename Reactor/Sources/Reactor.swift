//
//  RxReactor.swift
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

    public let observable: Observable<Either>

    public init<S: ObservableConvertibleType, R: ObservableConvertibleType>(state: S, result: R) where S.E == State, R.E == Result {
        self.init(
            observable: Observable
                .merge(
                    state.asObservable().shareReplay(1).materialize().map { Either.state($0) },
                    result.asObservable().shareReplay(1).materialize().map { Either.result($0) }
                )
        )
    }

    public init(observable: Observable<Either>) {
        self.observable = observable
    }

    public var state: Observable<State> {
        return observable.flatMap { $0.state }.dematerialize()
    }

    public var result: Observable<Result> {
        return observable.flatMap { $0.result }.dematerialize()
    }
}

public struct Either2Reactor<R1: Reactor, R2: Reactor>: Reactor {
    public typealias Action = Either2<R1.Action, R2.Action>
    public typealias State = Either2<R1.State, R2.State>
    public typealias Result = Either2<R1.Result, R2.Result>

    let reactor1: R1
    let reactor2: R2

    public init(_ reactor1: R1, _ reactor2: R2) {
        self.reactor1 = reactor1
        self.reactor2 = reactor2
    }

    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try Observable.merge(
                reactor1.process(action: action.flatMap { $0.a }).observable
                    .map { $0.transform({ State.a($0) }, { Result.a($0) }) },
                reactor2.process(action: action.flatMap { $0.b }).observable
                    .map { $0.transform({ State.b($0) }, { Result.b($0) }) }
            )
        )
    }
}

public struct Either3Reactor<R1: Reactor, R2: Reactor, R3: Reactor>: Reactor {
    public typealias Action = Either3<R1.Action, R2.Action, R3.Action>
    public typealias State = Either3<R1.State, R2.State, R3.State>
    public typealias Result = Either3<R1.Result, R2.Result, R3.Result>

    let reactor1: R1
    let reactor2: R2
    let reactor3: R3

    public init(_ reactor1: R1, _ reactor2: R2, _ reactor3: R3) {
        self.reactor1 = reactor1
        self.reactor2 = reactor2
        self.reactor3 = reactor3
    }

    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try Observable.merge(
                reactor1.process(action: action.flatMap { $0.a }).observable
                    .map { $0.transform({ State.a($0) }, { Result.a($0) }) },
                reactor2.process(action: action.flatMap { $0.b }).observable
                    .map { $0.transform({ State.b($0) }, { Result.b($0) }) },
                reactor3.process(action: action.flatMap { $0.c }).observable
                    .map { $0.transform({ State.c($0) }, { Result.c($0) }) }
            )
        )
    }
}

public struct Either4Reactor<R1: Reactor, R2: Reactor, R3: Reactor, R4: Reactor>: Reactor {
    public typealias Action = Either4<R1.Action, R2.Action, R3.Action, R4.Action>
    public typealias State = Either4<R1.State, R2.State, R3.State, R4.State>
    public typealias Result = Either4<R1.Result, R2.Result, R3.Result, R4.Result>

    let reactor1: R1
    let reactor2: R2
    let reactor3: R3
    let reactor4: R4

    public init(_ reactor1: R1, _ reactor2: R2, _ reactor3: R3, _ reactor4: R4) {
        self.reactor1 = reactor1
        self.reactor2 = reactor2
        self.reactor3 = reactor3
        self.reactor4 = reactor4
    }

    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try Observable.merge(
                reactor1.process(action: action.flatMap { $0.a }).observable
                    .map { $0.transform({ State.a($0) }, { Result.a($0) }) },
                reactor2.process(action: action.flatMap { $0.b }).observable
                    .map { $0.transform({ State.b($0) }, { Result.b($0) }) },
                reactor3.process(action: action.flatMap { $0.c }).observable
                    .map { $0.transform({ State.c($0) }, { Result.c($0) }) },
                reactor4.process(action: action.flatMap { $0.d }).observable
                    .map { $0.transform({ State.d($0) }, { Result.d($0) }) }
            )
        )
    }
}

public struct Either5Reactor<R1: Reactor, R2: Reactor, R3: Reactor, R4: Reactor, R5: Reactor>: Reactor {
    public typealias Action = Either5<R1.Action, R2.Action, R3.Action, R4.Action, R5.Action>
    public typealias State = Either5<R1.State, R2.State, R3.State, R4.State, R5.State>
    public typealias Result = Either5<R1.Result, R2.Result, R3.Result, R4.Result, R5.Result>

    let reactor1: R1
    let reactor2: R2
    let reactor3: R3
    let reactor4: R4
    let reactor5: R5

    public init(_ reactor1: R1, _ reactor2: R2, _ reactor3: R3, _ reactor4: R4, _ reactor5: R5) {
        self.reactor1 = reactor1
        self.reactor2 = reactor2
        self.reactor3 = reactor3
        self.reactor4 = reactor4
        self.reactor5 = reactor5
    }

    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            observable: try Observable.merge(
                reactor1.process(action: action.flatMap { $0.a }).observable
                    .map { $0.transform({ State.a($0) }, { Result.a($0) }) },
                reactor2.process(action: action.flatMap { $0.b }).observable
                    .map { $0.transform({ State.b($0) }, { Result.b($0) }) },
                reactor3.process(action: action.flatMap { $0.c }).observable
                    .map { $0.transform({ State.c($0) }, { Result.c($0) }) },
                reactor4.process(action: action.flatMap { $0.d }).observable
                    .map { $0.transform({ State.d($0) }, { Result.d($0) }) },
                reactor5.process(action: action.flatMap { $0.e }).observable
                    .map { $0.transform({ State.e($0) }, { Result.e($0) }) }
            )
        )
    }
}

public struct ReactorConverter2<Base: Reactor, Action1, State1> {
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

public struct ReactorConverter3<Base: Reactor, Action1, State1, Action2, State2> {
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

public struct ReactorConverter4<Base: Reactor, Action1, State1, Action2, State2, Action3, State3> {
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

public struct ReactorConverter5<Base: Reactor, Action1, State1, Action2, State2, Action3, State3, Action4, State4> {
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



