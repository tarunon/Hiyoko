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
    static func view<A>(view: @escaping (V) -> (A)) -> (NavigationController<V>) -> A {
        return { (navigationController) in
            return view(navigationController.rootViewController)
        }
    }
}
