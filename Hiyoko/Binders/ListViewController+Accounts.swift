//
//  ListViewController+Accounts.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import OAuthSwift
import Base

extension ListViewController {
    class AccountListView: View {
        typealias State = HiyokoKit.AccountListReactor.State
        typealias Action = HiyokoKit.AccountListReactor.Action
        let view: ListViewController
        
        init(view: ListViewController) {
            self.view = view
        }

        func present(state: Observable<State>) -> Present<Action> {
            view.tableView.registerNib(type: AccountCell.self)
            view.tableView.registerNib(type: NewAccountCell.self)
            let actions = state
                .bind(to: view.tableView.rx.animatedItem()) { [unowned view] (queue, element) -> Observable<Action> in
                    switch element {
                    case .account(let account, _, let credential):
                        return queue
                            .dequeue(
                                dequeue: AccountCell.dequeue,
                                reactor: AccountCellReactor(account: account, client: TwitterClient(credential: credential))
                            )
                            .flatMap { _ -> Observable<Bool> in
                                return view.rx
                                    .present(
                                        viewController: UIAlertController(
                                            title: "Logout",
                                            message: "Logout account, and remove from this list.",
                                            preferredStyle: .alert
                                        ),
                                        reactor: ~ConfirmReactor(
                                            ok: UIAlertAction.Config(title: "OK", style: .default),
                                            cancel: UIAlertAction.Config(title: "Cancel", style: .default)
                                        ),
                                        animated: true
                                )
                            }
                            .filter { $0 }
                            .map { _ in Action.delete(account) }
                    case .new:
                        return queue
                            .dequeue(
                                dequeue: NewAccountCell.dequeue,
                                reactor: EmptyReactor()
                            )
                            .flatMap { _ in Observable.empty() }
                    }
                }

            let select = view.tableView.rx.modelSelected(AccountCellModel.self)
                .flatMapFirst { (element) -> Observable<Action> in
                    let result: Observable<Action>
                    switch element {
                    case .account(let account, _, _):
                        result = .just(.select(account))
                    case .new:
                        result = self.view.rx
                            .present(
                                viewController: ProgressViewController.instantiate(),
                                reactor: LoginReactor(
                                    consumerKey: TWITTER_CONSUMER_KEY,
                                    consumerSecret: TWITTER_CONSUMER_SECRET
                                ),
                                animated: true
                            )
                            .flatMapFirst { (credential, parameter) -> Observable<(Account, OAuthSwiftCredential)> in
                                TwitterClient(credential: credential).request(request: ShowUserRequest(parameter["screen_name"] as! String))
                                    .map { (user) in
                                        let account = Account()
                                        account.id = user.id
                                        account.profileImageURL = user.profileImageURL
                                        account.screenName = user.screenName
                                        account.userName = user.name
                                        return account
                                    }
                                    .map { ($0, credential) }
                            }
                            .catchError { (error) in
                                if error is OAuthSwiftError {
                                    return Observable.empty()
                                }
                                return self.view.rx
                                    .present(
                                        viewController: UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert),
                                        reactor: ~AlertReactor(ok: UIAlertAction.Config(title: "OK", style: .default)),
                                        animated: true
                                    )
                                    .flatMap { Observable.empty() }
                            }
                            .map { Action.new($0, $1) }
                            .observeOn(MainScheduler.instance)
                    }
                    return result
                        .do(
                            onCompleted: {
                                self.view.deselectAll()
                            }
                    )
            }
            
            return .init(action: Observable.merge(actions, select))
        }
    }
}
