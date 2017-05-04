//
//  AppViewController.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/03.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxExtensions
import UIKitExtensions
import HiyokoKit
import RealmSwift
import Persistents

class AppViewController: UIViewController {
    let disposeBag = DisposeBag()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let list = ListViewController.instantiate()
        self.rx
            .present(
                viewController: list,
                viewModel: AccountListViewModel(
                    realm: Realm.init,
                    credentialFor: { KeychainStore.shared.typed("credential:\($0.id)") }
                ),
                binder: ListViewController.bind,
                animated: false
            )
            .subscribe()
            .addDisposableTo(disposeBag)
    }
}
