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
import Reactor
import UIKitExtensions
import HiyokoKit
import RealmSwift
import Persistents

class AppViewController: UIViewController {
    let disposeBag = DisposeBag()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let accounts = ListViewController.instantiate(with: .init(title: "Accounts"))
        self.rx
            .present(
                viewController: accounts,
                reactor: ~AccountListReactor(
                    realm: { try Realm(configuration: .init(schemaVersion: 1, migrationBlock: { _ in })) },
                    credentialFor: { KeychainStore.shared.typed("credential:\($0.id)") }
                ),
                animated: false
            )
            .flatMapFirst { (account, credential) -> Observable<Either5<TweetResource, TweetResource, Never, Never, Never>> in
                let home: () -> NavigationController<ListViewController> = {
                    return NavigationController(
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
                }
                let mention: () -> NavigationController<ListViewController> = {
                    return NavigationController(
                        rootViewController: ListViewController.instantiate(
                            with: .init(
                                title: "Mentions",
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
                }
                let post: () -> NavigationController<EmptyViewController> = {
                    return NavigationController(rootViewController: EmptyViewController())
                }
                let search: () -> NavigationController<EmptyViewController> = {
                    return NavigationController(rootViewController: EmptyViewController())
                }
                let list: () -> NavigationController<EmptyViewController> = {
                    return NavigationController(rootViewController: EmptyViewController())
                }
                let client = TwitterClient(credential: credential)
                let homeRealmIdentifier = "home_timeline:\(account.id)"
                let mentionRealmIdentifier = "mention_timeline:\(account.id)"
                return accounts.rx
                    .present(
                        viewController: { () -> TabBarController<
                            NavigationController<ListViewController>,
                            NavigationController<ListViewController>,
                            NavigationController<EmptyViewController>,
                            NavigationController<EmptyViewController>,
                            NavigationController<EmptyViewController>
                            > in
                            let tab = TabBarController(childViewControllers: (home(), mention(), post(), search(), list()))
                            tab.modalTransitionStyle = .flipHorizontal
                            return tab
                        }(),
                        reactor: Either5Reactor(
                            ~TimelineReactor(
                                realm: {
                                    try Realm(configuration: .init(inMemoryIdentifier: homeRealmIdentifier))
                                },
                                client: client,
                                initialRequest: SinceMaxPaginationRequest(request: HomeTimeLineRequest())
                            ),
                            ~TimelineReactor(
                                realm: {
                                    try Realm(configuration: .init(inMemoryIdentifier: mentionRealmIdentifier))
                                },
                                client: client,
                                initialRequest: SinceMaxPaginationRequest(request: MentionTimeLineRequest())
                            ),
                            EmptyReactor(),
                            EmptyReactor(),
                            EmptyReactor()
                        ),
                        animated: true
                    )
            }
            .subscribe { print($0) }
            .addDisposableTo(disposeBag)
    }
}
