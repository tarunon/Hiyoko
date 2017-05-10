//
//  TimelineReactor.swift
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
import Reactor
import Barrel
import Barrel_Realm
import Base

public enum TweetResource {
    case reply(Tweet)
}

public enum TimelineAction {
    case reload
    case next
    case close
    case retweet(Tweet)
    case favorite(Tweet)
    case reply(Tweet)
    case tweet(TweetResource)
    
    var close: Observable<Void> {
        switch self {
        case .close:
            return .just()
        default:
            return .empty()
        }
    }
    
    var reply: Observable<Tweet> {
        switch self {
        case .reply(let reply): return .just(reply)
        default: return .empty()
        }
    }
    
    var tweet: Observable<TweetResource> {
        switch self {
        case .tweet(let tweet): return .just(tweet)
        default: return .empty()
        }
    }
}

public enum TimelineState {
    case dataSources([AnimatableSection<TweetCellModel>])
    case isLoading(Bool)
    
    public var dataSources: Observable<[AnimatableSection<TweetCellModel>]> {
        switch self {
        case .dataSources(let dataSources): return .just(dataSources)
        default: return .empty()
        }
    }
    
    public var isLoading: Observable<Bool> {
        switch self {
        case .isLoading(let isLoading): return .just(isLoading)
        default: return .empty()
        }
    }
}

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

public class TimelineReactor<InitialRequest: PaginationRequest>: Reactor where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
    public typealias Result = TweetResource
    public typealias Action = TimelineAction
    public typealias State = TimelineState
    
    var realm: () throws -> Realm
    var client: TwitterClient
    var initialRequest: InitialRequest
    
    public init(realm: @escaping () throws -> Realm, client: TwitterClient, initialRequest: InitialRequest) {
        self.realm = realm
        self.client = client
        self.initialRequest = initialRequest
    }
    
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        var nextRequest: AnyRequest<InitialRequest.Response, InitialRequest.Error>? = nil
        
        let initialLoad = self.client.request(request: self.initialRequest)
            .do(
                onNext: { (response) in
                    nextRequest = response.next
                }
            )
            .map { $0.response.map { $0 as Tweet } }
        
        let actionLoad = action
            .flatMapFirst { (action) -> Observable<[Tweet]> in
                switch action {
                case .reload:
                    return self.client.request(request: self.initialRequest)
                        .map { Array($0.response) }
                case .next:
                    return Observable.from(optional: nextRequest)
                        .flatMap { self.client.request(request: $0) }
                        .do(
                            onNext: { (response) in
                                nextRequest = response.next
                            }
                        )
                        .map { Array($0.response) }
                case .retweet(let tweet) where tweet.retweeted.value == true:
                    return self.client.request(request: TweetDetailRequest(id: tweet.id))
                        .map { try $0.usersRetweetStatus?.id ??? RxError.noElements }
                        .flatMap { self.client.request(request: DeleteTweetRequest(id: $0)) }
                        .map { [$0] }
                case .retweet(let tweet):
                    return self.client.request(request: RetweetRequest(id: tweet.id))
                        .map { [$0] }
                case .favorite(let tweet) where tweet.favorited.value == true:
                    return self.client.request(request: UnfavoriteRequest(id: tweet.id))
                        .map { [$0] }
                case .favorite(let tweet):
                    return self.client.request(request: FavoriteRequest(id: tweet.id))
                        .map { [$0] }
                default:
                    return Observable.empty()
                }
            }
        
        let loading = Observable
            .merge(initialLoad, actionLoad)
            .do(
                onNext: { (tweets) in
                    let realm = try self.realm()
                    try realm.write {
                        tweets.forEach { $0.timeline = true }
                        realm.add(tweets, update: true)
                    }
                }
            )
            .observeOn(MainScheduler.instance)
            .map { _ in State.isLoading(false) }
        
        let realm = try self.realm()

        let timeline = Observable
            .array(
                from: Tweet.objects(realm).brl
                    .filter { $0.timeline == true }
                    .sorted { $0.createdAt > $1.createdAt }
                    .confirm()
            )
            .map { $0.map { TweetCellModel(client: self.client, tweet: $0) } }
            .map { [AnimatableSection(items: $0)] }
            .map { State.dataSources($0) }
        
        let tweet = action
            .flatMapFirst { (action) -> Observable<Result> in
                switch action {
                case .reply(let reply):
                    return .just(.reply(reply))
                case .tweet(let tweet):
                    return .just(tweet)
                default:
                    return .empty()
                    
                }
            }
        
        let close = action
            .flatMapFirst { $0.close }
        
        return .init(
            state: Observable
                .merge(
                    loading,
                    timeline
            ),
            result: tweet
                .takeUntil(close)
        )
    }
}

public class TweetCellReactor: Reactor {
    public enum Action {
        case tweet(Tweet.Action)
        case user(User.Action)
        case entities(Entities.Action)
        
        public var tweet: Observable<Tweet.Action> {
            switch self {
            case .tweet(let tweet): return .just(tweet)
            default: return .empty()
            }
        }

        public var user: Observable<User.Action> {
            switch self {
            case .user(let user): return .just(user)
            default: return .empty()
            }
        }

