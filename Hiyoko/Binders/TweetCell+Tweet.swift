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

extension TweetCellType where ContentView.Wrapped: TweetContentViewBase {
    func bind(text viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
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
                    .bind(to: self.userNameLabel.rx.text)
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
                let d5 = output
                    .flatMap { Observable.from(optional: $0.text) }
                    .bind { [textView=self.tweetContentView.view.textView] (attributedText) in
                        textView?.attributedText = attributedText.styled(with: .font(.systemFont(ofSize: 14.0)))
                    }
                return Disposables.create(d1, d2, d3, d4, d5)
            }
        let d3 = self.tweetContentView.view.textView.rx.linkTap
            .map { (url) in
                TweetCellViewModel.Action.entities(.tap(.init(url)))
            }
            .bind(to: viewModel.input)
        let d4 = self.tweetContentView.view.textView.rx.linkLongPress
            .map { (url) in
                TweetCellViewModel.Action.entities(.longpress(.init(url)))
            }
            .bind(to: viewModel.input)
        
        return Disposables.create(d1, d2, d3, d4)
    }
}

extension TweetCellType where ContentView.Wrapped: TweetContentViewBase, ContentView.Wrapped: TweetContentImageViewType {
    func bind(image viewModel: TweetCellViewModel.ViewBinder) -> Disposable {
        let d1 = self.bind(text: viewModel)
        let d2 = viewModel.output
            .flatMap { Observable.from(optional: $0.media) }
            .shareReplay(1)
            .bind { [collectionView=self.tweetContentView.view.imageCollectionView] (medias) -> Disposable in
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
                
                let layout = TweetContentImageFlowLayout(numberOfItems: 0, collectionViewSize: .zero)
                
                let d2 = collectionView.rx.setDelegate(layout)
                
                let d3 = Observable
                    .combineLatest(
                        medias.map { $0.count },
                        collectionView.rx.observe(CGRect.self, "frame")
                            .map { $0?.size ?? .zero }
                    ) { ($0, $1) }
                    .subscribe(
                        onNext: { (count, size) in
                            layout.numberOfItems = count
                            layout.collectionViewSize = size
                            collectionView.layoutIfNeeded()
                        }
                    )
                return Disposables.create(d1, d2, d3)
            }
        return Disposables.create(d1, d2)
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
        return Disposables.create(d1, d2)
    }
}
