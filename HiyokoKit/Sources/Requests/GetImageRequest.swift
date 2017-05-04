//
//  GetImageRequest.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIClient
import APIKit
import Illuso

public struct GetProfileImageRequest: APIClient.Request {
    public typealias Response = UIImage
    public typealias Error = TwitterError
    
    public enum Quality: String {
        case normal
        case bigger
        case mini
        case original
        
        func apply(_ url: URL) -> URL {
            switch self {
            case .original:
                return url
                    .deletingLastPathComponent()
                    .appendingPathComponent(url.lastPathComponent.replacingOccurrences(of: "_normal.", with: "."))
            default:
                return url
                    .deletingLastPathComponent()
                    .appendingPathComponent(url.lastPathComponent.replacingOccurrences(of: "_normal.", with: "_\(self.rawValue)."))
            }
        }
    }
    
    public let path: String = "/"
    public let method: HTTPMethod = .get
    public let url: URL
    
    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.url = url
        return urlRequest
    }
    
    public init(url: URL, quality: Quality = .normal) {
        self.url = quality.apply(url)
    }
}
