//
//  TweetCell.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

final class TweetCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBTweetCellView!
    var tweetContentView: TweetContentView! = TweetContentView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension TweetCell: NibInstantiatable {
    
}

extension TweetCell: Reusable {
    
}

extension TweetCell: HasTweetCellViewType {
    typealias TweetCellView = IBTweetCellView
}

extension TweetCell: HasTweetContentViewType {
    
}


final class TweetImageCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBTweetCellView!
    var tweetContentView: TweetContentImageView! = TweetContentImageView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension TweetImageCell: NibInstantiatable {
    
}

extension TweetImageCell: Reusable {
    
}

extension TweetImageCell: HasTweetCellViewType {
    typealias TweetCellView = IBTweetCellView
}

extension TweetImageCell: HasTweetContentImageViewType {
    typealias TweetContentView = TweetContentImageView
}

final class TweetQuotedCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBTweetCellView!
    var tweetContentView: TweetContentQuotedView! = TweetContentQuotedView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension TweetQuotedCell: NibInstantiatable {
    
}

extension TweetQuotedCell: Reusable {
    
}

extension TweetQuotedCell: HasTweetCellViewType {
    typealias TweetCellView = IBTweetCellView
}

extension TweetQuotedCell: HasTweetContentQuotedViewType {
    typealias TweetContentView = TweetContentQuotedView
    
}

final class RetweetCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBRetweetCellView!
    var tweetContentView: TweetContentView! = TweetContentView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension RetweetCell: NibInstantiatable {
    
}

extension RetweetCell: Reusable {
    
}

extension RetweetCell: HasRetweetCellViewType {
    typealias TweetCellView = IBRetweetCellView
}

extension RetweetCell: HasTweetContentViewType {
    
}

final class RetweetImageCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBRetweetCellView!
    var tweetContentView: TweetContentImageView! = TweetContentImageView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension RetweetImageCell: NibInstantiatable {
    
}

extension RetweetImageCell: Reusable {
    
}

extension RetweetImageCell: HasRetweetCellViewType {
    typealias TweetCellView = IBRetweetCellView
}

extension RetweetImageCell: HasTweetContentImageViewType {
    typealias TweetContentView = TweetContentImageView
}

final class RetweetQuotedCell: UITableViewCell {
    @IBOutlet weak var tweetCellView: IBRetweetCellView!
    var tweetContentView: TweetContentQuotedView! = TweetContentQuotedView.instantiate()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension RetweetQuotedCell: NibInstantiatable {
    
}

extension RetweetQuotedCell: Reusable {
    
}

extension RetweetQuotedCell: HasRetweetCellViewType {
    typealias TweetCellView = IBRetweetCellView
}

extension RetweetQuotedCell: HasTweetContentQuotedViewType {
    typealias TweetContentView = TweetContentQuotedView
}
