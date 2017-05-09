//
//  TweetContentView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard
import UIKitExtensions

protocol TweetContentViewType: class {
    var textView: LinkActionTextView! { get }
}

protocol HasTweetContentViewType: TweetContentViewType {
    associatedtype TweetContentView: TweetContentViewType
    var tweetContentView: TweetContentView! { get }
}

extension HasTweetContentViewType {
    var textView: LinkActionTextView! {
        return tweetContentView.textView
    }
}

class TweetContentViewBase: UIView {
    @IBOutlet weak var textView: LinkActionTextView! {
        didSet {
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0.0
        }
    }
}

final class TweetContentView: TweetContentViewBase {
    
}

extension TweetContentView: NibInstantiatable {
    
}

extension TweetContentView: TweetContentViewType {
    
}

protocol TweetContentImageViewType: TweetContentViewType {
    var imageCollectionView: UICollectionView! { get }
}

protocol HasTweetContentImageViewType: TweetContentImageViewType, HasTweetContentViewType {
    associatedtype TweetContentView: TweetContentImageViewType
}

extension HasTweetContentImageViewType {
    var imageCollectionView: UICollectionView! {
        return tweetContentView.imageCollectionView
    }
}

final class TweetContentImageView: TweetContentViewBase {
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.registerNib(type: TweetContentImageCell.self)
            imageCollectionView.layer.cornerRadius = 5.0
            imageCollectionView.layer.shouldRasterize = true
            imageCollectionView.layer.rasterizationScale = UIScreen.main.scale
            imageCollectionView.layer.masksToBounds = true
        }
    }
}

extension TweetContentImageView: NibInstantiatable {
    
}

extension TweetContentImageView: TweetContentImageViewType {
    
}

protocol TweetContentQuotedViewType: TweetContentViewType {
    var quotedUserNameLabel: UILabel! { get }
    var quotedScreenNameLabel: UILabel! { get }
    var quotedContentView: IBTweetContentView! { get }
}

protocol HasTweetContentQuotedViewType: TweetContentQuotedViewType, HasTweetContentViewType {
    associatedtype TweetContentView: TweetContentQuotedViewType
}

extension HasTweetContentQuotedViewType {
    var quotedUserNameLabel: UILabel! {
        return tweetContentView.quotedUserNameLabel
    }
    
    var quotedScreenNameLabel: UILabel! {
        return tweetContentView.quotedScreenNameLabel
    }
    
    var quotedContentView: IBTweetContentView! {
        return tweetContentView.quotedContentView
    }
}

final class TweetContentQuotedView: TweetContentViewBase {
    @IBOutlet weak var quotedUserNameLabel: UILabel!
    @IBOutlet weak var quotedScreenNameLabel: UILabel!
    @IBOutlet weak var quotedContentView: IBTweetContentView!
    @IBOutlet weak var quotedContainerView: UIView! {
        didSet {
            quotedContainerView.layer.cornerRadius = 5.0
            quotedContainerView.layer.masksToBounds = true
            quotedContainerView.layer.shouldRasterize = true
            quotedContainerView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

extension TweetContentQuotedView: NibInstantiatable {
    
}

extension TweetContentQuotedView: TweetContentQuotedViewType {
    
}

@IBDesignable final class IBTweetContentView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentView
    
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

extension IBTweetContentView: HasTweetContentViewType {
    var tweetContentView: TweetContentView! {
        return view
    }
}

@IBDesignable final class IBTweetContentImageView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentImageView
    
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

extension IBTweetContentImageView: HasTweetContentImageViewType {
    typealias TweetContentView = TweetContentImageView
    var tweetContentView: TweetContentImageView! {
        return view
    }
}

@IBDesignable final class IBTweetContentQuotedView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentQuotedView
    
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

extension IBTweetContentQuotedView: HasTweetContentQuotedViewType {
    typealias TweetContentView = TweetContentQuotedView
    var tweetContentView: TweetContentQuotedView! {
        return view
    }
}
