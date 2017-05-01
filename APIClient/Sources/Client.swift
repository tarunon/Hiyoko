//
//  Client.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class Client {
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
    
    open func proxy<R: Request>(request: @autoclosure @escaping () throws -> R) rethrows -> AnyRequest<R.Response, R.Error> {
        return try AnyRequest(_RequestProxy(base: request(), clientURL: self.baseURL))
    }
    
    open func request<R: Request>(request: @autoclosure @escaping () throws -> R) -> Observable<R.Response> {
        return Observable<() throws -> R>.just(request)
            .map { try self.proxy(request: $0()) }
            .flatMap { (request) in
                return try self.session.rx.response(request: request.buildURLRequest())
                    .map { (response, data) in
                        try request.parse(data: data, urlResponse: response)
                    }
            }
    }
}
