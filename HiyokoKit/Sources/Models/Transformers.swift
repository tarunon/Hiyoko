//
//  Transformers.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/29.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import Illuso
import Base

extension Range {
    struct Transformers {
        static var array: Transformer<[Bound], Range> { return .init{ $0[0]..<$0[1] } }
    }
}

extension Range: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [lowerBound, upperBound]
        )
    }
}

extension URL: Decodable, Encodable {
    enum Error: Swift.Error {
        case failDecoding
    }
    
    public static func decode(_ e: Extractor) throws -> URL {
        guard let string = e.rawValue as? String else {
            throw DecodeError.typeMismatch(expected: "\(URL.self)", actual: "\(type(of: e.rawValue))", keyPath: .empty)
        }
        return try URL(string: string) ??? DecodeError.custom("\(string) is not URL")
    }
    
    public func encode() throws -> JSON {
        return try encode(absoluteString)
    }
}

extension Date {
    enum Error: Swift.Error {
        case failDecoding
    }
    struct Transformers {
        private static let utcDateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE LLL dd HH:mm:ss Z yyyy"
            dateFormatter.locale = Locale(identifier: "en")
            return dateFormatter
        }()
        static let utcString = Transformer<String, Date> { try Transformers.utcDateFormatter.date(from: $0) ??? Error.failDecoding }
    }
}
