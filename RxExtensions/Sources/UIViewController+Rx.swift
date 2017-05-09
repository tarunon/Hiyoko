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
    public enum LifeCycleState {
        case willAppear
        case didAppear
        case willDisappear
        case didDisappear
        
        static func merge(_ lhs: LifeCycleState, _ rhs: LifeCycleState) -> LifeCycleState {
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
    private var _stateChange: Observable<UIViewController.LifeCycleState> {
        return Observable
            .of(
                base.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                    .map { _ in UIViewController.LifeCycleState.willAppear },
                base.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
                    .map { _ in UIViewController.LifeCycleState.didAppear },
                base.rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
                    .map { _ in UIViewController.LifeCycleState.didDisappear },
                base.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
                    .map { _ in UIViewController.LifeCycleState.didDisappear }
            )
            .merge()
            .shareReplay(1)
            .takeUntil(base.rx.deallocated)
    }
    
    public var stateChange: ControlEvent<UIViewController.LifeCycleState> {
        let source = Observable
            .combineLatest(
                _stateChange,
                base.rx.methodInvoked(#selector(UIViewController.didMove(toParentViewController:)))
                    .startWith([])
                    .flatMapLatest { [weak base] _ -> Observable<UIViewController.LifeCycleState?> in
                        guard let base = base, let parent = base.parent else {
                            return Observable.just(nil)
                        }
                        return parent.rx.stateChange
                            .map { .some($0) }
                    }
            ) { ($0, $1) }
            .map { (state, parentState) -> UIViewController.LifeCycleState in
                guard let parentState = parentState else {
                    return state
                }
                return UIViewController.LifeCycleState.merge(state, parentState)
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

    private func presentWithReactor<VC: UIViewController, V: View, R: Reactor>(viewController: VC, view: @escaping (VC) -> V,  reactor: R, present: @escaping (Base, VC) -> (), dismiss: Observable<Void>) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        return Observable<R.Result>
            .create { [weak base] (observer) -> Disposable in
                guard let base=base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                do {
                    return try bind(view(viewController), reactor)
                        .do(
                            onSubscribe: { present(base, viewController) }
                        )
                        .catchError { error in
                            dismiss.map { throw error }
                        }
                        .concat(
                            dismiss.flatMap { Observable.empty() }
                        )
                        .takeUntil(viewController.rx.deallocated)
                        .bind(to: observer)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
        }
    }

    public func present<V: View, R: Reactor>(viewController: V, reactor: R, animated: Bool) -> Observable<R.Result> where V: UIViewController, V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: { $0 },
                reactor: reactor,
                present: { (base, viewController) in
                    base.present(viewController, animated: animated)
                },
                dismiss: viewController.rx.dismiss(animated: animated)
            )
    }

    public func present<VC: UIViewController, V: View, R: Reactor>(viewController: VC, view: @escaping (VC) -> (V), reactor: R, animated: Bool) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: view,
                reactor: reactor,
                present: { (base, viewController) in
                    base.present(viewController, animated: animated)
            },
                dismiss: viewController.rx.dismiss(animated: animated)
        )
    }

    public func push<V: View, R: Reactor>(viewController: V, reactor: R, animated: Bool) -> Observable<R.Result> where V: UIViewController, V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: { $0 },
                reactor: reactor,
                present: { (base, viewController) in
                    base.navigationController?.pushViewController(viewController, animated: animated)
                },
                dismiss: viewController.rx.pop(animated: animated)
            )
    }

    public func push<VC: UIViewController, V: View, R: Reactor>(viewController: VC, view: @escaping (VC) -> (V), reactor: R, animated: Bool) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: view,
                reactor: reactor,
                present: { (base, viewController) in
                    base.navigationController?.pushViewController(viewController, animated: animated)
            },
                dismiss: viewController.rx.pop(animated: animated)
        )
    }

    public func present<V: View, R: Reactor>(viewController: V, reactor: R, presentAnimation: AnimatingTransitioning<Base, V>?=nil, dismissAnimation: AnimatingTransitioning<V, Base>?=nil) -> Observable<R.Result> where V: UIViewController, V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: { $0 },
                reactor: reactor,
                present: { (base, viewController) in
                    base.present(viewController, presentAnimation: presentAnimation, dismissAnimation: dismissAnimation)
                },
                dismiss: viewController.rx.dismiss(animated: true)
            )
    }

    public func present<VC: UIViewController, V: View, R: Reactor>(viewController: VC, view: @escaping (VC) -> (V), reactor: R, presentAnimation: AnimatingTransitioning<Base, VC>?=nil, dismissAnimation: AnimatingTransitioning<VC, Base>?=nil) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: view,
                reactor: reactor,
                present: { (base, viewController) in
                    base.present(viewController, presentAnimation: presentAnimation, dismissAnimation: dismissAnimation)
            },
                dismiss: viewController.rx.dismiss(animated: true)
        )
    }

    public func push<V: View, R: Reactor>(viewController: V, reactor: R, pushAnimation: AnimatingTransitioning<Base, V>?=nil, popAnimation: AnimatingTransitioning<V, Base>?=nil) -> Observable<R.Result> where V: UIViewController, V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: { $0 },
                reactor: reactor,
                present: { (base, viewController) in
                    base.push(viewController, pushAnimation: pushAnimation, popAnimation: popAnimation)
                },
                dismiss: viewController.rx.pop(animated: true)
            )
    }

    public func push<VC: UIViewController, V: View, R: Reactor>(viewController: VC, view: @escaping (VC) -> (V), reactor: R, pushAnimation: AnimatingTransitioning<Base, VC>?=nil, popAnimation: AnimatingTransitioning<VC, Base>?=nil) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        return base.rx
            .presentWithReactor(
                viewController: viewController,
                view: view,
                reactor: reactor,
                present: { (base, viewController) in
                    base.push(viewController, pushAnimation: pushAnimation, popAnimation: popAnimation)
            },
                dismiss: viewController.rx.pop(animated: true)
        )
    }
}
