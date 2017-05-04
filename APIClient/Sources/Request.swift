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
    associatedtype Error: Swift.Error
    var errorParser: DataParser { get }
    func error(from object: Any, urlResponse: HTTPURLResponse) throws -> Error
}

public enum ResponseError: Error {
    case parseSuccess(Error)
    case parseFail(responseParseFailure: Error, errorParseFailure: Error, statusCode: Int, data: Data)
}

public extension Request {
    public var baseURL: URL {
        return URL(string: "http://localhost:8080/")!
    }
    
    @available(*, unavailable)
    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        fatalError()
    }
    
    public func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        do {
            return try self.response(from: dataParser.parse(data: data), urlResponse: urlResponse)
        } catch (let err) {
            let error: ResponseError
            do {
                error = .parseSuccess(try self.error(from: errorParser.parse(data: data), urlResponse: urlResponse))
            } catch (let err2) {
                error = .parseFail(responseParseFailure: err, errorParseFailure: err2, statusCode: urlResponse.statusCode, data: data)
            }
            throw error
        }
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

extension Request where Response: RangeReplaceableCollection, Response.Iterator.Element: Decodable {
    public var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try Response(decodeArray(object))
    }
}

extension Request where Error: Decodable {
    public var errorParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    public func error(from object: Any, urlResponse: HTTPURLResponse) throws -> Error {
        return try decodeValue(object)
    }
}
