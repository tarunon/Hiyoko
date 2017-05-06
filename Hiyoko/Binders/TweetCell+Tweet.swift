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
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        return Disposables.create(d1, d2)
    }
}

extension TweetImageCell {
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(image: viewModel)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetQuotedCell {
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(quoted: viewModel)
        return Disposables.create(d1, d2, d3)
    }
}

extension RetweetCell {
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(retweet: viewModel)
        return Disposables.create(d1, d2, d3)
    }
}

extension RetweetImageCell {
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(image: viewModel)
        let d4 = bind(retweet: viewModel)
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension RetweetQuotedCell {
    func bind(viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = bind(tweet: viewModel)
        let d2 = bind(content: viewModel)
        let d3 = bind(quoted: viewModel)
        let d4 = bind(retweet: viewModel)
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension TweetCellViewType {
    fileprivate func bind(tweet viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = profileImageButton.rx.tap
            .withLatestFrom(viewModel.output.flatMap { Observable.from(optional: $0.screenName) })
            .map { TweetCellViewModel.Input.entities(.tap(.mention($0))) }
            .bind(to: viewModel.input)
        let d2 = viewModel.output
            .shareReplay(1)
            .bind { [unowned self] (output) -> Disposable in
                let d1 = output
                    .flatMap { Observable.from(optional: $0.profileImage) }
                    .bind { [profileImageButton=self.profileImageButton] (image) in
                        profileImageButton?.setImage(image, for: .normal)
                    }
                let d2 = output
                    .flatMap { Observable.from(optional: $0.userName) }
                    .bind(to: self.nameLabel.rx.text)
                let d3 = output
                    .flatMap { Observable.from(optional: $0.screenName) }
                    .bind(to: self.screenNameLabel.rx.text)
                let d4 = output
                    .flatMap { Observable.from(optional: $0.createdAt) }
                    .flatMapLatest { (date) in
                        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .default))
                            .map { _ in Date() }
                            .startWith(Date())
                            .map { date.label(since: $0) }
                            .observeOn(MainScheduler.instance)
                    }
                    .bind(to: self.dateLabel.rx.text)
                return Disposables.create(d1, d2, d3, d4)
            }
        return Disposables.create(d1, d2)
    }
}

extension RetweetCellViewType {
    fileprivate func bind(retweet viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        return viewModel.output
            .flatMap { Observable.from(optional: $0.retweeted) }
            .shareReplay(1)
            .bind { [imageView=self.retweetUserIconImageView, label=self.retweetUserScreenNameLabel] (retweeted) -> Disposable in
                guard let imageView = imageView, let label = label else {
                    return Disposables.create()
                }
                let d1 = retweeted
                    .flatMap { Observable.from(optional: $0.profileImage) }
                    .bind(to: imageView.rx.image)
                let d2 = retweeted
                    .flatMap { Observable.from(optional: $0.screenName) }
                    .map { "retweeted by \($0)" }
                    .bind(to: label.rx.text)
                return Disposables.create(d1, d2)
            }
    }
}

extension TweetContentViewType {
    fileprivate func bind(content viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = viewModel.output
            .flatMap { Observable.from(optional: $0.text) }
            .bind { [textView=self.textView] (attributedText) in
                textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
            }
        let d2 = self.textView.rx.linkTap
            .map { (url) in
                TweetCellViewModel.Action.entities(.tap(.init(url)))
            }
            .bind(to: viewModel.input)
        let d3 = self.textView.rx.linkLongPress
            .map { (url) in
                TweetCellViewModel.Action.entities(.longpress(.init(url)))
            }
            .bind(to: viewModel.input)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetContentImageViewType {
    fileprivate func bind(image viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        return viewModel.output
            .flatMap { Observable.from(optional: $0.media) }
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
                            .bind(to: viewModel.input)
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
    fileprivate func bind(quoted viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = viewModel.output
            .flatMap { Observable.from(optional: $0.quoted) }
            .shareReplay(1)
            .bind { [unowned self] (quoted) -> Disposable in
                let d1 = quoted
                    .flatMap { Observable.from(optional: $0.userName) }
                    .bind(to: self.quotedUserNameLabel.rx.text)
                let d2 = quoted
                    .flatMap { Observable.from(optional: $0.screenName) }
                    .bind(to: self.quotedScreenNameLabel.rx.text)
                let d3 = quoted
                    .flatMap { Observable.from(optional: $0.text) }
                    .bind { [textView=self.quotedContentView.view.textView] (attributedText) in
                        textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
                    }
                return Disposables.create(d1, d2, d3)
            }
        let d2 = self.quotedContentView.view.textView.rx.linkTap
            .map { (url) in
                TweetCellViewModel.Action.entities(.tap(.init(url)))
            }
            .bind(to: viewModel.input)
        let d3 = self.quotedContentView.view.textView.rx.linkLongPress
            .map { (url) in
                TweetCellViewModel.Action.entities(.longpress(.init(url)))
            }
            .bind(to: viewModel.input)
        return Disposables.create(d1, d2, d3)
    }
}

extension TweetContentImageCell {
    func bind(viewModel: TweetContentImageCellViewModel.ViewBinder) -> Disposable {
        let d1 = viewModel.output
            .bind(to: imageView.rx.image)
        let d2 = longPressGestureRecognizer.rx.event
            .filter { $0.state == .began }
            .map { _ in TweetContentImageCellViewModel.Input.longPress }
            .bind(to: viewModel.input)
        let d3 = tapGestureRecognizer.rx.event
            .map { _ in TweetContentImageCellViewModel.Input.tap }
            .bind(to: viewModel.input)
        return Disposables.create(d1, d2, d3)
    }
}
