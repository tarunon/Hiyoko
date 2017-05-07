//
//  ListViewController+Timeline.swift
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
import RxDataSources
import APIClient
import RealmSwift
import Instantiate
import SafariServices

extension ListViewController {
    func bind<InitialRequest: PaginationRequest>(viewModel: TimelineViewModel<InitialRequest>.ViewBinder) -> Disposable where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
        
        tableView.register(type: TweetCell.self)
        tableView.register(type: TweetImageCell.self)
        tableView.register(type: TweetQuotedCell.self)
        tableView.register(type: RetweetCell.self)
        tableView.register(type: RetweetImageCell.self)
        tableView.register(type: RetweetQuotedCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 76.0
        
        let refreshControl = UIRefreshControl()
        tableView.insertSubview(refreshControl, at: 0)
        
        let d1 = viewModel.output
            .flatMap { Observable.from(optional: $0.dataSources) }
            .map { [unowned self] (dataSources) -> ((visibleTopModel: TweetCellViewModel, offset: CGFloat)?, [AnimatableSection<TweetCellViewModel>]) in
                guard let indexPath = self.tableView.indexPathsForVisibleRows?.first else {
                    return (nil, dataSources)
                }
                return try (
                    (
                        visibleTopModel: self.tableView.rx.model(at: indexPath),
                        offset: self.tableView.contentOffset.y - self.tableView.cellForRow(at: indexPath)!.frame.minY
                    ),
                    dataSources
                )
            }
            .shareReplay(1)
            .bind { [unowned self] (dataSources) -> Disposable in
                let d1 = dataSources
                    .map { $0.1 }
                    .bind(to: self.tableView.rx.animatedItem(configureDataSource: { $0.animationConfiguration = AnimationConfiguration.init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none) })) { [_viewModel=viewModel] (presenter, viewModel) -> Disposable in
                        let result: Observable<TweetCellViewModel.Result>
                        switch viewModel.style {
                        case .tweet(.plain):
                            result = presenter
                                .present(
                                    dequeue: TweetCell.dequeue,
                                    viewModel: viewModel,
                                    binder: TweetCell.bind
                            )
                        case .tweet(.images):
                            result = presenter
                                .present(
                                    dequeue: TweetImageCell.dequeue,
                                    viewModel: viewModel,
                                    binder: TweetImageCell.bind
                            )
                        case .tweet(.quoted):
                            result = presenter
                                .present(
                                    dequeue: TweetQuotedCell.dequeue,
                                    viewModel: viewModel,
                                    binder: TweetQuotedCell.bind
                            )
                        case .retweet(.plain):
                            result = presenter
                                .present(
                                    dequeue: RetweetCell.dequeue,
                                    viewModel: viewModel,
                                    binder: RetweetCell.bind
                            )
                        case .retweet(.images):
                            result = presenter
                                .present(
                                    dequeue: RetweetImageCell.dequeue,
                                    viewModel: viewModel,
                                    binder: RetweetImageCell.bind
                            )
                        case .retweet(.quoted):
                            result = presenter
                                .present(
                                    dequeue: RetweetQuotedCell.dequeue,
                                    viewModel: viewModel,
                                    binder: RetweetQuotedCell.bind
                            )
                        }
                        return result
                            .bind { [unowned self] (result) -> Disposable in
                                let d1 = result
                                    .flatMap { Observable.from(optional: $0.entities) }
                                    .flatMapFirst { [unowned self] (entities) -> Observable<Void> in
                                        switch entities {
                                        case .tap(.hashtag(let tag)):
                                            return self.search(query: "#\(tag)", client: viewModel.client)
                                        case .tap(.symbol(let symbol)):
                                            return self.search(query: "$\(symbol)", client: viewModel.client)
                                        case .tap(.mention(let screenName)):
                                            return self.profile(screenName: screenName, client: viewModel.client)
                                        case .tap(.url(let url)):
                                            return self.safari(url: url)
                                        case .tap(.media(let media)):
                                            return self.safari(url: media.mediaURL)
                                        case .longpress(let entity):
                                            let item: Any
                                            switch entity {
                                            case .hashtag(let tag):
                                                item = "#" + tag
                                            case .symbol(let symbol):
                                                item = "$" + symbol
                                            case .mention(let screenName):
                                                item = "@" + screenName
                                            case .url(let url):
                                                item = url
                                            case .media(let media):
                                                item = media.mediaURL
                                            }
                                            return self.share(object: item).map { _ in }
                                        }
                                    }
                                    .subscribe()
                                
                                let d2 = result
                                    .flatMap { Observable.from(optional: $0.tweet) }
                                    .map { (tweet) in
                                        switch tweet {
                                        case .favourite:
                                            return TimelineViewModel.Input.favorite(viewModel.tweet)
                                        case .retweet:
                                            return TimelineViewModel.Input.retweet(viewModel.tweet)
                                        case .reply:
                                            return TimelineViewModel.Input.reply(viewModel.tweet)
                                        }
                                    }
                                    .concat(Observable.never())
                                    .bind(to: _viewModel.input)
                                
                                return Disposables.create(d1, d2)
                            }
                    }
        
                let d2 = dataSources
                    .flatMapLatest { (pair, dataSources) -> Observable<(Int, CGFloat)> in
                        return self.tableView.rx.sentMessage(#selector(UITableView.beginUpdates))
                            .do(onNext: { _ in UIView.setAnimationsEnabled(false) })
                            .flatMapLatest { _ -> Observable<(Int, CGFloat)> in
                                return self.tableView.rx.methodInvoked(#selector(UITableView.endUpdates))
                                    .do(onNext: { _ in UIView.setAnimationsEnabled(true) })
                                    .flatMap { _ in Observable.from(optional: pair) }
                                    .flatMap { (visibleTopModel, offset) in
                                        Observable.from(optional: dataSources[0].items.index(where: { $0 == visibleTopModel }))
                                            .map { ($0, offset) }
                                    }
                            }
                    }
                    .subscribe(onNext: { (index, offset) in
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        self.tableView.contentOffset.y += offset
                    })
                return Disposables.create(d1, d2)
            }
        
        let d2 = self.tableView.rx.modelSelected(TweetCellViewModel.self)
            .flatMapFirst { [unowned self] (element) in
                self.safari(url: element.tweet.url)
            }
            .subscribe()
        
        let d3 = Observable
            .merge(
                rx.stateChange
                    .filter { $0 == .willAppear }
                    .take(1)
                    .map { _ in },
                refreshControl.rx.controlEvent(.valueChanged)
                    .map { _ in }
            )
            .map { TimelineViewModel<InitialRequest>.Input.reload }
            .bind(to: viewModel.input)
        
        let d4 = Observable
            .combineLatest(
                viewModel.output
                    .flatMap { Observable.from(optional: $0.dataSources) },
                tableView.rx.willDisplayCell
            ) { ($0, $1) }
            .filter { (data, cell) in
                data.count - 1 == cell.indexPath.section && data[cell.indexPath.section].items.count - 1 == cell.indexPath.row
            }
            .map { _ in TimelineViewModel<InitialRequest>.Input.next }
            .bind(to: viewModel.input)
        
        let d5 = viewModel.output
            .filter { $0.isFinishLoading }
            .map { _ in false }
            .bind(to: refreshControl.rx.isRefreshing)
        
        let d6 = leftButton.rx.tap
            .map { TimelineViewModel<InitialRequest>.Input.close }
            .bind(to: viewModel.input)
        
        return Disposables.create(d1, d2, d3, d4, d5, d6)
    }
}

extension ListViewController {
    fileprivate func search(query: String, client: TwitterClient) -> Observable<Void> {
        let realmIdentifier = "search_tweet:\(query)"
        return self.rx.push(
            viewController: ListViewController.instantiate(with: .init(title: query)),
            viewModel: TimelineViewModel(
                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                client: client,
                initialRequest: SinceMaxPaginationRequest(request: SearchTimeLineRequest(query: query))
            ),
            binder: ListViewController.bind,
            animated: true
        )
    }
    
    fileprivate func profile(screenName: String, client: TwitterClient) -> Observable<Void> {
        let realmIdentifier = "user_timeline:\(screenName)"
        return self.rx.push(
            viewController: ListViewController.instantiate(with: .init(title: screenName)),
            viewModel: TimelineViewModel(
                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                client: client,
                initialRequest: SinceMaxPaginationRequest(request: UserTimeLineRequest(screenName: screenName))
            ),
            binder: ListViewController.bind,
            animated: true
        )
    }
    
    fileprivate func safari(url: URL) -> Observable<Void> {
        return self.rx.present(
            viewController: SFSafariViewController(url: url),
            viewModel: EmptyViewModel(),
            binder: SFSafariViewController.bind,
            animated: true
        )
    }
    
    fileprivate func share(object: Any) -> Observable<(UIActivityType?, Bool, [Any]?)> {
        return self.rx.present(
            viewController: UIActivityViewController(activityItems: [object], applicationActivities: nil),
            viewModel: ActivityViewModel(),
            binder: UIActivityViewController.bind,
            animated: true
        )
    }
}
