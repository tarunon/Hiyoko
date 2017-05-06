//
//  TimelineViewModel.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import Barrel
import Barrel_Realm

public struct TweetCellModel {
    public let client: TwitterClient
    public let tweet: Tweet
    public enum Style {
        case plain
        case images
    }
    public let style: Style
    
    init(client: TwitterClient, tweet: Tweet) {
        self.client = client
        self.tweet = tweet
        if tweet.entities.media.isEmpty {
            self.style = .plain
        } else {
            self.style = .images
        }
    }
}

extension TweetCellModel: Equatable {
    public static func == (lhs: TweetCellModel, rhs: TweetCellModel) -> Bool {
        return lhs.tweet == rhs.tweet
    }
}

extension TweetCellModel: IdentifiableType {
    public var identity: Int64 {
        return tweet.id
    }
}

public class TimelineViewModel<InitialRequest: PaginationRequest>: RxViewModel where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
    public typealias Result = Void
    public enum Input {
        case reload
        case next
        case close
    }
    
    public enum Output {
        case dataSources([AnimatableSection<TweetCellModel>])
        case finishLoading
        
        public var dataSources: [AnimatableSection<TweetCellModel>]? {
            switch self {
            case .dataSources(let dataSources): return dataSources
            default: return nil
            }
        }
        
        public var isFinishLoading: Bool {
            switch self {
            case .finishLoading: return true
            default: return false
            }
        }
    }
    
    public let result: Observable<Void>
    public let emitter: RxIOEmitter<Input, Output> = RxIOEmitter()
    
    public init(realm: @escaping () throws -> Realm, client: TwitterClient, initialRequest: InitialRequest) {
        result = Observable<Void>
            .create { [emitter = self.emitter] (observer) in
                var nextRequest: AnyRequest<InitialRequest.Response, InitialRequest.Error>? = nil
                let d1 = emitter.input
                    .shareReplay(1)
                    .bind { (input) -> Disposable in
                        let d1 = input
                            .filter { $0 == .close }
                            .take(1)
                            .map { _ in }
                            .bind(to: observer)
                        let d2 = input
                            .filter { $0 == .reload }
                            .flatMapFirst { _ in client.request(request: initialRequest) }
                            .do(
                                onNext: { (response) in
                                    nextRequest = response.next
                                }
                            )
                            .map { Array($0.response) }
                            .flatMapFirst { (tweets) -> Observable<[Tweet]> in
                                input
                                    .flatMapFirst { input -> Observable<[Tweet]> in
                                        switch input {
                                        case .reload:
                                            return client.request(request: initialRequest)
                                                .map { Array($0.response) }
                                        case .next:
                                            return Observable.from(optional: nextRequest)
                                                .flatMap { client.request(request: $0) }
                                                .do(
                                                    onNext: { (response) in
                                                        nextRequest = response.next
                                                    }
                                                )
                                                .map { Array($0.response) }
                                        case .close:
                                            return Observable.empty()
                                        }
                                    }
                                    .startWith(tweets)
                            }
                            .do(
                                onNext: { (tweets) in
                                    tweets.forEach { $0.timeline = true }
                                    let _realm = try realm()
                                    try _realm.write {
                                        _realm.add(tweets, update: true)
                                    }
                                }
                            )
                            .map { _ in Output.finishLoading }
                            .bind(to: emitter.output)
                        return Disposables.create(d1, d2)
                    }
                let d2 = Observable
                    .just(realm, scheduler: MainScheduler.instance)
                    .map { try $0() }
                    .flatMap { (realm) in
                        Observable.array(
                            from: Tweet.objects(realm).brl
                                .filter { $0.timeline == true }
                                .sorted { $0.createdAt > $1.createdAt }
                                .confirm()
                        )
                    }
                    .map { $0.map { TweetCellModel(client: client, tweet: $0) } }
                    .map { [AnimatableSection(items: $0)] }
                    .map { Output.dataSources($0) }
                    .bind(to: emitter.output)
                return Disposables.create(d1, d2)
            }
    }
}

