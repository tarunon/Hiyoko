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
    public typealias Input = Never
    public typealias Output = UIViewController
    
    public let result: Observable<(OAuthSwiftCredential, [String : Any])>
    public var emitter: RxIOEmitter<Never, UIViewController> = RxIOEmitter()
    
    public init(consumerKey: String, consumerSecret: String) {
        result = Observable<(OAuthSwiftCredential, [String : Any])>
            .create { [emitter = self.emitter] (observer) -> Disposable in
                let oauth = OAuth1Swift(
                    consumerKey: consumerKey,
                    consumerSecret: consumerSecret,
                    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                    accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
                )
                let safariURLHandler = SafariURLHandler(
                    present: { (viewController, _) in
                        emitter.output.onNext(viewController)
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
                    .bind(to: observer)
                let d2 = Disposables.create { oauth.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance }
                return Disposables.create(d1, d2)
            }
    }
}
