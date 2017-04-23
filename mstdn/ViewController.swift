//
//  ViewController.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UIKitExtensions
import MstdnKit
import APIClient

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.rx.tap
                .flatMapFirst { [unowned self] in
                    self.rx.present(LoginViewController.instantiate(), viewModel: LoginViewModel.init, animated: true)
                        .catchError { error in
                            switch error {
                            case ResponseError.parseSuccess(let error as Requests.MstdnError):
                                return self.rx
                                    .present(
                                        UIAlertController(title: "Error", message: error.error, preferredStyle: .alert),
                                        viewModel: Alert.buttonTitle("OK"),
                                        animated: true
                                    )
                                    .flatMap { Observable.empty() }
                            default:
                                print(error)
                                return Observable.empty()
                            }
                        }
                }
                .subscribe { (event) in
                    print(event)
                }
                .addDisposableTo(disposeBag)
        }
    }
}
