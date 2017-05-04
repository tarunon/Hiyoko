//
//  Client.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/30.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit
import OAuthSwift

public class TwitterClient: Client {
    struct AuthorizedRequestProxy<R: APIClient.Request>: RequestProxy {
        typealias Base = R
        
        var base: R
        var headerFields: [String : String]
        
        init(_ request: R, credential: OAuthSwiftCredential) {
            self.base = request
            self.headerFields = request.headerFields
            let body: Data?
            switch try? request.bodyParameters?.buildEntity() {
            case .some(.some(.data(let data))):
                body = data
            default:
                body = nil
            }
            headerFields["Authorization"] = credential.authorizationHeader(method: OAuthSwiftHTTPRequest.Method(rawValue: request.method.rawValue)!, url: request.baseURL.appendingPathComponent(request.path), parameters: request.queryParameters ?? [:], body: body)
        }
    }
    
    let credential: OAuthSwiftCredential
    
    public init(credential: OAuthSwiftCredential, session: URLSession = .shared) {
        self.credential = credential
        super.init(
            baseURL: URL(string: "https://api.twitter.com/1.1/")!,
            session: session
        )
    }
    
    public override func proxy<R: APIClient.Request>(request: @autoclosure @escaping () throws -> R) rethrows -> AnyRequest<R.Response, R.Error> {
        return try AnyRequest(AuthorizedRequestProxy(super.proxy(request: request()), credential: credential))
    }
}

