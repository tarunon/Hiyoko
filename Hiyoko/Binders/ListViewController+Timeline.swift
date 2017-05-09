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
    struct TimelineView<InitialRequest: PaginationRequest>: View where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
        typealias State = TimelineReactor<InitialRequest>.State
        typealias Action = TimelineReactor<InitialRequest>.Action

        let view: ListViewController

        func present(state: Observable<State>) -> Present<Action> {
            view.tableView.register(type: TweetCell.self)
            view.tableView.register(type: TweetImageCell.self)
            view.tableView.register(type: TweetQuotedCell.self)
            view.tableView.register(type: RetweetCell.self)
            view.tableView.register(type: RetweetImageCell.self)
            view.tableView.register(type: RetweetQuotedCell.self)
            view.tableView.rowHeight = UITableViewAutomaticDimension
            view.tableView.estimatedRowHeight = 76.0

            let refreshControl = UIRefreshControl()
            view.tableView.insertSubview(refreshControl, at: 0)

            typealias Action = TimelineReactor<InitialRequest>.Action


            let dataSource = state
                .flatMap { $0.dataSources }
                .map { (dataSources) -> ((visibleTopModel: TweetCellModel, offset: CGFloat)?, [AnimatableSection<TweetCellModel>]) in
                    guard let indexPath = self.view.tableView.indexPathsForVisibleRows?.first else {
                        return (nil, dataSources)
                    }
                    return try (
                        (
                            visibleTopModel: self.view.tableView.rx.model(at: indexPath),
                            offset: self.view.tableView.contentOffset.y - self.view.tableView.cellForRow(at: indexPath)!.frame.minY
                        ),
                        dataSources
                    )
                }
                .shareReplay(1)

            let cellResults = dataSource
                .map { $0.1 }
                .bind(to: self.view.tableView.rx.animatedItem(configureDataSource: { $0.animationConfiguration = AnimationConfiguration.init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none) })) { (queue, element) -> Observable<(TweetCellReactor.Result, TweetCellModel)> in
                    let reactor = TweetCellReactor(client: element.client, tweet: element.tweet)
                    let result: Observable<TweetCellReactor.Result>
                    switch element.style {
                    case .tweet(.plain):
                        result = queue
                            .dequeue(
                                dequeue: TweetCell.dequeue,
                                reactor: reactor
                            )
                    case .tweet(.images):
                        result = queue
                            .dequeue(
                                dequeue: TweetImageCell.dequeue,
                                reactor: reactor
                        )
                    case .tweet(.quoted):
                        result = queue
                            .dequeue(
                                dequeue: TweetQuotedCell.dequeue,
                                reactor: reactor
                        )
                    case .retweet(.plain):
                        result = queue
                            .dequeue(
                                dequeue: RetweetCell.dequeue,
                                reactor: reactor
                        )
                    case .retweet(.images):
                        result = queue
                            .dequeue(
                                dequeue: RetweetImageCell.dequeue,
                                reactor: reactor
                        )
                    case .retweet(.quoted):
                        result = queue
                            .dequeue(
                                dequeue: RetweetQuotedCell.dequeue,
                                reactor: reactor
                        )
                    }
                    return result.map { ($0, element) }
                }
                .shareReplay(1)

            let cellActions = cellResults
                .flatMap { (result, element) -> Observable<Action> in
                    let o1 = result.entities
                        .flatMap { (entities) -> Observable<TweetResource> in
                            switch entities {
                            case .tap(.hashtag(let tag)):
                                return self.view.search(query: "#\(tag)", client: element.client)
                            case .tap(.symbol(let symbol)):
                                return self.view.search(query: "$\(symbol)", client: element.client)
                            case .tap(.mention(let screenName)):
                                return self.view.profile(screenName: screenName, client: element.client)
                            case .tap(.url(let url)):
                                return self.view.safari(url: url)
                                    .flatMap { _ in Observable.empty() }
                            case .tap(.media(let media)):
                                return self.view.safari(url: media.mediaURL)
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
                                return self.view.share(object: item)
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
                    return self.view.tableView.rx.sentMessage(#selector(UITableView.beginUpdates))
                        .do(onNext: { _ in UIView.setAnimationsEnabled(false) })
                        .flatMapLatest { _ -> Observable<(Int, CGFloat)> in
                            return self.view.tableView.rx.methodInvoked(#selector(UITableView.endUpdates))
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
                        self.view.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        self.view.tableView.contentOffset.y += offset
                }
            )

            let showDetail = self.view.tableView.rx.modelSelected(TweetCellModel.self)
                .flatMapFirst { (element) in
                    self.view.safari(url: element.tweet.url)
                }
                .flatMap { _ in Observable<Action>.empty() }

            let refresh = refreshControl.rx.controlEvent(.valueChanged)
                .map { _ in Action.reload }

            let loadNext = Observable
                .combineLatest(
                    dataSource.map { $0.1 },
                    self.view.tableView.rx.willDisplayCell
                ) { ($0, $1) }
                .filter { (dataSources, cell) in
                    dataSources.count - 1 == cell.indexPath.section && dataSources[cell.indexPath.section].items.count - 1 == cell.indexPath.row
                }
                .map { _ in Action.next }
            
            let close = self.view.leftButton.rx.tap
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
}

extension ListViewController {
    fileprivate func search(query: String, client: TwitterClient) -> Observable<TweetResource> {
        let realmIdentifier = "search_tweet:\(query)"
        return self.rx.push(
            viewController: ListViewController.instantiate(with: .init(title: query)),
            view: ListViewController.TimelineView.init,
            reactor: TimelineReactor(
                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                client: client,
                initialRequest: SinceMaxPaginationRequest(request: SearchTimeLineRequest(query: query))
            ),
            animated: true
        )
    }
    
    fileprivate func profile(screenName: String, client: TwitterClient) -> Observable<TweetResource> {
        let realmIdentifier = "user_timeline:\(screenName)"
        return self.rx.push(
            viewController: ListViewController.instantiate(with: .init(title: screenName)),
            view: ListViewController.TimelineView.init,
            reactor: TimelineReactor(
                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                client: client,
                initialRequest: SinceMaxPaginationRequest(request: UserTimeLineRequest(screenName: screenName))
            ),
            animated: true
        )
    }
    
    fileprivate func safari(url: URL) -> Observable<Never> {
        return self.rx.present(
            viewController: SFSafariViewController(url: url),
            view: EmptyView.init,
            reactor: EmptyReactor(),
            animated: true
        )
    }
    
    fileprivate func share(object: Any) -> Observable<(UIActivityType?, Bool, [Any]?)> {
        return self.rx.present(
            viewController: UIActivityViewController(activityItems: [object], applicationActivities: nil),
            reactor: ActivityReactor(),
            animated: true
        )
    }
}
