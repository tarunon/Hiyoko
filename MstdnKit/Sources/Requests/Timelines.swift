//
//  Timelines.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit

extension Requests {
    public struct TimelinePagination<Request: RequestBase>: PaginationRequest where Request.Response == [Status] {
        public typealias Base = Request
        public typealias Response = PaginatedResponse<Base.Response, Base.Error>
        public var base: Request
        public var queryParameters: [String : Any]?
        
        public init(base: Base, maxId: Int?=nil) {
            self.base = base
            var queryParameters = base.queryParameters ?? [:]
            queryParameters["max_id"] = maxId
            self.queryParameters = queryParameters
        }
        
        public func next(object: Any, response: [Status], urlResponse: HTTPURLResponse) throws -> Requests.TimelinePagination<Request>? {
            if response.isEmpty {
                return nil
            }
            return TimelinePagination<Request>(base: base, maxId: response.last?.id)
        }
    }
    
    public struct HomeTimeline: RequestBase {
        public typealias Response = [Status]
        public typealias Error = MstdnError
        public var method: HTTPMethod = .get
        public var path: String = "/api/v1/timelines/home"
        
        public var queryParameters: [String : Any]? = [
            "limit": 40
        ]
    }
}
