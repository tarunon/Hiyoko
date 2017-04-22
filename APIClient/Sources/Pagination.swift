//
//  Pagination.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki


public indirect enum PaginatedResponse<Base> {
    case hasNext(response: Base, next: AnyRequest<PaginatedResponse>)
    case tail(response: Base)
    
    public var response: Base {
        switch self {
        case .hasNext(let response, _):
            return response
        case .tail(let response):
            return response
        }
    }
    
    public var next: AnyRequest<PaginatedResponse>? {
        switch self {
        case .hasNext(_, let next):
            return next
        case .tail:
            return nil
        }
    }
    
    public init<R: Request>(response: Base, next: R?) where R.Response == PaginatedResponse {
        if let next = next {
            self = .hasNext(response: response, next: AnyRequest(next))
        } else {
            self = .tail(response: response)
        }
    }
}

public protocol PaginationRequest: RequestProxy {
    associatedtype Response = PaginatedResponse<Base.Response>
    
    func next(object: Any, response: Base.Response, urlResponse: HTTPURLResponse) throws -> Self?
}

extension PaginationRequest where Response == PaginatedResponse<Base.Response> {
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let response = try base.response(from: object, urlResponse: urlResponse)
        let next = try self.next(object: object, response: response, urlResponse: urlResponse)
        return PaginatedResponse(response: response, next: next)
    }
}
