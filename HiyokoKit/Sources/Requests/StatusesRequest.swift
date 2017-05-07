//
//  StatusesRequest.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit

public struct HomeTimeLineRequest: APIClient.Request {
    public typealias Response = [Tweet]
    public typealias Error = TwitterError
    
    public var path: String = "statuses/home_timeline.json"
    public var method: HTTPMethod = .get
    
    public var queryParameters: [String : Any]?
    
    public init() {
        queryParameters = ["count": 200]
    }
}

public struct UserTimeLineRequest: APIClient.Request {
    public typealias Response = [Tweet]
    public typealias Error = TwitterError
    
    public var path: String = "statuses/user_timeline.json"
    public var method: HTTPMethod = .get
    
    public var queryParameters: [String : Any]?
    
    public init(id: Int64) {
        queryParameters = ["user_id": id]
    }
    
    public init(screenName: String) {
        queryParameters = ["screen_name": screenName]
    }
}

public struct SearchTimeLineRequest: APIClient.Request {
    public typealias Response = [Tweet]
    public typealias Error = TwitterError
    
    public var path: String = "search/tweets.json"
    public var method: HTTPMethod = .get
    
    public var queryParameters: [String : Any]?
    
    public init(query: String) {
        queryParameters = ["q": query]
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Tweet] {
        return try [Tweet].decode(object, rootKeyPath: "statuses")
    }
}

public struct TweetDetailRequest: APIClient.Request {
    public typealias Response = Tweet
    public typealias Error = TwitterError
    
    public var path: String = "statuses/show.json"
    public var method: HTTPMethod = .get
    
    public var queryParameters: [String : Any]?
    
    public init(id: Int64) {
        self.queryParameters = ["id": id, "include_my_retweet": true]
    }
}

public struct FavoriteRequest: APIClient.Request {
    public typealias Response = Tweet
    public typealias Error = TwitterError
    
    public var path: String = "favorites/create.json"
    public var method: HTTPMethod = .post
    
    public var queryParameters: [String : Any]?
    
    public init(id: Int64) {
        queryParameters = ["id": id]
    }
}

public struct UnfavoriteRequest: APIClient.Request {
    public typealias Response = Tweet
    public typealias Error = TwitterError
    
    public var path: String = "favorites/destroy.json"
    public var method: HTTPMethod = .post
    
    public var queryParameters: [String : Any]?
    
    public init(id: Int64) {
        queryParameters = ["id": id]
    }
}

public struct RetweetRequest: APIClient.Request {
    public typealias Response = Tweet
    public typealias Error = TwitterError
    
    public var path: String {
        return "statuses/retweet/\(id).json"
    }
    public var method: HTTPMethod = .post
    
    public var id: Int64
    
    public init(id: Int64) {
        self.id = id
    }
}

public struct DeleteTweetRequest: APIClient.Request {
    public typealias Response = Tweet
    public typealias Error = TwitterError
    
    public var path: String {
        return "statuses/destroy/\(id).json"
    }
    public var method: HTTPMethod = .post
    
    public var id: Int64
    
    public init(id: Int64) {
        self.id = id
    }
}
