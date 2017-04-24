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

public class Alert<V: UIAlertController>: RxViewModel {
    public typealias Result = Void
    public typealias Owner = V
    
    public let result: Observable<Void>
    
    init(owner: Owner, buttonTitle: String) {
        result = owner.rx.addAction(config: UIAlertAction.Config.init(title: buttonTitle, style: .cancel))
            .map { _ in }
    }
    
    public static func buttonTitle(_ title: String) -> (_ owner: Owner) -> Alert {
        return { owner in
            return Alert(owner: owner, buttonTitle: title)
        }
    }
}

public class Confirm<V: UIAlertController>: RxViewModel {
    public typealias Result = Bool
    public typealias Owner = V
    
    public let result: Observable<Bool>
    
    init(owner: Owner, okButtonTitle: String, cancelButtonTitle: String) {
        result = Observable
            .of(
                owner.rx.addAction(config: UIAlertAction.Config.init(title: okButtonTitle, style: .default))
                    .map { _ in true },
                owner.rx.addAction(config: UIAlertAction.Config.init(title: cancelButtonTitle, style: .cancel))
                    .map { _ in false }
            )
            .merge()
    }
    
    public static func buttonTitles(okButtonTitle: String, cancelButtonTitle: String) -> (_ owner: Owner) -> Confirm {
        return { owner in
            return Confirm(owner: owner, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle)
        }
    }
}

public class Prompt<V: UIAlertController>: RxViewModel {
    public typealias Result = String?
    public typealias Owner = V
    
    public let result: Observable<String?>
    
    init(owner: Owner, okButtonTitle: String, cancelButtonTitle: String, defaultText: String?) {
        owner.addTextField()
        result = Observable
            .of(
                owner.rx.addAction(config: UIAlertAction.Config.init(title: okButtonTitle, style: .default))
                    .map { _ in owner.textFields?.first?.text },
                owner.rx.addAction(config: UIAlertAction.Config.init(title: cancelButtonTitle, style: .cancel))
                    .map { _ in nil }
            )
            .merge()
    }
    
    public static func buttonTitles(okButtonTitle: String, cancelButtonTitle: String, defaultText: String? = nil) -> (_ owner: Owner) -> Prompt {
        return { owner in
            return Prompt(owner: owner, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle, defaultText: defaultText)
        }
    }
}
