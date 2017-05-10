//
//  LoginReactor.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/30.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Accounts
import RxSwift
import RxCocoa
import Reactor
import SafariServices
import Social
import OAuthSwift

public enum LoginAccount {
    case system(ACAccount)
    case web
}

public protocol ConsumerProtocol {
    var key: String { get }
    var secret: String { get }
}

extension LoginAccount: ActionSheetElement {
    public var element: LoginAccount {
        return self
    }
    
    public var buttonConfig: UIAlertAction.Config {
        switch self {
        case .system(let account):
            return .init(title: "@" + account.username, style: .default)
        case .web:
            return .init(title: "Other...", style: .default)
        }
    }
}

public class LoginReactor: Reactor {
    public typealias Result = (OAuthSwiftCredential, [String : Any])
    public typealias Action = Never
    public typealias State = UIViewController
    
    let consumer: ConsumerProtocol
    
    public init(consumer: ConsumerProtocol) {
        self.consumer = consumer
    }
    
    public func process(action: Observable<Never>) throws -> Process<UIViewController, (OAuthSwiftCredential, [String : Any])> {
        let oauth = OAuth1Swift(
            consumerKey: self.consumer.key,
            consumerSecret: self.consumer.secret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        let safariViewControllerSubject = PublishSubject<UIViewController>()
        
        let safariURLHandler = SafariURLHandler(
            present: { (viewController, _) in
                safariViewControllerSubject.onNext(viewController)
            }, dismiss: { (viewController, _) in
                viewController.dismiss(animated: true)
            }, oauthSwift: oauth
        )
        
        oauth.authorizeURLHandler = safariURLHandler
        return Process(
            state: safariViewControllerSubject,
            result: oauth.rx.authorize(withCallbackURL: URL(string: "hiyokoapp://oauth_callback/twitter")!)
                .takeUntil(
                    safariURLHandler.rx.methodInvoked(#selector(SafariURLHandler.safariViewControllerDidFinish(_:)))
                )
        )
    }
}
