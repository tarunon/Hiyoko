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
    var favouriteButton: UIButton! { get }
    var replyButton: UIButton! { get }
    var retweetButton: UIButton! { get }
}

protocol HasTweetActionViewType: TweetActionViewType {
    associatedtype TweetActionView: TweetActionViewType
    var actionView: TweetActionView! { get }
}

extension HasTweetActionViewType {
    var favouriteButton: UIButton! {
        return actionView.favouriteButton
    }
    
    var replyButton: UIButton! {
        return actionView.replyButton
    }
    
    var retweetButton: UIButton! {
        return actionView.retweetButton
    }
}

extension TweetActionViewType {
    func setEnabled(_ flag: Bool, animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0.0,
            animations: {
                self.favouriteButton.alpha = flag ? 1.0 : 0.5
                self.replyButton.alpha = flag ? 1.0 : 0.5
                self.retweetButton.alpha = flag ? 1.0 : 0.5
            }
        )
    }
}

final class TweetActionView: UIView {
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
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
