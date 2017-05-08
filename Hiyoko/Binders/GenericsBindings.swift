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
    static func bind<M>(binder: @escaping (V) -> (M) -> Disposable) -> (NavigationController<V>) -> (M) -> Disposable {
        return { (navigationController) in
            return { (viewModel) in
                return binder(navigationController.rootViewController)(viewModel)
            }
        }
    }
}

extension UIViewController {
    func bind<M>(viewModel: M) -> Disposable {
        return Disposables.create()
    }
}
