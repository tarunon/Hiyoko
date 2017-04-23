//
//  LoginViewController.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Instantiate
import InstantiateStandard
import MstdnKit
import APIClient
import Persistents

final class LoginViewController: UIViewController {
    @IBOutlet weak var hostNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
}

extension LoginViewController: LoginViewModelOwner {
    var hostName: Observable<String> {
        return hostNameField.rx.text
            .map { $0 ?? "" }
    }
    
    var email: Observable<String> {
        return emailField.rx.text
            .map { $0 ?? "" }
    }
    
    var password: Observable<String> {
        return passwordField.rx.text
            .map { $0 ?? "" }
    }
    
    var loginButtonTapped: Observable<Void> {
        return loginButton.rx.tap
            .asObservable()
    }
    
    func apiClient(hostName: String) -> APIClient.Client {
        return APIClient.Client(baseURL: URL(string: hostName)!)
    }
    
    func clientPersistent(hostName: String) -> PersistentStore<MstdnKit.Client> {
        return KeychainStore.shared.typed("client:" + hostName)
    }
}

extension LoginViewController: StoryboardInstantiatable {
    
}
