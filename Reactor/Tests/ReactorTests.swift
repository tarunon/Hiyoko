//
//  ReactorTests.swift
//  ReactorTests
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import XCTest
@testable import Reactor
import RxSwift
import RxCocoa
import RxTest

struct AnyReactor<Action, State, Result>: Reactor {
    let _process: (Observable<Action>) throws -> Process<State, Result>
    func process(action: Observable<Action>) throws -> Process<State, Result> {
        return try _process(action)
    }
}

struct AnyView<Action, State>: View {
    let _present: (Observable<State>) -> Present<Action>
    
    func present(state: Observable<State>) -> Present<Action> {
        return _present(state)
    }
}

struct DummyError: Error {
    static let instance = DummyError()
}

class ReactorTests: XCTestCase {
    
    func testSimplePresent() {
        let ts = TestScheduler(initialClock: 0)
        let emurator = PublishSubject<Int>()
        let simulator = PublishSubject<Int>()
        let reactor = AnyReactor<Never, Int, Never> { _ in Process(state: emurator, result: Observable.never()) }
        let view = AnyView<Never, Int> { state in return Present(action: Observable.never(), bind: state.bind(to: simulator)) }
        
        let d = ts.createColdObservable(
            [
                .init(time: 150, value: .next(1)),
                .init(time: 250, value: .next(10)),
                .init(time: 300, value: .next(20)),
                .init(time: 350, value: .error(DummyError.instance))
            ]
        ).bind(to: simulator)
        
        let x = ts.start {
            Observable
                .merge(
                    simulator,
                    Result(view: view, reactor: reactor).asObservable().flatMap { $0.result }.flatMap { _ in Observable.empty() }
            )
        }
        
        XCTAssertEqual(
            x.events,
            [
                .init(time: 250, value: .next(10)),
                .init(time: 300, value: .next(20)),
                .init(time: 350, value: .error(DummyError.instance)),
            ]
        )
        
        XCTAssertFalse(emurator.hasObservers)
        
        d.dispose()
    }
    
    func testSimpleResult() {
        let ts = TestScheduler(initialClock: 0)
        let simulator = PublishSubject<Int>()
        let reactor = AnyReactor<Int, Never, Int> { action in Process(state: Observable.never(), result: action) }
        let view = AnyView<Int, Never> { _ in return Present(action: simulator) }
        
        let d = ts.createColdObservable(
            [
                .init(time: 150, value: .next(1)),
                .init(time: 250, value: .next(10)),
                .init(time: 300, value: .next(20)),
                .init(time: 350, value: .error(DummyError.instance))
            ]
            ).bind(to: simulator)
        
        let x = ts.start {
            Result(view: view, reactor: reactor).asObservable().flatMap { $0.result }
        }
        
        XCTAssertEqual(
            x.events,
            [
                .init(time: 250, value: .next(10)),
                .init(time: 300, value: .next(20)),
                .init(time: 350, value: .error(DummyError.instance)),
            ]
        )
        
        XCTAssertFalse(simulator.hasObservers)
        
        d.dispose()
    }
}
