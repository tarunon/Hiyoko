//
//  ShowUserRequest.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit
import Illuso

public struct ShowUserRequest: APIClient.Request {
    public typealias Response = User
    public typealias Error = TwitterError
    
    public let path: String = "users/show.json"
    public let method: HTTPMethod = .get
    public let queryParameters: [String : Any]?
    
    public init(_ id: Int64) {
        queryParameters = ["user_id": id, "include_entities": true]
    }
    
    public init(_ screenName: String) {
        queryParameters = ["screen_name": screenName, "include_entities": true]
    }
}
