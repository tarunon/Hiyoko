//
//  GenericsBindings.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxExtensions
import UIKitExtensions

extension NavigationController {
    static func present<S, A>(binder: @escaping (V) -> (Observable<S>) -> Present<A>) -> (NavigationController<V>) -> (Observable<S>) -> Present<A> {
        return { (navigationController) in
            return { (state) in
                return binder(navigationController.rootViewController)(state)
            }
        }
    }
}

extension UIViewController {
    func present<S, A>(state: Observable<S>) -> Present<A> {
        return Present(action: Observable.empty())
    }
}

extension UIView {
    func present<S, A>(state: Observable<S>) -> Present<A> {
        return Present(action: Observable.empty())
    }
}