        public var entities: Observable<Entities.Action> {
            switch self {
            case .entities(let entities): return .just(entities)
            default: return .empty()
            }
        }
    }
    public typealias Result = Action
    public indirect enum State {
        case profileImage(UIImage?)
        case userName(String)
        case screenName(String)
        case createdAt(Date)
        case text(NSAttributedString)
        case media([TweetContentImageCellReactor])
        case quote(State)
        case retweetBy(State)
        case favorited(Bool)
        case retweeted(Bool)
        
        public var profileImage: Observable<UIImage?> {
            switch self {
            case .profileImage(let image): return .just(image)
            default: return .empty()
            }
        }
        
        public var userName: Observable<String> {
            switch self {
            case .userName(let userName): return .just(userName)
            default: return .empty()
            }
        }
        
        public var screenName: Observable<String> {
            switch self {
            case .screenName(let screenName): return .just(screenName)
            default: return .empty()
            }
        }
        
        public var createdAt: Observable<Date> {
            switch self {
            case .createdAt(let createdAt): return .just(createdAt)
            default: return .empty()
            }
        }
        
        public var text: Observable<NSAttributedString> {
            switch self {
            case .text(let text): return .just(text)
            default: return .empty()
            }
        }
        
        public var media: Observable<[TweetContentImageCellReactor]> {
            switch self {
            case .media(let media): return .just(media)
            default: return .empty()
            }
        }
        
        public var quote: Observable<State> {
            switch self {
            case .quote(let quote): return .just(quote)
            default: return .empty()
            }
        }
        
        public var retweetBy: Observable<State> {
            switch self {
            case .retweetBy(let retweetBy): return .just(retweetBy)
            default: return .empty()
            }
        }
        
        public var retweeted: Observable<Bool> {
            switch self {
            case .retweeted(let retweeted): return .just(retweeted)
            default: return .empty()
            }
        }
        
        public var favorited: Observable<Bool> {
            switch self {
            case .favorited(let favorited): return .just(favorited)
            default: return .empty()
            }
        }
    }
   
    let client: TwitterClient
    let tweet: Tweet
    
    public init(client: TwitterClient, tweet: Tweet) {
        self.client = client
        self.tweet = tweet
    }
    
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        
        let presentTweet = tweet.retweetedStatus ?? tweet
        
        let state = Observable<State>
            .merge(
                Observable
                    .of(
                        .userName(presentTweet.user.name),
                        .screenName("@" + presentTweet.user.screenName),
                        .createdAt(presentTweet.createdAt),
                        .text(presentTweet.attributedText),
                        .favorited(presentTweet.favorited.value ?? false),
                        .retweeted(presentTweet.retweeted.value ?? false),
                        .media(presentTweet.entities.media.map { TweetContentImageCellReactor(client: client, media: $0) })
                    ),
                Observable
                    .from(optional: presentTweet.user.profileImageURL)
                    .flatMap { self.client.request(request: GetProfileImageRequest(url: $0, quality: .bigger)) }
                    .map { UIImage?.some($0) }
                    .startWith(nil)
                    .map { State.profileImage($0) }
                    .observeOn(MainScheduler.instance),
                Observable
                    .from(optional: presentTweet.quotedStatus)
                    .flatMap { (tweet) in
                        Observable<State>
                            .of(
                                .quote(.userName(tweet.user.name)),
                                .quote(.screenName("@" + tweet.user.screenName)),
                                .quote(.text(tweet.attributedText))
                        )
                    },
                Observable
                    .just(tweet)
                    .filter { $0.retweetedStatus != nil }
                    .flatMap { (tweet) in
                        Observable<State>
                            .merge(
                                Observable
                                    .of(
                                        .retweetBy(.userName(tweet.user.name)),
                                        .retweetBy(.screenName("retweeted by @" + tweet.user.screenName))
                                    ),
                                Observable
                                    .from(optional: tweet.user.profileImageURL)
                                    .flatMap { self.client.request(request: GetProfileImageRequest(url: $0, quality: .mini)) }
                                    .map { UIImage?.some($0) }
                                    .startWith(nil)
                                    .map { State.retweetBy(.profileImage($0)) }
                                    .observeOn(MainScheduler.instance)
                            )
                    }
            )
        
        return .init(state: state, result: action)
    }
}

public class TweetContentImageCellReactor: Reactor {
    public enum Action {
        case tap
        case longPress
    }
    public typealias State = UIImage?
    public typealias Result = Entities.Action
    
    
    let client: TwitterClient
    let media: Entities.Media
    
    public init(client: TwitterClient, media: Entities.Media) {
        self.client = client
        self.media = media
    }
    
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        return .init(
            state: client.request(request: GetEntitiesImageRequest(url: self.media.mediaURL))
                .map { UIImage?.some($0) }
                .startWith(nil)
                .observeOn(MainScheduler.instance),
            result: action
                .map { (action) in
                    switch action {
                    case .tap: return Entities.Action.tap(.media(self.media))
                    case .longPress: return Entities.Action.longpress(.media(self.media))
                    }
                }
        )
    }
}
