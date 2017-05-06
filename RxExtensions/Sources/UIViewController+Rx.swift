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

extension UIViewController {
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

extension Reactive where Base: UIViewController {
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
                    .flatMapLatest { [weak base] _ -> Observable<UIViewController.State?> in
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

extension Reactive where Base: UIViewController {
    public func dismiss(animated: Bool) -> Observable<Void> {
        return Observable
            .create { [weak base] (observer) -> Disposable in
                guard let base = base, let presenting = base.presentingViewController else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                presenting.dismiss(animated: animated, completion: {
                    observer.onNext()
                    observer.onCompleted()
                })
                return Disposables.create()
            }
    }
    
    public func pop(animated: Bool) -> Observable<Void> {
        return Observable
            .create { [weak base] (observer) -> Disposable in
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
    
    private func presentWithViewModel<V: UIViewController, M: RxViewModel>(viewController: V, viewModel: M, binder: @escaping (V) -> (M.ViewBinder) -> Disposable, present: @escaping (Base, V) -> (), dismiss: Observable<Void>) -> Observable<M.Result> {
        return Observable<M.Result>
            .create { [weak base] (observer) -> Disposable in
                guard let base=base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                let d1 = binder(viewController)(viewModel.asViewBinder())
                present(base, viewController)
                let d2 = viewModel.result
                    .catchError { error in
                        dismiss.map { throw error }
                    }
                    .concat(
                        dismiss.flatMap { Observable.empty() }
                    )
                    .takeUntil(viewController.rx.deallocated)
                    .bind(to: observer)
                return Disposables.create(d1, d2)
            }
    }
    
    public func present<V: UIViewController, M: RxViewModel>(viewController: V, viewModel: M, binder: @escaping (V) -> (M.ViewBinder) -> Disposable, animated: Bool) -> Observable<M.Result> {
        return base.rx
            .presentWithViewModel(
                viewController: viewController,
                viewModel: viewModel,
                binder: binder,
                present: { (base, viewController) in
                    base.present(viewController, animated: animated)
                },
                dismiss: viewController.rx.dismiss(animated: animated)
            )
    }
    
    public func push<V: UIViewController, M: RxViewModel>(viewController: V, viewModel: M, binder: @escaping (V) -> (M.ViewBinder) -> Disposable, animated: Bool) -> Observable<M.Result> {
        return base.rx
            .presentWithViewModel(
                viewController: viewController,
                viewModel: viewModel,
                binder: binder,
                present: { (base, viewController) in
                    base.navigationController?.pushViewController(viewController, animated: animated)
                },
                dismiss: viewController.rx.pop(animated: animated)
            )
    }
    
    public func present<V: UIViewController, M: RxViewModel>(viewController: V, presentAnimation: AnimatingTransitioning<Base, V>?=nil, dismissAnimation: AnimatingTransitioning<V, Base>?=nil, viewModel: M, binder: @escaping (V) -> (M.ViewBinder) -> Disposable) -> Observable<M.Result> {
        return base.rx
            .presentWithViewModel(
                viewController: viewController,
                viewModel: viewModel,
                binder: binder,
                present: { (base, viewController) in
                    base.present(viewController, presentAnimation: presentAnimation, dismissAnimation: dismissAnimation)
                },
                dismiss: viewController.rx.dismiss(animated: true)
            )
    }
    
    public func push<V: UIViewController, M: RxViewModel>(viewController: V, pushAnimation: AnimatingTransitioning<Base, V>?=nil, popAnimation: AnimatingTransitioning<V, Base>?=nil, viewModel: M, binder: @escaping (V) -> (M.ViewBinder) -> Disposable) -> Observable<M.Result> {
        return base.rx
            .presentWithViewModel(
                viewController: viewController,
                viewModel: viewModel,
                binder: binder,
                present: { (base, viewController) in
                    base.push(viewController, pushAnimation: pushAnimation, popAnimation: popAnimation)
                },
                dismiss: viewController.rx.pop(animated: true)
            )
    }
}
