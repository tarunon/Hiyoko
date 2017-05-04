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

final public class AlertViewModel: RxViewModel {
    public typealias Result = Void
    public typealias Input = Void
    public typealias Output = String
    
    public let result: Observable<Void>
    public let emitter: RxIOEmitter<Void, String> = RxIOEmitter()
    
    public init(ok: String) {
        self.result = emitter.input
        emitter.output.onNext(ok)
    }
}

extension UIAlertController {
    public func bind(alert: AlertViewModel.ViewBinder) -> Disposable {
        return alert.output
            .flatMapFirst { [unowned self] (ok) in
                self.rx.addAction(config: .init(title: ok, style: .cancel))
                    .map { _ in }
            }
            .bind(to: alert.input)
    }
}

final public class ConfirmViewModel: RxViewModel {
    public typealias Result = Bool
    public typealias Input = Bool
    public typealias Output = (ok: String, cancel: String)
    
    public let result: Observable<Bool>
    public var emitter: RxIOEmitter<Bool, (ok: String, cancel: String)> = RxIOEmitter()
    
    public init(ok: String, cancel: String) {
        self.result = emitter.input
        emitter.output.onNext((ok: ok, cancel: cancel))
    }
}

extension UIAlertController {
    public func bind(confirm: ConfirmViewModel.ViewBinder) -> Disposable {
        return confirm.output
            .flatMapFirst { [unowned self] (ok, cancel) in
                Observable
                    .merge(
                        self.rx.addAction(config: .init(title: ok, style: .default))
                            .map { _ in true },
                        self.rx.addAction(config: .init(title: cancel, style: .cancel))
                            .map { _ in false }
                    )
            }
            .bind(to: confirm.input)
    }
}

final public class PromptViewModel: RxViewModel {
    public typealias Result = String?
    public typealias Input = String?
    public typealias Output = (ok: String, cancel: String, defaultText: String?)
    
    public let result: Observable<String?>
    public let emitter: RxIOEmitter<String?, (ok: String, cancel: String, defaultText: String?)> = RxIOEmitter()
    
    public init(ok: String, cancel: String, defaultText: String?=nil) {
        self.result = emitter.input
        emitter.output.onNext((ok: ok, cancel: cancel, defaultText: defaultText))
    }
}

extension UIAlertController {
    public func bind(prompt: PromptViewModel.ViewBinder) -> Disposable {
        return prompt.output
            .flatMapFirst { [unowned self] (ok, cancel, defaultText) -> Observable<String?> in
                self.addTextField { $0.text = defaultText }
                return Observable
                    .merge(
                        self.rx.addAction(config: .init(title: ok, style: .default))
                            .map { _ in self.textFields?.first?.text },
                        self.rx.addAction(config: .init(title: cancel, style: .cancel))
                            .map { _ in nil }
                    )
            }
            .bind(to: prompt.input)
    }
}

public protocol ActionSheetElement: CustomStringConvertible {
    associatedtype E
    var element: E { get }
}

final public class ActionSheetViewModel<E: ActionSheetElement>: RxViewModel {
    public typealias Result = E.E
    public typealias Input = E.E
    public typealias Output = (elements: [E], cancel: String)
    
    public let result: Observable<Result>
    public let emitter: RxIOEmitter<E.E, (elements: [E], cancel: String)> = RxIOEmitter()
    
    public init(elements: [E], cancel: String) {
        self.result = emitter.input
        emitter.output.onNext((elements: elements, cancel: cancel))
    }
}

extension UIAlertController {
    public func bind<E: ActionSheetElement>(actionSheet: ActionSheetViewModel<E>.ViewBinder) -> Disposable {
        return actionSheet.output
            .flatMapFirst { [unowned self] (elements, cancel) in
                Observable
                    .merge(
                        elements
                            .map { element in
                                self.rx.addAction(config: .init(title: "\(element)", style: .default))
                                    .map { _ in element.element }
                            } + [
                                self.rx.addAction(config: .init(title: cancel, style: .cancel))
                                    .flatMap { _ in Observable.empty() }
                            ]
                    )
            }
            .bind(to: actionSheet.input)
    }
}
