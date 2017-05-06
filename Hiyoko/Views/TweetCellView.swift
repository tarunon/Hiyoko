//
//  TweetCellView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/06.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

protocol TweetCellViewType: class {
    var nameLabel: UILabel! { get }
    var screenNameLabel: UILabel! { get }
    var dateLabel: UILabel! { get }
    var profileImageButton: UIButton! { get }
    var contentContainerView: UIView! { get }
}

protocol HasTweetCellViewType: TweetCellViewType {
    associatedtype TweetCellView: TweetCellViewType
    var tweetCellView: TweetCellView! { get }
}

extension HasTweetCellViewType {
    var nameLabel: UILabel! {
        return tweetCellView.nameLabel
    }
    
    var screenNameLabel: UILabel! {
        return tweetCellView.screenNameLabel
    }
    
    var dateLabel: UILabel! {
        return tweetCellView.dateLabel
    }
    
    var profileImageButton: UIButton! {
        return tweetCellView.profileImageButton
    }
    
    var contentContainerView: UIView! {
        return tweetCellView.contentContainerView
    }
}

final class TweetCellView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 5.0
            profileImageButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var contentContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension TweetCellView: NibInstantiatable {
    
}

extension TweetCellView: TweetCellViewType {
    
}

@IBDesignable final class IBTweetCellView: UIView {
    typealias Wrapped = TweetCellView
    
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

extension IBTweetCellView: NibInstantiatableWrapper {
    
}

extension IBTweetCellView: HasTweetCellViewType {
    var tweetCellView: TweetCellView! {
        return view
    }
}

protocol RetweetCellViewType: TweetCellViewType {
    var retweetUserIconImageView: UIImageView! { get }
    var retweetUserScreenNameLabel: UILabel! { get }
}

protocol HasRetweetCellViewType: RetweetCellViewType, HasTweetCellViewType {
    associatedtype TweetCellView: RetweetCellViewType
}

extension HasRetweetCellViewType {
    var retweetUserIconImageView: UIImageView! {
        return tweetCellView.retweetUserIconImageView
    }
    
    var retweetUserScreenNameLabel: UILabel! {
        return tweetCellView.retweetUserScreenNameLabel
    }
}

final class RetweetCellView: UIView {
    @IBOutlet weak var retweetUserIconImageView: UIImageView! {
        didSet {
            retweetUserIconImageView.layer.cornerRadius = 5.0
            retweetUserIconImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var retweetUserScreenNameLabel: UILabel!
    @IBOutlet weak var tweetCellView: IBTweetCellView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension RetweetCellView: NibInstantiatable {
    
}

extension RetweetCellView: RetweetCellViewType, HasTweetCellViewType {
    typealias TweetCellView = IBTweetCellView
}

@IBDesignable final class IBRetweetCellView: UIView {
    typealias Wrapped = RetweetCellView
    
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

extension IBRetweetCellView: NibInstantiatableWrapper {
    
}

extension IBRetweetCellView: HasRetweetCellViewType {
    typealias TweetCellView = RetweetCellView
    var tweetCellView: RetweetCellView! {
        return view
    }
}
