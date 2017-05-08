//
//  Paginations.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit

public struct SinceMaxPaginationRequest<Request: APIClient.Request>: PaginationRequest where Request.Response: RangeReplaceableCollection & RandomAccessCollection, Request.Response.Iterator.Element: HasID {
    public typealias Base = Request
    public var base: Request
    
    var maxID: Int64?
    public var queryParameters: [String : Any]? {
        var queryParameters = base.queryParameters ?? [:]
        if let maxID = maxID {
            queryParameters["max_id"] = maxID
        }
        return queryParameters
    }
    
    public init(request: Request, maxID: Int64? = nil) {
        self.base = request
        self.maxID = maxID
    }
    
    public func next(object: Any, response: Request.Response, urlResponse: HTTPURLResponse) throws -> SinceMaxPaginationRequest<Request>? {
        if response.isEmpty {
            return nil
        }
        return SinceMaxPaginationRequest(request: base, maxID: response.last?.id)
    }
}

