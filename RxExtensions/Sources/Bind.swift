//
//  Bind.swift
//  Hiyoko
//
//  Created by ST90872 on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

internal func bind<A, S, V: View, R: Reactor>(_ view: V, _ reactor: R) throws -> Observable<R.Result> where V.Action == A, R.Action == A, V.State == S, R.State == S {
    let actionSubject = PublishSubject<A>()
    let process = try reactor.process(action: actionSubject.asObservable())
    return Observable.create { (observer) -> Disposable in
        let d1 = process.result.bind(to: observer)
        let present = view.present(state: process.state.concat(Observable.never()).shareReplay(1))
        let d2 = present.action.bind(to: actionSubject)
        return Disposables.create(d1, d2)
    }
}
