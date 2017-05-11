//
//  GenericsBindings.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import Reactor
import UIKitExtensions
import HiyokoKit

class NavigationController<V: UIViewController>: UIKitExtensions.NavigationController<V>, View where V: View {
    typealias State = V.State
    typealias Action = V.Action
    
    func present(state: Observable<V.State>) -> Present<V.Action> {
        return rootViewController.present(state: state)
    }
}

class TabBarController<V1: UIViewController, V2: UIViewController, V3: UIViewController, V4: UIViewController, V5: UIViewController>: TabBarController5<V1, V2, V3, V4, V5>, View where V1: View, V2: View, V3: View, V4: View, V5: View {
    typealias State = Either5<V1.State, V2.State, V3.State, V4.State, V5.State>
    typealias Action = Either5<V1.Action, V2.Action, V3.Action, V4.Action, V5.Action>

    func present(state: Observable<State>) -> Present<Action> {
        return Present(
            action: Observable
                .merge(
                    childViewController1.present(state: state.flatMap { $0.a }).action.map { Action.a($0) },
                    childViewController2.present(state: state.flatMap { $0.b }).action.map { Action.b($0) },
                    childViewController3.present(state: state.flatMap { $0.c }).action.map { Action.c($0) },
                    childViewController4.present(state: state.flatMap { $0.d }).action.map { Action.d($0) },
                    childViewController5.present(state: state.flatMap { $0.e }).action.map { Action.e($0) }
                )
        )
    }
}

class EmptyViewController: UIViewController, EmptyView {

}
