//
//  Request.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import APIKit
import Himotoki
import Base

public protocol Request: APIKit.Request {
    
}

public extension Request {
    public var baseURL: URL {
        return URL(string: "http://localhost:8080/")!
    }
}

public class ImageDataParser: DataParser {
    public enum Error: Swift.Error {
        case imageNotFound
    }
    
    public var contentType: String? {
        return "image/*"
    }
    
    public func parse(data: Data) throws -> Any {
        return try UIImage(data: data) ??? Error.imageNotFound
    }
}

extension Request where Response == UIImage {
    public var dataParser: DataParser {
        return ImageDataParser()
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return object as! UIImage
    }
}

extension Request where Response: Decodable {
    public var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}
