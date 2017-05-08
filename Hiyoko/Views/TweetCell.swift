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

class TweetCellBase<CellView: UIView, ContentView: UIView>: UITableViewCell where CellView: TweetCellViewType, CellView: NibInstantiatable, ContentView: TweetContentViewType, ContentView: NibInstantiatable, CellView.Dependency == Void, ContentView.Dependency == Void  {
    var tweetCellView: CellView! = CellView.instantiate()
    var tweetContentView: ContentView! = ContentView.instantiate()
    var interactiveView: TweetCellInteractiveView! = TweetCellInteractiveView.instantiate()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private func _init() {
        self.translatesAutoresizingMaskIntoConstraints = false
        tweetCellView.translatesAutoresizingMaskIntoConstraints = false
        tweetContentView.translatesAutoresizingMaskIntoConstraints = false
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(interactiveView)
        self.tweetCellContainerView.addSubview(tweetCellView)
        self.contentContainerView.addSubview(tweetContentView)
        NSLayoutConstraint.activate(
            [
                interactiveView.topAnchor.constraint(equalTo: contentView.topAnchor),
                {
                    let bottom = interactiveView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                    bottom.priority = 750
                    return bottom
                }(),
                interactiveView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                interactiveView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                tweetCellView.topAnchor.constraint(equalTo: tweetCellContainerView.topAnchor),
                tweetCellView.bottomAnchor.constraint(equalTo: tweetCellContainerView.bottomAnchor),
                tweetCellView.leftAnchor.constraint(equalTo: tweetCellContainerView.leftAnchor),
                tweetCellView.rightAnchor.constraint(equalTo: tweetCellContainerView.rightAnchor),
                tweetContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                tweetContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                tweetContentView.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor),
                tweetContentView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor)
            ]
        )
    }
}

extension TweetCellBase: HasTweetCellViewType {
    
}

extension TweetCellBase: HasTweetContentViewType {
    
}

extension TweetCellBase: HasTweetCellInteractiveViewType {
    
}

final class TweetCell: TweetCellBase<TweetCellView, TweetContentView> {
    
}

extension TweetCell: Reusable {
    
}


final class TweetImageCell: TweetCellBase<TweetCellView, TweetContentImageView> {
    
}

extension TweetImageCell: Reusable {
    
}

extension TweetImageCell: HasTweetContentImageViewType {
    
}

final class TweetQuotedCell: TweetCellBase<TweetCellView, TweetContentQuotedView> {
    
}

extension TweetQuotedCell: Reusable {
    
}

extension TweetQuotedCell: HasTweetContentQuotedViewType {
    
}

final class RetweetCell: TweetCellBase<RetweetCellView, TweetContentView> {
    
}

extension RetweetCell: Reusable {
    
}

extension RetweetCell: HasRetweetCellViewType {
    
}

final class RetweetImageCell: TweetCellBase<RetweetCellView, TweetContentImageView> {
    
}

extension RetweetImageCell: Reusable {
    
}

extension RetweetImageCell: HasRetweetCellViewType {
    
}

extension RetweetImageCell: HasTweetContentImageViewType {
    
}


final class RetweetQuotedCell: TweetCellBase<RetweetCellView, TweetContentQuotedView> {
    
}

extension RetweetQuotedCell: Reusable {
    
}

extension RetweetQuotedCell: HasRetweetCellViewType {
    
}

extension RetweetQuotedCell: HasTweetContentQuotedViewType {
    
}
