//
//  ListViewController+Accounts.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import SafariServices
import RealmSwift
import Persistents
import OAuthSwift
import Base

extension ListViewController {
    func bind(viewModel: AccountListViewModel.ViewBinder) -> Disposable {
        tableView.registerNib(type: AccountCell.self)
        tableView.registerNib(type: NewAccountCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        rightButton.isHidden = true
        leftButton.isHidden = true
        titleLabel.text = "Accounts"
        
        let d1 = viewModel.output
            .bind(to: tableView.rx.animatedItem()) { [unowned self] (presenter, indexPath, element) -> Disposable in
                switch element {
                case .account(let account, _, let credential):
                    return presenter
                        .present(
                            dequeue: { AccountCell.dequeue(from: $0, for: indexPath) },
                            viewModel: AccountCellViewModel(account: account, apiClient: TwitterClient(credential: credential)),
                            binder: AccountCell.bind
                        )
                        .flatMapFirst { (action) -> Observable<AccountCellViewModel.Result> in
                            switch action {
                            case .delete(let account):
                                return self.rx
                                    .present(
                                        viewController: UIAlertController(
                                            title: "Logout",
                                            message: "Logout account, and remove from this list.",
                                            preferredStyle: .alert
                                        ),
                                        viewModel: ConfirmViewModel(ok: "OK", cancel: "Cancel"),
                                        binder: UIAlertController.bind,
                                        animated: true
                                    )
                                    .filter { $0 }
                                    .map { _ in AccountCellViewModel.Result.delete(account) }
                            default:
                                return Observable.just(action)
                            }
                        }
                        .concat(Observable.never())
                        .bind(to: viewModel.input)
                case .new:
                    return presenter.present(dequeue: { NewAccountCell.dequeue(from: $0, for: indexPath) })
                }
            }
        
        let d2 = tableView.rx.modelSelected(AccountCellModel.self)
            .flatMapFirst { [unowned self] (element) -> Observable<AccountListViewModel.Action> in
                let result: Observable<AccountListViewModel.Action>
                switch element {
                case .account(let account, _, _):
                    result = Observable.just(.select(account))
                case .new:
                    result = self.rx
                        .present(
                            viewController: ProgressViewController.instantiate(),
                            viewModel: LoginViewModel(
                                consumerKey: TWITTER_CONSUMER_KEY,
                                consumerSecret: TWITTER_CONSUMER_SECRET
                            ),
                            binder: ProgressViewController.bind,
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
                                    viewModel: AlertViewModel(ok: "OK"),
                                    binder: UIAlertController.bind,
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
            .bind(to: viewModel.input)
        
        return Disposables.create(d1, d2)
    }
}
