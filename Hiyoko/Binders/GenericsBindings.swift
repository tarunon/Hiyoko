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

class NavigationController<V: UIViewController>: UIKitExtensions.NavigationController<V>, View where V: View {
    typealias State = V.State
    typealias Action = V.Action
    
    func present(state: Observable<V.State>) -> Present<V.Action> {
        return rootViewController.present(state: state)
    }
}
