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
    func bind(viewModel: LoginViewModel.Emitter) -> Disposable {
        return viewModel.state
            .subscribe(
                onNext: { [weak self] (viewController) in
                    viewController.modalPresentationStyle = .overFullScreen
                    self?.present(viewController, animated: true)
            }
        )
    }
}
