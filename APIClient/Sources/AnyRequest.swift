//
//  AnyRequest.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIKit

public struct AnyRequest<Response, Error: Swift.Error>: Request {
    public var baseURL: URL
    public var method: APIKit.HTTPMethod
    public var path: String
    public var queryParameters: [String : Any]?
    public var bodyParameters: BodyParameters?
    public var headerFields: [String : String]
    public var dataParser: DataParser
    public var errorParser: DataParser
    internal var interceptRequest: (_ urlRequest: URLRequest) throws -> URLRequest
    internal var interceptResponse: (_ object: Any, _ urlResponse: HTTPURLResponse) throws -> Any
    internal var response: (_ object: Any, _ urlResponse: HTTPURLResponse) throws -> Response
    internal var error: (_ object: Any, _ urlResponse: HTTPURLResponse) throws -> Error
    
    public init<R: Request>(_ request: R) where R.Response == Response, R.Error == Error {
        baseURL = request.baseURL
        method = request.method
        path = request.path
        queryParameters = request.queryParameters
        bodyParameters = request.bodyParameters
        headerFields = request.headerFields
        dataParser = request.dataParser
        errorParser = request.errorParser
        interceptRequest = request.intercept
        interceptResponse = request.intercept
        response = request.response
        error = request.error
    }
    
    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return try interceptRequest(urlRequest)
    }
    
    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        return try interceptResponse(object, urlResponse)
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try response(object, urlResponse)
    }
    
    public func error(from object: Any, urlResponse: HTTPURLResponse) throws -> Error {
        return try error(object, urlResponse)
    }
}
