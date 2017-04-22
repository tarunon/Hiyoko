//
//  RequestProxy.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIKit

public protocol RequestProxy: Request {
    associatedtype Base: Request
    associatedtype Response = Base.Response
    
    var base: Base { get }
}

public extension RequestProxy {
    public var baseURL: URL {
        return base.baseURL
    }
    
    public var method: APIKit.HTTPMethod {
        return base.method
    }
    
    public var path: String {
        return base.path
    }
    
    public var queryParameters: [String : Any]? {
        return base.queryParameters
    }
    
    public var bodyParameters: BodyParameters? {
        return base.bodyParameters
    }
    
    public var headerFields: [String : String] {
        return base.headerFields
    }
    
    public var dataParser: DataParser {
        return base.dataParser
    }

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return try base.intercept(urlRequest: urlRequest)
    }
    
    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        return try base.intercept(object: object, urlResponse: urlResponse)
    }
}

public extension RequestProxy where Response == Base.Response {
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Self.Response {
        return try base.response(from: object, urlResponse: urlResponse)
    }
}
