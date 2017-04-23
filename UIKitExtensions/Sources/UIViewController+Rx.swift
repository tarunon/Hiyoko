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
import Transitioning

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

public extension Reactive where Base: UIViewController {
    func dismiss(animated: Bool) -> Observable<Void> {
        return Observable
            .create { [weak base=base] (observer) -> Disposable in
                guard let base = base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                base.dismiss(animated: animated, completion: { 
                    observer.onNext()
                    observer.onCompleted()
                })
                return Disposables.create()
            }
    }
    
    func pop(animated: Bool) -> Observable<Void> {
        return Observable
            .create { [weak base=base] (observer) -> Disposable in
                guard let base = base, let navigationController = base.navigationController else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                navigationController.popViewController(animated: animated)
                observer.onNext()
                observer.onCompleted()
                return Disposables.create()
            }
    }
    
    func present<V: UIViewController, M: RxViewModel>(_ viewController: V, viewModel: @escaping (V) -> M, animated: Bool) -> Observable<M.Result> where M.Owner == V {
        return Observable<(V, M)>
            .create { [weak base=base] (observer) -> Disposable in
                guard let base=base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let viewModel = viewModel(viewController)
                base.present(viewController, animated: animated, completion: { _ in
                    observer.onNext((viewController, viewModel))
                    observer.onCompleted()
                })
                return Disposables.create()
            }
            .flatMap { (viewController, viewModel) -> Observable<M.Result> in
                let dismiss = viewController.rx.dismiss(animated: animated)
                return viewModel.result
                    .catchError { (error) in
                        dismiss.map { throw error }
                    }
                    .concat(
                        dismiss.flatMap { Observable.empty() }
                    )
                    .takeUntil(viewController.rx.deallocated)
            }
    }
    
    func push<V: UIViewController, M: RxViewModel>(_ viewController: V, viewModel: @escaping (V) -> M, animated: Bool) -> Observable<M.Result> where M.Owner == V {
        return Observable<(V, M)>
            .create { [weak base=base] (observer) -> Disposable in
                guard let base=base, let navigationController = base.navigationController else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let viewModel = viewModel(viewController)
                navigationController.pushViewController(viewController, animated: animated)
                observer.onNext((viewController, viewModel))
                observer.onCompleted()
                return Disposables.create()
            }
            .flatMap { (viewController, viewModel) -> Observable<M.Result> in
                let pop = viewController.rx.pop(animated: animated)
                return viewModel.result
                    .catchError { (error) in
                        pop.map { throw error }
                    }
                    .concat(
                        pop.flatMap { Observable.empty() }
                    )
                    .takeUntil(viewController.rx.deallocated)
        }
    }
    
    func present<V: UIViewController, M: RxViewModel>(_ viewController: V, presentAnimation: AnimatingTransitioning<Base, V>?=nil, dismissAnimation: AnimatingTransitioning<V, Base>?=nil, viewModel: @escaping (V) -> M) -> Observable<M.Result> where M.Owner == V {
        return Observable<(V, M)>
            .create { [weak base=base] (observer) -> Disposable in
                guard let base=base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let viewModel = viewModel(viewController)
                base.present(viewController, presentAnimation: presentAnimation, dismissAnimation: dismissAnimation, completion: { _ in
                    observer.onNext((viewController, viewModel))
                    observer.onCompleted()
                })
                return Disposables.create()
            }
            .flatMap { (viewController, viewModel) -> Observable<M.Result> in
                let dismiss = viewController.rx.dismiss(animated: true)
                return viewModel.result
                    .catchError { (error) in
                        dismiss.map { throw error }
                    }
                    .concat(
                        dismiss.flatMap { Observable.empty() }
                    )
                    .takeUntil(viewController.rx.deallocated)
        }
    }
    
    func push<V: UIViewController, M: RxViewModel>(_ viewController: V, pushAnimation: AnimatingTransitioning<Base, V>?=nil, popAnimation: AnimatingTransitioning<V, Base>?=nil, viewModel: @escaping (V) -> M) -> Observable<M.Result> where M.Owner == V {
        return Observable<(V, M)>
            .create { [weak base=base] (observer) -> Disposable in
                guard let base=base, base.navigationController != nil else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let viewModel = viewModel(viewController)
                base.push(viewController, pushAnimation: pushAnimation, popAnimation: popAnimation)
                observer.onNext((viewController, viewModel))
                observer.onCompleted()
                return Disposables.create()
            }
            .flatMap { (viewController, viewModel) -> Observable<M.Result> in
                let pop = viewController.rx.pop(animated: true)
                return viewModel.result
                    .catchError { (error) in
                        pop.map { throw error }
                    }
                    .concat(
                        pop.flatMap { Observable.empty() }
                    )
                    .takeUntil(viewController.rx.deallocated)
        }
    }
}
