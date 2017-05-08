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

public class LoginViewModel: RxViewModel {
    public typealias Result = (OAuthSwiftCredential, [String : Any])
    public typealias Action = Never
    public typealias State = UIViewController
    
    let consumerKey: String
    let consumerSecret: String
    
    public init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    public func state(action: Observable<Never>, result: AnyObserver<(OAuthSwiftCredential, [String : Any])>) -> Observable<UIViewController> {
        return Observable<UIViewController>
            .create { (observer) -> Disposable in
                let oauth = OAuth1Swift(
                    consumerKey: self.consumerKey,
                    consumerSecret: self.consumerSecret,
                    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                    accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
                )
                let safariURLHandler = SafariURLHandler(
                    present: { (viewController, _) in
                        observer.onNext(viewController)
                    }, dismiss: { (viewController, _) in
                        viewController.dismiss(animated: true)
                    }, oauthSwift: oauth
                )
                oauth.authorizeURLHandler = safariURLHandler
                let d1 = oauth.rx.authorize(withCallbackURL: URL(string: "hiyokoapp://oauth_callback/twitter")!)
                    .amb(
                        safariURLHandler.rx.methodInvoked(#selector(SafariURLHandler.safariViewControllerDidFinish(_:)))
                            .take(1)
                            .flatMap { _ in Observable.empty() }
                    )
                    .bind(to: result)
                let d2 = Disposables.create { oauth.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance }
                return Disposables.create(d1, d2)
            }
    }
}
