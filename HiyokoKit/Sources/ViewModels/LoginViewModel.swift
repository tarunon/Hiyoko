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

public enum LoginAccount {
    case system(ACAccount)
    case web
}

extension LoginAccount: ActionSheetElement {
    public var element: LoginAccount {
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

public class LoginReactor: Reactor {
    public typealias Result = (OAuthSwiftCredential, [String : Any])
    public typealias Action = Never
    public typealias State = UIViewController
    
    let consumerKey: String
    let consumerSecret: String
    
    public init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    public func process(action: Observable<Never>) throws -> Process<UIViewController, (OAuthSwiftCredential, [String : Any])> {
        let oauth = OAuth1Swift(
            consumerKey: self.consumerKey,
            consumerSecret: self.consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        let state = Observable<UIViewController>
            .create { (observer) in
                let safariURLHandler = SafariURLHandler(
                    present: { (viewController, _) in
                        observer.onNext(viewController)
                    }, dismiss: { (viewController, _) in
                        viewController.dismiss(animated: true)
                    }, oauthSwift: oauth
                )
                oauth.authorizeURLHandler = safariURLHandler
                let d1 = Disposables.create { oauth.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance }
                let d2 = safariURLHandler.rx.methodInvoked(#selector(SafariURLHandler.safariViewControllerDidFinish(_:)))
                    .take(1)
                    .flatMap { _ in Observable.empty() }
                    .bind(to: observer)
                return Disposables.create(d1, d2)
            }
            .shareReplay(1)
        return .init(
            state: state,
            result: oauth.rx.authorize(withCallbackURL: URL(string: "hiyokoapp://oauth_callback/twitter")!).shareReplay(1)
        )
    }
}
