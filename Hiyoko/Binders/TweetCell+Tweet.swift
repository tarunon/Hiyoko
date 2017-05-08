//
//  TweetCell+Tweet.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import RxSwift
import RxCocoa
import RxExtensions
import BonMot

extension TweetCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetImageCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(image: viewModel)
        let d4 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension TweetQuotedCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(quoted: viewModel)
        let d4 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension RetweetCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(retweet: viewModel)
        let d4 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension RetweetImageCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(image: viewModel)
        let d4 = bind(retweet: viewModel)
        let d5 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3, d4, d5)
    }
}

extension RetweetQuotedCell {
    func bind(viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(quoted: viewModel)
        let d4 = bind(retweet: viewModel)
        let d5 = bind(interactive: viewModel)
        return Disposables.create(d1, d2, d3, d4, d5)
    }
}

extension TweetCellViewType {
    fileprivate func bind(tweet viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = profileImageButton.rx.tap
            .withLatestFrom(viewModel.state.flatMap { $0.screenName })
            .map { TweetCellViewModel.Action.entities(.tap(.mention($0))) }
            .bind(to: viewModel.action)
        let d2 = viewModel.state
            .shareReplay(1)
            .bind { [unowned self] (output) -> Disposable in
                let d1 = output
                    .flatMap { $0.profileImage }
                    .bind { [profileImageButton=self.profileImageButton] (image) in
                        profileImageButton?.setImage(image, for: .normal)
                    }
                let d2 = output
                    .flatMap { $0.userName }
                    .bind(to: self.nameLabel.rx.text)
                let d3 = output
                    .flatMap { $0.screenName }
                    .bind(to: self.screenNameLabel.rx.text)
                let d4 = output
                    .flatMap { $0.createdAt }
                    .flatMapLatest { (date) in
                        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .default))
                            .map { _ in Date() }
                            .startWith(Date())
                            .map { date.label(since: $0) }
                    }
                    .bind(to: self.dateLabel.rx.text)
                return Disposables.create(d1, d2, d3, d4)
            }
        return Disposables.create(d1, d2)
    }
}

extension RetweetCellViewType {
    fileprivate func bind(retweet viewModel: TweetCellViewModel.Emitter) -> Disposable {
        return viewModel.state
            .flatMap { $0.retweet }
            .shareReplay(1)
            .bind { [imageView=self.retweetUserIconImageView, label=self.retweetUserScreenNameLabel] (retweet) -> Disposable in
                guard let imageView = imageView, let label = label else {
                    return Disposables.create()
                }
                let d1 = retweet
                    .flatMap { $0.profileImage }
                    .bind(to: imageView.rx.image)
                let d2 = retweet
                    .flatMap { $0.screenName }
                    .map { "retweeted by \($0)" }
                    .bind(to: label.rx.text)
                return Disposables.create(d1, d2)
            }
    }
}

