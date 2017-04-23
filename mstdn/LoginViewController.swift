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
    let disposeBag = DisposeBag()
    @IBOutlet weak var hostNameField: UITextField! 
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        hostNameField.rx.didEndEditing
            .subscribe(
                onNext: { [unowned emailField=self.emailField as UITextField] in
                    emailField.becomeFirstResponder()
                }
            )
            .addDisposableTo(disposeBag)
        
        emailField.rx.didEndEditing
            .subscribe(
                onNext: { [unowned passwordField=self.passwordField as UITextField] in
                    passwordField.becomeFirstResponder()
                }
            )
            .addDisposableTo(disposeBag)
    }
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
        return Observable
            .of(
                loginButton.rx.tap,
                passwordField.rx.didEndEditing
            )
            .merge()
    }
    
    var cancelButtonTapped: Observable<Void> {
        return cancelButton.rx.tap
            .asObservable()
    }
    
    func apiClient(hostName: String) -> APIClient.Client {
        return APIClient.Client(baseURL: URL(string: "https://" + hostName + "/")!)
    }
    
    func clientPersistent(hostName: String) -> PersistentStore<MstdnKit.Client> {
        return KeychainStore.shared.typed("client:" + hostName)
    }
}

extension LoginViewController: StoryboardInstantiatable {
    
}
