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
import Base

public struct TweetCellModel {
    public let client: TwitterClient
    public let tweet: Tweet
    public enum Style {
        public enum Style {
            case plain
            case images
            case quoted
        }
        case tweet(Style)
        case retweet(Style)
    }
    public let style: Style
    
    init(client: TwitterClient, tweet: Tweet) {
        self.client = client
        self.tweet = tweet
        switch (tweet.retweetedStatus == nil, tweet.quotedStatus == nil, tweet.entities.media.isEmpty) {
        case (false, false, _):
            self.style = .retweet(.quoted)
        case (false, true, false):
            self.style = .retweet(.images)
        case (false, _, _):
            self.style = .retweet(.plain)
        case (_, false, _):
            self.style = .tweet(.quoted)
        case (_, true, false):
            self.style = .tweet(.images)
        case (_, _, _):
            self.style = .tweet(.plain)
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
        case retweet(Tweet)
        case favorite(Tweet)
        case reply(Tweet)
        
        var isClose: Bool {
            switch self {
            case .close:
                return true
            default:
                return false
            }
        }
        
        var isReload: Bool {
            switch self {
            case .reload:
                return true
            default:
                return false
            }
        }
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
                            .filter { $0.isClose }
                            .take(1)
                            .map { _ in }
                            .bind(to: observer)
                        let d2 = input
                            .filter { $0.isReload }
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
                                        case .retweet(let tweet) where tweet.retweeted.value == true:
                                            return client.request(request: TweetDetailRequest(id: tweet.id))
                                                .map { try $0.usersRetweetStatus?.id ??? RxError.noElements }
                                                .flatMap { client.request(request: DeleteTweetRequest(id: $0)) }
                                                .map { [$0] }
                                        case .retweet(let tweet):
                                            return client.request(request: RetweetRequest(id: tweet.id))
                                                .map { [$0] }
                                        case .favorite(let tweet) where tweet.favorited.value == true:
                                            return client.request(request: UnfavoriteRequest(id: tweet.id))
                                                .map { [$0] }
                                        case .favorite(let tweet):
                                            return client.request(request: FavoriteRequest(id: tweet.id))
                                                .map { [$0] }
                                        case .reply(let tweet):
                                            print("reply \(tweet.id) but method is not implemented yet")
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
        
        public var tweet: Tweet.Action? {
            switch self {
            case .tweet(let tweet): return tweet
            default: return nil
            }
        }

        public var user: User.Action? {
            switch self {
            case .user(let user): return user
            default: return nil
            }
        }

        public var entities: Entities.Action? {
            switch self {
            case .entities(let entities): return entities
            default: return nil
            }
        }
    }
    public typealias Result = Action
    public typealias Input = Action
    public indirect enum Output {
        case profileImage(UIImage?)
        case userName(String)
        case screenName(String)
        case createdAt(Date)
        case text(NSAttributedString)
        case media([TweetContentImageCellViewModel])
        case quote(Output)
        case retweet(Output)
        case favorited(Bool)
        case retweeted(Bool)
        
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
        
        public var quote: Output? {
            switch self {
            case .quote(let quote): return quote
            default: return nil
            }
        }
        
        public var retweet: Output? {
            switch self {
            case .retweet(let retweet): return retweet
            default: return nil
            }
        }
        
        public var retweeted: Bool? {
            switch self {
            case .retweeted(let retweeted): return retweeted
            default: return nil
            }
        }
        
        public var favorited: Bool? {
            switch self {
            case .favorited(let favorited): return favorited
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
                    .bind { (tweet) -> Disposable in
                        let presentTweet = tweet.map { $0.retweetedStatus ?? $0 }
                        let d1 = presentTweet
                            .flatMap { Observable.from(optional: $0.user.profileImageURL) }
                            .flatMap { client.request(request: GetProfileImageRequest(url: $0, quality: .bigger)) }
                            .map { Output.profileImage($0) }
                            .startWith(Output.profileImage(nil))
                            .observeOn(MainScheduler.instance)
                            .bind(to: emitter.output)
                        let d2 = presentTweet
                            .flatMap { (tweet) in
                                return Observable
                                    .of(
                                        Output.userName(tweet.user.name),
                                        Output.screenName("@" + tweet.user.screenName),
                                        Output.createdAt(tweet.createdAt),
                                        Output.text(tweet.attributedText),
                                        Output.favorited(tweet.favorited.value ?? false),
                                        Output.retweeted(tweet.retweeted.value ?? false)
                                    )
                            }
                            .bind(to: emitter.output)
                        let d3 = presentTweet
                            .map { Output.media($0.entities.media.map { TweetContentImageCellViewModel(client: client, media: $0) }) }
                            .bind(to: emitter.output)
                        let d4 = presentTweet
                            .flatMap { Observable.from(optional: $0.quotedStatus) }
                            .flatMap { (quoted) in
                                return Observable
                                    .of(
                                        Output.quote(.userName(quoted.user.name)),
                                        Output.quote(.screenName("@" + quoted.user.screenName)),
                                        Output.quote(.text(quoted.attributedText))
                                    )
                            }
                            .bind(to: emitter.output)
                        let d5 = tweet
                            .filter { $0.retweetedStatus != nil }
                            .flatMap { (source) in
                                return Observable
                                    .of(
                                        Output.retweet(.userName(source.user.name)),
                                        Output.retweet(.screenName("@" + source.user.screenName))
                                    )
                            }
                            .bind(to: emitter.output)
                        let d6 = tweet
                            .filter { $0.retweetedStatus != nil }
                            .flatMap { Observable.from(optional: $0.user.profileImageURL) }
                            .flatMap { client.request(request: GetProfileImageRequest(url: $0, quality: .mini)) }
                            .map { UIImage?.some($0) }
                            .startWith(nil)
                            .map { Output.retweet(.profileImage($0)) }
                            .observeOn(MainScheduler.instance)
                            .bind(to: emitter.output)
                        return Disposables.create(d1, d2, d3, d4, d5, d6)
                    }
                return Disposables.create(d1, d2)
            }
    }
}

public class TweetContentImageCellViewModel: RxViewModel {
    public enum Input {
        case tap
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
                    .map { (input) in
                        switch input {
                        case .tap:
                            return Entities.Action.tap(.media(media))
                        case .longPress:
                            return Entities.Action.longpress(.media(media))
                        }
                    }
                    .bind(to: observer)
                return Disposables.create(d1, d2)
            }
    }
}
