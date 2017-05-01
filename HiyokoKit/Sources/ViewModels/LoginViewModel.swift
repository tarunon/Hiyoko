//
//  LoginViewModel.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/30.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Accounts
import RxSwift
import RxCocoa
import RxExtensions
import SafariServices
import Social
import OAuthSwift

public protocol LoginViewControllerType {
    func selectAccount(_ accounts: [Account]) -> Observable<Account>
    func presentWebViewController(_ webViewController: UIViewController)
}

public enum Account {
    case system(ACAccount)
    case web
}

extension Account: ActionSheetElement {
    public var element: Account {
        return self
    }
    
    public var description: String {
        switch self {
        case .system(let account):
            return "@" + account.username
        case .web:
            return "Other"
        }
    }
}

public class LoginViewModel<V: LoginViewControllerType>: RxViewModel {
    public let result: Observable<OAuthSwiftCredential>
    
    public init(view: V, consumerKey: String, consumerSecret: String) {
        // reverse auth unsupported yet
//        let store = ACAccountStore()
//        result = Observable
//            .create { (observer: AnyObserver<Bool>) -> Disposable in
//                store.requestAccessToAccounts(with: store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter), options: nil, completion: { (enabled, error) in
//                    if let error = error {
//                        observer.onError(error)
//                        return
//                    }
//                    observer.onNext(enabled)
//                    observer.onCompleted()
//                })
//                return Disposables.create()
//            }
//            .map { (enabled) -> [Account] in
//                guard enabled else {
//                    throw RxError.noElements
//                }
//                return store.accounts
//                    .map { $0 as AnyObject as! ACAccount }
//                    .filter { $0.accountType.identifier! == ACAccountTypeIdentifierTwitter }
//                    .map { Account.system($0) } + [Account.web]
//            }
//            .catchErrorJustReturn([Account.web])
//            .flatMap(view.selectAccount)
        result = Observable.just()
            .flatMap{ _ -> Observable<OAuthSwiftCredential> in
                let oauth = OAuth1Swift(
                    consumerKey: consumerKey,
                    consumerSecret: consumerSecret,
                    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                    accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
                )
                let safariURLHandler = SafariURLHandler(
                    present: { (viewController, _) in
                        view.presentWebViewController(viewController)
                    }, dismiss: { (viewController, _) in
                        viewController.dismiss(animated: true)
                    }, oauthSwift: oauth
                )
                
                oauth.authorizeURLHandler = safariURLHandler
                
                return oauth.rx.authorize(withCallbackURL: URL(string: "hiyokoapp://oauth_callback/twitter")!)
                    .amb(
                        safariURLHandler.rx.methodInvoked(#selector(SafariURLHandler.safariViewControllerDidFinish(_:)))
                            .take(1)
                            .flatMap { _ in Observable.empty() }
                    )
            }
    }
    
    public static func factory(consumerKey: String, consumerSecret: String) -> (V) -> LoginViewModel {
        return { (view) in
            return LoginViewModel(view: view, consumerKey: consumerKey, consumerSecret: consumerSecret)
        }
    }
}
