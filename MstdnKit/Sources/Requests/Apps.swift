//
//  Apps.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit

public extension Requests {
    public struct Apps: RequestBase {
        public typealias Response = Client
        public typealias Error = MstdnError
        public var method: HTTPMethod = .post
        public var path: String = "/api/v1/apps"
        
        public var bodyParameters: BodyParameters?
        
        public init(_ form: Client.Form) throws {
            bodyParameters = FormURLEncodedBodyParameters(formObject: try form.encode().asObject() as! [String: Any])
        }
    }
    
    public struct Oauth: RequestBase {
        public typealias Response = Token
        public typealias Error = MstdnError
        public var method: HTTPMethod = .post
        public var path: String = "/oauth/token"
        
        public var bodyParameters: BodyParameters?
        
        public init(_ client: Client, email: String, password: String) {
            bodyParameters = FormURLEncodedBodyParameters(
                formObject: [
                    "client_id": client.clientId,
                    "client_secret": client.clientSecret,
                    "grant_type": "password",
                    "username": email,
                    "password": password,
                    "scope": "read write follow"
                ]
            )
        }
    }
}