public class TweetCellViewModel: RxViewModel {
    public enum Action {
        case tweet(Tweet.Action)
        case user(User.Action)
        case entities(Entities.Action)
    }
    public typealias Result = Action
    public typealias Input = Action
    public enum Output {
        case profileImage(UIImage?)
        case userName(String)
        case screenName(String)
        case createdAt(Date)
        case text(NSAttributedString)
        case media([TweetContentImageCellViewModel])
        
        public var profileImage: UIImage?? {
            switch self {
            case .profileImage(let image): return image
            default: return nil
            }
        }
        
        public var userName: String? {
            switch self {
            case .userName(let userName): return userName
            default: return nil
            }
        }
        
        public var screenName: String? {
            switch self {
            case .screenName(let screenName): return screenName
            default: return nil
            }
        }
        
        public var createdAt: Date? {
            switch self {
            case .createdAt(let createdAt): return createdAt
            default: return nil
            }
        }
        
        public var text: NSAttributedString? {
            switch self {
            case .text(let text): return text
            default: return nil
            }
        }
        
        public var media: [TweetContentImageCellViewModel]? {
            switch self {
            case .media(let media): return media
            default: return nil
            }
        }
    }
    
    public let result: Observable<Result>
    public var emitter: RxIOEmitter<Input, Output> = RxIOEmitter()
    
    public init(client: TwitterClient, tweet: Tweet) {
        result = Observable<Action>
            .create { [emitter = self.emitter] (observer) in
                let d1 = emitter.input.bind(to: observer)
                let d2 = Observable.from(object: tweet)
                    .catchError { _ in Observable.empty() }
                    .shareReplay(1)
                    .map { (tweet) in
                        return tweet.retweetedStatus ?? tweet
                    }
                    .bind { (tweet) -> Disposable in
                        let d1 = tweet
                            .flatMap { Observable.from(optional: $0.user.profileImageURL) }
                            .flatMap { client.request(request: GetProfileImageRequest(url: $0, quality: .bigger)) }
                            .map { Output.profileImage($0) }
                            .startWith(Output.profileImage(nil))
                            .observeOn(MainScheduler.instance)
                            .bind(to: emitter.output)
                        let d2 = tweet
                            .map { Output.userName($0.user.name) }
                            .bind(to: emitter.output)
                        let d3 = tweet
                            .map { Output.screenName("@" + $0.user.screenName) }
                            .bind(to: emitter.output)
                        let d4 = tweet
                            .map { Output.createdAt($0.createdAt) }
                            .bind(to: emitter.output)
                        let d5 = tweet
                            .map { Output.text($0.attributedText) }
                            .bind(to: emitter.output)
                        let d6 = tweet
                            .map { Output.media($0.entities.media.map { TweetContentImageCellViewModel(client: client, media: $0) }) }
                            .bind(to: emitter.output)
                        return Disposables.create(d1, d2, d3, d4, d5, d6)
                    }
                return Disposables.create(d1, d2)
            }
    }
}

public class TweetContentImageCellViewModel: RxViewModel {
    public enum Input {
        case longPress
    }
    public typealias Output = UIImage?
    public typealias Result = Entities.Action
    
    public let result: Observable<Entities.Action>
    public let emitter: RxIOEmitter<Input, UIImage?> = RxIOEmitter()
    
    public init(client: TwitterClient, media: Entities.Media) {
        result = Observable<Entities.Action>
            .create { [emitter=self.emitter] (observer) in
                let d1 = client.request(request: GetEntitiesImageRequest(url: media.mediaURL))
                    .map { UIImage?.some($0) }
                    .observeOn(MainScheduler.instance)
                    .startWith(nil)
                    .bind(to: emitter.output)
                let d2 = emitter.input
                    .map { _ in Entities.Action.longpress(.media(media)) }
                    .bind(to: observer)
                return Disposables.create(d1, d2)
            }
    }
}
