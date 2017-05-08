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
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(interactive: state)
        return Present.merge(p1, p2, p3)
    }
}

extension TweetImageCell {
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(image: state)
        let p4 = present(interactive: state)
        return Present.merge(p1, p2, p3, p4)
    }
}

extension TweetQuotedCell {
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(quoted: state)
        let p4 = present(interactive: state)
        return Present.merge(p1, p2, p3, p4)
    }
}

extension RetweetCell {
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(retweet: state)
        let p4 = present(interactive: state)
        return Present.merge(p1, p2, p3, p4)
    }
}

extension RetweetImageCell {
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(image: state)
        let p4 = present(retweet: state)
        let p5 = present(interactive: state)
        return Present.merge(p1, p2, p3, p4, p5)
    }
}

extension RetweetQuotedCell {
    func present(state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let p1 = present(tweet: state)
        let p2 = present(content: state)
        let p3 = present(quoted: state)
        let p4 = present(retweet: state)
        let p5 = present(interactive: state)
        return Present.merge(p1, p2, p3, p4, p5)
    }
}

extension TweetCellViewType {
    fileprivate func present(tweet state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        return .init(
            action: profileImageButton.rx.tap
                .withLatestFrom(state.flatMap { $0.screenName })
                .map { TweetCellViewModel.Action.entities(.tap(.mention($0))) },
            bind: state
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
        )
    }
}

extension RetweetCellViewType {
    fileprivate func present(retweet state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        return .init(
            action: Observable.empty(),
            bind: state
                .flatMap { $0.retweetBy }
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
        )
    }
}

extension TweetContentViewType {
    fileprivate func present(content state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        return .init(
            action: Observable
                .merge(
                    self.textView.rx.linkTap
                        .map { (url) in
                            TweetCellViewModel.Action.entities(.tap(.init(url)))
                    },
                    self.textView.rx.linkLongPress
                        .map { (url) in
                            TweetCellViewModel.Action.entities(.longpress(.init(url)))
                    }
                ),
            bind: state
                .flatMap { $0.text }
                .bind { [textView=self.textView] (attributedText) in
                    textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
            }
        )
    }
}

extension TweetContentImageViewType {
    fileprivate func present(image state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let layout = TweetContentImageFlowLayout(numberOfItems: 0)
        
        let d1 = self.imageCollectionView.rx.setDelegate(layout)
        
        let medias = state
            .flatMap { $0.media }
            .shareReplay(1)
        
        let d2 = medias.map { $0.count }
            .subscribe(
                onNext: { (count) in
                    layout.numberOfItems = count
                    self.imageCollectionView.collectionViewLayout.invalidateLayout()
            }
        )

        let mediaActions = medias.map { [Section(items: $0)] }
            .bind(to: self.imageCollectionView.rx.reloadItem()) { (presenter, element) -> Observable<Entities.Action> in
                presenter
                    .present(
                        dequeue: TweetContentImageCell.dequeue,
                        viewModel: element,
                        presenter: TweetContentImageCell.present
                    )
            }
            .flatMap { $0.result }
            .map { TweetCellViewModel.Action.entities($0) }
        
        return .init(
            action: mediaActions,
            bind: Disposables.create(d1, d2)
        )
    }
}

extension TweetContentQuotedViewType {
    fileprivate func present(quoted state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        return .init(
            action: Observable
                .merge(
                    self.quotedContentView.view.textView.rx.linkTap
                        .map { (url) in
                            TweetCellViewModel.Action.entities(.tap(.init(url)))
                    },
                    self.quotedContentView.view.textView.rx.linkLongPress
                        .map { (url) in
                            TweetCellViewModel.Action.entities(.longpress(.init(url)))
                    }
                ),
            bind: state
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
        )
    }
}

extension TweetContentImageCell {
    func present(state: Observable<TweetContentImageCellViewModel.State>) -> Present<TweetContentImageCellViewModel.Action> {
        return .init(
            action: Observable
                .merge(
                    self.longPressGestureRecognizer.rx.event
                        .filter { $0.state == .began }
                        .map { _ in TweetContentImageCellViewModel.Action.longPress },
                    self.tapGestureRecognizer.rx.event
                        .map { _ in TweetContentImageCellViewModel.Action.tap }
            ),
            bind: state
                .bind(to: self.imageView.rx.image)
        )
    }
}

extension TweetCellInteractiveViewType {
    fileprivate func present(interactive state: Observable<TweetCellViewModel.State>) -> Present<TweetCellViewModel.Action> {
        let tweetActionEnabled = self.interactiveScrollView.rx.contentOffset
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
            .map { [unowned self] in $0.location(in: self.interactiveScrollView) }
            .map { [unowned self] in $0.y - (self.interactiveScrollView.frame.height / 2.0) }
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
                onNext: { [unowned self] (flag) in
                    self.tweetActionView.setEnabled(flag, animated: true)
            }
        )
        
        let d2 = interactiveState
            .subscribe(
                onNext: { [unowned self] (action, preAction, y) in
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
        
        let d3 = state
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
        
        return .init(
            action: self.interactiveScrollView.rx.didEndDragging
                .withLatestFrom(
                    Observable
                        .combineLatest(
                            tweetActionEnabled,
                            interactiveState
                        )
                        .map { (enabled: $0, action: $1.action) }
                )
                .filter { $0.enabled }
                .map { TweetCellViewModel.Action.tweet($0.action) },
            bind: Disposables.create(d1, d2, d3)
        )
    }
}
