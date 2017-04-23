//
//  UIViewController+Rx.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension UIViewController {
    public enum State {
        case willAppear
        case didAppear
        case willDisappear
        case didDisappear
        
        static func merge(_ lhs: State, _ rhs: State) -> State {
            switch (lhs, rhs) {
            case (.didDisappear, _), (_, .didDisappear):
                return .didDisappear
            case (.willDisappear, _), (_, .willDisappear):
                return .willDisappear
            case (.willAppear, _), (_, .willAppear):
                return .willAppear
            default:
                return .didAppear
            }
        }
    }
}

public extension Reactive where Base: UIViewController {
    private var _stateChange: Observable<UIViewController.State> {
        return Observable
            .of(
                base.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                    .map { _ in UIViewController.State.willAppear },
                base.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
                    .map { _ in UIViewController.State.didAppear },
                base.rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
                    .map { _ in UIViewController.State.didDisappear },
                base.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
                    .map { _ in UIViewController.State.didDisappear }
            )
            .merge()
            .shareReplay(1)
            .takeUntil(base.rx.deallocated)
    }
    
    public var stateChange: ControlEvent<UIViewController.State> {
        let source = Observable
            .combineLatest(
                _stateChange,
                base.rx.methodInvoked(#selector(UIViewController.didMove(toParentViewController:)))
                    .startWith([])
                    .flatMapLatest { [weak base=base] _ -> Observable<UIViewController.State?> in
                        guard let base = base, let parent = base.parent else {
                            return Observable.just(nil)
                        }
                        return parent.rx.stateChange
                            .map { .some($0) }
                    }
            ) { ($0, $1) }
            .map { (state, parentState) -> UIViewController.State in
                guard let parentState = parentState else {
                    return state
                }
                return UIViewController.State.merge(state, parentState)
            }
        return ControlEvent(events: source)
    }
}
