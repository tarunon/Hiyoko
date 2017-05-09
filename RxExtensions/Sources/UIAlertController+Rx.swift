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
import Base

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

final public class AlertReactor<ButtonConfig>: Reactor {
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
    public struct AlertView: View {
        public typealias State = UIAlertAction.Config
        public typealias Action = Void

        let view: UIAlertController

        public init(view: UIAlertController) {
            self.view = view
        }

        public func present(state: Observable<UIAlertAction.Config>) -> Present<Void> {
            return .init(
                action: state
                    .flatMapFirst { [view = self.view] (ok) in
                        view.rx.addAction(config: ok)
                    }
                    .map { _ in }
            )
        }
    }
}

final public class ConfirmReactor<ButtonConfig>: Reactor {
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
    public struct ConfirmView: View {
        public typealias State = (ok: UIAlertAction.Config, cancel: UIAlertAction.Config)
        public typealias Action = Bool

        let view: UIAlertController

        public init(view: UIAlertController) {
            self.view = view
        }

        public func present(state: Observable<(ok: UIAlertAction.Config, cancel: UIAlertAction.Config)>) -> Present<Bool> {
            return .init(
                action: state
                    .flatMapFirst { [view = self.view] (ok, cancel) in
                        Observable
                            .merge(
                                view.rx.addAction(config: ok)
                                    .map { _ in true },
                                view.rx.addAction(config: cancel)
                                    .map { _ in false }
                        )
                    }
            )
        }
    }
}

final public class PromptReactor<ButtonConfig>: Reactor {
    public typealias Result = String?
    public typealias Action = String?
    public typealias State = (ok: ButtonConfig, cancel: ButtonConfig, defaultText: String?, placeholder: String?)

    let initialState: State

    public init(ok: ButtonConfig, cancel: ButtonConfig, defaultText: String?=nil, placeholder: String?=nil) {
        self.initialState = (ok: ok, cancel: cancel, defaultText: defaultText, placeholder: placeholder)
    }

    public func process(action: Observable<String?>) throws -> Process<State, String?> {
        return .init(
            state: Observable.just(initialState),
            result: action
        )
    }
}

extension UIAlertController {
    public struct PromptView: View {
        public typealias State = (ok: UIAlertAction.Config, cancel: UIAlertAction.Config, defaultText: String?, placeholder: String?)
        public typealias Action = String?

        let view: UIAlertController

        public init(view: UIAlertController) {
            self.view = view
        }

        public func present(state: Observable<(ok: UIAlertAction.Config, cancel: UIAlertAction.Config, defaultText: String?, placeholder: String?)>) -> Present<String?> {
            return .init(
                action: state
                    .flatMap { [view=self.view] (state) -> Observable<String?> in
                        view.addTextField { (textField) in
                            textField.text = state.defaultText
                            textField.placeholder = state.placeholder
                        }
                        return Observable
                            .merge(
                                view.rx.addAction(config: state.ok)
                                    .map { _ in view.textFields?.first?.text },
                                view.rx.addAction(config: state.cancel)
                                    .map { _ in String?.none }
                        )
                }
            )
        }
    }
}

public protocol ActionSheetElement {
    associatedtype E
    associatedtype ButtonConfig
    var element: E { get }
    var buttonConfig: ButtonConfig { get }
}

final public class ActionSheetReactor<ButtonConfig, E: ActionSheetElement>: Reactor where E.ButtonConfig == ButtonConfig {
    public typealias Result = E.E
    public typealias Action = Int
    public typealias State = (selects: [ButtonConfig], cancel: ButtonConfig)

    let elements: [E]
    let cancel: ButtonConfig

    public init(elements: [E], cancel: ButtonConfig) {
        self.elements = elements
        self.cancel = cancel
    }

    public func process(action: Observable<Int>) throws -> Process<(selects: [ButtonConfig], cancel: ButtonConfig), E.E> {
        return .init(
            state: Observable.just((selects: elements.map { $0.buttonConfig }, cancel: cancel)),
            result: action.map { self.elements[$0].element }
        )
    }
}

extension UIAlertController {
    public struct ActionSheetView: View {
        public typealias State = (selects: [UIAlertAction.Config], cancel: UIAlertAction.Config)
        public typealias Action = Int

        let view: UIAlertController

        public init(view: UIAlertController) {
            self.view = view
        }

        public func present(state: Observable<(selects: [UIAlertAction.Config], cancel: UIAlertAction.Config)>) -> Present<Int> {
            return .init(
                action: state.flatMap { (selects, cancel) -> Observable<Int> in
                    Observable
                        .merge(
                            selects.enumerated()
                                .map { (offset, element) in
                                    self.view.rx.addAction(config: element)
                                        .map { _ in offset }
                            } + [
                                self.view.rx.addAction(config: cancel)
                                    .flatMap { _ in
                                        Observable.empty()
                                }
                            ]
                        )
                }
            )
        }
    }
}

