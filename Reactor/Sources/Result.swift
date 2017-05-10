//
//  Result.swift
//  Hiyoko
//
//  Created by ST90872 on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

internal class Result<V: View, R: Reactor>: ObservableConvertibleType where V.Action == R.Action, V.State == R.State {
    let view: () -> V
    let reactor: () -> R

    init(view: @autoclosure @escaping () -> V, reactor: @autoclosure @escaping () -> R) {
        self.view = view
        self.reactor = reactor
    }

    func asObservable() -> Observable<(result: Observable<R.Result>, view: V)> {
        return Observable.create { (observer) -> Disposable in
            do {
                let actionSubject = PublishSubject<V.Action>()
                let view = self.view()
                let reactor = self.reactor()
                let process = try reactor.process(action: actionSubject.asObservable())
                let present = view.present(state: process.state.concat(Observable.never()).shareReplay(1))
                let result = Observable<R.Result>
                    .create { (observer) in
                        let d1 = present.action.bind(to: actionSubject)
                        let d2 = process.result.bind(to: observer)
                        return Disposables.create(d1, d2)
                }
                observer.onNext((result: result, view: view))
                observer.onCompleted()
                return Disposables.create()
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }
}
