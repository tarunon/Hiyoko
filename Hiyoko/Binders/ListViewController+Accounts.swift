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
    func present(state: Observable<AccountListViewModel.State>) -> Present<AccountListViewModel.Action> {
        tableView.registerNib(type: AccountCell.self)
        tableView.registerNib(type: NewAccountCell.self)
        let actions = state
            .bind(to: self.tableView.rx.animatedItem()) { [unowned self] (presenter, element) -> Observable<AccountListViewModel.Action> in
                switch element {
                case .account(let account, _, let credential):
                    return presenter
                        .present(
                            dequeue: AccountCell.dequeue,
                            viewModel: AccountCellViewModel(account: account, client: TwitterClient(credential: credential)),
                            presenter: AccountCell.present
                        )
                        .flatMap { (_) -> Observable<Bool> in
                            return self.rx
                                .present(
                                    viewController: UIAlertController(
                                        title: "Logout",
                                        message: "Logout account, and remove from this list.",
                                        preferredStyle: .alert
                                    ),
                                    viewModel: ConfirmViewModel(
                                        ok: UIAlertAction.Config(title: "OK", style: .default),
                                        cancel: UIAlertAction.Config(title: "Cancel", style: .default)
                                    ),
                                    presenter: UIAlertController.present,
                                    animated: true
                                )
                        }
                        .filter { $0 }
                        .map { _ in AccountListViewModel.Action.delete(account) }
                case .new:
                    return presenter
                        .present(
                            dequeue: NewAccountCell.dequeue,
                            viewModel: EmptyViewModel(),
                            presenter: NewAccountCell.present
                        )
                        .flatMap { _ in Observable.empty() }
                }
            }
            .flatMap { $0.result }

        let select = self.tableView.rx.modelSelected(AccountCellModel.self)
            .flatMapFirst { [unowned self] (element) -> Observable<AccountListViewModel.Action> in
                let result: Observable<AccountListViewModel.Action>
                switch element {
                case .account(let account, _, _):
                    result = .just(.select(account))
                case .new:
                    result = self.rx
                        .present(
                            viewController: ProgressViewController.instantiate(),
                            viewModel: LoginViewModel(
                                consumerKey: TWITTER_CONSUMER_KEY,
                                consumerSecret: TWITTER_CONSUMER_SECRET
                            ),
                            presenter: ProgressViewController.present,
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
                            return self.rx
                                .present(
                                    viewController: UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert),
                                    viewModel: AlertViewModel(ok: UIAlertAction.Config(title: "OK", style: .default)),
                                    presenter: UIAlertController.present,
                                    animated: true
                                )
                                .flatMap { Observable.empty() }
                        }
                        .map { AccountListViewModel.Action.new($0, $1) }
                }
                return result
                    .do(
                        onCompleted: { [weak self] in
                            self?.deselectAll()
                        }
                )
            }
        
        return .init(action: Observable.merge(actions, select))
    }
}
