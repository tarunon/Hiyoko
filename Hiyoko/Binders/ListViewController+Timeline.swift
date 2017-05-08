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
    func present<InitialRequest: PaginationRequest>(state: Observable<TimelineViewModel<InitialRequest>.State>) -> Present<TimelineViewModel<InitialRequest>.Action> where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
        
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
        
        typealias Action = TimelineViewModel<InitialRequest>.Action
        
        
        let dataSource = state
            .flatMap { $0.dataSources }
            .map { (dataSources) -> ((visibleTopModel: TweetCellModel, offset: CGFloat)?, [AnimatableSection<TweetCellModel>]) in
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
        
        let cellResults = dataSource
            .map { $0.1 }
            .bind(to: self.tableView.rx.animatedItem(configureDataSource: { $0.animationConfiguration = AnimationConfiguration.init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none) })) { (presenter, element) -> Observable<TweetCellViewModel.Result> in
                let viewModel = TweetCellViewModel(client: element.client, tweet: element.tweet)
                switch element.style {
                case .tweet(.plain):
                    return presenter
                        .present(
                            dequeue: TweetCell.dequeue,
                            viewModel: viewModel,
                            presenter: TweetCell.present
                    )
                case .tweet(.images):
                    return presenter
                        .present(
                            dequeue: TweetImageCell.dequeue,
                            viewModel: viewModel,
                            presenter: TweetImageCell.present
                    )
                case .tweet(.quoted):
                    return presenter
                        .present(
                            dequeue: TweetQuotedCell.dequeue,
                            viewModel: viewModel,
                            presenter: TweetQuotedCell.present
                    )
                case .retweet(.plain):
                    return presenter
                        .present(
                            dequeue: RetweetCell.dequeue,
                            viewModel: viewModel,
                            presenter: RetweetCell.present
                    )
                case .retweet(.images):
                    return presenter
                        .present(
                            dequeue: RetweetImageCell.dequeue,
                            viewModel: viewModel,
                            presenter: RetweetImageCell.present
                    )
                case .retweet(.quoted):
                    return presenter
                        .present(
                            dequeue: RetweetQuotedCell.dequeue,
                            viewModel: viewModel,
                            presenter: RetweetQuotedCell.present
                    )
                }
            }
            .flatMap { (element, result) in
                result.map { (element: element, result: $0) }
            }
            .shareReplay(1)
        
        let cellActions = cellResults
            .flatMap { (element, result) -> Observable<Action> in
                let o1 = result.entities
                    .flatMap { (entities) -> Observable<TweetResource> in
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
                    .map { Action.tweet($0) }
                
                let o2 = result.tweet
                    .map { (tweet) -> Action in
                        switch tweet {
                        case .favourite:
                            return Action.favorite(element.tweet)
                        case .retweet:
                            return Action.retweet(element.tweet)
                        case .reply:
                            return Action.reply(element.tweet)
                        }
                }
                return Observable.merge(o1, o2)
            }
        
        let scrollAdjustment = dataSource
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
            .subscribe(
                onNext: { (index, offset) in
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    self.tableView.contentOffset.y += offset
            }
        )
        
        let showDetail = self.tableView.rx.modelSelected(TweetCellModel.self)
            .flatMapFirst { [unowned self] (element) in
                self.safari(url: element.tweet.url)
            }
            .flatMap { _ in Observable<Action>.empty() }
        
        let refresh = refreshControl.rx.controlEvent(.valueChanged)
            .map { _ in Action.reload }
        
        let loadNext = Observable
            .combineLatest(
                dataSource.map { $0.1 },
                self.tableView.rx.willDisplayCell
            ) { ($0, $1) }
            .filter { (dataSources, cell) in
                dataSources.count - 1 == cell.indexPath.section && dataSources[cell.indexPath.section].items.count - 1 == cell.indexPath.row
            }
            .map { _ in Action.next }
        
        let close = self.leftButton.rx.tap
            .map { Action.close }
        
        let switchRefresh = state
            .flatMap { $0.isLoading }
            .bind(to: refreshControl.rx.isRefreshing)
        
        return .init(
            action: Observable<Action>
                .merge(
                    cellActions,
                    showDetail,
                    refresh,
                    loadNext,
                    close,
                    refresh
            ),
            bind: Disposables.create(scrollAdjustment, switchRefresh)
        )
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
            presenter: ListViewController.present,
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
            presenter: ListViewController.present,
            animated: true
        )
    }
    
    fileprivate func safari(url: URL) -> Observable<Never> {
        return self.rx.present(
            viewController: SFSafariViewController(url: url),
            viewModel: EmptyViewModel(),
            presenter: SFSafariViewController.present,
            animated: true
        )
    }
    
    fileprivate func share(object: Any) -> Observable<(UIActivityType?, Bool, [Any]?)> {
        return self.rx.present(
            viewController: UIActivityViewController(activityItems: [object], applicationActivities: nil),
            viewModel: ActivityViewModel(),
            presenter: UIActivityViewController.present,
            animated: true
        )
    }
}
