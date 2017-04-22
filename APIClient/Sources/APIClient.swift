//
//  APIClient.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


open class APIClient {
    struct _RequestProxy<Base: Request>: RequestProxy {
        let base: Base
        let clientURL: URL
        
        var baseURL: URL {
            return clientURL
        }
    }
    
    let baseURL: URL
    let session: URLSession
    public init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    open func request<R: Request>(request: @autoclosure @escaping () throws -> R) -> Observable<R.Response> {
        return Observable<() throws -> R>.just(request)
            .map { try $0() }
            .map { _RequestProxy(base: $0, clientURL: self.baseURL) }
            .flatMap { (request) in
                return try self.session.rx.response(request: request.buildURLRequest())
                    .map { (response, data) in
                        try request.parse(data: data, urlResponse: response)
                    }
            }
    }
}