extension UIAlertController: Either4View {
    public typealias View1 = AlertView
    public typealias View2 = ConfirmView
    public typealias View3 = PromptView
    public typealias View4 = ActionSheetView
    
    public var view1: UIAlertController.AlertView {
        return .init(view: self)
    }
    
    public var view2: UIAlertController.ConfirmView {
        return .init(view: self)
    }
    
    public var view3: UIAlertController.PromptView {
        return .init(view: self)
    }
    
    public var view4: UIAlertController.ActionSheetView {
        return .init(view: self)
    }
    
    public struct ActionSheetElement: RxExtensions.ActionSheetElement {
        public var element: String
        public var buttonConfig: UIAlertAction.Config
    }
    
    public class AlertReactor: Either4Reactor {
        public typealias Reactor1 = RxExtensions.AlertReactor<UIAlertAction.Config>
        public typealias Reactor2 = RxExtensions.ConfirmReactor<UIAlertAction.Config>
        public typealias Reactor3 = RxExtensions.PromptReactor<UIAlertAction.Config>
        public typealias Reactor4 = RxExtensions.ActionSheetReactor<UIAlertAction.Config, ActionSheetElement>
        
        public typealias Result = Reactor1.Result
        
        public lazy var reactor1: Reactor1 = undefined()
        public lazy var reactor2: Reactor2 = undefined()
        public lazy var reactor3: Reactor3 = undefined()
        public lazy var reactor4: Reactor4 = undefined()
        
        public init(ok: UIAlertAction.Config) {
            self.reactor1 = Reactor1(ok: ok)
        }
    }
    
    public class ConfirmReactor: Either4Reactor {
        public typealias Reactor1 = RxExtensions.AlertReactor<UIAlertAction.Config>
        public typealias Reactor2 = RxExtensions.ConfirmReactor<UIAlertAction.Config>
        public typealias Reactor3 = RxExtensions.PromptReactor<UIAlertAction.Config>
        public typealias Reactor4 = RxExtensions.ActionSheetReactor<UIAlertAction.Config, ActionSheetElement>
        
        public typealias Result = Reactor2.Result
        
        public lazy var reactor1: Reactor1 = undefined()
        public lazy var reactor2: Reactor2 = undefined()
        public lazy var reactor3: Reactor3 = undefined()
        public lazy var reactor4: Reactor4 = undefined()
        
        public init(ok: UIAlertAction.Config, cancel: UIAlertAction.Config) {
            self.reactor2 = Reactor2(ok: ok, cancel: cancel)
        }
    }
    
    public class PromptReactor: Either4Reactor {
        public typealias Reactor1 = RxExtensions.AlertReactor<UIAlertAction.Config>
        public typealias Reactor2 = RxExtensions.ConfirmReactor<UIAlertAction.Config>
        public typealias Reactor3 = RxExtensions.PromptReactor<UIAlertAction.Config>
        public typealias Reactor4 = RxExtensions.ActionSheetReactor<UIAlertAction.Config, ActionSheetElement>
        
        public typealias Result = Reactor3.Result
        
        public lazy var reactor1: Reactor1 = undefined()
        public lazy var reactor2: Reactor2 = undefined()
        public lazy var reactor3: Reactor3 = undefined()
        public lazy var reactor4: Reactor4 = undefined()
        
        public init(ok: UIAlertAction.Config, cancel: UIAlertAction.Config, defaultText: String?=nil, placeholder: String?=nil) {
            reactor3 = Reactor3(ok: ok, cancel: cancel, defaultText: defaultText, placeholder: placeholder)
        }
    }
    
    public class ActionSheetReactor<E: RxExtensions.ActionSheetElement>: Either4Reactor where E.ButtonConfig == UIAlertAction.Config {
        public typealias Reactor1 = RxExtensions.AlertReactor<UIAlertAction.Config>
        public typealias Reactor2 = RxExtensions.ConfirmReactor<UIAlertAction.Config>
        public typealias Reactor3 = RxExtensions.PromptReactor<UIAlertAction.Config>
        public typealias Reactor4 = RxExtensions.ActionSheetReactor<UIAlertAction.Config, E>
        
        public typealias Result = Reactor4.Result
        
        public lazy var reactor1: Reactor1 = undefined()
        public lazy var reactor2: Reactor2 = undefined()
        public lazy var reactor3: Reactor3 = undefined()
        public lazy var reactor4: Reactor4 = undefined()
        
        public init(elements: [E], cancel: UIAlertAction.Config) {
            reactor4 = Reactor4(elements: elements, cancel: cancel)
        }
    }
}
