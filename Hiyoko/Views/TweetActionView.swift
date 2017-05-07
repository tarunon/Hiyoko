//
//  TweetActionView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/07.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

protocol TweetActionViewType: class {
    var favouriteView: UIView! { get }
    var replyView: UIView! { get }
    var retweetView: UIView! { get }
}

protocol HasTweetActionViewType: TweetActionViewType {
    associatedtype TweetActionView: TweetActionViewType
    var actionView: TweetActionView! { get }
}

extension HasTweetActionViewType {
    var favouriteView: UIView! {
        return actionView.favouriteView
    }
    
    var replyView: UIView! {
        return actionView.replyView
    }
    
    var retweetView: UIView! {
        return actionView.retweetView
    }
}

extension TweetActionViewType {
    func setEnabled(_ flag: Bool, animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0.0,
            animations: {
                self.favouriteView.alpha = flag ? 1.0 : 0.5
                self.replyView.alpha = flag ? 1.0 : 0.5
                self.retweetView.alpha = flag ? 1.0 : 0.5
            }
        )
    }
}

final class TweetActionView: UIView {
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var retweetView: UIView!
}

extension TweetActionView: NibInstantiatable {
    
}

extension TweetActionView: TweetActionViewType {
    
}

@IBDesignable final class IBTweetActionView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetActionView
    
    #if TARGET_INTERFACE_BUILDER
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
    #else
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    #endif
}

extension IBTweetActionView: HasTweetActionViewType {
    var actionView: TweetActionView! {
        return view
    }
}
