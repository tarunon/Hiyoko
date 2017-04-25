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
            .create { [weak base=base] (observer) -> Disposable in
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

final public class AlertViewModel<V: UIAlertController>: RxViewModel {
    public typealias Result = Void
    
    public let result: Observable<Void>
    
    init(view: V, buttonTitle: String) {
        result = view.rx.addAction(config: UIAlertAction.Config.init(title: buttonTitle, style: .cancel))
            .map { _ in }
    }
    
    public static func factory(_ buttonTitle: String) -> (_ view: V) -> AlertViewModel {
        return { view in
            return AlertViewModel(view: view, buttonTitle: buttonTitle)
        }
    }
}

final public class ConfirmViewModel<V: UIAlertController>: RxViewModel {
    public typealias Result = Bool
    
    public let result: Observable<Bool>
    
    init(view: V, okButtonTitle: String, cancelButtonTitle: String) {
        result = Observable
            .of(
                view.rx.addAction(config: UIAlertAction.Config.init(title: okButtonTitle, style: .default))
                    .map { _ in true },
                view.rx.addAction(config: UIAlertAction.Config.init(title: cancelButtonTitle, style: .cancel))
                    .map { _ in false }
            )
            .merge()
    }
    
    public static func factory(_ okButtonTitle: String, cancelButtonTitle: String) -> (_ view: V) -> ConfirmViewModel {
        return { (view) in
            self.init(view: view, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle)
        }
    }
}

final public class PromptViewModel<V: UIAlertController>: RxViewModel {
    public typealias Result = String?
    
    public let result: Observable<String?>
    
    public init(view: V, okButtonTitle: String, cancelButtonTitle: String, defaultText: String?) {
        view.addTextField()
        result = Observable
            .of(
                view.rx.addAction(config: UIAlertAction.Config.init(title: okButtonTitle, style: .default))
                    .map { _ in view.textFields?.first?.text },
                view.rx.addAction(config: UIAlertAction.Config.init(title: cancelButtonTitle, style: .cancel))
                    .map { _ in nil }
            )
            .merge()
    }
    
    public static func factory(okButtonTitle: String, cancelButtonTitle: String, defaultText: String?=nil) -> (_ view: V) -> PromptViewModel {
        return { (view) in
            PromptViewModel(view: view, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle, defaultText: defaultText)
        }
    }
}
