//
//  ProgressViewController+Login.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/03.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import RxSwift
import RxCocoa
import RxExtensions

extension ProgressViewController {
    struct LoginView: View {
        typealias State = LoginReactor.State
        typealias Action = LoginReactor.Action

        let view: ProgressViewController

        func present(state: Observable<State>) -> Present<Action> {
            return .init(
                action: Observable.never(),
                bind: state
                    .subscribe(
                        onNext: { (viewController) in
                            viewController.modalPresentationStyle = .overFullScreen
                            self.view.present(viewController, animated: true)
                        }
                )
            )
        }
    }
}