extension TweetContentViewType {
    fileprivate func bind(content viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = viewModel.state
            .flatMap { $0.text }
            .bind { [textView=self.textView] (attributedText) in
                textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
            }
        let d2 = self.textView.rx.linkTap
            .map { (url) in
                TweetCellViewModel.Action.entities(.tap(.init(url)))
            }
            .bind(to: viewModel.action)
        let d3 = self.textView.rx.linkLongPress
            .map { (url) in
                TweetCellViewModel.Action.entities(.longpress(.init(url)))
            }
            .bind(to: viewModel.action)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetContentImageViewType {
    fileprivate func bind(image viewModel: TweetCellViewModel.Emitter) -> Disposable {
        return viewModel.state
            .flatMap { $0.media }
            .shareReplay(1)
            .bind { [collectionView=self.imageCollectionView] (medias) -> Disposable in
                guard let collectionView = collectionView else {
                    return Disposables.create()
                }
                let d1 = medias
                    .map { [Section(items: $0)] }
                    .bind(to: collectionView.rx.reloadItem()) { (presenter, element) -> Disposable in
                        presenter
                            .present(
                                dequeue: TweetContentImageCell.dequeue,
                                viewModel: element,
                                binder: TweetContentImageCell.bind
                            )
                            .concat(Observable.never())
                            .map { TweetCellViewModel.Action.entities($0) }
                            .bind(to: viewModel.action)
                }
                
                let layout = TweetContentImageFlowLayout(numberOfItems: 0)
                
                let d2 = collectionView.rx.setDelegate(layout)
                
                let d3 = medias.map { $0.count }
                    .subscribe(
                        onNext: { (count) in
                            layout.numberOfItems = count
                            collectionView.collectionViewLayout.invalidateLayout()
                    }
                )
                return Disposables.create(d1, d2, d3)
            }
    }
}

extension TweetContentQuotedViewType {
    fileprivate func bind(quoted viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let d1 = viewModel.state
            .flatMap { $0.quote }
            .shareReplay(1)
            .bind { [unowned self] (quoted) -> Disposable in
                let d1 = quoted
                    .flatMap { $0.userName }
                    .bind(to: self.quotedUserNameLabel.rx.text)
                let d2 = quoted
                    .flatMap { $0.screenName }
                    .bind(to: self.quotedScreenNameLabel.rx.text)
                let d3 = quoted
                    .flatMap { $0.text }
                    .bind { [textView=self.quotedContentView.view.textView] (attributedText) in
                        textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
                    }
                return Disposables.create(d1, d2, d3)
            }
        let d2 = self.quotedContentView.view.textView.rx.linkTap
            .map { (url) in
                TweetCellViewModel.Action.entities(.tap(.init(url)))
            }
            .bind(to: viewModel.action)
        let d3 = self.quotedContentView.view.textView.rx.linkLongPress
            .map { (url) in
                TweetCellViewModel.Action.entities(.longpress(.init(url)))
            }
            .bind(to: viewModel.action)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetContentImageCell {
    func bind(viewModel: TweetContentImageCellViewModel.Emitter) -> Disposable {
        let d1 = viewModel.state
            .bind(to: imageView.rx.image)
        let d2 = longPressGestureRecognizer.rx.event
            .filter { $0.state == .began }
            .map { _ in TweetContentImageCellViewModel.Action.longPress }
            .bind(to: viewModel.action)
        let d3 = tapGestureRecognizer.rx.event
            .map { _ in TweetContentImageCellViewModel.Action.tap }
            .bind(to: viewModel.action)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetCellInteractiveViewType {
    fileprivate func bind(interactive viewModel: TweetCellViewModel.Emitter) -> Disposable {
        let tweetActionEnabled = interactiveScrollView.rx.contentOffset
            .map { $0.x }
            .scan(false) { (flag, x) -> (Bool) in
                if flag && x > -40.0 {
                    return false
                } else if !flag && x < -60.0 {
                    return true
                }
                return flag
            }
            .distinctUntilChanged()
            .shareReplay(1)
        
        typealias InteractiveState = (action: Tweet.Action, preAction: Tweet.Action, y: CGFloat)
        
        let interactiveState = self.interactiveScrollView.panGestureRecognizer.rx.event
            .map { $0.location(in: self.interactiveScrollView) }
            .map { $0.y - (self.interactiveScrollView.frame.height / 2.0) }
            .scan((action: Tweet.Action.reply, preAction: Tweet.Action.reply, y: 0)) { (previousStatus: InteractiveState, y) -> (InteractiveState) in
                switch (previousStatus.action, y) {
                case (.favourite, let y) where y < 100.0:
                    return (action: .reply, preAction: previousStatus.action, y: y)
                case (.retweet, let y) where y > -100.0:
                    return (action: .reply, preAction: previousStatus.action, y: y)
                case (.reply, let y) where y > 110.0:
                    return (action: .favourite, preAction: previousStatus.action, y: y)
                case (.reply, let y) where y < -110.0:
                    return (action: .retweet, preAction: previousStatus.action, y: y)
                default:
                    return (action: previousStatus.action, preAction: previousStatus.action, y: y)
                }
            }
            .shareReplay(1)
        
        
        let d1 = tweetActionEnabled
            .subscribe(
                onNext: { (flag) in
                    self.tweetActionView.setEnabled(flag, animated: true)
                }
            )
        
        let d2 = interactiveState
            .subscribe(
                onNext: { (action, preAction, y) in
                    let needsToAnimation: Bool
                    switch (action, preAction) {
                    case (.reply, .reply):
                        self.tweetActionCenter.constant = (self.interactiveScrollView.frame.height / 10) * (y / 100.0)
                        needsToAnimation = false
                    case (.reply, _):
                        self.tweetActionCenter.constant = (self.interactiveScrollView.frame.height / 10) * (y / 100.0)
                        needsToAnimation = true
                    case (.retweet, .reply):
                        self.tweetActionCenter.constant = -self.interactiveScrollView.frame.height / 5 * 3
                        needsToAnimation = true
                    case (.favourite, .reply):
                        self.tweetActionCenter.constant = self.interactiveScrollView.frame.height / 5 * 3
                        needsToAnimation = true
                    default:
                        needsToAnimation = false
                    }
                    if needsToAnimation {
                        UIView.animate(
                            withDuration: 0.25,
                            delay: 0.0,
                            usingSpringWithDamping: 0.8,
                            initialSpringVelocity: 0.0,
                            options: .curveEaseInOut,
                            animations: { 
                                self.tweetActionView.superview?.layoutIfNeeded()
                            }
                        )
                    }
                }
            )
        
        let d3 = self.interactiveScrollView.rx.didEndDragging
            .withLatestFrom(
                Observable
                    .combineLatest(
                        tweetActionEnabled,
                        interactiveState
                    )
                    .map { (enabled: $0, action: $1.action) }
            )
            .filter { $0.enabled }
            .map { TweetCellViewModel.Action.tweet($0.action) }
            .bind(to: viewModel.action)
        
        let d4 = viewModel.state
            .shareReplay(1)
            .bind { [actionView=self.tweetActionView] (tweet) -> Disposable in
                guard let actionView = actionView else {
                    return Disposables.create()
                }
                let d1 = tweet
                    .flatMap { $0.retweeted }
                    .bind(to: actionView.retweetButton.rx.isSelected)
                let d2 = tweet
                    .flatMap { $0.favorited }
                    .bind(to: actionView.favouriteButton.rx.isSelected)
                return Disposables.create(d1, d2)
            }
        
        
        return Disposables.create(d1, d2, d3, d4)
    }
}
