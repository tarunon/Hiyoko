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
    func bind<InitialRequest: PaginationRequest>(viewModel: TimelineViewModel<InitialRequest>.Emitter) -> Disposable where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
        
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
        
        let d1 = viewModel.state
            .flatMap { $0.dataSources }
            .map { [unowned self] (dataSources) -> ((visibleTopModel: TweetCellModel, offset: CGFloat)?, [AnimatableSection<TweetCellModel>]) in
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
                    .bind(to: self.tableView.rx.animatedItem(configureDataSource: { $0.animationConfiguration = AnimationConfiguration.init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none) })) { [_viewModel=viewModel] (presenter, element) -> Disposable in
                        let result: Observable<TweetCellViewModel.Result>
                        let viewModel = TweetCellViewModel(client: element.client, tweet: element.tweet)
                        switch element.style {
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
                            .shareReplay(1)
                            .bind { [unowned self] (result) -> Disposable in
                                let d1 = result
                                    .flatMap { $0.entities }
                                    .flatMapFirst { [unowned self] (entities) -> Observable<TweetResource> in
                                        switch entities {
                                        case .tap(.hashtag(let tag)):
                                            return self.search(query: "#\(tag)", client: element.client)
                                        case .tap(.symbol(let symbol)):
                                            return self.search(query: "$\(symbol)", client: element.client)
                                        case .tap(.mention(let screenName)):
                                            return self.profile(screenName: screenName, client: element.client)
                                        case .tap(.url(let url)):
                                            return self.safari(url: url)
                                                .flatMap { _ in Observable.empty() }
                                        case .tap(.media(let media)):
                                            return self.safari(url: media.mediaURL)
                                                .flatMap { _ in Observable.empty() }
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
                                            return self.share(object: item)
                                                .flatMap { _ in Observable.empty() }
                                        }
                                    }
                                    .map { TimelineViewModel.Action.tweet($0) }
                                    .concat(Observable.never())
                                    .bind(to: _viewModel.action)
                                
                                let d2 = result
                                    .flatMap { $0.tweet }
                                    .map { (tweet) in
                                        switch tweet {
                                        case .favourite:
                                            return TimelineViewModel.Action.favorite(element.tweet)
                                        case .retweet:
                                            return TimelineViewModel.Action.retweet(element.tweet)
                                        case .reply:
                                            return TimelineViewModel.Action.reply(element.tweet)
                                        }
                                    }
                                    .concat(Observable.never())
                                    .bind(to: _viewModel.action)
                                
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
        
        let d2 = self.tableView.rx.modelSelected(TweetCellModel.self)
            .flatMapFirst { [unowned self] (element) in
                self.safari(url: element.tweet.url)
            }
            .subscribe()
        
        let d3 = refreshControl.rx.controlEvent(.valueChanged)
            .map { _ in TimelineViewModel<InitialRequest>.Action.reload }
            .bind(to: viewModel.action)
        
        let d4 = Observable
            .combineLatest(
                viewModel.state
                    .flatMap { $0.dataSources },
                tableView.rx.willDisplayCell
            ) { ($0, $1) }
            .filter { (data, cell) in
                data.count - 1 == cell.indexPath.section && data[cell.indexPath.section].items.count - 1 == cell.indexPath.row
            }
            .map { _ in TimelineViewModel<InitialRequest>.Action.next }
            .bind(to: viewModel.action)
        
        let d5 = viewModel.state
            .flatMap { $0.isLoading }
            .bind(to: refreshControl.rx.isRefreshing)
        
        let d6 = leftButton.rx.tap
            .map { TimelineViewModel<InitialRequest>.Action.close }
            .bind(to: viewModel.action)
        
        return Disposables.create(d1, d2, d3, d4, d5, d6)
    }
}

extension ListViewController {
    fileprivate func search(query: String, client: TwitterClient) -> Observable<TweetResource> {
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
    
    fileprivate func profile(screenName: String, client: TwitterClient) -> Observable<TweetResource> {
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
    
    fileprivate func safari(url: URL) -> Observable<Never> {
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
