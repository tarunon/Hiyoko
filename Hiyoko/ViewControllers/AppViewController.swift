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
        let list = ListViewController.instantiate(with: .init(title: "Accounts"))
        self.rx
            .present(
                viewController: list,
                viewModel: AccountListViewModel(
                    realm: { try Realm(configuration: .init(schemaVersion: 1, migrationBlock: { _ in })) },
                    credentialFor: { KeychainStore.shared.typed("credential:\($0.id)") }
                ),
                presenter: ListViewController.present,
                animated: false
            )
            .flatMapFirst { (account, credential) -> Observable<TweetResource> in
                let realmIdentifier = "home_timeline:\(account.id)"
                let client = TwitterClient(credential: credential)
                let timelineRootViewController = NavigationController.instantiate(
                    rootViewController: ListViewController.instantiate(
                        with: .init(
                            title: "Timeline",
                            leftButtonConfig: { (button) in
                                button.layer.cornerRadius = 20.0
                                button.layer.masksToBounds = true
                                button.layer.shouldRasterize = true
                                button.layer.rasterizationScale = UIScreen.main.scale
                                button.imageView?.contentMode = .scaleToFill
                            }
                        )
                    )
                )
                timelineRootViewController.modalTransitionStyle = .flipHorizontal
                return list.rx
                    .present(
                        viewController: timelineRootViewController,
                        viewModel: TimelineViewModel(
                            realm: {
                                try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier))
                            },
                            client: client,
                            initialRequest: SinceMaxPaginationRequest(request: HomeTimeLineRequest())
                        ),
                        presenter: NavigationController.present(binder: ListViewController.present),
                        animated: true
                    )
            }
            .subscribe { print($0) }
            .addDisposableTo(disposeBag)
    }
}
