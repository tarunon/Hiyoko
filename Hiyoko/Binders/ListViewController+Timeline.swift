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
        
        tableView.registerNib(type: TweetCell.self)
        tableView.registerNib(type: TweetImageCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 76.0
        
        let refreshControl = UIRefreshControl()
        tableView.insertSubview(refreshControl, at: 0)
        
        let d1 = viewModel.output
            .flatMap { Observable.from(optional: $0.dataSources) }
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
                    .bind(to: self.tableView.rx.animatedItem(configureDataSource: { $0.animationConfiguration = AnimationConfiguration.init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none) })) { (presenter, element) -> Disposable in
                        let result: Observable<TweetCellViewModel.Result>
                        switch element.style {
                        case .plain:
                            result = presenter
                                .present(
                                    dequeue: TweetCell.dequeue,
                                    viewModel: TweetCellViewModel(client: element.client, tweet: element.tweet),
                                    binder: TweetCell.bind
                            )
                        case .images:
                            result = presenter
                                .present(
                                    dequeue: TweetImageCell.dequeue,
                                    viewModel: TweetCellViewModel(client: element.client, tweet: element.tweet),
                                    binder: TweetImageCell.bind
                            )
                        }
                        return result
                            .flatMapFirst { [unowned self] (action) -> Observable<Void> in
                                switch action {
                                case .entities(.tap(.hashtag(let tag))):
                                    let realmIdentifier = "search_tweets:#\(tag)"
                                    return self.rx
                                        .push(
                                            viewController: ListViewController.instantiate(
                                                with: .init(
                                                    title: "#\(tag)"
                                                )
                                            ),
                                            viewModel: TimelineViewModel(
                                                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                                                client: element.client,
                                                initialRequest: SinceMaxPaginationRequest(request: SearchTimeLineRequest(query: "#\(tag)"))
                                            ),
                                            binder: ListViewController.bind,
                                            animated: true
                                    )
                                case .entities(.tap(.symbol(let symbol))):
                                    let realmIdentifier = "search_tweets:$\(symbol)"
                                    return self.rx
                                        .push(
                                            viewController: ListViewController.instantiate(
                                                with: .init(
                                                    title: "$\(symbol)"
                                                )
                                            ),
                                            viewModel: TimelineViewModel(
                                                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                                                client: element.client,
                                                initialRequest: SinceMaxPaginationRequest(request: SearchTimeLineRequest(query: "$\(symbol)"))
                                            ),
                                            binder: ListViewController.bind,
                                            animated: true
                                    )
                                case .entities(.tap(.mention(let screenName))):
                                    let realmIdentifier = "user_timeline:\(screenName)"
                                    return self.rx
                                        .push(
                                            viewController: ListViewController.instantiate(
                                                with: .init(
                                                    title: "\(screenName)"
                                                )
                                            ),
                                            viewModel: TimelineViewModel(
                                                realm: { try Realm(configuration: .init(inMemoryIdentifier: realmIdentifier)) },
                                                client: element.client,
                                                initialRequest: SinceMaxPaginationRequest(request: UserTimeLineRequest(screenName: screenName))
                                            ),
                                            binder: ListViewController.bind,
                                            animated: true
                                    )
                                case .entities(.tap(.url(let url))):
                                    return self.rx
                                        .present(
                                            viewController: SFSafariViewController(url: url),
                                            viewModel: EmptyViewModel(),
                                            binder: SFSafariViewController.bind,
                                            animated: true
                                    )
                                case .entities(.longpress(let entity)):
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
                                    return self.rx
                                        .present(
                                            viewController: UIActivityViewController(activityItems: [item], applicationActivities: nil),
                                            viewModel: ActivityViewModel(),
                                            binder: UIActivityViewController.bind,
                                            animated: true
                                        )
                                        .map { _ in }
                                default:
                                    return Observable.empty()
                                }
                            }
                            .subscribe()
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
        
        let d2 = Observable
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
        
        let d3 = Observable
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
        
        let d4 = viewModel.output
            .filter { $0.isFinishLoading }
            .map { _ in false }
            .bind(to: refreshControl.rx.isRefreshing)
        
        let d5 = leftButton.rx.tap
            .map { TimelineViewModel<InitialRequest>.Input.close }
            .bind(to: viewModel.input)
        
        return Disposables.create(d1, d2, d3, d4, d5)
    }
}
