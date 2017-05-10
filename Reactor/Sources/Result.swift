//
//  Result.swift
//  Hiyoko
//
//  Created by ST90872 on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

internal class Result<T>: ObservableConvertibleType {
    private let _observable: () -> Observable<T>

    init<V: View, R: Reactor>(view: V, reactor: R) where V.Action == R.Action, V.State == R.State, R.Result == T {
        _observable = {
            let actionSubject = PublishSubject<V.Action>()
            return Observable.create { (observer) -> Disposable in
                do {
                    let process = try reactor.process(action: actionSubject.asObservable())
                    let d1 = process.result.bind(to: observer)
                    let present = view.present(state: process.state.concat(Observable.never()).shareReplay(1))
                    let d2 = present.action.bind(to: actionSubject)
                    return Disposables.create(d1, d2)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }
        }
    }

    func asObservable() -> Observable<T> {
        return _observable()
    }
}
