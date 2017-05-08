//
//  UIAlertController+Rx.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension UIAlertAction {
    public struct Config {
        public let title: String?
        public let style: UIAlertActionStyle
        
        public init(title: String?, style: UIAlertActionStyle) {
            self.title = title
            self.style = style
        }
    }
}

public extension Reactive where Base: UIAlertController {
    func addAction(config: UIAlertAction.Config) -> ControlEvent<UIAlertAction.Config> {
        let source = Observable<UIAlertAction.Config>
            .create { [weak base] (observer) -> Disposable in
                guard let base = base else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                base.addAction(UIAlertAction(title: config.title, style: config.style, handler: { _ in
                    observer.onNext(config)
                    observer.onCompleted()
                }))
                return Disposables.create()
            }
        return ControlEvent(events: source)
    }
}

final public class AlertViewModel<ButtonConfig>: RxViewModel {
    public typealias Result = Void
    public typealias Action = Void
    public typealias State = ButtonConfig

    let ok: ButtonConfig

    public init(ok: ButtonConfig) {
        self.ok = ok
    }

    public func process(action: Observable<Void>) throws -> Process<ButtonConfig, Void> {
        return .init(
            state: Observable.just(ok),
            result: action
        )
    }
}

extension UIAlertController {
    public func present(state: Observable<AlertViewModel<UIAlertAction.Config>.State>) -> Present<Void> {
        return .init(
            action: state
                .flatMapFirst { [unowned self] (ok) in
                    self.rx.addAction(config: ok)
                }
                .map { _ in }
        )
    }
}

final public class ConfirmViewModel<ButtonConfig>: RxViewModel {
    public typealias Result = Bool
    public typealias Action = Bool
    public typealias State = (ok: ButtonConfig, cancel: ButtonConfig)

    let ok: ButtonConfig
    let cancel: ButtonConfig

    public init(ok: ButtonConfig, cancel: ButtonConfig) {
        self.ok = ok
        self.cancel = cancel
    }

    public func process(action: Observable<Bool>) throws -> Process<(ok: ButtonConfig, cancel: ButtonConfig), Bool> {
        return .init(
            state: Observable.just((ok: ok, cancel: cancel)),
            result: action
        )
    }
}

extension UIAlertController {
    public func present(state: Observable<ConfirmViewModel<UIAlertAction.Config>.State>) -> Present<Bool> {
        return .init(
            action: state.flatMapFirst { [unowned self] (ok, cancel) in
                Observable
                    .merge(
                        self.rx.addAction(config: ok)
                            .map { _ in true },
                        self.rx.addAction(config: cancel)
                            .map { _ in false }
                )
            }
        )
    }
}

final public class PromptViewModel<ButtonConfig>: RxViewModel {
    public typealias Result = String?
    public typealias Action = String?
    public struct State {
        let ok: ButtonConfig
        let cancel: ButtonConfig
        let defaultText: String?
        let placeholder: String?
    }

    let initialState: State

    public init(ok: ButtonConfig, cancel: ButtonConfig, defaultText: String?=nil, placeholder: String?=nil) {
        self.initialState = State(ok: ok, cancel: cancel, defaultText: defaultText, placeholder: placeholder)
    }

    public func process(action: Observable<String?>) throws -> Process<PromptViewModel<ButtonConfig>.State, String?> {
        return .init(
            state: Observable.just(initialState),
            result: action
        )
    }
}

extension UIAlertController {
    public func present(state: Observable<PromptViewModel<UIAlertAction.Config>.State>) -> Present<String?> {
        return .init(
            action: state
                .flatMap { [unowned self] (state) -> Observable<String?> in
                    self.addTextField { (textField) in
                        textField.text = state.defaultText
                        textField.placeholder = state.placeholder
                    }
                    return Observable
                        .merge(
                            self.rx.addAction(config: state.ok)
                                .map { _ in self.textFields?.first?.text },
                            self.rx.addAction(config: state.cancel)
                                .map { _ in String?.none }
                    )
            }
        )
    }
}

public protocol ActionSheetElement: CustomStringConvertible {
    associatedtype E
    var element: E { get }
}

final public class ActionSheetViewModel<ButtonConfig, E: ActionSheetElement>: RxViewModel {
    public typealias Result = E.E
    public typealias Action = E.E
    public typealias State = (elements: [E], cancel: ButtonConfig)

    let elements: [E]
    let cancel: ButtonConfig

    public init(elements: [E], cancel: ButtonConfig) {
        self.elements = elements
        self.cancel = cancel
    }

    public func process(action: Observable<E.E>) throws -> Process<(elements: [E], cancel: ButtonConfig), E.E> {
        return .init(
            state: Observable.just((elements: elements, cancel: cancel)),
            result: action
        )
    }
}

extension UIAlertController {
    public func presenter<E: ActionSheetElement>(state: Observable<ActionSheetViewModel<UIAlertAction.Config, E>.State>) -> Present<E.E> {
        return .init(
            action: state
                .flatMapFirst { (elements, cancel) in
                    Observable
                        .merge(
                            elements
                                .map { element in
                                    self.rx.addAction(config: .init(title: "\(element)", style: .default))
                                        .map { _ in element.element }
                                } + [
                                    self.rx.addAction(config: cancel)
                                        .flatMap { _ in Observable.empty() }
                            ]
                    )
            }
        )
    }
}
