//
//  LoginViewController.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/30.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import RxExtensions
import SafariServices

final class LoginViewController: UIViewController {
    
}

extension LoginViewController: StoryboardInstantiatable {
    
}

extension LoginViewController: LoginViewControllerType {
    func selectAccount(_ accounts: [Account]) -> Observable<Account> {
        return self.rx.present(
            UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet),
            viewModelFactory: ActionSheetViewModel.factory(elements: accounts, cancelButtonTitle: "Cancel"),
            animated: true
        )
    }
    
    func presentWebViewController(_ webViewController: UIViewController) {
        self.present(webViewController, animated: true, completion: nil)
    }
}
