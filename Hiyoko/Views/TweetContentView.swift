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

class TweetContentViewBase: UIView {
    @IBOutlet weak var textView: LinkActionTextView! {
        didSet {
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

final class TweetContentView: TweetContentViewBase {
    
}

extension TweetContentView: NibInstantiatable {
    
}

protocol TweetContentImageViewType: class {
    var imageCollectionView: UICollectionView! { get }
}

final class TweetContentImageView: TweetContentViewBase {
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.registerNib(type: TweetContentImageCell.self)
            imageCollectionView.layer.cornerRadius = 5.0
            imageCollectionView.layer.masksToBounds = true
        }
    }
}

extension TweetContentImageView: NibInstantiatable {
    
}

extension TweetContentImageView: Reusable {
    
}

extension TweetContentImageView: TweetContentImageViewType {
    
}

protocol TweetContentQuotedViewType: class {
    var quotedUserNameLabel: UILabel! { get }
    var quotedScreenNameLabel: UILabel! { get }
    var quotedContentView: IBTweetContentView! { get }
}

final class TweetContentQuotedView: TweetContentViewBase {
    @IBOutlet weak var quotedUserNameLabel: UILabel!
    @IBOutlet weak var quotedScreenNameLabel: UILabel!
    @IBOutlet weak var quotedContentView: IBTweetContentView!
    @IBOutlet weak var quotedContainerView: UIView! {
        didSet {
            quotedContainerView.layer.cornerRadius = 5.0
            quotedContainerView.layer.masksToBounds = true
        }
    }
}

extension TweetContentQuotedView: NibInstantiatable {
    
}

@IBDesignable final class IBTweetContentView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
}

@IBDesignable final class IBTweetContentImageView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentImageView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
}

@IBDesignable final class IBTweetContentQuotedView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentQuotedView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
}
